import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:calibrefit/features/sync/domain/sync_repository.dart';
import 'package:flutter/foundation.dart';

/// Orchestrates synchronization between the local offline cache and remote backend.
class SyncEngine extends ChangeNotifier {
  SyncEngine({required this._repository}) {
    _init();
  }

  final SyncRepository _repository;
  SyncState _state = const SyncState();

  SyncState get state => _state;

  Future<void> _init() async {
    final lastSync = await _repository.getLastSyncTime();
    final pending = await _repository.getPendingMutations();
    _state = _state.copyWith(
      lastSyncTime: lastSync,
      pendingCount: pending.length,
      status: SyncStatus.idle,
    );
    notifyListeners();
  }

  /// Toggles simulated network connectivity.
  /// If transitioning from offline to online, automatically triggers sync.
  void setOnline(bool isOnline) {
    if (_state.isOnline == isOnline) return;

    _state = _state.copyWith(
      isOnline: isOnline,
      status: isOnline ? SyncStatus.idle : SyncStatus.offline,
    );
    notifyListeners();

    if (isOnline) {
      syncNow();
    }
  }

  /// Executes full push-pull synchronization sequence.
  Future<void> syncNow() async {
    if (!_state.isOnline) {
      _state = _state.copyWith(status: SyncStatus.offline);
      notifyListeners();
      return;
    }

    _state = _state.copyWith(status: SyncStatus.syncing, lastError: null);
    notifyListeners();

    try {
      // 1. Push pending offline mutations
      final pending = await _repository.getPendingMutations();
      if (pending.isNotEmpty) {
        await _repository.pushMutations(pending);
      }

      // 2. Pull remote delta updates
      final now = DateTime.now();
      await _repository.pullRemoteChanges(_state.lastSyncTime);
      await _repository.setLastSyncTime(now);

      // 3. Re-evaluate remaining pending count
      final remaining = await _repository.getPendingMutations();

      _state = _state.copyWith(
        status: SyncStatus.idle,
        lastSyncTime: now,
        pendingCount: remaining.length,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: SyncStatus.error,
        lastError: e.toString(),
      );
    } finally {
      notifyListeners();
    }
  }

  /// Enqueues a new offline mutation.
  Future<void> enqueueMutation({
    required EntityType entityType,
    required MutationAction action,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    final mutation = OfflineMutation(
      id: 'mut-${DateTime.now().millisecondsSinceEpoch}',
      entityType: entityType,
      action: action,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _repository.enqueueMutation(mutation);
    final pending = await _repository.getPendingMutations();
    _state = _state.copyWith(pendingCount: pending.length);
    notifyListeners();

    // If online, immediately sync the new mutation
    if (_state.isOnline) {
      syncNow();
    }
  }

  /// Removes an un-synced mutation from the queue.
  Future<void> discardMutation(String mutationId) async {
    await _repository.removeMutation(mutationId);
    final pending = await _repository.getPendingMutations();
    _state = _state.copyWith(pendingCount: pending.length);
    notifyListeners();
  }

  /// Clears the entire offline mutation queue.
  Future<void> clearQueue() async {
    await _repository.clearQueue();
    _state = _state.copyWith(pendingCount: 0);
    notifyListeners();
  }

  /// Clears all recorded conflict resolution logs.
  Future<void> clearConflictLogs() async {
    await _repository.clearConflictLogs();
    notifyListeners();
  }
}
