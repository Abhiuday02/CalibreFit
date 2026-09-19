import 'package:calibrefit/features/set_logging/data/local_set_log_repository.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalSetLogRepository repository;

  setUp(() {
    repository = LocalSetLogRepository();
  });

  group('SetLog domain model', () {
    test('stores both planned and actual performance without overwriting', () {
      final log = SetLog(
        id: 'log-1',
        sessionId: 'session-100',
        exerciseId: 'ex-bench-press',
        exerciseName: 'Barbell Bench Press',
        setNumber: 1,
        plannedWeight: 42.5,
        plannedReps: 8,
        actualWeight: 40.0,
        actualReps: 10,
        rir: 2,
        rpe: 8.0,
        restSeconds: 90,
        formScore: 95.0,
        notes: 'Felt explosive on concentric phase',
        timestamp: DateTime(2026, 9, 19, 10, 0),
      );

      // Verify planned values are preserved
      expect(log.plannedWeight, 42.5);
      expect(log.plannedReps, 8);
      expect(log.plannedVolume, 42.5 * 8);

      // Verify actual values are distinct
      expect(log.actualWeight, 40.0);
      expect(log.actualReps, 10);
      expect(log.volume, 40.0 * 10); // 400.0 kg

      // Verify differences
      expect(log.weightDiff, -2.5);
      expect(log.repsDiff, 2);

      // Verify metrics
      expect(log.rir, 2);
      expect(log.rpe, 8.0);
      expect(log.notes, 'Felt explosive on concentric phase');
    });

    test('toJson and fromJson serialize accurately', () {
      final original = SetLog(
        id: 'log-2',
        sessionId: 'session-100',
        exerciseId: 'ex-bench-press',
        exerciseName: 'Barbell Bench Press',
        setNumber: 2,
        plannedWeight: 42.5,
        plannedReps: 8,
        actualWeight: 40.0,
        actualReps: 9,
        rir: 1,
        rpe: 8.5,
        restSeconds: 90,
        formScore: 92.0,
        notes: 'Good bar path',
        timestamp: DateTime(2026, 9, 19, 10, 5),
      );

      final json = original.toJson();
      final restored = SetLog.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.sessionId, original.sessionId);
      expect(restored.exerciseId, original.exerciseId);
      expect(restored.plannedWeight, original.plannedWeight);
      expect(restored.plannedReps, original.plannedReps);
      expect(restored.actualWeight, original.actualWeight);
      expect(restored.actualReps, original.actualReps);
      expect(restored.rir, original.rir);
      expect(restored.rpe, original.rpe);
      expect(restored.notes, original.notes);
      expect(restored.volume, original.volume);
    });
  });

  group('LocalSetLogRepository offline persistence', () {
    test('saves and retrieves set logs for a session', () async {
      final log1 = SetLog(
        id: 'set-1',
        sessionId: 'session-1',
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        setNumber: 1,
        plannedWeight: 42.5,
        plannedReps: 8,
        actualWeight: 40.0,
        actualReps: 10,
        timestamp: DateTime.now(),
      );

      final log2 = SetLog(
        id: 'set-2',
        sessionId: 'session-1',
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        setNumber: 2,
        plannedWeight: 42.5,
        plannedReps: 8,
        actualWeight: 40.0,
        actualReps: 9,
        timestamp: DateTime.now(),
      );

      await repository.saveSetLog(log1);
      await repository.saveSetLog(log2);

      final sessionLogs = await repository.getSetLogsForSession('session-1');
      expect(sessionLogs.length, 2);
      expect(sessionLogs[0].setNumber, 1);
      expect(sessionLogs[1].setNumber, 2);
    });

    test('getSetLogsForExercise filters correctly', () async {
      final logBench = SetLog(
        id: 'set-b1',
        sessionId: 'session-1',
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        setNumber: 1,
        plannedWeight: 42.5,
        plannedReps: 8,
        actualWeight: 40.0,
        actualReps: 10,
        timestamp: DateTime.now(),
      );

      final logSquat = SetLog(
        id: 'set-s1',
        sessionId: 'session-1',
        exerciseId: 'ex-squat',
        exerciseName: 'Barbell Squat',
        setNumber: 1,
        plannedWeight: 60.0,
        plannedReps: 6,
        actualWeight: 60.0,
        actualReps: 6,
        timestamp: DateTime.now(),
      );

      await repository.saveSetLogs([logBench, logSquat]);

      final benchLogs = await repository.getSetLogsForExercise('ex-bench');
      expect(benchLogs.length, 1);
      expect(benchLogs.first.exerciseId, 'ex-bench');

      final squatLogs = await repository.getSetLogsForExercise('ex-squat');
      expect(squatLogs.length, 1);
      expect(squatLogs.first.exerciseId, 'ex-squat');
    });

    test('deleteSetLog removes log from storage', () async {
      final log = SetLog(
        id: 'to-delete',
        sessionId: 'session-1',
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        setNumber: 1,
        plannedWeight: 42.5,
        plannedReps: 8,
        actualWeight: 40.0,
        actualReps: 10,
        timestamp: DateTime.now(),
      );

      await repository.saveSetLog(log);
      var all = await repository.getAllSetLogs();
      expect(all.length, 1);

      await repository.deleteSetLog('to-delete');
      all = await repository.getAllSetLogs();
      expect(all, isEmpty);
    });
  });
}
