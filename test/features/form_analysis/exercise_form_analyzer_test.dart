import 'package:calibrefit/features/form_analysis/domain/exercise_form_analyzer.dart';
import 'package:calibrefit/features/form_analysis/domain/form_feedback.dart';
import 'package:calibrefit/features/form_analysis/domain/pose_landmark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseFormAnalyzer', () {
    test('SquatFormAnalyzer extracts angles and evaluates depth', () {
      final analyzer = SquatFormAnalyzer();

      // Create a pose frame representing deep squat (leftHip, leftKnee, leftAnkle at 90 degrees)
      final deepSquatFrame = PoseFrame(
        timestamp: DateTime.now(),
        landmarks: const [
          PoseLandmark(type: PoseLandmarkType.leftHip, x: 0.5, y: 0.6),
          PoseLandmark(type: PoseLandmarkType.leftKnee, x: 0.5, y: 0.7),
          PoseLandmark(type: PoseLandmarkType.leftAnkle, x: 0.6, y: 0.7),
          PoseLandmark(type: PoseLandmarkType.leftShoulder, x: 0.5, y: 0.4),
        ],
      );

      final angles = analyzer.extractKeyAngles(deepSquatFrame);
      expect(angles.containsKey('Knee'), isTrue);
      expect(angles['Knee'], closeTo(90.0, 1.0));

      // Trigger descent first
      analyzer.stateMachine.processAngle(130.0);

      // Now analyze bottom depth
      final feedback = analyzer.analyzeForm(deepSquatFrame);
      expect(feedback, isNotNull);
      expect(feedback!.severity, FeedbackSeverity.good);
      expect(feedback.message.contains('parallel depth'), isTrue);
    });

    test('PushUpFormAnalyzer detects hip sag and chest depth', () {
      final analyzer = PushUpFormAnalyzer();

      // Frame with sagging hips (shoulder (0.2, 0.5), hip (0.5, 0.7), ankle (0.8, 0.6))
      final sagFrame = PoseFrame(
        timestamp: DateTime.now(),
        landmarks: const [
          PoseLandmark(type: PoseLandmarkType.leftShoulder, x: 0.2, y: 0.5),
          PoseLandmark(type: PoseLandmarkType.leftElbow, x: 0.2, y: 0.4),
          PoseLandmark(type: PoseLandmarkType.leftWrist, x: 0.2, y: 0.6),
          PoseLandmark(
            type: PoseLandmarkType.leftHip,
            x: 0.5,
            y: 0.75,
          ), // Sagging low
          PoseLandmark(type: PoseLandmarkType.leftAnkle, x: 0.8, y: 0.6),
        ],
      );

      final angles = analyzer.extractKeyAngles(sagFrame);
      expect(angles.containsKey('Spine'), isTrue);
      expect(angles['Spine']!, lessThan(155.0));

      final feedback = analyzer.analyzeForm(sagFrame);
      expect(feedback, isNotNull);
      expect(feedback!.severity, FeedbackSeverity.warning);
      expect(feedback.message.contains('hip sag'), isTrue);
    });

    test('BicepCurlFormAnalyzer detects peak contraction and elbow drift', () {
      final analyzer = BicepCurlFormAnalyzer();

      // Curled frame with elbow drift (shoulder swing)
      final curledFrame = PoseFrame(
        timestamp: DateTime.now(),
        landmarks: const [
          PoseLandmark(type: PoseLandmarkType.leftShoulder, x: 0.5, y: 0.3),
          PoseLandmark(type: PoseLandmarkType.leftElbow, x: 0.5, y: 0.5),
          PoseLandmark(
            type: PoseLandmarkType.leftWrist,
            x: 0.45,
            y: 0.35,
          ), // Curled up
          PoseLandmark(type: PoseLandmarkType.leftHip, x: 0.5, y: 0.7),
        ],
      );

      final angles = analyzer.extractKeyAngles(curledFrame);
      expect(angles.containsKey('Elbow'), isTrue);
      expect(angles['Elbow']!, lessThanOrEqualTo(55.0));

      // Trigger curl ascent
      analyzer.stateMachine.processAngle(100.0);

      final feedback = analyzer.analyzeForm(curledFrame);
      expect(feedback, isNotNull);
      expect(feedback!.severity, FeedbackSeverity.good);
      expect(feedback.message.contains('Peak bicep contraction'), isTrue);
    });
  });
}
