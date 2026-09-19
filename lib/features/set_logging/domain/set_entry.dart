// Domain model for Set Logging.

/// Represents a logged set with both planned and recorded performance.
class SetEntry {
  const SetEntry({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.plannedWeightKg,
    required this.plannedReps,
    this.actualWeightKg,
    this.actualReps,
    this.rir,
    this.rpe,
    this.restSeconds,
    this.formScore,
    this.notes,
    this.isCompleted = false,
    this.timestamp,
  });

  final String id;
  final String exerciseId;
  final int setNumber;
  final double plannedWeightKg;
  final int plannedReps;
  final double? actualWeightKg;
  final int? actualReps;
  final int? rir;
  final double? rpe;
  final int? restSeconds;
  final double? formScore;
  final String? notes;
  final bool isCompleted;
  final DateTime? timestamp;

  SetEntry copyWith({
    String? id,
    String? exerciseId,
    int? setNumber,
    double? plannedWeightKg,
    int plannedReps = 0,
    double? actualWeightKg,
    int? actualReps,
    int? rir,
    double? rpe,
    int? restSeconds,
    double? formScore,
    String? notes,
    bool? isCompleted,
    DateTime? timestamp,
  }) {
    return SetEntry(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      plannedReps: plannedReps > 0 ? plannedReps : this.plannedReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      actualReps: actualReps ?? this.actualReps,
      rir: rir ?? this.rir,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
      formScore: formScore ?? this.formScore,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
