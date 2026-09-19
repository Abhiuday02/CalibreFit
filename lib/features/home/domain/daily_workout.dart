// Domain models for the Home Dashboard.

/// An exercise entry within today's workout preview.
class DailyWorkoutExercise {
  const DailyWorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.repRange,
    required this.suggestedLoadKg,
  });

  final String id;
  final String name;
  final int sets;
  final String repRange;
  final double suggestedLoadKg;

  @override
  String toString() =>
      'DailyWorkoutExercise(name: $name, sets: $sets, reps: $repRange, load: ${suggestedLoadKg}kg)';
}

/// Today's planned workout preview.
class DailyWorkout {
  const DailyWorkout({
    required this.id,
    required this.title,
    required this.targetMuscles,
    required this.estimatedDurationMinutes,
    required this.exercises,
  });

  final String id;
  final String title;
  final String targetMuscles;
  final int estimatedDurationMinutes;
  final List<DailyWorkoutExercise> exercises;

  int get totalSets =>
      exercises.fold(0, (sum, exercise) => sum + exercise.sets);
}

/// Quick progress summary snapshot for the home dashboard.
class QuickProgressSummary {
  const QuickProgressSummary({
    required this.completedWorkoutsThisWeek,
    required this.targetWorkoutsPerWeek,
    required this.currentStreakDays,
    required this.weeklyVolumeKg,
  });

  final int completedWorkoutsThisWeek;
  final int targetWorkoutsPerWeek;
  final int currentStreakDays;
  final double weeklyVolumeKg;

  double get weeklyCompletionRate => targetWorkoutsPerWeek > 0
      ? (completedWorkoutsThisWeek / targetWorkoutsPerWeek).clamp(0.0, 1.0)
      : 0.0;
}
