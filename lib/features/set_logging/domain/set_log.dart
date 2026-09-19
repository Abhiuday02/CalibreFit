// Domain model for SetLog.

/// Represents an individual set log recording both planned and actual performance.
///
/// Requirement: "Never replace planned data with actual data. Store both."
class SetLog {
  const SetLog({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.plannedWeight,
    required this.plannedReps,
    required this.actualWeight,
    required this.actualReps,
    this.rir,
    this.rpe,
    this.restSeconds,
    this.formScore,
    this.notes,
    this.isCompleted = true,
    required this.timestamp,
  });

  final String id;
  final String sessionId;
  final String exerciseId;
  final String exerciseName;
  final int setNumber;

  // Planned values (Never overwritten)
  final double plannedWeight;
  final int plannedReps;

  // Actual recorded values
  final double actualWeight;
  final int actualReps;

  // Effort & Execution metrics
  final int? rir; // Reps In Reserve (e.g. 0, 1, 2, 3+)
  final double? rpe; // Rate of Perceived Exertion (e.g. 6.5 - 10.0)
  final int? restSeconds;
  final double? formScore; // 0.0 - 100.0 or 0.0 - 1.0
  final String? notes;

  final bool isCompleted;
  final DateTime timestamp;

  /// Total volume lifted for this set (actual_weight * actual_reps).
  double get volume => actualWeight * actualReps;

  /// Planned volume target (planned_weight * planned_reps).
  double get plannedVolume => plannedWeight * plannedReps;

  /// Difference between actual reps and planned reps.
  int get repsDiff => actualReps - plannedReps;

  /// Difference between actual weight and planned weight in kg.
  double get weightDiff => actualWeight - plannedWeight;

  SetLog copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    String? exerciseName,
    int? setNumber,
    double? plannedWeight,
    int? plannedReps,
    double? actualWeight,
    int? actualReps,
    int? rir,
    double? rpe,
    int? restSeconds,
    double? formScore,
    String? notes,
    bool? isCompleted,
    DateTime? timestamp,
  }) {
    return SetLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      plannedWeight: plannedWeight ?? this.plannedWeight,
      plannedReps: plannedReps ?? this.plannedReps,
      actualWeight: actualWeight ?? this.actualWeight,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'session_id': sessionId,
    'exercise_id': exerciseId,
    'exercise_name': exerciseName,
    'set_number': setNumber,
    'planned_weight': plannedWeight,
    'planned_reps': plannedReps,
    'actual_weight': actualWeight,
    'actual_reps': actualReps,
    'rir': rir,
    'rpe': rpe,
    'rest_seconds': restSeconds,
    'form_score': formScore,
    'notes': notes,
    'is_completed': isCompleted,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SetLog.fromJson(Map<String, dynamic> json) => SetLog(
    id: json['id'] as String,
    sessionId: json['session_id'] as String,
    exerciseId: json['exercise_id'] as String,
    exerciseName: json['exercise_name'] as String,
    setNumber: json['set_number'] as int,
    plannedWeight: (json['planned_weight'] as num).toDouble(),
    plannedReps: json['planned_reps'] as int,
    actualWeight: (json['actual_weight'] as num).toDouble(),
    actualReps: json['actual_reps'] as int,
    rir: json['rir'] as int?,
    rpe: (json['rpe'] as num?)?.toDouble(),
    restSeconds: json['rest_seconds'] as int?,
    formScore: (json['form_score'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
    isCompleted: json['is_completed'] as bool? ?? true,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  @override
  String toString() =>
      'SetLog(set: $setNumber, planned: ${plannedWeight}kg x $plannedReps, actual: ${actualWeight}kg x $actualReps, RIR: $rir, RPE: $rpe)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetLog && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
