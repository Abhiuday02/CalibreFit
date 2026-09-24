import 'package:calibrefit/features/form_analysis/domain/pose_landmark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PoseLandmark & Angle Calculation Math', () {
    test('calculateAngle computes exact right angle (90 degrees)', () {
      const a = PoseLandmark(type: PoseLandmarkType.leftHip, x: 0.0, y: 1.0);
      const b = PoseLandmark(type: PoseLandmarkType.leftKnee, x: 0.0, y: 0.0);
      const c = PoseLandmark(type: PoseLandmarkType.leftAnkle, x: 1.0, y: 0.0);

      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(90.0, 0.01));
    });

    test('calculateAngle computes straight angle (180 degrees)', () {
      const a = PoseLandmark(type: PoseLandmarkType.leftHip, x: -1.0, y: 0.0);
      const b = PoseLandmark(type: PoseLandmarkType.leftKnee, x: 0.0, y: 0.0);
      const c = PoseLandmark(type: PoseLandmarkType.leftAnkle, x: 1.0, y: 0.0);

      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(180.0, 0.01));
    });

    test('calculateAngle computes 45 degree acute angle', () {
      const a = PoseLandmark(type: PoseLandmarkType.leftHip, x: 1.0, y: 1.0);
      const b = PoseLandmark(type: PoseLandmarkType.leftKnee, x: 0.0, y: 0.0);
      const c = PoseLandmark(type: PoseLandmarkType.leftAnkle, x: 1.0, y: 0.0);

      final angle = calculateAngle(a, b, c);
      expect(angle, closeTo(45.0, 0.01));
    });

    test(
      'calculateAngle safely handles zero-length vectors without crashing',
      () {
        const a = PoseLandmark(type: PoseLandmarkType.leftHip, x: 0.0, y: 0.0);
        const b = PoseLandmark(type: PoseLandmarkType.leftKnee, x: 0.0, y: 0.0);
        const c = PoseLandmark(
          type: PoseLandmarkType.leftAnkle,
          x: 1.0,
          y: 0.0,
        );

        final angle = calculateAngle(a, b, c);
        expect(angle, 0.0);
      },
    );

    test('PoseFrame retrieves landmarks by type', () {
      const knee = PoseLandmark(
        type: PoseLandmarkType.leftKnee,
        x: 0.5,
        y: 0.6,
        visibility: 0.9,
      );

      final frame = PoseFrame(
        timestamp: DateTime.now(),
        landmarks: const [knee],
      );

      expect(frame.getLandmark(PoseLandmarkType.leftKnee), knee);
      expect(frame.getLandmark(PoseLandmarkType.rightKnee), isNull);
    });
  });
}
