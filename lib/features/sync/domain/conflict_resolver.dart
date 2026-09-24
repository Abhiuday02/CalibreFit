import 'package:calibrefit/features/sync/domain/sync_models.dart';

/// Result of a conflict resolution operation.
class ConflictResolutionResult<T> {
  const ConflictResolutionResult({
    required this.resolvedData,
    required this.log,
  });

  final T resolvedData;
  final ConflictResolutionLog log;

  String get winner => log.winner;
}

/// Deterministic conflict resolver implementing the **Last-Write-Wins (LWW)** strategy.
class ConflictResolver {
  const ConflictResolver();

  /// Resolves conflicts between a local entity and a remote entity based on their timestamps.
  ///
  /// - If [localTimestamp] is strictly newer than [remoteTimestamp], the local version is retained.
  /// - If [remoteTimestamp] is newer (or equal), the remote version takes precedence.
  static ConflictResolutionResult<T> resolveLWW<T>({
    required String entityId,
    required EntityType entityType,
    required T localData,
    required DateTime localTimestamp,
    required T remoteData,
    required DateTime remoteTimestamp,
  }) {
    final bool localWins = localTimestamp.isAfter(remoteTimestamp);
    final winner = localWins ? 'local' : 'remote';
    final resolvedData = localWins ? localData : remoteData;
    final strategy = localWins
        ? 'Last-Write-Wins (Local Preserved: +${localTimestamp.difference(remoteTimestamp).inSeconds}s)'
        : 'Last-Write-Wins (Remote Applied: +${remoteTimestamp.difference(localTimestamp).inSeconds}s)';

    final log = ConflictResolutionLog(
      id: 'conflict-${DateTime.now().microsecondsSinceEpoch}',
      entityId: entityId,
      entityType: entityType,
      localTimestamp: localTimestamp,
      remoteTimestamp: remoteTimestamp,
      winner: winner,
      strategy: strategy,
      resolvedAt: DateTime.now(),
    );

    return ConflictResolutionResult(resolvedData: resolvedData, log: log);
  }
}
