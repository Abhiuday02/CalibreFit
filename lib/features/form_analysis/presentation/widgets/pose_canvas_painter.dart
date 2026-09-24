import 'package:calibrefit/features/form_analysis/domain/pose_landmark.dart';
import 'package:flutter/material.dart';

/// CustomPainter that renders detected pose landmarks and skeleton bone connections.
class PoseCanvasPainter extends CustomPainter {
  PoseCanvasPainter({
    required this.frame,
    required this.boneColor,
    required this.jointColor,
    required this.accentColor,
    this.keyAngles = const {},
  });

  final PoseFrame? frame;
  final Color boneColor;
  final Color jointColor;
  final Color accentColor;
  final Map<String, double> keyAngles;

  // Pairs of landmark types to connect with skeleton bones
  static const _connections = <(PoseLandmarkType, PoseLandmarkType)>[
    // Torso box
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder),
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip),
    (PoseLandmarkType.leftHip, PoseLandmarkType.rightHip),

    // Left arm
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
    (PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),

    // Right arm
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
    (PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),

    // Left leg
    (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee),
    (PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),

    // Right leg
    (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee),
    (PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (frame == null || frame!.landmarks.isEmpty) return;

    final bonePaint = Paint()
      ..color = boneColor
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = jointColor
      ..style = PaintingStyle.fill;

    final jointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 1. Draw skeleton bones
    for (final connection in _connections) {
      final p1 = frame!.getLandmark(connection.$1);
      final p2 = frame!.getLandmark(connection.$2);

      if (p1 != null && p2 != null && p1.isVisible && p2.isVisible) {
        canvas.drawLine(
          Offset(p1.x * size.width, p1.y * size.height),
          Offset(p2.x * size.width, p2.y * size.height),
          bonePaint,
        );
      }
    }

    // 2. Draw landmark joints
    for (final lm in frame!.landmarks) {
      if (!lm.isVisible) continue;

      final center = Offset(lm.x * size.width, lm.y * size.height);
      canvas.drawCircle(center, 5.0, jointPaint);
      canvas.drawCircle(center, 5.0, jointBorderPaint);
    }

    // 3. Draw key angle callouts on the active joint
    final leftKnee = frame!.getLandmark(PoseLandmarkType.leftKnee);
    final leftElbow = frame!.getLandmark(PoseLandmarkType.leftElbow);

    if (keyAngles.containsKey('Knee') && leftKnee != null) {
      _drawAnglePill(
        canvas,
        Offset(leftKnee.x * size.width + 12, leftKnee.y * size.height - 10),
        '${keyAngles['Knee']!.toStringAsFixed(0)}°',
      );
    } else if (keyAngles.containsKey('Elbow') && leftElbow != null) {
      _drawAnglePill(
        canvas,
        Offset(leftElbow.x * size.width + 12, leftElbow.y * size.height - 10),
        '${keyAngles['Elbow']!.toStringAsFixed(0)}°',
      );
    }
  }

  void _drawAnglePill(Canvas canvas, Offset position, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        position.dx - 4,
        position.dy - 2,
        textPainter.width + 8,
        textPainter.height + 4,
      ),
      const Radius.circular(4),
    );

    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);
    canvas.drawRRect(bgRect, bgPaint);
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant PoseCanvasPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.keyAngles != keyAngles;
  }
}
