import 'package:calibrefit/features/sync/data/local_cache_store.dart';
import 'package:calibrefit/features/sync/domain/conflict_resolver.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:calibrefit/features/sync/domain/sync_repository.dart';

/// In-memory implementation of [SyncRepository] with a simulated remote backend,
/// queue persistence, and Last-Write-Wins conflict resolution.
class MockSyncRepository implements SyncRepository {
  MockSyncRepository({LocalCacheStore? cacheStore})
    : _cache = cacheStore ?? LocalCacheStore() {
    _initSeedQueue();
  }

  final LocalCacheStore _cache;
  final List<OfflineMutation> _queue = [];
  final List<ConflictResolutionLog> _conflictLogs = [];
  final Map<String, Map<String, dynamic>> _remoteDb = {};
  DateTime? _lastSyncTime;
  static const _delay = Duration(milliseconds: 120);

  @override
  Future<List<OfflineMutation>> getPendingMutations() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_queue);
  }

  @override
  Future<void> enqueueMutation(OfflineMutation mutation) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _queue.add(mutation);
  }

  @override
  Future<void> removeMutation(String mutationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _queue.removeWhere((m) => m.id == mutationId);
  }

  @override
  Future<void> clearQueue() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _queue.clear();
  }

  @override
  Future<List<ConflictResolutionLog>> getConflictLogs() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_conflictLogs);
  }

  @override
  Future<void> logConflict(ConflictResolutionLog log) async {
    _conflictLogs.insert(0, log);
  }

  @override
  Future<void> clearConflictLogs() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _conflictLogs.clear();
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return _lastSyncTime;
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    _lastSyncTime = time;
  }

  @override
  Future<void> pushMutations(List<OfflineMutation> mutations) async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (final mutation in mutations) {
      final key = '${mutation.entityType.name}:${mutation.entityId}';
      final remoteRecord = _remoteDb[key];

      if (remoteRecord != null) {
        // Potential conflict! Check timestamps
        final remoteUpdatedAt =
            DateTime.tryParse(remoteRecord['updatedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final localUpdatedAt = mutation.createdAt;

        final resolution = ConflictResolver.resolveLWW<Map<String, dynamic>>(
          entityId: mutation.entityId,
          entityType: mutation.entityType,
          localData: mutation.payload,
          localTimestamp: localUpdatedAt,
          remoteData: remoteRecord,
          remoteTimestamp: remoteUpdatedAt,
        );

        _conflictLogs.insert(0, resolution.log);

        if (resolution.log.winner == 'local') {
          // Local wins -> Overwrite remote
          _remoteDb[key] = Map<String, dynamic>.from(mutation.payload)
            ..['updatedAt'] = localUpdatedAt.toIso8601String();
        } else {
          // Remote wins -> Update local cache
          await _cache.put(
            mutation.entityType.name,
            mutation.entityId,
            remoteRecord,
          );
        }
      } else {
        // No remote conflict -> create or update remote
        if (mutation.action == MutationAction.delete) {
          _remoteDb.remove(key);
        } else {
          _remoteDb[key] = Map<String, dynamic>.from(mutation.payload)
            ..['updatedAt'] = mutation.createdAt.toIso8601String();
        }
      }

      // Remove from queue
      _queue.removeWhere((m) => m.id == mutation.id);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pullRemoteChanges(DateTime? since) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (since == null) return _remoteDb.values.toList();

    return _remoteDb.values.where((r) {
      final updatedAt = DateTime.tryParse(r['updatedAt'] as String? ?? '');
      return updatedAt != null && updatedAt.isAfter(since);
    }).toList();
  }

  @override
  Future<void> saveLocalRecord(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _cache.put(collection, id, data);
  }

  @override
  Future<Map<String, dynamic>?> getLocalRecord(
    String collection,
    String id,
  ) async {
    return _cache.get(collection, id);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllLocalRecords(
    String collection,
  ) async {
    return _cache.getAll(collection);
  }

  @override
  Future<void> clearLocalCache() async {
    await _cache.clearAll();
  }

  void _initSeedQueue() {
    final now = DateTime.now();
    _lastSyncTime = now.subtract(const Duration(minutes: 45));

    // Seed 1 pending offline mutation to demonstrate the queue
    _queue.add(
      OfflineMutation(
        id: 'seed-mut-1',
        entityType: EntityType.workout,
        action: MutationAction.create,
        entityId: 'workout-offline-101',
        payload: {
          'id': 'workout-offline-101',
          'name': 'Late Night Shoulders & Abs',
          'completedAt': now
              .subtract(const Duration(minutes: 20))
              .toIso8601String(),
          'totalVolume': 4250.0,
          'exercisesCount': 4,
          'updatedAt': now
              .subtract(const Duration(minutes: 20))
              .toIso8601String(),
        },
        createdAt: now.subtract(const Duration(minutes: 20)),
        retryCount: 0,
      ),
    );

    // Seed a remote conflicting record to test conflict resolution
    _remoteDb['workout:workout-conflict-demo'] = {
      'id': 'workout-conflict-demo',
      'name': 'Morning Push (Cloud Version)',
      'updatedAt': now.subtract(const Duration(minutes: 10)).toIso8601String(),
      'totalVolume': 6500.0,
    };
  }
}
