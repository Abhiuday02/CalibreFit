import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';

/// Abstract contract for fetching progressive overload and weight recommendations.
abstract class RecommendationsRepository {
  /// Fetches all active progressive overload recommendations across all logged exercises.
  Future<List<WeightRecommendation>> getAllActiveRecommendations();

  /// Fetches the recommendation for a specific exercise by [exerciseId].
  Future<WeightRecommendation?> getExerciseRecommendation(String exerciseId);

  /// Fetches recommendations for all exercises included in a planned workout [workoutId].
  Future<List<WeightRecommendation>> getWorkoutRecommendations(
    String workoutId,
  );
}
