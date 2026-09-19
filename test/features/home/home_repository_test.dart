import 'package:calibrefit/features/home/data/mock_home_repository.dart';
import 'package:calibrefit/features/home/domain/daily_workout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockHomeRepository repository;

  setUp(() {
    repository = const MockHomeRepository();
  });

  group('MockHomeRepository.getTodaysWorkout', () {
    test("returns today's workout with exercises and duration", () async {
      final workout = await repository.getTodaysWorkout();

      expect(workout.title, "Today's Workout");
      expect(workout.targetMuscles, 'Chest + Triceps');
      expect(workout.estimatedDurationMinutes, 45);
      expect(workout.exercises.length, 3);

      final bench = workout.exercises[0];
      expect(bench.name, 'Bench Press');
      expect(bench.sets, 4);
      expect(bench.repRange, '6–8');
      expect(bench.suggestedLoadKg, 42.5);

      final incline = workout.exercises[1];
      expect(incline.name, 'Incline DB Press');
      expect(incline.sets, 3);
      expect(incline.repRange, '8–10');
      expect(incline.suggestedLoadKg, 17.5);

      final fly = workout.exercises[2];
      expect(fly.name, 'Cable Fly');
      expect(fly.sets, 3);
      expect(fly.repRange, '10–12');
      expect(fly.suggestedLoadKg, 15.0);

      expect(workout.totalSets, 10);
    });
  });

  group('MockHomeRepository.getQuickProgressSummary', () {
    test('returns weekly workouts, streak, and volume', () async {
      final summary = await repository.getQuickProgressSummary();

      expect(summary.completedWorkoutsThisWeek, 3);
      expect(summary.targetWorkoutsPerWeek, 4);
      expect(summary.currentStreakDays, 5);
      expect(summary.weeklyVolumeKg, 14250.0);
      expect(summary.weeklyCompletionRate, 0.75);
    });
  });

  group('QuickProgressSummary domain calculations', () {
    test('calculates weekly completion rate correctly', () {
      const summary = QuickProgressSummary(
        completedWorkoutsThisWeek: 4,
        targetWorkoutsPerWeek: 4,
        currentStreakDays: 7,
        weeklyVolumeKg: 20000,
      );

      expect(summary.weeklyCompletionRate, 1.0);
    });

    test('clamps weekly completion rate at 1.0 even if exceeded', () {
      const summary = QuickProgressSummary(
        completedWorkoutsThisWeek: 6,
        targetWorkoutsPerWeek: 4,
        currentStreakDays: 10,
        weeklyVolumeKg: 30000,
      );

      expect(summary.weeklyCompletionRate, 1.0);
    });

    test('returns 0.0 when targetWorkoutsPerWeek is 0', () {
      const summary = QuickProgressSummary(
        completedWorkoutsThisWeek: 0,
        targetWorkoutsPerWeek: 0,
        currentStreakDays: 0,
        weeklyVolumeKg: 0,
      );

      expect(summary.weeklyCompletionRate, 0.0);
    });
  });
}
