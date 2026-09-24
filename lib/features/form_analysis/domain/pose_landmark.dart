import 'dart:math' as math;

/// 33 standard MediaPipe Pose Landmark indices.
enum PoseLandmarkType {
  nose,
  leftEyeInner,
  leftEye,
  leftEyeOuter,
  rightEyeInner,
  rightEye,
  rightEyeOuter,
  leftEar,
  rightEar,
  mouthLeft,
  mouthRight,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftPinky,
  rightPinky,
  leftIndex,
  rightIndex,
  leftThumb,
  rightThumb,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftHeel,
  rightHeel,
  leftFootIndex,
  rightFootIndex,
}

/// A single detected 3D landmark with confidence metrics.
class PoseLandmark {
  const PoseLandmark({
    required this.type,
    required this.x,
    required this.y,
    this.z = 0.0,
    this.visibility = 1.0,
  });

  final PoseLandmarkType type;

  /// Normalized horizontal coordinate (0.0 = left edge, 1.0 = right edge).
  final double x;

  /// Normalized vertical coordinate (0.0 = top edge, 1.0 = bottom edge).
  final double y;

  /// Depth coordinate relative to the midpoint of hips.
  final double z;

  /// Likelihood that the landmark is visible in the frame (0.0 to 1.0).
  final double visibility;

  bool get isVisible => visibility >= 0.5;

  PoseLandmark copyWith({
    PoseLandmarkType? type,
    double? x,
    double? y,
    double? z,
    double? visibility,
  }) {
    return PoseLandmark(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      visibility: visibility ?? this.visibility,
    );
  }
}

/// A single frame of detected pose landmarks from a camera or simulator.
class PoseFrame {
  const PoseFrame({required this.timestamp, required this.landmarks});

  final DateTime timestamp;
  final List<PoseLandmark> landmarks;

  /// Retrieves a landmark by its type, or null if not detected.
  PoseLandmark? getLandmark(PoseLandmarkType type) {
    for (final l in landmarks) {
      if (l.type == type) return l;
    }
    return null;
  }
}

/// Calculates the 2D joint angle at point [b] between vectors BA and BC in degrees (0° to 180°).
///
/// Formula:
/// \[ \theta = \arccos\left(\frac{\vec{BA} \cdot \vec{BC}}{\|\vec{BA}\| \|\vec{BC}\|}\right) \]
double calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
  final vAx = a.x - b.x;
  final vAy = a.y - b.y;

  final vCx = c.x - b.x;
  final vCy = c.y - b.y;

  final dotProduct = (vAx * vCx) + (vAy * vCy);
  final magBA = math.sqrt((vAx * vAx) + (vAy * vAy));
  final magBC = math.sqrt((vCx * vCx) + (vCy * vCy));

  if (magBA == 0 || magBC == 0) return 0.0;

  final cosTheta = (dotProduct / (magBA * magBC)).clamp(-1.0, 1.0);
  final radians = math.acos(cosTheta);
  return radians * (180.0 / math.pi);
}
