import 'package:calibrefit/features/sync/domain/conflict_resolver.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConflictResolver', () {
    final now = DateTime.now();

    test('resolveLWW preserves local version when local is strictly newer', () {
      final localTime = now;
      final remoteTime = now.subtract(const Duration(minutes: 5));

      final localData = {'name': 'Local Workout', 'reps': 12};
      final remoteData = {'name': 'Remote Workout', 'reps': 10};

      final result = ConflictResolver.resolveLWW<Map<String, dynamic>>(
        entityId: 'workout-1',
        entityType: EntityType.workout,
        localData: localData,
        localTimestamp: localTime,
        remoteData: remoteData,
        remoteTimestamp: remoteTime,
      );

      expect(result.winner, 'local');
      expect(result.resolvedData['name'], 'Local Workout');
      expect(result.resolvedData['reps'], 12);
      expect(result.log.winner, 'local');
      expect(result.log.entityId, 'workout-1');
      expect(result.log.entityType, EntityType.workout);
      expect(result.log.strategy, contains('Local Preserved'));
    });

    test('resolveLWW applies remote version when remote is strictly newer', () {
      final localTime = now.subtract(const Duration(minutes: 10));
      final remoteTime = now;

      final localData = {'name': 'Local Workout', 'reps': 12};
      final remoteData = {'name': 'Remote Workout', 'reps': 15};

      final result = ConflictResolver.resolveLWW<Map<String, dynamic>>(
        entityId: 'workout-2',
        entityType: EntityType.workout,
        localData: localData,
        localTimestamp: localTime,
        remoteData: remoteData,
        remoteTimestamp: remoteTime,
      );

      expect(result.winner, 'remote');
      expect(result.resolvedData['name'], 'Remote Workout');
      expect(result.resolvedData['reps'], 15);
      expect(result.log.winner, 'remote');
      expect(result.log.strategy, contains('Remote Applied'));
    });

    test('resolveLWW defaults to remote on identical timestamps for deterministic convergence', () {
      final sameTime = now;

      final localData = {'name': 'Local Version'};
      final remoteData = {'name': 'Remote Version'};

      final result = ConflictResolver.resolveLWW<Map<String, dynamic>>(
        entityId: 'workout-3',
        entityType: EntityType.workout,
        localData: localData,
        localTimestamp: sameTime,
        remoteData: remoteData,
        remoteTimestamp: sameTime,
      );

      expect(result.winner, 'remote');
      expect(result.resolvedData['name'], 'Remote Version');
    });
  });
}
