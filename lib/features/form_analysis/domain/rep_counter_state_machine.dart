/// Biomechanical phases of an exercise repetition.
enum MovementPhase {
  start,
  eccentric, // Lowering / descent / stretching phase
  inflection, // Peak contraction / bottom inflection point
  concentric, // Lifting / ascent / pressing phase
  completed; // Returned to starting position, rep registered

  String get displayName => switch (this) {
    MovementPhase.start => 'Starting Position',
    MovementPhase.eccentric => 'Descent',
    MovementPhase.inflection => 'Inflection Point',
    MovementPhase.concentric => 'Ascent',
    MovementPhase.completed => 'Rep Completed',
  };
}

/// A finite state machine that tracks joint angles and accurately counts repetitions.
///
/// Prevents false positives by strictly verifying:
/// 1. Movement starts from a lockout/starting angle.
/// 2. Movement enters eccentric phase past a descent threshold.
/// 3. Peak contraction/bottom inflection angle is reached.
/// 4. Movement returns across the completion threshold.
class RepCounterStateMachine {
  RepCounterStateMachine({
    required this.startThreshold,
    required this.inflectionThreshold,
    required this.completionThreshold,
    this.isDescendingMovement = true,
  });

  /// Threshold angle indicating the exercise start/lockout position.
  final double startThreshold;

  /// Threshold angle that MUST be reached at peak contraction/bottom.
  final double inflectionThreshold;

  /// Threshold angle required to finish and count the rep.
  final double completionThreshold;

  /// True if angle decreases during eccentric (e.g. Squats, Push-ups: 170° -> 90°).
  /// False if angle increases during eccentric (e.g. Curls: 50° -> 150°).
  final bool isDescendingMovement;

  int _reps = 0;
  MovementPhase _phase = MovementPhase.start;
  double _minAngle = 180.0;
  double _maxAngle = 0.0;
  double _currentAngle = 180.0;

  int get reps => _reps;
  MovementPhase get phase => _phase;
  double get minAngleAchieved => _minAngle;
  double get maxAngleAchieved => _maxAngle;
  double get currentAngle => _currentAngle;

  /// Evaluates an updated joint [angle] and transitions the state machine.
  ///
  /// Returns true if a new repetition was completed on this update.
  bool processAngle(double angle) {
    _currentAngle = angle;
    if (angle < _minAngle) _minAngle = angle;
    if (angle > _maxAngle) _maxAngle = angle;

    bool repCompleted = false;

    if (isDescendingMovement) {
      switch (_phase) {
        case MovementPhase.start:
        case MovementPhase.completed:
          // Initiate descent when angle drops significantly below start threshold
          if (angle < startThreshold - 15.0) {
            _phase = MovementPhase.eccentric;
          }
          break;

        case MovementPhase.eccentric:
          // Reach bottom inflection threshold
          if (angle <= inflectionThreshold) {
            _phase = MovementPhase.inflection;
          }
          break;

        case MovementPhase.inflection:
          // Begin ascent
          if (angle > inflectionThreshold + 10.0) {
            _phase = MovementPhase.concentric;
          }
          break;

        case MovementPhase.concentric:
          // Return to top lockout
          if (angle >= completionThreshold) {
            _reps++;
            _phase = MovementPhase.completed;
            repCompleted = true;
            // Reset inflection tracking for next rep
            _minAngle = 180.0;
            _maxAngle = 0.0;
          }
          break;
      }
    } else {
      // For ascending movements (e.g. Bicep curls where angle drops on concentric)
      switch (_phase) {
        case MovementPhase.start:
        case MovementPhase.completed:
          if (angle < startThreshold - 15.0) {
            _phase = MovementPhase.concentric;
          }
          break;

        case MovementPhase.concentric:
          if (angle <= inflectionThreshold) {
            _phase = MovementPhase.inflection;
          }
          break;

        case MovementPhase.inflection:
          if (angle > inflectionThreshold + 15.0) {
            _phase = MovementPhase.eccentric;
          }
          break;

        case MovementPhase.eccentric:
          if (angle >= completionThreshold) {
            _reps++;
            _phase = MovementPhase.completed;
            repCompleted = true;
            _minAngle = 180.0;
            _maxAngle = 0.0;
          }
          break;
      }
    }

    return repCompleted;
  }

  /// Resets the counter and state machine to initial values.
  void reset() {
    _reps = 0;
    _phase = MovementPhase.start;
    _minAngle = 180.0;
    _maxAngle = 0.0;
    _currentAngle = 180.0;
  }
}
