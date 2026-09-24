import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/history/domain/history_repository.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_engine.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';
import 'package:calibrefit/features/recommendations/domain/recommendations_repository.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';

/// In-memory implementation of [RecommendationsRepository].
///
/// Uses [RecommendationEngine] to dynamically evaluate exercise performance
/// from [HistoryRepository] and produces evidence-based progressive overload recommendations.
class MockRecommendationsRepository implements RecommendationsRepository {
  MockRecommendationsRepository({
    this.historyRepository,
    RecommendationEngine? engine,
  }) : _engine = engine ?? const RecommendationEngine();

  final HistoryRepository? historyRepository;
  final RecommendationEngine _engine;
  static const _delay = Duration(milliseconds: 150);

  @override
  Future<List<WeightRecommendation>> getAllActiveRecommendations() async {
    await Future.delayed(_delay);

    final recommendations = <WeightRecommendation>[];

    // If historyRepository is available, analyze actual recorded sets
    if (historyRepository != null) {
      final history = await historyRepository!.getWorkoutHistory();
      final exerciseSetsMap = <String, List<SetLog>>{};
      final exerciseNameMap = <String, String>{};

      for (final workout in history) {
        for (final summary in workout.exerciseSummaries) {
          exerciseSetsMap
              .putIfAbsent(summary.exerciseId, () => [])
              .addAll(summary.sets);
          exerciseNameMap[summary.exerciseId] = summary.exerciseName;
        }
      }

      for (final entry in exerciseSetsMap.entries) {
        final exerciseId = entry.key;
        final name = exerciseNameMap[exerciseId] ?? 'Exercise';
        final category = _guessCategory(exerciseId);

        final rec = _engine.generateExerciseRecommendation(
          exerciseId: exerciseId,
          exerciseName: name,
          category: category,
          recentSets: entry.value,
        );
        recommendations.add(rec);
      }
    }

    // Augment with realistic curated baselines for core compound movements not yet logged
    final baselines = _getCuratedBaselines();
    for (final b in baselines) {
      if (!recommendations.any((r) => r.exerciseId == b.exerciseId)) {
        recommendations.add(b);
      }
    }

    return recommendations;
  }

  @override
  Future<WeightRecommendation?> getExerciseRecommendation(
    String exerciseId,
  ) async {
    final all = await getAllActiveRecommendations();
    try {
      return all.firstWhere((r) => r.exerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WeightRecommendation>> getWorkoutRecommendations(
    String workoutId,
  ) async {
    return getAllActiveRecommendations();
  }

  ExerciseCategory _guessCategory(String exerciseId) {
    if (exerciseId.contains('bench') || exerciseId.contains('chest')) {
      return ExerciseCategory.chest;
    }
    if (exerciseId.contains('deadlift') ||
        exerciseId.contains('pull') ||
        exerciseId.contains('row')) {
      return ExerciseCategory.back;
    }
    if (exerciseId.contains('squat') || exerciseId.contains('leg')) {
      return ExerciseCategory.legs;
    }
    if (exerciseId.contains('shoulder') || exerciseId.contains('press')) {
      return ExerciseCategory.shoulders;
    }
    return ExerciseCategory.arms;
  }

  List<WeightRecommendation> _getCuratedBaselines() {
    return const [
      WeightRecommendation(
        exerciseId: 'ex-bench-press',
        exerciseName: 'Barbell Bench Press',
        category: ExerciseCategory.chest,
        currentWeightKg: 42.5,
        suggestedWeightKg: 45.0,
        currentRepRange: '8–12',
        suggestedRepRange: '8–10',
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.doubleProgression,
        reason: AdjustmentReason.targetRepsExceeded,
        explanation: 'You completed all 4 sets at the top of your rep range (10-12 reps) with 2 RIR. Increase weight by +2.5 kg and aim for 8–10 reps.',
        confidenceScore: 0.95,
      ),
      WeightRecommendation(
        exerciseId: 'ex-squat',
        exerciseName: 'Barbell Back Squat',
        category: ExerciseCategory.legs,
        currentWeightKg: 65.0,
        suggestedWeightKg: 70.0,
        currentRepRange: '6–8',
        suggestedRepRange: '6–8',
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.linearLoad,
        reason: AdjustmentReason.lowExertion,
        explanation: 'Average exertion was low (RPE 6.5, 3+ RIR). Lower body compound capacity allows a +5.0 kg progression to 70.0 kg.',
        confidenceScore: 0.92,
      ),
      WeightRecommendation(
        exerciseId: 'ex-deadlift',
        exerciseName: 'Barbell Conventional Deadlift',
        category: ExerciseCategory.back,
        currentWeightKg: 85.0,
        suggestedWeightKg: 85.0,
        currentRepRange: '5–5',
        suggestedRepRange: '5–5',
        targetRpe: 8.5,
        targetRir: 1,
        strategy: OverloadStrategy.maintain,
        reason: AdjustmentReason.nearFailure,
        explanation: 'High exertion detected (RPE 9.5). Maintain 85.0 kg for another session to consolidate CNS recovery and form.',
        confidenceScore: 0.88,
      ),
      WeightRecommendation(
        exerciseId: 'ex-overhead-press',
        exerciseName: 'Standing Overhead Press',
        category: ExerciseCategory.shoulders,
        currentWeightKg: 30.0,
        suggestedWeightKg: 32.5,
        currentRepRange: '8–10',
        suggestedRepRange: '8–8',
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.doubleProgression,
        reason: AdjustmentReason.targetRepsExceeded,
        explanation: 'Rep cap of 10 reps achieved across 3 consecutive sets. Micro-load +2.5 kg to 32.5 kg.',
        confidenceScore: 0.9,
      ),
    ];
  }
}
