import 'dart:async';
import 'dart:math' as math;

import 'package:calibrefit/features/form_analysis/domain/pose_landmark.dart';

/// Abstract service contract for pose landmark detection.
abstract class PoseDetectorService {
  Stream<PoseFrame> get poseStream;
  void start();
  void stop();
  void setExercise(String exerciseType);
  void dispose();
}

/// Simulated implementation of [PoseDetectorService].
///
/// Emits biomechanically realistic continuous pose landmarks at ~15-20 fps,
/// animating the movement phases of Squats, Push-ups, and Bicep Curls.
class SimulatedPoseDetectorService implements PoseDetectorService {
  SimulatedPoseDetectorService() {
    _controller = StreamController<PoseFrame>.broadcast(
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }

  late final StreamController<PoseFrame> _controller;
  Timer? _timer;
  bool _isRunning = false;
  String _currentExercise = 'squat'; // 'squat', 'pushup', 'curl'
  double _phaseProgress = 0.0; // 0.0 to 2*PI cycle

  @override
  Stream<PoseFrame> get poseStream => _controller.stream;

  void _onListen() {
    start();
  }

  void _onCancel() {
    stop();
  }

  @override
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer?.cancel();

    // Emits a frame every 80ms (~12.5 fps)
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!_isRunning) return;

      _phaseProgress += 0.15;
      if (_phaseProgress >= math.pi * 2) {
        _phaseProgress -= math.pi * 2;
      }

