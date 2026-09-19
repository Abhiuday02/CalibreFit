import 'package:calibrefit/features/home/domain/daily_workout.dart';
import 'package:calibrefit/features/workouts/domain/workout_session.dart';
import 'package:calibrefit/features/workouts/presentation/active_workout_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleWorkout = DailyWorkout(
    id: 'test-workout-1',
    title: "Today's Workout",
    targetMuscles: 'Chest + Triceps',
    estimatedDurationMinutes: 45,
    exercises: [
      DailyWorkoutExercise(
        id: 'ex-bench',
        name: 'Bench Press',
        sets: 4,
        repRange: '6–8',
        suggestedLoadKg: 42.5,
      ),
      DailyWorkoutExercise(
        id: 'ex-incline',
        name: 'Incline DB Press',
        sets: 3,
        repRange: '8–10',
        suggestedLoadKg: 17.5,
      ),
    ],
  );

  group('ActiveWorkoutNotifier workflow', () {
    test('startWorkout correctly initializes session from DailyWorkout', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(sampleWorkout);

      final session = container.read(activeWorkoutProvider);
      expect(session, isNotNull);
      expect(session!.workoutPlanTitle, "Today's Workout");
      expect(session.targetMuscles, 'Chest + Triceps');
      expect(session.status, WorkoutSessionStatus.inProgress);
      expect(session.exercises.length, 2);
      expect(session.currentExerciseIndex, 0);
      expect(session.currentExercise.name, 'Bench Press');
      expect(session.currentExercise.sets.length, 4);
      expect(session.currentExercise.sets.first.plannedWeightKg, 42.5);
      expect(session.currentExercise.sets.first.plannedRepsDisplay, '6–8');
      expect(session.currentExercise.sets.first.plannedReps, 8);
      expect(session.currentExercise.sets.first.actualWeightKg, 42.5);
      expect(session.currentExercise.sets.first.actualReps, 8);
      expect(session.currentExercise.sets.first.isCompleted, isFalse);
    });

    test('toggleSet marks set as completed and triggers rest timer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(sampleWorkout);

      // Complete first set of first exercise
      notifier.toggleSet(0, 0);

      var session = container.read(activeWorkoutProvider)!;
      expect(session.exercises[0].sets[0].isCompleted, isTrue);
      expect(session.completedSetsCount, 1);
      expect(session.isResting, isTrue);
      expect(session.restSecondsRemaining, 90);

      // Toggle again to uncomplete
      notifier.toggleSet(0, 0);
      session = container.read(activeWorkoutProvider)!;
      expect(session.exercises[0].sets[0].isCompleted, isFalse);
      expect(session.completedSetsCount, 0);
      expect(session.isResting, isFalse);
      expect(session.restSecondsRemaining, 0);
    });

    test('rest timer controls add time and skip rest', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(sampleWorkout);

      notifier.toggleSet(0, 0);
      var session = container.read(activeWorkoutProvider)!;
      expect(session.restSecondsRemaining, 90);

      // Add 30 seconds
      notifier.addRestSeconds(30);
      session = container.read(activeWorkoutProvider)!;
      expect(session.restSecondsRemaining, 120);

      // Skip rest
      notifier.skipRest();
      session = container.read(activeWorkoutProvider)!;
      expect(session.isResting, isFalse);
      expect(session.restSecondsRemaining, 0);
    });

    test('exercise navigation moves forward and backward within bounds', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(sampleWorkout);

      var session = container.read(activeWorkoutProvider)!;
      expect(session.isFirstExercise, isTrue);
      expect(session.isLastExercise, isFalse);

      // Moving backward at index 0 does nothing
      notifier.previousExercise();
      expect(container.read(activeWorkoutProvider)!.currentExerciseIndex, 0);

      // Move forward to second exercise
      notifier.nextExercise();
      session = container.read(activeWorkoutProvider)!;
      expect(session.currentExerciseIndex, 1);
      expect(session.currentExercise.name, 'Incline DB Press');
      expect(session.isLastExercise, isTrue);

      // Moving forward at last exercise does nothing
      notifier.nextExercise();
      expect(container.read(activeWorkoutProvider)!.currentExerciseIndex, 1);

      // Move back to first exercise
      notifier.previousExercise();
      expect(container.read(activeWorkoutProvider)!.currentExerciseIndex, 0);
    });

    test('finishWorkout calculates summary and resets active session', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(sampleWorkout);

      // Complete two sets of Bench Press (42.5kg * 7 reps approx)
      notifier.toggleSet(0, 0);
      notifier.toggleSet(0, 1);

      final summary = notifier.finishWorkout();

      expect(summary, isNotNull);
      expect(summary!.workoutTitle, "Today's Workout");
      expect(summary.totalSetsCompleted, 2);
      expect(summary.totalSetsPlanned, 7); // 4 + 3 sets
      expect(summary.completedExercises, ['Bench Press']);
      expect(summary.totalVolumeKg, greaterThan(0));

      // Active session is now cleared
      expect(container.read(activeWorkoutProvider), isNull);

      // Summary stored in lastWorkoutSummaryProvider
      expect(container.read(lastWorkoutSummaryProvider), equals(summary));
    });

    test('discardWorkout resets active session without saving summary', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(activeWorkoutProvider.notifier);
      notifier.startWorkout(sampleWorkout);

      notifier.discardWorkout();

      expect(container.read(activeWorkoutProvider), isNull);
      expect(container.read(lastWorkoutSummaryProvider), isNull);
    });
  });
}
