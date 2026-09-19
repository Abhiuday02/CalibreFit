import 'package:calibrefit/features/history/data/mock_history_repository.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockHistoryRepository repository;

  setUp(() {
    repository = MockHistoryRepository();
  });

  group('MockHistoryRepository.getWorkoutHistory', () {
    test('returns historical workouts sorted by date descending', () async {
      final history = await repository.getWorkoutHistory();

      expect(history.length, greaterThanOrEqualTo(3));
      for (int i = 0; i < history.length - 1; i++) {
        expect(
          history[i].date.isAfter(history[i + 1].date) ||
              history[i].date.isAtSameMomentAs(history[i + 1].date),
          isTrue,
        );
      }

      final first = history.first;
      expect(first.workoutTitle, isNotEmpty);
      expect(first.durationSeconds, greaterThan(0));
      expect(first.totalVolumeKg, greaterThan(0));
      expect(first.totalReps, greaterThan(0));
      expect(first.totalSets, greaterThan(0));
      expect(first.exerciseSummaries, isNotEmpty);
    });
  });

  group('MockHistoryRepository.getWorkoutHistoryById', () {
    test('returns workout record when ID matches', () async {
      final record = await repository.getWorkoutHistoryById('hist-01');

      expect(record, isNotNull);
      expect(record!.id, 'hist-01');
      expect(record.workoutTitle, contains('Chest + Triceps'));
      expect(record.exerciseSummaries.length, 2);
    });

    test('returns null when ID does not exist', () async {
      final record = await repository.getWorkoutHistoryById('non-existent');

      expect(record, isNull);
    });
  });

  group('MockHistoryRepository.getExerciseProgress', () {
    test(
      'returns progression points with weight, reps, volume, and 1RM',
      () async {
        final points = await repository.getExerciseProgress('ex-bench-press');

        expect(points.length, 4);
        for (final p in points) {
          expect(p.weightKg, greaterThan(0));
          expect(p.reps, greaterThan(0));
          expect(p.volumeKg, greaterThan(0));
          expect(p.estimated1RmKg, greaterThan(0));
        }

        // Verify progression: weight increases over time
        expect(points.first.weightKg, lessThan(points.last.weightKg));
      },
    );
  });

  group('MockHistoryRepository.recordCompletedWorkout', () {
    test('inserts completed workout at top of history list', () async {
      final newRecord = WorkoutHistoryRecord(
        id: 'new-workout-1',
        workoutTitle: 'Full Body Blast',
        targetMuscles: 'Full Body',
        date: DateTime.now(),
        durationSeconds: 3000,
        totalVolumeKg: 5000.0,
        totalReps: 100,
        totalSets: 15,
        exerciseSummaries: const [],
      );

      await repository.recordCompletedWorkout(newRecord);

      final history = await repository.getWorkoutHistory();
      expect(history.first.id, 'new-workout-1');
      expect(history.first.workoutTitle, 'Full Body Blast');
    });
  });
}
