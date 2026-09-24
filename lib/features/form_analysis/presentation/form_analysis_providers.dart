import 'dart:async';

import 'package:calibrefit/features/form_analysis/data/pose_detector_service.dart';
import 'package:calibrefit/features/form_analysis/domain/exercise_form_analyzer.dart';
import 'package:calibrefit/features/form_analysis/domain/form_feedback.dart';
import 'package:calibrefit/features/form_analysis/domain/pose_landmark.dart';
import 'package:calibrefit/features/form_analysis/domain/rep_counter_state_machine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Service Provider
// ---------------------------------------------------------------------------

final poseDetectorServiceProvider = Provider<PoseDetectorService>((ref) {
  final service = SimulatedPoseDetectorService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Selected Exercise Provider
// ---------------------------------------------------------------------------

class FormAnalysisExerciseNotifier extends Notifier<String> {
  @override
  String build() => 'squat';

  void select(String exercise) {
    state = exercise.toLowerCase();
    ref.read(poseDetectorServiceProvider).setExercise(state);
    ref.read(formAnalysisStateProvider.notifier).resetForExercise(state);
  }
}

final formAnalysisExerciseTypeProvider =
    NotifierProvider<FormAnalysisExerciseNotifier, String>(
      FormAnalysisExerciseNotifier.new,
    );

// ---------------------------------------------------------------------------
// Form Analysis State & Notifier
// ---------------------------------------------------------------------------

class FormAnalysisState {
  const FormAnalysisState({
    this.latestFrame,
    this.reps = 0,
    this.phase = MovementPhase.start,
    this.keyAngles = const {},
    this.latestFeedback,
    this.feedbackHistory = const [],
    this.isActive = false,
    this.isCompleted = false,
    this.summary,
  });

  final PoseFrame? latestFrame;
  final int reps;
  final MovementPhase phase;
  final Map<String, double> keyAngles;
  final FormFeedback? latestFeedback;
  final List<FormFeedback> feedbackHistory;
  final bool isActive;
  final bool isCompleted;
  final FormSetSummary? summary;

  FormAnalysisState copyWith({
    PoseFrame? latestFrame,
    int? reps,
    MovementPhase? phase,
    Map<String, double>? keyAngles,
    FormFeedback? latestFeedback,
    List<FormFeedback>? feedbackHistory,
    bool? isActive,
    bool? isCompleted,
    FormSetSummary? summary,
  }) {
    return FormAnalysisState(
      latestFrame: latestFrame ?? this.latestFrame,
      reps: reps ?? this.reps,
      phase: phase ?? this.phase,
      keyAngles: keyAngles ?? this.keyAngles,
      latestFeedback: latestFeedback ?? this.latestFeedback,
      feedbackHistory: feedbackHistory ?? this.feedbackHistory,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      summary: summary ?? this.summary,
    );
  }
}

class FormAnalysisNotifier extends Notifier<FormAnalysisState> {
  StreamSubscription<PoseFrame>? _subscription;
  late ExerciseFormAnalyzer _analyzer;

  @override
  FormAnalysisState build() {
    _analyzer = SquatFormAnalyzer();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const FormAnalysisState();
  }

  void startTracking() {
    final service = ref.read(poseDetectorServiceProvider);
    service.start();

    _subscription?.cancel();
    _subscription = service.poseStream.listen(_handleFrame);

    state = state.copyWith(isActive: true, isCompleted: false, summary: null);
  }

  void pauseTracking() {
    ref.read(poseDetectorServiceProvider).stop();
    _subscription?.cancel();
    state = state.copyWith(isActive: false);
  }

  void _handleFrame(PoseFrame frame) {
    if (!state.isActive) return;

    final angles = _analyzer.extractKeyAngles(frame);
    final feedback = _analyzer.analyzeForm(frame);

    final history = feedback != null
        ? [...state.feedbackHistory, feedback]
        : state.feedbackHistory;

    state = state.copyWith(
      latestFrame: frame,
      reps: _analyzer.stateMachine.reps,
      phase: _analyzer.stateMachine.phase,
      keyAngles: angles,
      latestFeedback: feedback ?? state.latestFeedback,
      feedbackHistory: history,
    );
  }

  void finishSet() {
    pauseTracking();

    final scores = state.feedbackHistory.map((f) => f.score).toList();
    final avgScore = scores.isNotEmpty
        ? scores.reduce((a, b) => a + b) / scores.length
        : 85.0;

    final summary = FormSetSummary(
      exerciseName: _analyzer.exerciseName,
      totalReps: state.reps,
      averageFormScore: (avgScore * 10).round() / 10.0,
      repScores: scores,
      feedbackList: state.feedbackHistory,
    );

    state = state.copyWith(isCompleted: true, summary: summary);
  }

  void resetForExercise(String exerciseType) {
    pauseTracking();
    _analyzer = switch (exerciseType.toLowerCase()) {
      'pushup' => PushUpFormAnalyzer(),
      'curl' => BicepCurlFormAnalyzer(),
      _ => SquatFormAnalyzer(),
    };

    state = const FormAnalysisState();
  }
}

final formAnalysisStateProvider =
    NotifierProvider<FormAnalysisNotifier, FormAnalysisState>(
      FormAnalysisNotifier.new,
    );
