import 'package:calibrefit/features/set_logging/domain/set_log.dart';

/// Summary of an exercise completed within a historical workout.
class ExerciseHistorySummary {
  const ExerciseHistorySummary({
    required this.exerciseId,
    required this.exerciseName,
    required this.setsCount,
    required this.bestSetWeightKg,
    required this.bestSetReps,
    required this.totalVolumeKg,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final int setsCount;
  final double bestSetWeightKg;
  final int bestSetReps;
  final double totalVolumeKg;
  final List<SetLog> sets;
}

/// A completed workout session record in history.
class WorkoutHistoryRecord {
  const WorkoutHistoryRecord({
    required this.id,
    required this.workoutTitle,
    required this.targetMuscles,
    required this.date,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.totalReps,
    required this.totalSets,
    required this.exerciseSummaries,
  });

  final String id;
  final String workoutTitle;
  final String targetMuscles;
  final DateTime date;
  final int durationSeconds;
  final double totalVolumeKg;
  final int totalReps;
  final int totalSets;
  final List<ExerciseHistorySummary> exerciseSummaries;

  Duration get duration => Duration(seconds: durationSeconds);
}

/// A chronological progress point for a specific exercise over time.
class ExerciseProgressPoint {
  const ExerciseProgressPoint({
    required this.date,
    required this.weightKg,
    required this.reps,
    required this.volumeKg,
    required this.estimated1RmKg,
  });

  final DateTime date;
  final double weightKg;
  final int reps;
  final double volumeKg;
  final double estimated1RmKg;
}
