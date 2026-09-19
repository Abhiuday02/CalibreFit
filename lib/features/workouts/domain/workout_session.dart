// Domain models for Active Workout Session and Summary.

/// Status of an active workout session.
enum WorkoutSessionStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  cancelled,
}

/// Represents a single set in an active workout exercise.
///
/// Stores BOTH planned targets and actual performance.
class ActiveExerciseSet {
  const ActiveExerciseSet({
    required this.setNumber,
    required this.plannedReps,
    required this.plannedRepsDisplay,
    required this.plannedWeightKg,
    required this.actualReps,
    required this.actualWeightKg,
    this.rir,
    this.rpe,
    this.restSeconds,
    this.formScore,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
  });

  final int setNumber;

  // Planned targets (Never overwritten)
  final int plannedReps;
  final String plannedRepsDisplay;
  final double plannedWeightKg;

  // Actual recorded values
  final int actualReps;
  final double actualWeightKg;

  // Effort & Execution metrics
  final int? rir;
  final double? rpe;
  final int? restSeconds;
  final double? formScore;
  final String? notes;

  final bool isCompleted;
  final DateTime? completedAt;

  double get actualVolume => actualWeightKg * actualReps;

  ActiveExerciseSet copyWith({
    int? setNumber,
    int? plannedReps,
    String? plannedRepsDisplay,
    double? plannedWeightKg,
    int? actualReps,
    double? actualWeightKg,
    int? rir,
    double? rpe,
    int? restSeconds,
    double? formScore,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ActiveExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      plannedReps: plannedReps ?? this.plannedReps,
      plannedRepsDisplay: plannedRepsDisplay ?? this.plannedRepsDisplay,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      actualReps: actualReps ?? this.actualReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      rir: rir ?? this.rir,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
      formScore: formScore ?? this.formScore,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Represents an exercise within an active workout session.
class ActiveWorkoutExercise {
  const ActiveWorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
    this.restDurationSeconds = 90,
  });

  final String exerciseId;
  final String name;
  final List<ActiveExerciseSet> sets;
  final int restDurationSeconds;

  int get completedSetsCount => sets.where((s) => s.isCompleted).length;
  bool get isAllSetsCompleted =>
      sets.isNotEmpty && sets.every((s) => s.isCompleted);

  ActiveWorkoutExercise copyWith({
    String? exerciseId,
    String? name,
    List<ActiveExerciseSet>? sets,
    int? restDurationSeconds,
  }) {
    return ActiveWorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
    );
  }
}

/// The entire active workout session state.
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.workoutPlanTitle,
    required this.targetMuscles,
    required this.startedAt,
    required this.exercises,
    this.endedAt,
    this.status = WorkoutSessionStatus.notStarted,
    this.currentExerciseIndex = 0,
    this.elapsedSeconds = 0,
    this.restSecondsRemaining = 0,
    this.isResting = false,
  });

  final String id;
  final String workoutPlanTitle;
  final String targetMuscles;
  final DateTime startedAt;
  final DateTime? endedAt;
  final WorkoutSessionStatus status;
  final List<ActiveWorkoutExercise> exercises;
  final int currentExerciseIndex;
  final int elapsedSeconds;
  final int restSecondsRemaining;
  final bool isResting;

  ActiveWorkoutExercise get currentExercise => exercises.isNotEmpty
      ? exercises[currentExerciseIndex]
      : throw StateError('No exercises');

  bool get isFirstExercise => currentExerciseIndex == 0;
  bool get isLastExercise =>
      exercises.isNotEmpty && currentExerciseIndex == exercises.length - 1;

  int get totalSetsCount =>
      exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  int get completedSetsCount =>
      exercises.fold(0, (sum, ex) => sum + ex.completedSetsCount);

  double get sessionProgress => totalSetsCount > 0
      ? (completedSetsCount / totalSetsCount).clamp(0.0, 1.0)
      : 0.0;

  WorkoutSession copyWith({
    String? id,
    String? workoutPlanTitle,
    String? targetMuscles,
    DateTime? startedAt,
    DateTime? endedAt,
    WorkoutSessionStatus? status,
    List<ActiveWorkoutExercise>? exercises,
    int? currentExerciseIndex,
    int? elapsedSeconds,
    int? restSecondsRemaining,
    bool? isResting,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutPlanTitle: workoutPlanTitle ?? this.workoutPlanTitle,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      isResting: isResting ?? this.isResting,
    );
  }
}

/// Summary metrics computed upon workout completion.
class WorkoutSummaryData {
  const WorkoutSummaryData({
    required this.workoutTitle,
    required this.targetMuscles,
    required this.totalDurationSeconds,
    required this.totalSetsCompleted,
    required this.totalSetsPlanned,
    required this.totalVolumeKg,
    required this.completedExercises,
  });

  final String workoutTitle;
  final String targetMuscles;
  final int totalDurationSeconds;
  final int totalSetsCompleted;
  final int totalSetsPlanned;
  final double totalVolumeKg;
  final List<String> completedExercises;
}
