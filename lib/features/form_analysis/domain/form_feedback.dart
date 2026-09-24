/// Severity rating for biomechanical form feedback.
enum FeedbackSeverity {
  good,
  info,
  warning,
  critical;

  String get label => switch (this) {
    FeedbackSeverity.good => 'Good Form',
    FeedbackSeverity.info => 'Form Tip',
    FeedbackSeverity.warning => 'Correction Needed',
    FeedbackSeverity.critical => 'Injury Risk',
  };
}

/// A real-time biomechanical feedback notification generated during a repetition.
class FormFeedback {
  const FormFeedback({
    required this.message,
    required this.severity,
    required this.score,
    required this.timestamp,
  });

  final String message;
  final FeedbackSeverity severity;

  /// Quality score for the specific phase/rep from 0.0 to 100.0.
  final double score;
  final DateTime timestamp;
}

/// Summary report generated after completing a set with AI form tracking.
class FormSetSummary {
  const FormSetSummary({
    required this.exerciseName,
    required this.totalReps,
    required this.averageFormScore,
    required this.repScores,
    required this.feedbackList,
  });

  final String exerciseName;
  final int totalReps;
  final double averageFormScore; // 0.0 to 100.0
  final List<double> repScores;
  final List<FormFeedback> feedbackList;

  String get qualityTier {
    if (averageFormScore >= 90.0) return 'Flawless Execution';
    if (averageFormScore >= 80.0) return 'Solid Technique';
    if (averageFormScore >= 70.0) return 'Acceptable Form';
    return 'Technique Needs Work';
  }
}
