import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/history/presentation/history_providers.dart';
import 'package:calibrefit/features/recommendations/data/mock_recommendations_repository.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_engine.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';
import 'package:calibrefit/features/recommendations/domain/recommendations_repository.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository & Engine Providers
// ---------------------------------------------------------------------------

final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return const RecommendationEngine();
});

final recommendationsRepositoryProvider = Provider<RecommendationsRepository>((
  ref,
) {
  final historyRepo = ref.watch(historyRepositoryProvider);
  final engine = ref.watch(recommendationEngineProvider);
  return MockRecommendationsRepository(
    historyRepository: historyRepo,
    engine: engine,
  );
});

// ---------------------------------------------------------------------------
// Category Filter Provider
// ---------------------------------------------------------------------------

class SelectedCategoryFilterNotifier extends Notifier<ExerciseCategory?> {
  @override
  ExerciseCategory? build() => null;

  void select(ExerciseCategory? category) => state = category;
}

final selectedCategoryFilterProvider =
    NotifierProvider<SelectedCategoryFilterNotifier, ExerciseCategory?>(
      SelectedCategoryFilterNotifier.new,
    );

// ---------------------------------------------------------------------------
// Recommendation Query Providers
// ---------------------------------------------------------------------------

/// Fetches all progressive overload recommendations.
final activeRecommendationsProvider =
    FutureProvider<List<WeightRecommendation>>((ref) async {
      final repo = ref.watch(recommendationsRepositoryProvider);
      return repo.getAllActiveRecommendations();
    });

/// Recommendations filtered by the selected muscle group category.
final filteredRecommendationsProvider =
    Provider<AsyncValue<List<WeightRecommendation>>>((ref) {
      final allAsync = ref.watch(activeRecommendationsProvider);
      final category = ref.watch(selectedCategoryFilterProvider);

      return allAsync.whenData((list) {
        if (category == null) return list;
        return list.where((r) => r.category == category).toList();
      });
    });

/// Recommendation for a specific exercise.
final exerciseRecommendationProvider =
    FutureProvider.family<WeightRecommendation?, String>((ref, id) async {
      final repo = ref.watch(recommendationsRepositoryProvider);
      return repo.getExerciseRecommendation(id);
    });

// ---------------------------------------------------------------------------
// Live Next-Set Adjustment Provider
// ---------------------------------------------------------------------------

/// Calculates a real-time intra-workout adjustment based on the most recently completed set.
final nextSetAdjustmentProvider = Provider.family<NextSetAdjustment?, SetLog>((
  ref,
  lastSet,
) {
  final engine = ref.watch(recommendationEngineProvider);
  return engine.calculateNextSetAdjustment(
    lastCompletedSet: lastSet,
    nextSetNumber: lastSet.setNumber + 1,
    targetReps: lastSet.plannedReps,
  );
});
