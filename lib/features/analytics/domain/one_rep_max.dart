/// 1RM (One-Rep Maximum) calculation formulas and training percentages.
library;

/// Supported 1RM estimation formulas.
enum OneRepMaxFormula {
  epley,
  brzycki,
  lander,
  average;

  String get displayName => switch (this) {
    OneRepMaxFormula.epley => 'Epley',
    OneRepMaxFormula.brzycki => 'Brzycki',
    OneRepMaxFormula.lander => 'Lander',
    OneRepMaxFormula.average => 'Average (Hybrid)',
  };

  String get formulaDescription => switch (this) {
    OneRepMaxFormula.epley => 'Weight × (1 + Reps / 30)',
    OneRepMaxFormula.brzycki => 'Weight × (36 / (37 - Reps))',
    OneRepMaxFormula.lander => '(100 × Weight) / (101.3 - 2.67123 × Reps)',
    OneRepMaxFormula.average => 'Mean of Epley & Brzycki',
  };
}

/// A target percentage of 1RM with estimated rep capacity.
class TrainingPercentage {
  const TrainingPercentage({
    required this.percentage,
    required this.weightKg,
    required this.estimatedReps,
  });

  final int percentage; // e.g. 95, 90, 85, etc.
  final double weightKg;
  final String estimatedReps;
}

/// Comprehensive 1RM estimation result across formulas.
class OneRepMaxEstimate {
  const OneRepMaxEstimate({
    required this.inputWeightKg,
    required this.inputReps,
    required this.epleyKg,
    required this.brzyckiKg,
    required this.landerKg,
    required this.averageKg,
    required this.selectedFormula,
    required this.selected1RmKg,
    required this.trainingPercentages,
  });

  final double inputWeightKg;
  final int inputReps;
  final double epleyKg;
  final double brzyckiKg;
  final double landerKg;
  final double averageKg;
  final OneRepMaxFormula selectedFormula;
  final double selected1RmKg;
  final List<TrainingPercentage> trainingPercentages;
}

/// Calculates 1RM using the Epley formula:
/// \[ 1\text{RM} = \text{weight} \times \left(1 + \frac{\text{reps}}{30}\right) \]
double calculateEpley1RM(double weight, int reps) {
  if (weight <= 0 || reps <= 0) return 0.0;
  if (reps == 1) return weight;
  return weight * (1.0 + (reps / 30.0));
}

/// Calculates 1RM using the Brzycki formula:
/// \[ 1\text{RM} = \text{weight} \times \left(\frac{36}{37 - \text{reps}}\right) \]
/// Guarded against division by zero or negative values when reps >= 37.
double calculateBrzycki1RM(double weight, int reps) {
  if (weight <= 0 || reps <= 0) return 0.0;
  if (reps == 1) return weight;
  if (reps >= 37) {
    // Beyond 36 reps, Brzycki formula denominator is <= 0; fall back to Epley
    return calculateEpley1RM(weight, reps);
  }
  return weight * (36.0 / (37.0 - reps));
}

/// Calculates 1RM using the Lander formula:
/// \[ 1\text{RM} = \frac{100 \times \text{weight}}{101.3 - 2.67123 \times \text{reps}} \]
double calculateLander1RM(double weight, int reps) {
  if (weight <= 0 || reps <= 0) return 0.0;
  if (reps == 1) return weight;
  final denominator = 101.3 - (2.67123 * reps);
  if (denominator <= 0) {
    return calculateEpley1RM(weight, reps);
  }
  return (100.0 * weight) / denominator;
}

/// Calculates 1RM based on the specified [formula].
double calculate1RM(
  double weight,
  int reps, [
  OneRepMaxFormula formula = OneRepMaxFormula.epley,
]) {
  return switch (formula) {
    OneRepMaxFormula.epley => calculateEpley1RM(weight, reps),
    OneRepMaxFormula.brzycki => calculateBrzycki1RM(weight, reps),
    OneRepMaxFormula.lander => calculateLander1RM(weight, reps),
    OneRepMaxFormula.average =>
      (calculateEpley1RM(weight, reps) + calculateBrzycki1RM(weight, reps)) /
          2.0,
  };
}

/// Standard training percentage breakdown based on a known 1RM.
List<TrainingPercentage> calculateTrainingPercentages(double oneRepMax) {
  if (oneRepMax <= 0) return const [];

  const percentageMap = <int, String>{
    100: '1 rep',
    95: '2 reps',
    90: '3–4 reps',
    85: '5–6 reps',
    80: '7–8 reps',
    75: '9–10 reps',
    70: '11–12 reps',
    65: '13–15 reps',
    60: '16–20 reps',
  };

  return percentageMap.entries.map((entry) {
    final pct = entry.key;
    final weight = (oneRepMax * (pct / 100.0) * 2).round() / 2.0; // round to nearest 0.5 kg
    return TrainingPercentage(
      percentage: pct,
      weightKg: weight,
      estimatedReps: entry.value,
    );
  }).toList();
}

/// Calculates comprehensive 1RM estimates across all formulas and builds
/// the training percentage table.
OneRepMaxEstimate calculateOneRepMaxEstimate({
  required double weight,
  required int reps,
  OneRepMaxFormula formula = OneRepMaxFormula.epley,
}) {
  final epley = calculateEpley1RM(weight, reps);
  final brzycki = calculateBrzycki1RM(weight, reps);
  final lander = calculateLander1RM(weight, reps);
  final average = (epley + brzycki) / 2.0;

  final selected1Rm = switch (formula) {
    OneRepMaxFormula.epley => epley,
    OneRepMaxFormula.brzycki => brzycki,
    OneRepMaxFormula.lander => lander,
    OneRepMaxFormula.average => average,
  };

  final trainingPercentages = calculateTrainingPercentages(selected1Rm);

  return OneRepMaxEstimate(
    inputWeightKg: weight,
    inputReps: reps,
    epleyKg: (epley * 10).round() / 10.0,
    brzyckiKg: (brzycki * 10).round() / 10.0,
    landerKg: (lander * 10).round() / 10.0,
    averageKg: (average * 10).round() / 10.0,
    selectedFormula: formula,
    selected1RmKg: (selected1Rm * 10).round() / 10.0,
    trainingPercentages: trainingPercentages,
  );
}

