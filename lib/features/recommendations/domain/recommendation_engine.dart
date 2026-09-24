import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';

/// Pure algorithmic engine for progressive overload and RPE-based weight recommendations.
class RecommendationEngine {
  const RecommendationEngine();

  /// Parses a rep range string (e.g. "8–12", "8-12", "10–15", "5") into [minReps, maxReps].
  static (int, int) parseRepRange(String repRange) {
    final cleaned = repRange.replaceAll('–', '-').replaceAll(' ', '');
    final parts = cleaned.split('-');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]) ?? 8;
      final max = int.tryParse(parts[1]) ?? 12;
      return (min, max);
    }
    final single = int.tryParse(parts[0]) ?? 8;
    return (single, single);
  }

  /// Determines default load increment in kg based on exercise category.
  static double defaultIncrementForCategory(ExerciseCategory category) {
    return switch (category) {
      ExerciseCategory.legs => 5.0, // Lower body compound / squats / deadlifts
      _ => 2.5, // Upper body / dumbbells / isolation
    };
  }

  /// Evaluates recent performance for an exercise and generates a progressive overload recommendation.
  WeightRecommendation generateExerciseRecommendation({
    required String exerciseId,
    required String exerciseName,
    required ExerciseCategory category,
    required List<SetLog> recentSets,
    String repRange = '8–12',
    double? customIncrementKg,
  }) {
    final incrementKg =
        customIncrementKg ?? defaultIncrementForCategory(category);
    final (minReps, maxReps) = parseRepRange(repRange);

    if (recentSets.isEmpty) {
      // Baseline recommendation when no sets exist
      return WeightRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        category: category,
        currentWeightKg: 20.0,
        suggestedWeightKg: 20.0,
        currentRepRange: repRange,
        suggestedRepRange: repRange,
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.maintain,
        reason: AdjustmentReason.optimalZone,
        explanation:
            'Start with baseline weight of 20.0 kg for $repRange reps at RPE 8.0.',
        confidenceScore: 0.6,
      );
    }

    // Filter to completed sets
    final completedSets = recentSets.where((s) => s.isCompleted).toList();
    if (completedSets.isEmpty) {
      final w = recentSets.first.plannedWeight;
      return WeightRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        category: category,
        currentWeightKg: w,
        suggestedWeightKg: w,
        currentRepRange: repRange,
        suggestedRepRange: repRange,
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.maintain,
        reason: AdjustmentReason.optimalZone,
        explanation: 'Maintain $w kg for $repRange reps.',
        confidenceScore: 0.6,
      );
    }

    // Performance statistics
    final currentWeight = completedSets
        .map((s) => s.actualWeight)
        .fold<double>(0.0, (prev, curr) => curr > prev ? curr : prev);

    final avgReps =
        completedSets.map((s) => s.actualReps).reduce((a, b) => a + b) /
        completedSets.length;

    final rpeList = completedSets
        .where((s) => s.rpe != null)
        .map((s) => s.rpe!)
        .toList();

    final avgRpe = rpeList.isNotEmpty
        ? rpeList.reduce((a, b) => a + b) / rpeList.length
        : 8.0;

    final allHitMaxReps = completedSets.every((s) => s.actualReps >= maxReps);
    final anyBelowMinReps = completedSets.any((s) => s.actualReps < minReps);

    // ── Decision Tree ───────────────────────────────────────────────────────

    // 1. Double Progression Trigger: All sets hit max reps with RPE <= 8.5
    if (allHitMaxReps && avgRpe <= 8.5) {
      final nextWeight = currentWeight + incrementKg;
      final nextRepRange = '$minReps–${minReps + 2}';

      return WeightRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        category: category,
        currentWeightKg: currentWeight,
        suggestedWeightKg: nextWeight,
        currentRepRange: repRange,
        suggestedRepRange: nextRepRange,
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.doubleProgression,
        reason: AdjustmentReason.targetRepsExceeded,
        explanation:
            'You hit the top of your rep range ($maxReps reps) across all sets with solid reserve (avg RPE ${avgRpe.toStringAsFixed(1)}). Increase weight by +$incrementKg kg and reset reps to $nextRepRange.',
        confidenceScore: 0.95,
      );
    }

    // 2. Underperformed: Multiple sets failed to achieve minimum reps
    if (anyBelowMinReps && avgReps < minReps) {
      // If significantly underperformed with high RPE, suggest micro-deload
      if (avgRpe >= 9.0) {
        final deloadWeight =
            ((currentWeight * 0.9) * 2).round() / 2.0; // -10% rounded to 0.5kg
        return WeightRecommendation(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          category: category,
          currentWeightKg: currentWeight,
          suggestedWeightKg: deloadWeight,
          currentRepRange: repRange,
          suggestedRepRange: repRange,
          targetRpe: 8.0,
          targetRir: 2,
          strategy: OverloadStrategy.deload,
          reason: AdjustmentReason.underperformed,
          explanation:
              'Failed to hit target reps (avg ${avgReps.toStringAsFixed(1)} reps) at high exertion (RPE ${avgRpe.toStringAsFixed(1)}). Deload to $deloadWeight kg (-10%) to reset fatigue.',
          confidenceScore: 0.85,
        );
      }

      return WeightRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        category: category,
        currentWeightKg: currentWeight,
        suggestedWeightKg: currentWeight,
        currentRepRange: repRange,
        suggestedRepRange: repRange,
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.maintain,
        reason: AdjustmentReason.underperformed,
        explanation:
            'Sets fell short of minimum rep target ($minReps reps). Maintain $currentWeight kg and focus on reaching $minReps reps before progressing.',
        confidenceScore: 0.8,
      );
    }

    // 3. Low Exertion Trigger: RPE <= 7.0 (RIR >= 3)
    if (avgRpe <= 7.0 && !anyBelowMinReps) {
      final nextWeight = currentWeight + incrementKg;

      return WeightRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        category: category,
        currentWeightKg: currentWeight,
        suggestedWeightKg: nextWeight,
        currentRepRange: repRange,
        suggestedRepRange: repRange,
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.linearLoad,
        reason: AdjustmentReason.lowExertion,
        explanation:
            'Average exertion was very low (RPE ${avgRpe.toStringAsFixed(1)}), indicating 3+ reps in reserve. Increase weight to $nextWeight kg to achieve optimal stimulus.',
        confidenceScore: 0.9,
      );
    }

    // 4. High Fatigue / Near Failure: RPE >= 9.5
    if (avgRpe >= 9.5) {
      return WeightRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        category: category,
        currentWeightKg: currentWeight,
        suggestedWeightKg: currentWeight,
        currentRepRange: repRange,
        suggestedRepRange: repRange,
        targetRpe: 8.0,
        targetRir: 2,
        strategy: OverloadStrategy.maintain,
        reason: AdjustmentReason.nearFailure,
        explanation:
            'High exertion detected (avg RPE ${avgRpe.toStringAsFixed(1)}). Hold weight steady at $currentWeight kg until bar speed and fatigue recover.',
        confidenceScore: 0.85,
      );
    }

    // 5. Optimal Hypertrophy Progression: In the pocket (RPE 7.5 - 8.5, reps between min and max)
    return WeightRecommendation(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      category: category,
      currentWeightKg: currentWeight,
      suggestedWeightKg: currentWeight,
      currentRepRange: repRange,
      suggestedRepRange: repRange,
      targetRpe: 8.5,
      targetRir: 1,
      strategy: OverloadStrategy.doubleProgression,
      reason: AdjustmentReason.optimalZone,
      explanation:
          'Solid execution in the optimal hypertrophy zone (RPE ${avgRpe.toStringAsFixed(1)}). Maintain $currentWeight kg and aim to add +1 rep per set toward $maxReps reps.',
      confidenceScore: 0.9,
    );
  }

  /// Calculates real-time intra-workout adjustments for the next set based on the set just completed.
  NextSetAdjustment calculateNextSetAdjustment({
    required SetLog lastCompletedSet,
    required int nextSetNumber,
    int targetReps = 10,
    double targetRpe = 8.0,
  }) {
    final weight = lastCompletedSet.actualWeight;
    final reps = lastCompletedSet.actualReps;
    final rpe = lastCompletedSet.rpe ?? 8.0;

    // Effort significantly below target (RPE <= 6.5)
    if (rpe <= 6.5) {
      final nextWeight = weight + 2.5;
      return NextSetAdjustment(
        setNumber: nextSetNumber,
        suggestedWeightKg: nextWeight,
        suggestedReps: reps,
        targetRpe: 8.0,
        reason: AdjustmentReason.lowExertion,
        message:
            'Last set felt easy (RPE ${rpe.toStringAsFixed(1)}). Increase to $nextWeight kg for Set $nextSetNumber.',
      );
    }

    // Near failure or failure (RPE >= 9.5)
    if (rpe >= 9.5) {
      if (reps < targetReps) {
        final reducedWeight = (weight - 2.5).clamp(0.0, double.infinity);
        return NextSetAdjustment(
          setNumber: nextSetNumber,
          suggestedWeightKg: reducedWeight,
          suggestedReps: targetReps,
          targetRpe: 8.0,
          reason: AdjustmentReason.nearFailure,
          message:
              'Near failure reached (RPE ${rpe.toStringAsFixed(1)}). Reduce load to $reducedWeight kg for Set $nextSetNumber to maintain rep volume.',
        );
      }
      return NextSetAdjustment(
        setNumber: nextSetNumber,
        suggestedWeightKg: weight,
        suggestedReps: reps,
        targetRpe: 8.5,
        reason: AdjustmentReason.nearFailure,
        message:
            'High exertion (RPE ${rpe.toStringAsFixed(1)}). Maintain $weight kg and take a full rest before Set $nextSetNumber.',
      );
    }

    // On target
    return NextSetAdjustment(
      setNumber: nextSetNumber,
      suggestedWeightKg: weight,
      suggestedReps: reps,
      targetRpe: targetRpe,
      reason: AdjustmentReason.optimalZone,
      message:
          'On target (RPE ${rpe.toStringAsFixed(1)}). Keep $weight kg for Set $nextSetNumber.',
    );
  }
}
