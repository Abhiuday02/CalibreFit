import 'dart:async';

import 'package:calibrefit/features/history/domain/workout_history_record.dart';
import 'package:calibrefit/features/history/presentation/history_providers.dart';
import 'package:calibrefit/features/home/domain/daily_workout.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';
import 'package:calibrefit/features/set_logging/presentation/set_log_providers.dart';
import 'package:calibrefit/features/workouts/domain/workout_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Active Workout Notifier
// ---------------------------------------------------------------------------

class ActiveWorkoutNotifier extends Notifier<WorkoutSession?> {
  Timer? _sessionTimer;

  @override
  WorkoutSession? build() {
    ref.onDispose(() {
      _sessionTimer?.cancel();
    });
    return null;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle Actions
  // ---------------------------------------------------------------------------

  /// Starts a new active workout session from a [DailyWorkout] plan.
  void startWorkout(DailyWorkout workout) {
    _sessionTimer?.cancel();

    final activeExercises = workout.exercises.map((ex) {
      final targetReps = _parseTargetReps(ex.repRange);

      final sets = List.generate(
        ex.sets,
        (index) => ActiveExerciseSet(
          setNumber: index + 1,
          plannedReps: targetReps,
          plannedRepsDisplay: ex.repRange,
          plannedWeightKg: ex.suggestedLoadKg,
          actualReps: targetReps,
          actualWeightKg: ex.suggestedLoadKg,
          rir: 2, // sensible default
          rpe: 8.0,
        ),
      );

      return ActiveWorkoutExercise(
        exerciseId: ex.id,
        name: ex.name,
        sets: sets,
        restDurationSeconds: 90,
      );
    }).toList();

    state = WorkoutSession(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      workoutPlanTitle: workout.title,
      targetMuscles: workout.targetMuscles,
      startedAt: DateTime.now(),
      status: WorkoutSessionStatus.inProgress,
      exercises: activeExercises,
      currentExerciseIndex: 0,
      elapsedSeconds: 0,
      isResting: false,
      restSecondsRemaining: 0,
    );

    // Start 1-second ticker for elapsed workout duration and rest countdown
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
  }

  void _onTick() {
    final current = state;
    if (current == null || current.status != WorkoutSessionStatus.inProgress) {
      return;
    }

    var newRestSeconds = current.restSecondsRemaining;
    var newIsResting = current.isResting;

    if (current.isResting) {
      if (newRestSeconds > 1) {
        newRestSeconds -= 1;
      } else {
        newRestSeconds = 0;
        newIsResting = false;
      }
    }

    state = current.copyWith(
      elapsedSeconds: current.elapsedSeconds + 1,
      restSecondsRemaining: newRestSeconds,
      isResting: newIsResting,
    );
  }

  // ---------------------------------------------------------------------------
  // Set Logging & Completion
  // ---------------------------------------------------------------------------

  /// Updates actual recorded parameters for a set before or after completion.
  void updateSetActuals({
    required int exerciseIndex,
    required int setIndex,
    double? actualWeight,
    int? actualReps,
    int? rir,
    double? rpe,
    String? notes,
  }) {
    final session = state;
    if (session == null) return;

    final exercise = session.exercises[exerciseIndex];
    final targetSet = exercise.sets[setIndex];

    final updatedSet = targetSet.copyWith(
      actualWeightKg: actualWeight ?? targetSet.actualWeightKg,
      actualReps: actualReps ?? targetSet.actualReps,
      rir: rir ?? targetSet.rir,
      rpe: rpe ?? targetSet.rpe,
      notes: notes ?? targetSet.notes,
    );

    final updatedSets = List<ActiveExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedExercises = List<ActiveWorkoutExercise>.from(
      session.exercises,
    );
    updatedExercises[exerciseIndex] = updatedExercise;

    state = session.copyWith(exercises: updatedExercises);

    // If set was already completed, update the persisted SetLog
    if (updatedSet.isCompleted) {
      _persistSetLog(session.id, exercise, updatedSet);
    }
  }

  /// Toggles completion of a set, persists the [SetLog], and triggers the rest timer.
  void toggleSet(int exerciseIndex, int setIndex) {
    final session = state;
    if (session == null) return;

    final exercise = session.exercises[exerciseIndex];
    final targetSet = exercise.sets[setIndex];
    final wasCompleted = targetSet.isCompleted;
    final nowCompleted = !wasCompleted;

    final updatedSet = targetSet.copyWith(
      isCompleted: nowCompleted,
      completedAt: nowCompleted ? DateTime.now() : null,
    );

    final updatedSets = List<ActiveExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedExercises = List<ActiveWorkoutExercise>.from(
      session.exercises,
    );
    updatedExercises[exerciseIndex] = updatedExercise;

    // Start rest timer if newly completed, or cancel if uncompleted
    final shouldRest = nowCompleted;
    final restSeconds = shouldRest ? exercise.restDurationSeconds : 0;

    state = session.copyWith(
      exercises: updatedExercises,
      isResting: shouldRest,
      restSecondsRemaining: restSeconds,
    );

    final setLogId = 'set-log-${session.id}-$exerciseIndex-$setIndex';

    if (nowCompleted) {
      _persistSetLog(session.id, exercise, updatedSet);
    } else {
      ref.read(setLogRepositoryProvider).deleteSetLog(setLogId);
    }
  }

  void _persistSetLog(
    String sessionId,
    ActiveWorkoutExercise exercise,
    ActiveExerciseSet set,
  ) {
    final setLog = SetLog(
      id: 'set-log-$sessionId-${exercise.exerciseId}-${set.setNumber}',
      sessionId: sessionId,
      exerciseId: exercise.exerciseId,
      exerciseName: exercise.name,
      setNumber: set.setNumber,
      plannedWeight: set.plannedWeightKg,
      plannedReps: set.plannedReps,
      actualWeight: set.actualWeightKg,
      actualReps: set.actualReps,
      rir: set.rir,
      rpe: set.rpe,
      restSeconds: exercise.restDurationSeconds,
      formScore: set.formScore,
      notes: set.notes,
      isCompleted: true,
      timestamp: set.completedAt ?? DateTime.now(),
    );

    ref.read(setLogRepositoryProvider).saveSetLog(setLog);
  }

  // ---------------------------------------------------------------------------
  // Rest Timer Controls
  // ---------------------------------------------------------------------------

  void skipRest() {
    final session = state;
    if (session == null) return;

    state = session.copyWith(isResting: false, restSecondsRemaining: 0);
  }

  void addRestSeconds(int seconds) {
    final session = state;
    if (session == null) return;

    state = session.copyWith(
      isResting: true,
      restSecondsRemaining: session.restSecondsRemaining + seconds,
    );
  }

  // ---------------------------------------------------------------------------
  // Exercise Navigation
  // ---------------------------------------------------------------------------

  void nextExercise() {
    final session = state;
    if (session == null || session.isLastExercise) return;

    state = session.copyWith(
      currentExerciseIndex: session.currentExerciseIndex + 1,
    );
  }

  void previousExercise() {
    final session = state;
    if (session == null || session.isFirstExercise) return;

    state = session.copyWith(
      currentExerciseIndex: session.currentExerciseIndex - 1,
    );
  }

  void goToExercise(int index) {
    final session = state;
    if (session == null || index < 0 || index >= session.exercises.length) {
      return;
    }

    state = session.copyWith(currentExerciseIndex: index);
  }

  // ---------------------------------------------------------------------------
  // Finish or Discard
  // ---------------------------------------------------------------------------

  /// Finishes the session, stops timers, and stores the summary data.
  WorkoutSummaryData? finishWorkout() {
    final session = state;
    if (session == null) return null;

    _sessionTimer?.cancel();
    _sessionTimer = null;

    var totalVolume = 0.0;
    var totalReps = 0;
    final completedExercises = <String>[];
    final exerciseSummaries = <ExerciseHistorySummary>[];

    for (final ex in session.exercises) {
      final completedSets = ex.sets.where((s) => s.isCompleted).toList();
      if (completedSets.isNotEmpty) {
        completedExercises.add(ex.name);

        var exVolume = 0.0;
        var bestWeight = 0.0;
        var bestReps = 0;
        final loggedSets = <SetLog>[];

        for (final s in completedSets) {
          totalVolume += s.actualVolume;
          totalReps += s.actualReps;
          exVolume += s.actualVolume;

          if (s.actualWeightKg > bestWeight ||
              (s.actualWeightKg == bestWeight && s.actualReps > bestReps)) {
            bestWeight = s.actualWeightKg;
            bestReps = s.actualReps;
          }

          loggedSets.add(
            SetLog(
              id: 'set-log-${session.id}-${ex.exerciseId}-${s.setNumber}',
              sessionId: session.id,
              exerciseId: ex.exerciseId,
              exerciseName: ex.name,
              setNumber: s.setNumber,
              plannedWeight: s.plannedWeightKg,
              plannedReps: s.plannedReps,
              actualWeight: s.actualWeightKg,
              actualReps: s.actualReps,
              rir: s.rir,
              rpe: s.rpe,
              restSeconds: ex.restDurationSeconds,
              notes: s.notes,
              timestamp: s.completedAt ?? DateTime.now(),
            ),
          );
        }

        exerciseSummaries.add(
          ExerciseHistorySummary(
            exerciseId: ex.exerciseId,
            exerciseName: ex.name,
            setsCount: completedSets.length,
            bestSetWeightKg: bestWeight,
            bestSetReps: bestReps,
            totalVolumeKg: exVolume,
            sets: loggedSets,
          ),
        );
      }
    }

    final summary = WorkoutSummaryData(
      workoutTitle: session.workoutPlanTitle,
      targetMuscles: session.targetMuscles,
      totalDurationSeconds: session.elapsedSeconds,
      totalSetsCompleted: session.completedSetsCount,
      totalSetsPlanned: session.totalSetsCount,
      totalVolumeKg: totalVolume,
      completedExercises: completedExercises,
    );

    // Save history record
    final historyRecord = WorkoutHistoryRecord(
      id: session.id,
      workoutTitle: session.workoutPlanTitle,
      targetMuscles: session.targetMuscles,
      date: session.startedAt,
      durationSeconds: session.elapsedSeconds,
      totalVolumeKg: totalVolume,
      totalReps: totalReps,
      totalSets: session.completedSetsCount,
      exerciseSummaries: exerciseSummaries,
    );
    ref.read(historyRepositoryProvider).recordCompletedWorkout(historyRecord);
    ref.invalidate(workoutHistoryListProvider);

    // Save summary in provider before clearing session
    ref.read(lastWorkoutSummaryProvider.notifier).setSummary(summary);

    state = null;
    return summary;
  }

  void discardWorkout() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    state = null;
  }

  int _parseTargetReps(String repRange) {
    try {
      if (repRange.contains('–') || repRange.contains('-')) {
        final parts = repRange.replaceAll('–', '-').split('-');
        if (parts.length == 2) {
          return int.tryParse(parts[1].trim()) ?? 10;
        }
      }
      return int.tryParse(repRange.trim()) ?? 10;
    } catch (_) {
      return 10;
    }
  }
}

final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, WorkoutSession?>(
      ActiveWorkoutNotifier.new,
    );

/// Holds the summary data of the most recently finished workout session.
class LastWorkoutSummaryNotifier extends Notifier<WorkoutSummaryData?> {
  @override
  WorkoutSummaryData? build() => null;

  void setSummary(WorkoutSummaryData? summary) => state = summary;
  void clear() => state = null;
}

final lastWorkoutSummaryProvider =
    NotifierProvider<LastWorkoutSummaryNotifier, WorkoutSummaryData?>(
      LastWorkoutSummaryNotifier.new,
    );
