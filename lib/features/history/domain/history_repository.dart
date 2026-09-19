import 'package:calibrefit/features/history/domain/workout_history_record.dart';

/// Contract for accessing past workout history and exercise progression.
abstract interface class HistoryRepository {
  /// Fetches all completed historical workouts, ordered by date descending.
  Future<List<WorkoutHistoryRecord>> getWorkoutHistory();

  /// Fetches a specific historical workout record by its unique [id].
  Future<WorkoutHistoryRecord?> getWorkoutHistoryById(String id);

  /// Fetches chronological progress data points for a specific [exerciseId].
  Future<List<ExerciseProgressPoint>> getExerciseProgress(String exerciseId);

  /// Saves a newly finished workout session into history.
  Future<void> recordCompletedWorkout(WorkoutHistoryRecord record);
}
