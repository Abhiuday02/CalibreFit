import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_engine.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = RecommendationEngine();

  group('RecommendationEngine - Progressive Overload', () {
    test('Double progression triggers when all sets hit top of rep range', () {
      final now = DateTime.now();
      final sets = [
        SetLog(
          id: 's1',
          sessionId: 'w1',
          exerciseId: 'ex-bench',
          exerciseName: 'Bench Press',
          setNumber: 1,
          plannedWeight: 40.0,
          plannedReps: 12,
          actualWeight: 40.0,
          actualReps: 12,
          rpe: 8.0,
          timestamp: now,
        ),
        SetLog(
          id: 's2',
          sessionId: 'w1',
          exerciseId: 'ex-bench',
          exerciseName: 'Bench Press',
          setNumber: 2,
          plannedWeight: 40.0,
          plannedReps: 12,
          actualWeight: 40.0,
          actualReps: 12,
          rpe: 8.0,
          timestamp: now,
        ),
        SetLog(
          id: 's3',
          sessionId: 'w1',
          exerciseId: 'ex-bench',
          exerciseName: 'Bench Press',
          setNumber: 3,
          plannedWeight: 40.0,
          plannedReps: 12,
          actualWeight: 40.0,
          actualReps: 12,
          rpe: 8.5,
          timestamp: now,
        ),
      ];

      final rec = engine.generateExerciseRecommendation(
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        category: ExerciseCategory.chest,
        recentSets: sets,
        repRange: '8–12',
      );

      expect(rec.strategy, OverloadStrategy.doubleProgression);
      expect(rec.reason, AdjustmentReason.targetRepsExceeded);
      expect(rec.currentWeightKg, 40.0);
      expect(rec.suggestedWeightKg, 42.5); // +2.5kg for upper body
      expect(rec.suggestedRepRange, '8–10');
      expect(rec.isIncrease, isTrue);
    });

    test('Low exertion triggers linear load progression', () {
      final now = DateTime.now();
      final sets = [
        SetLog(
          id: 's1',
          sessionId: 'w1',
          exerciseId: 'ex-squat',
          exerciseName: 'Squat',
          setNumber: 1,
          plannedWeight: 60.0,
          plannedReps: 8,
          actualWeight: 60.0,
          actualReps: 8,
          rpe: 6.5,
          timestamp: now,
        ),
        SetLog(
          id: 's2',
          sessionId: 'w1',
          exerciseId: 'ex-squat',
          exerciseName: 'Squat',
          setNumber: 2,
          plannedWeight: 60.0,
          plannedReps: 8,
          actualWeight: 60.0,
          actualReps: 8,
          rpe: 6.0,
          timestamp: now,
        ),
      ];

      final rec = engine.generateExerciseRecommendation(
        exerciseId: 'ex-squat',
        exerciseName: 'Squat',
        category: ExerciseCategory.legs,
        recentSets: sets,
        repRange: '6–10',
      );

      expect(rec.strategy, OverloadStrategy.linearLoad);
      expect(rec.reason, AdjustmentReason.lowExertion);
      expect(rec.currentWeightKg, 60.0);
      expect(rec.suggestedWeightKg, 65.0); // +5.0kg for lower body
      expect(rec.isIncrease, isTrue);
    });

    test('Near failure (RPE >= 9.5) maintains current weight', () {
      final now = DateTime.now();
      final sets = [
        SetLog(
          id: 's1',
          sessionId: 'w1',
          exerciseId: 'ex-deadlift',
          exerciseName: 'Deadlift',
          setNumber: 1,
          plannedWeight: 100.0,
          plannedReps: 5,
          actualWeight: 100.0,
          actualReps: 5,
          rpe: 9.5,
          timestamp: now,
        ),
      ];

      final rec = engine.generateExerciseRecommendation(
        exerciseId: 'ex-deadlift',
        exerciseName: 'Deadlift',
        category: ExerciseCategory.back,
        recentSets: sets,
        repRange: '5–5',
      );

      expect(rec.strategy, OverloadStrategy.maintain);
      expect(rec.reason, AdjustmentReason.nearFailure);
      expect(rec.suggestedWeightKg, 100.0);
      expect(rec.isMaintain, isTrue);
    });

    test('Underperformed sets with high RPE triggers deload', () {
      final now = DateTime.now();
      final sets = [
        SetLog(
          id: 's1',
          sessionId: 'w1',
          exerciseId: 'ex-bench',
          exerciseName: 'Bench Press',
          setNumber: 1,
          plannedWeight: 60.0,
          plannedReps: 8,
          actualWeight: 60.0,
          actualReps: 5, // Missed min target 8
          rpe: 9.5,
          timestamp: now,
        ),
        SetLog(
          id: 's2',
          sessionId: 'w1',
          exerciseId: 'ex-bench',
          exerciseName: 'Bench Press',
          setNumber: 2,
          plannedWeight: 60.0,
          plannedReps: 8,
          actualWeight: 60.0,
          actualReps: 4, // Missed min target 8
          rpe: 10.0,
          timestamp: now,
        ),
      ];

      final rec = engine.generateExerciseRecommendation(
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        category: ExerciseCategory.chest,
        recentSets: sets,
        repRange: '8–12',
      );

      expect(rec.strategy, OverloadStrategy.deload);
      expect(rec.reason, AdjustmentReason.underperformed);
      expect(rec.suggestedWeightKg, 54.0); // -10% of 60kg
      expect(rec.isDecrease, isTrue);
    });

    test('Optimal zone maintains weight and aims for rep progression', () {
      final now = DateTime.now();
      final sets = [
        SetLog(
          id: 's1',
          sessionId: 'w1',
          exerciseId: 'ex-press',
          exerciseName: 'Shoulder Press',
          setNumber: 1,
          plannedWeight: 20.0,
          plannedReps: 10,
          actualWeight: 20.0,
          actualReps: 9,
          rpe: 8.0,
          timestamp: now,
        ),
        SetLog(
          id: 's2',
          sessionId: 'w1',
          exerciseId: 'ex-press',
          exerciseName: 'Shoulder Press',
          setNumber: 2,
          plannedWeight: 20.0,
          plannedReps: 10,
          actualWeight: 20.0,
          actualReps: 9,
          rpe: 8.5,
          timestamp: now,
        ),
      ];

      final rec = engine.generateExerciseRecommendation(
        exerciseId: 'ex-press',
        exerciseName: 'Shoulder Press',
        category: ExerciseCategory.shoulders,
        recentSets: sets,
        repRange: '8–12',
      );

      expect(rec.strategy, OverloadStrategy.doubleProgression);
      expect(rec.reason, AdjustmentReason.optimalZone);
      expect(rec.suggestedWeightKg, 20.0);
      expect(rec.isMaintain, isTrue);
    });
  });

  group('RecommendationEngine - Next Set Intra-Workout Adjustments', () {
    test('Low exertion on previous set suggests weight bump for next set', () {
      final lastSet = SetLog(
        id: 's1',
        sessionId: 'active-1',
        exerciseId: 'ex-bench',
        exerciseName: 'Bench Press',
        setNumber: 1,
        plannedWeight: 40.0,
        plannedReps: 10,
        actualWeight: 40.0,
        actualReps: 10,
        rpe: 6.0,
        timestamp: DateTime.now(),
      );

      final adj = engine.calculateNextSetAdjustment(
        lastCompletedSet: lastSet,
        nextSetNumber: 2,
        targetReps: 10,
      );

      expect(adj.suggestedWeightKg, 42.5);
      expect(adj.reason, AdjustmentReason.lowExertion);
      expect(adj.setNumber, 2);
    });

    test(
      'Near failure on previous set with missed reps suggests micro-drop',
      () {
        final lastSet = SetLog(
          id: 's2',
          sessionId: 'active-1',
          exerciseId: 'ex-bench',
          exerciseName: 'Bench Press',
          setNumber: 2,
          plannedWeight: 42.5,
          plannedReps: 10,
          actualWeight: 42.5,
          actualReps: 7, // Missed reps
          rpe: 9.5,
          timestamp: DateTime.now(),
        );

        final adj = engine.calculateNextSetAdjustment(
          lastCompletedSet: lastSet,
          nextSetNumber: 3,
          targetReps: 10,
        );

        expect(adj.suggestedWeightKg, 40.0); // Dropped by 2.5kg
        expect(adj.reason, AdjustmentReason.nearFailure);
        expect(adj.setNumber, 3);
      },
    );
  });
}
