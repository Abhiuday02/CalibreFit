import 'package:calibrefit/features/exercise_library/domain/exercise.dart';

/// Contract for accessing the exercise library.
abstract interface class ExerciseRepository {
  /// Fetches all exercises, optionally filtered by search [query] and [category].
  Future<List<Exercise>> getExercises({
    String? query,
    ExerciseCategory? category,
  });

  /// Fetches a specific exercise by its unique [id].
  Future<Exercise?> getExerciseById(String id);
}
