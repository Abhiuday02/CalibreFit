import 'package:calibrefit/features/exercise_library/domain/exercise.dart';

/// Progressive overload strategies used by the recommendation engine.
enum OverloadStrategy {
  doubleProgression,
  linearLoad,
  volumeAccumulation,
  deload,
  maintain;

  String get displayName => switch (this) {
    OverloadStrategy.doubleProgression => 'Double Progression',
    OverloadStrategy.linearLoad => 'Linear Load Progression',
    OverloadStrategy.volumeAccumulation => 'Volume Accumulation',
    OverloadStrategy.deload => 'Fatigue Deload',
    OverloadStrategy.maintain => 'Consolidation & Form',
  };

  String get description => switch (this) {
    OverloadStrategy.doubleProgression =>
      'Increase reps to upper rep target before increasing load.',
    OverloadStrategy.linearLoad =>
      'Consistently increase load by micro-increments (+2.5kg / +5kg).',
    OverloadStrategy.volumeAccumulation =>
      'Add an additional set to increase total weekly stimulus.',
    OverloadStrategy.deload =>
      'Reduce load by 10% to dissipate systemic fatigue.',
    OverloadStrategy.maintain =>
      'Hold weight steady to solidify technique and motor patterns.',
  };
}

/// The specific physiological or performance reason for an adjustment.
enum AdjustmentReason {
  targetRepsExceeded,
  lowExertion,
  optimalZone,
  nearFailure,
  underperformed,
  fatigueDeload;

  String get label => switch (this) {
    AdjustmentReason.targetRepsExceeded => 'Rep Target Met',
    AdjustmentReason.lowExertion => 'Low RPE (Sub-maximal)',
    AdjustmentReason.optimalZone => 'Optimal Hypertrophy Zone',
    AdjustmentReason.nearFailure => 'High Exertion (RPE ≥ 9)',
    AdjustmentReason.underperformed => 'Missed Rep Targets',
    AdjustmentReason.fatigueDeload => 'Fatigue Accumulation',
  };
}

/// Comprehensive progressive overload recommendation for an exercise.
class WeightRecommendation {
  const WeightRecommendation({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.currentWeightKg,
    required this.suggestedWeightKg,
    required this.currentRepRange,
    required this.suggestedRepRange,
    required this.targetRpe,
    required this.targetRir,
    required this.strategy,
    required this.reason,
    required this.explanation,
    required this.confidenceScore,
  });

  final String exerciseId;
  final String exerciseName;
  final ExerciseCategory category;

  final double currentWeightKg;
  final double suggestedWeightKg;

  final String currentRepRange;
  final String suggestedRepRange;

  final double targetRpe;
  final int targetRir;

  final OverloadStrategy strategy;
  final AdjustmentReason reason;
  final String explanation;

  /// Confidence rating in the recommendation from 0.0 to 1.0.
  final double confidenceScore;

  /// Absolute load difference in kilograms (positive for increase, negative for deload).
  double get weightChangeKg =>
      (suggestedWeightKg - currentWeightKg * 10).round() / 10.0;

  /// Percentage load change.
  double get percentageChange => currentWeightKg > 0
      ? (((suggestedWeightKg - currentWeightKg) / currentWeightKg) * 1000)
                .round() /
            10.0
      : 0.0;

  bool get isIncrease => suggestedWeightKg > currentWeightKg;
  bool get isDecrease => suggestedWeightKg < currentWeightKg;
  bool get isMaintain => suggestedWeightKg == currentWeightKg;
}

/// Real-time live recommendation for the very next set in an active workout.
class NextSetAdjustment {
  const NextSetAdjustment({
    required this.setNumber,
    required this.suggestedWeightKg,
    required this.suggestedReps,
    required this.targetRpe,
    required this.reason,
    required this.message,
  });

  final int setNumber;
  final double suggestedWeightKg;
  final int suggestedReps;
  final double targetRpe;
  final AdjustmentReason reason;
  final String message;
}
