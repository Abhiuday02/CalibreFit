import 'package:calibrefit/features/form_analysis/domain/form_feedback.dart';
import 'package:calibrefit/features/form_analysis/domain/pose_landmark.dart';
import 'package:calibrefit/features/form_analysis/domain/rep_counter_state_machine.dart';

/// Base contract for exercise-specific form analyzers.
abstract class ExerciseFormAnalyzer {
  String get exerciseName;
  RepCounterStateMachine get stateMachine;

  /// Extracts key joint angles (in degrees) for HUD telemetry and display.
  Map<String, double> extractKeyAngles(PoseFrame frame);

  /// Analyzes the frame for biomechanical posture flaws and generates feedback.
  FormFeedback? analyzeForm(PoseFrame frame);

  /// Resets the analyzer and state machine.
  void reset();
}

/// AI Form Analyzer for Squats.
///
/// Evaluates:
/// - Knee flexion angle (Squat depth: parallel <= 90°)
/// - Torso / hip hinge angle (Chest up vs excessive forward lean)
/// - Knee valgus (inward caving)
class SquatFormAnalyzer implements ExerciseFormAnalyzer {
  SquatFormAnalyzer()
    : _stateMachine = RepCounterStateMachine(
        startThreshold: 165.0,
        inflectionThreshold: 95.0,
        completionThreshold: 160.0,
        isDescendingMovement: true,
      );

  final RepCounterStateMachine _stateMachine;

  @override
  String get exerciseName => 'Barbell Back Squat';

  @override
  RepCounterStateMachine get stateMachine => _stateMachine;

  @override
  Map<String, double> extractKeyAngles(PoseFrame frame) {
    final leftHip = frame.getLandmark(PoseLandmarkType.leftHip);
    final leftKnee = frame.getLandmark(PoseLandmarkType.leftKnee);
    final leftAnkle = frame.getLandmark(PoseLandmarkType.leftAnkle);
    final leftShoulder = frame.getLandmark(PoseLandmarkType.leftShoulder);

    final angles = <String, double>{};

    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      final kneeAngle = calculateAngle(leftHip, leftKnee, leftAnkle);
      angles['Knee'] = (kneeAngle * 10).round() / 10.0;
    }

    if (leftShoulder != null && leftHip != null && leftKnee != null) {
      final hipAngle = calculateAngle(leftShoulder, leftHip, leftKnee);
      angles['Hip'] = (hipAngle * 10).round() / 10.0;
    }

    return angles;
  }

  @override
  FormFeedback? analyzeForm(PoseFrame frame) {
    final angles = extractKeyAngles(frame);
    final kneeAngle = angles['Knee'];
    if (kneeAngle == null) return null;

    final repFinished = _stateMachine.processAngle(kneeAngle);
    final now = DateTime.now();

    // 1. Rep Completed Feedback
    if (repFinished) {
      return FormFeedback(
        message: 'Rep ${_stateMachine.reps} completed with full lockout!',
        severity: FeedbackSeverity.good,
        score: 95.0,
        timestamp: now,
      );
    }

    // 2. Depth Check during bottom inflection
    if (_stateMachine.phase == MovementPhase.inflection) {
      if (kneeAngle <= 90.0) {
        return FormFeedback(
          message:
              'Excellent parallel depth (${kneeAngle.toStringAsFixed(0)}°)! Drive through heels.',
          severity: FeedbackSeverity.good,
          score: 98.0,
          timestamp: now,
        );
      } else if (kneeAngle <= 100.0) {
        return FormFeedback(
          message:
              'Decent depth (${kneeAngle.toStringAsFixed(0)}°). Try squatting 1 inch deeper for full hypertrophy.',
          severity: FeedbackSeverity.info,
          score: 82.0,
          timestamp: now,
        );
      } else {
        return FormFeedback(
          message:
              'Squat deeper! Knee angle is ${kneeAngle.toStringAsFixed(0)}° (target ≤ 90°).',
          severity: FeedbackSeverity.warning,
          score: 65.0,
          timestamp: now,
        );
      }
    }

    // 3. Torso Angle Check
    final hipAngle = angles['Hip'];
    if (hipAngle != null &&
        hipAngle < 50.0 &&
        _stateMachine.phase == MovementPhase.eccentric) {
      return FormFeedback(
        message: 'Chest up! Excessive forward torso lean detected.',
        severity: FeedbackSeverity.warning,
        score: 72.0,
        timestamp: now,
      );
    }

    return null;
  }

  @override
  void reset() {
    _stateMachine.reset();
  }
}

/// AI Form Analyzer for Push-ups.
///
/// Evaluates:
/// - Elbow flexion angle (Chest depth <= 90°, lockout >= 160°)
/// - Hip / spine line (avoiding hip sag)
class PushUpFormAnalyzer implements ExerciseFormAnalyzer {
  PushUpFormAnalyzer()
    : _stateMachine = RepCounterStateMachine(
        startThreshold: 160.0,
        inflectionThreshold: 90.0,
        completionThreshold: 155.0,
        isDescendingMovement: true,
      );

  final RepCounterStateMachine _stateMachine;

  @override
  String get exerciseName => 'Push-up';

  @override
  RepCounterStateMachine get stateMachine => _stateMachine;

