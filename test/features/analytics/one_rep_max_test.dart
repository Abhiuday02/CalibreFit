import 'package:calibrefit/features/analytics/domain/one_rep_max.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('1RM Mathematical Formulas', () {
    test('Epley formula calculates accurately', () {
      // 1 rep should equal load
      expect(calculateEpley1RM(100.0, 1), 100.0);

      // 100 kg for 10 reps: 100 * (1 + 10/30) = 133.333...
      final est10 = calculateEpley1RM(100.0, 10);
      expect(est10, closeTo(133.33, 0.01));

      // 60 kg for 5 reps: 60 * (1 + 5/30) = 70.0
      expect(calculateEpley1RM(60.0, 5), 70.0);

      // Zero or negative handling
      expect(calculateEpley1RM(0.0, 10), 0.0);
      expect(calculateEpley1RM(100.0, 0), 0.0);
      expect(calculateEpley1RM(-50.0, 5), 0.0);
      expect(calculateEpley1RM(50.0, -1), 0.0);
    });

    test('Brzycki formula calculates accurately', () {
      // 1 rep should equal load
      expect(calculateBrzycki1RM(100.0, 1), 100.0);

      // 100 kg for 10 reps: 100 * (36 / (37 - 10)) = 100 * (36 / 27) = 133.333...
      final est10 = calculateBrzycki1RM(100.0, 10);
      expect(est10, closeTo(133.33, 0.01));

      // 80 kg for 8 reps: 80 * (36 / 29) = 99.3103...
      final est8 = calculateBrzycki1RM(80.0, 8);
      expect(est8, closeTo(99.31, 0.01));

      // Guarded high reps (>= 37) falls back without NaN / Infinity
      final highRepEst = calculateBrzycki1RM(50.0, 40);
      expect(highRepEst.isFinite, isTrue);
      expect(highRepEst > 0, isTrue);

      // Zero handling
      expect(calculateBrzycki1RM(0.0, 10), 0.0);
      expect(calculateBrzycki1RM(100.0, 0), 0.0);
    });

    test('Lander formula calculates accurately', () {
      expect(calculateLander1RM(100.0, 1), 100.0);

      // 100 kg for 10 reps: (100 * 100) / (101.3 - 26.7123) = 10000 / 74.5877 = 134.07
      final est = calculateLander1RM(100.0, 10);
      expect(est, closeTo(134.07, 0.1));
    });

    test('calculate1RM dispatches to selected formula', () {
      const weight = 100.0;
      const reps = 6;

      final epley = calculate1RM(weight, reps, OneRepMaxFormula.epley);
      final brzycki = calculate1RM(weight, reps, OneRepMaxFormula.brzycki);
      final lander = calculate1RM(weight, reps, OneRepMaxFormula.lander);
      final avg = calculate1RM(weight, reps, OneRepMaxFormula.average);

      expect(epley, calculateEpley1RM(weight, reps));
      expect(brzycki, calculateBrzycki1RM(weight, reps));
      expect(lander, calculateLander1RM(weight, reps));
      expect(avg, closeTo((epley + brzycki) / 2.0, 0.01));
    });

    test('calculateTrainingPercentages generates expected table', () {
      const oneRepMax = 100.0;
      final percentages = calculateTrainingPercentages(oneRepMax);

      expect(percentages.length, 9);
      expect(percentages.first.percentage, 100);
      expect(percentages.first.weightKg, 100.0);
      expect(percentages.first.estimatedReps, '1 rep');

      final ninety = percentages.firstWhere((p) => p.percentage == 90);
      expect(ninety.weightKg, 90.0);
      expect(ninety.estimatedReps, '3–4 reps');

      final seventy = percentages.firstWhere((p) => p.percentage == 70);
      expect(seventy.weightKg, 70.0);

      // Empty for non-positive 1RM
      expect(calculateTrainingPercentages(0.0), isEmpty);
      expect(calculateTrainingPercentages(-20.0), isEmpty);
    });

    test('calculateOneRepMaxEstimate returns comprehensive model', () {
      final estimate = calculateOneRepMaxEstimate(
        weight: 100.0,
        reps: 10,
        formula: OneRepMaxFormula.epley,
      );

      expect(estimate.inputWeightKg, 100.0);
      expect(estimate.inputReps, 10);
      expect(estimate.selectedFormula, OneRepMaxFormula.epley);
      expect(estimate.selected1RmKg, 133.3);
      expect(estimate.epleyKg, 133.3);
      expect(estimate.brzyckiKg, 133.3);
      expect(estimate.averageKg, 133.3);
      expect(estimate.trainingPercentages.isNotEmpty, isTrue);
    });
  });
}