      final frame = _generateFrameForExercise(_currentExercise, _phaseProgress);
      _controller.add(frame);
    });
  }

  @override
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void setExercise(String exerciseType) {
    _currentExercise = exerciseType.toLowerCase();
    _phaseProgress = 0.0;
  }

  @override
  void dispose() {
    stop();
    _controller.close();
  }

  PoseFrame _generateFrameForExercise(String exercise, double progress) {
    final now = DateTime.now();

    // Normalised movement parameter from 0.0 (top) to 1.0 (bottom/peak) and back to 0.0
    // cos goes from 1.0 (at 0) to -1.0 (at PI) to 1.0 (at 2*PI)
    final normalizedCycle = (1.0 - math.cos(progress)) / 2.0;

    return switch (exercise) {
      'pushup' => _generatePushUpFrame(now, normalizedCycle),
      'curl' => _generateCurlFrame(now, normalizedCycle),
      _ => _generateSquatFrame(now, normalizedCycle),
    };
  }

  PoseFrame _generateSquatFrame(DateTime timestamp, double cycle) {
    // Top position: standing tall at x=0.5
    // As cycle increases (0 -> 1): hips and knees descend and flex
    final hipY = 0.48 + (0.18 * cycle); // Hips sink down
    final hipX = 0.50 - (0.05 * cycle); // Slight hip hinge back
    final kneeY = 0.68 + (0.04 * cycle); // Knees bend forward slightly
    final kneeX = 0.52 + (0.03 * cycle);
    const ankleY = 0.88;
    const ankleX = 0.50;

    final shoulderY = 0.28 + (0.16 * cycle); // Torso tilts forward
    final shoulderX = 0.48 - (0.04 * cycle);

    return PoseFrame(
      timestamp: timestamp,
      landmarks: [
        const PoseLandmark(type: PoseLandmarkType.nose, x: 0.47, y: 0.20),
        PoseLandmark(
          type: PoseLandmarkType.leftShoulder,
          x: shoulderX,
          y: shoulderY,
        ),
        PoseLandmark(
          type: PoseLandmarkType.rightShoulder,
          x: shoulderX + 0.04,
          y: shoulderY,
        ),
        PoseLandmark(
          type: PoseLandmarkType.leftElbow,
          x: shoulderX - 0.05,
          y: shoulderY + 0.12,
        ),
        PoseLandmark(
          type: PoseLandmarkType.rightElbow,
          x: shoulderX + 0.09,
          y: shoulderY + 0.12,
        ),
        PoseLandmark(
          type: PoseLandmarkType.leftWrist,
          x: shoulderX - 0.03,
          y: shoulderY + 0.06,
        ),
        PoseLandmark(
          type: PoseLandmarkType.rightWrist,
          x: shoulderX + 0.07,
          y: shoulderY + 0.06,
        ),
        PoseLandmark(type: PoseLandmarkType.leftHip, x: hipX, y: hipY),
        PoseLandmark(type: PoseLandmarkType.rightHip, x: hipX + 0.05, y: hipY),
        PoseLandmark(type: PoseLandmarkType.leftKnee, x: kneeX, y: kneeY),
        PoseLandmark(
          type: PoseLandmarkType.rightKnee,
          x: kneeX + 0.05,
          y: kneeY,
        ),
        const PoseLandmark(
          type: PoseLandmarkType.leftAnkle,
          x: ankleX,
          y: ankleY,
        ),
        const PoseLandmark(
          type: PoseLandmarkType.rightAnkle,
          x: ankleX + 0.05,
          y: ankleY,
        ),
      ],
    );
  }

  PoseFrame _generatePushUpFrame(DateTime timestamp, double cycle) {
    // Horizontal prone orientation
    // Cycle goes 0 (lockout) -> 1 (chest to floor)
    final chestDrop = 0.12 * cycle;
    final shoulderY = 0.52 + chestDrop;
    final elbowY = 0.46 + (0.06 * cycle);
    const wristY = 0.64;

    return PoseFrame(
      timestamp: timestamp,
      landmarks: [
        PoseLandmark(type: PoseLandmarkType.nose, x: 0.24, y: shoulderY - 0.04),
        PoseLandmark(
          type: PoseLandmarkType.leftShoulder,
          x: 0.32,
          y: shoulderY,
        ),
        PoseLandmark(type: PoseLandmarkType.leftElbow, x: 0.30, y: elbowY),
        const PoseLandmark(
          type: PoseLandmarkType.leftWrist,
          x: 0.32,
          y: wristY,
        ),
        PoseLandmark(
          type: PoseLandmarkType.leftHip,
          x: 0.56,
          y: 0.54 + (chestDrop * 0.7),
        ),
        PoseLandmark(
          type: PoseLandmarkType.leftKnee,
          x: 0.72,
          y: 0.56 + (chestDrop * 0.4),
        ),
        const PoseLandmark(type: PoseLandmarkType.leftAnkle, x: 0.86, y: 0.60),
      ],
    );
  }

  PoseFrame _generateCurlFrame(DateTime timestamp, double cycle) {
    // Standing upright with arm curling
    // Cycle 0 = extended arm (wrist low), Cycle 1 = curled (wrist high near shoulder)
    const shoulderX = 0.50;
    const shoulderY = 0.32;
    const elbowX = 0.50;
    const elbowY = 0.50;

    // Wrist arcs upward and inward
    final wristY = 0.70 - (0.35 * cycle);
    final wristX = 0.50 - (0.08 * cycle);

    return PoseFrame(
      timestamp: timestamp,
      landmarks: [
        const PoseLandmark(type: PoseLandmarkType.nose, x: 0.50, y: 0.22),
        const PoseLandmark(
          type: PoseLandmarkType.leftShoulder,
          x: shoulderX,
          y: shoulderY,
        ),
        const PoseLandmark(
          type: PoseLandmarkType.rightShoulder,
          x: shoulderX + 0.08,
          y: shoulderY,
        ),
        const PoseLandmark(
          type: PoseLandmarkType.leftElbow,
          x: elbowX,
          y: elbowY,
        ),
        PoseLandmark(type: PoseLandmarkType.leftWrist, x: wristX, y: wristY),
        const PoseLandmark(type: PoseLandmarkType.leftHip, x: 0.50, y: 0.58),
        const PoseLandmark(type: PoseLandmarkType.leftKnee, x: 0.50, y: 0.76),
        const PoseLandmark(type: PoseLandmarkType.leftAnkle, x: 0.50, y: 0.92),
      ],
    );
  }
}
