import 'package:calibrefit/features/sync/domain/sync_models.dart';

/// Abstract contract for offline mutation queue management, local cache persistence,
/// remote API syncing, and conflict audit logging.
abstract class SyncRepository {
  /// Retrieves all pending offline mutations awaiting synchronization.
  Future<List<OfflineMutation>> getPendingMutations();

  /// Enqueues a new offline mutation.
  Future<void> enqueueMutation(OfflineMutation mutation);

  /// Removes a successfully synchronized or discarded mutation by [mutationId].
  Future<void> removeMutation(String mutationId);

  /// Clears all pending mutations from the queue.
  Future<void> clearQueue();

  /// Retrieves the history of conflict resolution logs.
  Future<List<ConflictResolutionLog>> getConflictLogs();

  /// Appends a new conflict resolution audit entry.
  Future<void> logConflict(ConflictResolutionLog log);

  /// Clears the conflict resolution audit history.
  Future<void> clearConflictLogs();

  /// Retrieves the timestamp of the last successful synchronization.
  Future<DateTime?> getLastSyncTime();

  /// Updates the timestamp of the last successful synchronization.
  Future<void> setLastSyncTime(DateTime time);

  /// Pushes a batch of offline mutations to the remote API.
  Future<void> pushMutations(List<OfflineMutation> mutations);

  /// Pulls remote delta updates modified on the server since [since].
  Future<List<Map<String, dynamic>>> pullRemoteChanges(DateTime? since);

  /// Saves or updates a record in the local cache under [collection].
  Future<void> saveLocalRecord(
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  /// Retrieves a record from the local cache by [id] within [collection].
  Future<Map<String, dynamic>?> getLocalRecord(String collection, String id);

  /// Retrieves all records in the specified [collection] from the local cache.
  Future<List<Map<String, dynamic>>> getAllLocalRecords(String collection);

  /// Clears all cached records in the local store.
  Future<void> clearLocalCache();
}
