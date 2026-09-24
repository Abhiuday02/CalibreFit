import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';
import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MacroCalculator', () {
    test(
      'calculateBmr applies Mifflin-St Jeor equation correctly for male',
      () {
        // 80kg, 180cm, 30 years old, Male:
        // Base = 10(80) + 6.25(180) - 5(30) = 800 + 1125 - 150 = 1775
        // Male = 1775 + 5 = 1780
        final bmr = MacroCalculator.calculateBmr(
          weightKg: 80,
          heightCm: 180,
          age: 30,
          sex: BiologicalSex.male,
        );

        expect(bmr, equals(1780.0));
      },
    );

    test(
      'calculateBmr applies Mifflin-St Jeor equation correctly for female',
      () {
        // 60kg, 165cm, 28 years old, Female:
        // Base = 10(60) + 6.25(165) - 5(28) = 600 + 1031.25 - 140 = 1491.25
        // Female = 1491.25 - 161 = 1330.25
        final bmr = MacroCalculator.calculateBmr(
          weightKg: 60,
          heightCm: 165,
          age: 28,
          sex: BiologicalSex.female,
        );

        expect(bmr, equals(1330.25));
      },
    );

    test('calculateTdee scales BMR based on training frequency', () {
      const bmr = 1800.0;

      expect(
        MacroCalculator.calculateTdee(bmr: bmr, trainingDaysPerWeek: 1),
        closeTo(1800.0 * 1.2, 0.01),
      );
      expect(
        MacroCalculator.calculateTdee(bmr: bmr, trainingDaysPerWeek: 2),
        closeTo(1800.0 * 1.375, 0.01),
      );
      expect(
        MacroCalculator.calculateTdee(bmr: bmr, trainingDaysPerWeek: 4),
        closeTo(1800.0 * 1.55, 0.01),
      );
      expect(
        MacroCalculator.calculateTdee(bmr: bmr, trainingDaysPerWeek: 5),
        closeTo(1800.0 * 1.725, 0.01),
      );
      expect(
        MacroCalculator.calculateTdee(bmr: bmr, trainingDaysPerWeek: 7),
        closeTo(1800.0 * 1.9, 0.01),
      );
    });

    test('calculateCaloricTarget adjusts for fitness goals', () {
      const tdee = 2500.0;

      // Fat loss: -500 kcal deficit
      expect(
        MacroCalculator.calculateCaloricTarget(
          tdee: tdee,
          goal: FitnessGoal.loseWeight,
        ),
        equals(2000),
      );

      // Hypertrophy: +300 kcal surplus
      expect(
        MacroCalculator.calculateCaloricTarget(
          tdee: tdee,
          goal: FitnessGoal.buildMuscle,
        ),
        equals(2800),
      );

      // Maintenance
      expect(
        MacroCalculator.calculateCaloricTarget(
          tdee: tdee,
          goal: FitnessGoal.maintainFitness,
        ),
        equals(2500),
      );
    });

    test('calculateFromProfile produces scientific macro distribution', () {
      const profile = OnboardingProfile(
        weightKg: 75.0,
        heightCm: 178.0,
        age: 26,
        biologicalSex: BiologicalSex.male,
        trainingDaysPerWeek: 4,
        fitnessGoal: FitnessGoal.loseWeight,
      );

      final target = MacroCalculator.calculateFromProfile(profile);

      // Weight = 75kg
      // Protein = 75 * 2.0 = 150g
      expect(target.proteinG, equals(150));

      // Water = 75 * 35 = 2625ml
      expect(target.waterMl, equals(2625));

      // Calories must be within valid range
      expect(target.calories, greaterThan(1500));
      expect(target.calories, lessThan(3500));

      // Fat should be ~25% of target calories / 9
      final expectedFat = ((target.calories * 0.25) / 9).round();
      expect(target.fatG, equals(expectedFat));

      // Carbs should make up the remainder
      final proteinKcal = target.proteinG * 4;
      final fatKcal = target.fatG * 9;
      final remainingKcal = target.calories - proteinKcal - fatKcal;
      final expectedCarbs = (remainingKcal / 4).round();
      expect(target.carbsG, equals(expectedCarbs));
    });
  });
}
