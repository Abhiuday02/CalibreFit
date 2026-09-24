import 'package:calibrefit/features/sync/data/mock_sync_repository.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:calibrefit/features/sync/domain/sync_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return MockSyncRepository();
});

// ---------------------------------------------------------------------------
// Sync Engine Notifier & Provider
// ---------------------------------------------------------------------------

class SyncEngineNotifier extends Notifier<SyncState> {
  SyncRepository get _repo => ref.read(syncRepositoryProvider);

  @override
  SyncState build() {
    // Trigger initial state population
    Future.microtask(init);
    return const SyncState();
  }

  Future<void> init() async {
    final lastSync = await _repo.getLastSyncTime();
    final pending = await _repo.getPendingMutations();
    if (!ref.mounted) return;
    state = state.copyWith(
      lastSyncTime: lastSync,
      pendingCount: pending.length,
      status: state.isOnline ? SyncStatus.idle : SyncStatus.offline,
    );
  }

  /// Toggles simulated network connectivity.
  Future<void> setOnline(bool isOnline) async {
    if (state.isOnline == isOnline) return;

    state = state.copyWith(
      isOnline: isOnline,
      status: isOnline ? SyncStatus.idle : SyncStatus.offline,
    );

    if (isOnline) {
      await syncNow();
    }
  }

  /// Executes full push-pull synchronization sequence.
  Future<void> syncNow() async {
    if (!state.isOnline) {
      state = state.copyWith(status: SyncStatus.offline);
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing, lastError: null);

    try {
      // 1. Push pending offline mutations
      final pending = await _repo.getPendingMutations();
      if (pending.isNotEmpty) {
        await _repo.pushMutations(pending);
      }

      // 2. Pull remote delta updates
      final now = DateTime.now();
      await _repo.pullRemoteChanges(state.lastSyncTime);
      await _repo.setLastSyncTime(now);

      // 3. Re-evaluate remaining pending count
      final remaining = await _repo.getPendingMutations();

      if (!ref.mounted) return;
      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncTime: now,
        pendingCount: remaining.length,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(status: SyncStatus.error, lastError: e.toString());
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

    await _repo.enqueueMutation(mutation);
    final pending = await _repo.getPendingMutations();
    if (!ref.mounted) return;
    state = state.copyWith(pendingCount: pending.length);

    if (state.isOnline) {
      await syncNow();
    }
  }

  /// Discards a mutation by [mutationId].
  Future<void> discardMutation(String mutationId) async {
    await _repo.removeMutation(mutationId);
    final pending = await _repo.getPendingMutations();
    if (!ref.mounted) return;
    state = state.copyWith(pendingCount: pending.length);
  }

  /// Clears the entire offline mutation queue.
  Future<void> clearQueue() async {
    await _repo.clearQueue();
    if (!ref.mounted) return;
    state = state.copyWith(pendingCount: 0);
  }

  /// Clears all recorded conflict resolution logs.
  Future<void> clearConflictLogs() async {
    await _repo.clearConflictLogs();
    if (!ref.mounted) return;
    ref.invalidate(conflictLogsProvider);
  }
}

final syncEngineProvider = NotifierProvider<SyncEngineNotifier, SyncState>(
  SyncEngineNotifier.new,
);

// ---------------------------------------------------------------------------
// Query Providers
// ---------------------------------------------------------------------------

final pendingMutationsProvider = FutureProvider<List<OfflineMutation>>((
  ref,
) async {
  // Re-read whenever sync state updates
  ref.watch(syncEngineProvider);
  final repo = ref.watch(syncRepositoryProvider);
  return repo.getPendingMutations();
});

final conflictLogsProvider = FutureProvider<List<ConflictResolutionLog>>((
  ref,
) async {
  // Re-read whenever sync state updates
  ref.watch(syncEngineProvider);
  final repo = ref.watch(syncRepositoryProvider);
  return repo.getConflictLogs();
});
