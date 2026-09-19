import 'package:calibrefit/features/home/domain/daily_workout.dart';
import 'package:calibrefit/features/home/domain/home_repository.dart';

/// In-memory mock implementation of [HomeRepository].
///
/// Supplies realistic workout preview and quick progress data for Phase 3.
class MockHomeRepository implements HomeRepository {
  const MockHomeRepository();

  static const _simulatedDelay = Duration(milliseconds: 200);

  @override
  Future<DailyWorkout> getTodaysWorkout() async {
    await Future<void>.delayed(_simulatedDelay);

    return const DailyWorkout(
      id: 'workout-today-01',
      title: "Today's Workout",
      targetMuscles: 'Chest + Triceps',
      estimatedDurationMinutes: 45,
      exercises: [
        DailyWorkoutExercise(
          id: 'ex-01',
          name: 'Bench Press',
          sets: 4,
          repRange: '6–8',
          suggestedLoadKg: 42.5,
        ),
        DailyWorkoutExercise(
          id: 'ex-02',
          name: 'Incline DB Press',
          sets: 3,
          repRange: '8–10',
          suggestedLoadKg: 17.5,
        ),
        DailyWorkoutExercise(
          id: 'ex-03',
          name: 'Cable Fly',
          sets: 3,
          repRange: '10–12',
          suggestedLoadKg: 15.0,
        ),
      ],
    );
  }

  @override
  Future<QuickProgressSummary> getQuickProgressSummary() async {
    await Future<void>.delayed(_simulatedDelay);

    return const QuickProgressSummary(
      completedWorkoutsThisWeek: 3,
      targetWorkoutsPerWeek: 4,
      currentStreakDays: 5,
      weeklyVolumeKg: 14250.0,
    );
  }
}
