import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';

/// Scientific targets for daily calorie, macronutrient, and water intake.
class MacroTarget {
  const MacroTarget({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.waterMl,
    required this.bmr,
    required this.tdee,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int waterMl;
  final int bmr;
  final int tdee;

  /// Default baseline target for a standard adult (2000 kcal, 150g P, 220g C, 55g F, 2500ml H2O).
  static const defaultTarget = MacroTarget(
    calories: 2000,
    proteinG: 150,
    carbsG: 220,
    fatG: 55,
    waterMl: 2500,
    bmr: 1650,
    tdee: 2200,
  );
}

/// Pure algorithmic calculations for BMR, TDEE, and macronutrient targets.
class MacroCalculator {
  const MacroCalculator();

  /// Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation.
  ///
  /// Men:   \[ 10 \times W + 6.25 \times H - 5 \times A + 5 \]
  /// Women: \[ 10 \times W + 6.25 \times H - 5 \times A - 161 \]
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    BiologicalSex? sex,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 1600.0;

    final base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);

    return switch (sex) {
      BiologicalSex.male => base + 5.0,
      BiologicalSex.female => base - 161.0,
      _ => base - 78.0, // Neutral average
    };
  }

  /// Calculates Total Daily Energy Expenditure (TDEE) based on weekly training frequency.
  static double calculateTdee({
    required double bmr,
    required int trainingDaysPerWeek,
  }) {
    final multiplier = switch (trainingDaysPerWeek) {
      <= 1 => 1.2, // Sedentary
      2 => 1.375, // Light activity
      3 || 4 => 1.55, // Moderate activity
      5 || 6 => 1.725, // Very active
      _ => 1.9, // Extremely active / athlete
    };

    return bmr * multiplier;
  }

  /// Calculates target calories based on high-level fitness goal.
  static int calculateCaloricTarget({required double tdee, FitnessGoal? goal}) {
    final adjusted = switch (goal) {
      FitnessGoal.loseWeight =>
        tdee - 500.0, // Healthy 0.5kg/week fat loss deficit
      FitnessGoal.buildMuscle => tdee + 300.0, // Lean hypertrophy surplus
      _ => tdee, // Maintenance
    };

    return adjusted.round().clamp(1200, 5000);
  }

  /// Calculates comprehensive macronutrient and hydration targets from an [OnboardingProfile].
  static MacroTarget calculateFromProfile(OnboardingProfile profile) {
    final weight = profile.weightKg ?? 70.0;
    final height = profile.heightCm ?? 175.0;
    final age = profile.age ?? 25;
    final sex = profile.biologicalSex ?? BiologicalSex.male;
    final days = profile.trainingDaysPerWeek ?? 4;
    final goal = profile.fitnessGoal ?? FitnessGoal.maintainFitness;

    final bmr = calculateBmr(
      weightKg: weight,
      heightCm: height,
      age: age,
      sex: sex,
    );

    final tdee = calculateTdee(bmr: bmr, trainingDaysPerWeek: days);

    final targetCalories = calculateCaloricTarget(tdee: tdee, goal: goal);

    // 1. Protein: 2.0g per kg of bodyweight (4 kcal/g)
    final proteinG = (weight * 2.0).round().clamp(80, 300);
    final proteinKcal = proteinG * 4;

    // 2. Fat: 25% of total caloric intake (9 kcal/g)
    final fatKcal = targetCalories * 0.25;
    final fatG = (fatKcal / 9.0).round().clamp(30, 150);

    // 3. Carbohydrates: Remainder of calories (4 kcal/g)
    final remainingKcal = targetCalories - proteinKcal - (fatG * 9);
    final carbsG = (remainingKcal / 4.0).round().clamp(50, 600);

    // 4. Water: 35ml per kg body weight
    final waterMl = (weight * 35.0).round().clamp(2000, 5000);

    return MacroTarget(
      calories: targetCalories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      waterMl: waterMl,
      bmr: bmr.round(),
      tdee: tdee.round(),
    );
  }
}
