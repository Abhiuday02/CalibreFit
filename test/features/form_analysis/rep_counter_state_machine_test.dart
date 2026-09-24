import 'package:calibrefit/features/form_analysis/domain/rep_counter_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepCounterStateMachine', () {
    test('Counts a full valid squat rep cycle', () {
      final sm = RepCounterStateMachine(
        startThreshold: 165.0,
        inflectionThreshold: 95.0,
        completionThreshold: 160.0,
        isDescendingMovement: true,
      );

      expect(sm.reps, 0);
      expect(sm.phase, MovementPhase.start);

      // 1. Standing lockout
      sm.processAngle(170.0);
      expect(sm.phase, MovementPhase.start);

      // 2. Initiate descent
      sm.processAngle(130.0);
      expect(sm.phase, MovementPhase.eccentric);

      // 3. Reach bottom depth (inflection)
      sm.processAngle(88.0);
      expect(sm.phase, MovementPhase.inflection);

      // 4. Begin ascent
      sm.processAngle(120.0);
      expect(sm.phase, MovementPhase.concentric);

      // 5. Complete lockout
      final repCounted = sm.processAngle(165.0);
      expect(repCounted, isTrue);
      expect(sm.reps, 1);
      expect(sm.phase, MovementPhase.completed);
    });

    test('Does NOT count partial rep that fails to reach inflection depth', () {
      final sm = RepCounterStateMachine(
        startThreshold: 165.0,
        inflectionThreshold: 95.0,
        completionThreshold: 160.0,
        isDescendingMovement: true,
      );

      // Standing
      sm.processAngle(170.0);

      // Shallow descent to only 110° (target <= 95°)
      sm.processAngle(110.0);
      expect(sm.phase, MovementPhase.eccentric);

      // Cheated ascent back to top without hitting bottom
      final repCounted = sm.processAngle(165.0);
      expect(repCounted, isFalse);
      expect(sm.reps, 0); // Rep must NOT be counted
    });

    test('Counts multiple consecutive reps accurately', () {
      final sm = RepCounterStateMachine(
        startThreshold: 165.0,
        inflectionThreshold: 95.0,
        completionThreshold: 160.0,
        isDescendingMovement: true,
      );

      for (int i = 0; i < 3; i++) {
        sm.processAngle(170.0);
        sm.processAngle(130.0);
        sm.processAngle(85.0);
        sm.processAngle(120.0);
        sm.processAngle(165.0);
      }

      expect(sm.reps, 3);
    });

    test('Counts ascending movement (bicep curl) rep cycle', () {
      final sm = RepCounterStateMachine(
        startThreshold: 150.0,
        inflectionThreshold: 55.0,
        completionThreshold: 145.0,
        isDescendingMovement: false, // Curl: angle drops during concentric
      );

      // Arm extended at bottom
      sm.processAngle(160.0);
      expect(sm.phase, MovementPhase.start);

      // Concentric curling upward
      sm.processAngle(100.0);
      expect(sm.phase, MovementPhase.concentric);

      // Peak bicep contraction (inflection)
      sm.processAngle(50.0);
      expect(sm.phase, MovementPhase.inflection);

      // Eccentric lowering downward
      sm.processAngle(100.0);
      expect(sm.phase, MovementPhase.eccentric);

      // Returned to full extension
      final repFinished = sm.processAngle(150.0);
      expect(repFinished, isTrue);
      expect(sm.reps, 1);
    });

    test('Reset clears reps, phase, and angles', () {
      final sm = RepCounterStateMachine(
        startThreshold: 165.0,
        inflectionThreshold: 95.0,
        completionThreshold: 160.0,
      );

      sm.processAngle(85.0);
      expect(sm.minAngleAchieved, 85.0);

      sm.reset();
      expect(sm.reps, 0);
      expect(sm.phase, MovementPhase.start);
      expect(sm.minAngleAchieved, 180.0);
    });
  });
}