  @override
  Map<String, double> extractKeyAngles(PoseFrame frame) {
    final shoulder = frame.getLandmark(PoseLandmarkType.leftShoulder);
    final elbow = frame.getLandmark(PoseLandmarkType.leftElbow);
    final wrist = frame.getLandmark(PoseLandmarkType.leftWrist);
    final hip = frame.getLandmark(PoseLandmarkType.leftHip);
    final ankle = frame.getLandmark(PoseLandmarkType.leftAnkle);

    final angles = <String, double>{};

    if (shoulder != null && elbow != null && wrist != null) {
      final elbowAngle = calculateAngle(shoulder, elbow, wrist);
      angles['Elbow'] = (elbowAngle * 10).round() / 10.0;
    }

    if (shoulder != null && hip != null && ankle != null) {
      final bodyLine = calculateAngle(shoulder, hip, ankle);
      angles['Spine'] = (bodyLine * 10).round() / 10.0;
    }

    return angles;
  }

  @override
  FormFeedback? analyzeForm(PoseFrame frame) {
    final angles = extractKeyAngles(frame);
    final elbowAngle = angles['Elbow'];
    if (elbowAngle == null) return null;

    final repFinished = _stateMachine.processAngle(elbowAngle);
    final now = DateTime.now();

    if (repFinished) {
      return FormFeedback(
        message: 'Rep ${_stateMachine.reps} completed! Full extension.',
        severity: FeedbackSeverity.good,
        score: 95.0,
        timestamp: now,
      );
    }

    if (_stateMachine.phase == MovementPhase.inflection) {
      if (elbowAngle <= 90.0) {
        return FormFeedback(
          message:
              'Full chest depth reached (${elbowAngle.toStringAsFixed(0)}°)! Press up explosively.',
          severity: FeedbackSeverity.good,
          score: 96.0,
          timestamp: now,
        );
      } else {
        return FormFeedback(
          message:
              'Lower your chest more! Elbow angle at ${elbowAngle.toStringAsFixed(0)}° (target ≤ 90°).',
          severity: FeedbackSeverity.warning,
          score: 68.0,
          timestamp: now,
        );
      }
    }

    // Spine alignment check
    final spineAngle = angles['Spine'];
    if (spineAngle != null && spineAngle < 155.0) {
      return FormFeedback(
        message: 'Core disengaged: tighten abs and glutes to stop hip sag.',
        severity: FeedbackSeverity.warning,
        score: 70.0,
        timestamp: now,
      );
    }

    return null;
  }

  @override
  void reset() {
    _stateMachine.reset();
  }
}

/// AI Form Analyzer for Bicep Curls.
///
/// Evaluates:
/// - Elbow flexion angle (Peak contraction <= 55°, Full extension >= 150°)
/// - Elbow drift / momentum swing
class BicepCurlFormAnalyzer implements ExerciseFormAnalyzer {
  BicepCurlFormAnalyzer()
    : _stateMachine = RepCounterStateMachine(
        startThreshold: 150.0,
        inflectionThreshold: 55.0,
        completionThreshold: 145.0,
        isDescendingMovement: false, // Angle decreases during concentric curl
      );

  final RepCounterStateMachine _stateMachine;

  @override
  String get exerciseName => 'Bicep Curl';

  @override
  RepCounterStateMachine get stateMachine => _stateMachine;

  @override
  Map<String, double> extractKeyAngles(PoseFrame frame) {
    final shoulder = frame.getLandmark(PoseLandmarkType.leftShoulder);
    final elbow = frame.getLandmark(PoseLandmarkType.leftElbow);
    final wrist = frame.getLandmark(PoseLandmarkType.leftWrist);
    final hip = frame.getLandmark(PoseLandmarkType.leftHip);

    final angles = <String, double>{};

    if (shoulder != null && elbow != null && wrist != null) {
      final elbowAngle = calculateAngle(shoulder, elbow, wrist);
      angles['Elbow'] = (elbowAngle * 10).round() / 10.0;
    }

    if (hip != null && shoulder != null && elbow != null) {
      final shoulderAngle = calculateAngle(hip, shoulder, elbow);
      angles['Elbow Drift'] = (shoulderAngle * 10).round() / 10.0;
    }

    return angles;
  }

  @override
  FormFeedback? analyzeForm(PoseFrame frame) {
    final angles = extractKeyAngles(frame);
    final elbowAngle = angles['Elbow'];
    if (elbowAngle == null) return null;

    final repFinished = _stateMachine.processAngle(elbowAngle);
    final now = DateTime.now();

    if (repFinished) {
      return FormFeedback(
        message: 'Rep ${_stateMachine.reps} completed! Full extension.',
        severity: FeedbackSeverity.good,
        score: 95.0,
        timestamp: now,
      );
    }

    if (_stateMachine.phase == MovementPhase.inflection) {
      if (elbowAngle <= 55.0) {
        return FormFeedback(
          message:
              'Peak bicep contraction reached (${elbowAngle.toStringAsFixed(0)}°)! Control the eccentric.',
          severity: FeedbackSeverity.good,
          score: 98.0,
          timestamp: now,
        );
      } else {
        return FormFeedback(
          message:
              'Curl higher! Elbow angle at ${elbowAngle.toStringAsFixed(0)}° (target ≤ 55°).',
          severity: FeedbackSeverity.info,
          score: 75.0,
          timestamp: now,
        );
      }
    }

    final drift = angles['Elbow Drift'];
    if (drift != null && drift > 35.0) {
      return FormFeedback(
        message: 'Keep elbows pinned to your ribs: avoid swinging momentum.',
        severity: FeedbackSeverity.warning,
        score: 68.0,
        timestamp: now,
      );
    }

    return null;
  }

  @override
  void reset() {
    _stateMachine.reset();
  }
}
