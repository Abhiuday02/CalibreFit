import 'package:calibrefit/features/history/data/mock_history_repository.dart';
import 'package:calibrefit/features/recommendations/data/mock_recommendations_repository.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockRecommendationsRepository repository;

  setUp(() {
    repository = MockRecommendationsRepository(
      historyRepository: MockHistoryRepository(),
    );
  });

  group('MockRecommendationsRepository', () {
    test(
      'getAllActiveRecommendations returns comprehensive recommendations',
      () async {
        final list = await repository.getAllActiveRecommendations();

        expect(list.isNotEmpty, isTrue);
        expect(list.length, greaterThanOrEqualTo(4));

        final bench = list.firstWhere((r) => r.exerciseId == 'ex-bench-press');
        expect(bench.exerciseName, 'Barbell Bench Press');
        expect(bench.suggestedWeightKg, greaterThan(0));
        expect(bench.confidenceScore, greaterThanOrEqualTo(0.8));
        expect(bench.strategy, isNotNull);
        expect(bench.reason, isNotNull);
        expect(bench.explanation.isNotEmpty, isTrue);
      },
    );

    test(
      'getExerciseRecommendation finds specific exercise recommendation',
      () async {
        final squat = await repository.getExerciseRecommendation('ex-squat');

        expect(squat, isNotNull);
        expect(squat!.exerciseName, 'Barbell Back Squat');
        expect(squat.suggestedWeightKg, greaterThan(0));
        expect(squat.strategy, isNotNull);

        final ohp = await repository.getExerciseRecommendation(
          'ex-overhead-press',
        );
        expect(ohp, isNotNull);
        expect(ohp!.strategy, OverloadStrategy.doubleProgression);

        final nonExistent = await repository.getExerciseRecommendation(
          'ex-non-existent',
        );
        expect(nonExistent, isNull);
      },
    );

    test('getWorkoutRecommendations returns list of recommendations', () async {
      final recs = await repository.getWorkoutRecommendations('workout-1');
      expect(recs.isNotEmpty, isTrue);
    });
  });
}
