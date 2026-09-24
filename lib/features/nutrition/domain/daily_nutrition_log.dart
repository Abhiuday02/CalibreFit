import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';

/// Complete nutrition snapshot and meal log for a specific calendar day.
class DailyNutritionLog {
  const DailyNutritionLog({
    required this.date,
    required this.target,
    this.loggedEntries = const [],
    this.waterIntakeMl = 0,
  });

  final DateTime date;
  final MacroTarget target;
  final List<LoggedFoodEntry> loggedEntries;
  final int waterIntakeMl;

  // ── Consumed Totals ────────────────────────────────────────────────────────

  int get consumedCalories =>
      loggedEntries.fold(0, (sum, entry) => sum + entry.totalCalories);

  double get consumedProteinG {
    final val = loggedEntries.fold(
      0.0,
      (sum, entry) => sum + entry.totalProteinG,
    );
    return (val * 10).round() / 10.0;
  }

  double get consumedCarbsG {
    final val = loggedEntries.fold(
      0.0,
      (sum, entry) => sum + entry.totalCarbsG,
    );
    return (val * 10).round() / 10.0;
  }

  double get consumedFatG {
    final val = loggedEntries.fold(0.0, (sum, entry) => sum + entry.totalFatG);
    return (val * 10).round() / 10.0;
  }

  // ── Remaining & Progress ───────────────────────────────────────────────────

  int get remainingCalories => target.calories - consumedCalories;

  double get proteinProgress => target.proteinG > 0
      ? (consumedProteinG / target.proteinG).clamp(0.0, 1.5)
      : 0.0;

  double get carbsProgress => target.carbsG > 0
      ? (consumedCarbsG / target.carbsG).clamp(0.0, 1.5)
      : 0.0;

  double get fatProgress =>
      target.fatG > 0 ? (consumedFatG / target.fatG).clamp(0.0, 1.5) : 0.0;

  double get waterProgress => target.waterMl > 0
      ? (waterIntakeMl / target.waterMl).clamp(0.0, 2.0)
      : 0.0;

  // ── Per-Meal Helpers ───────────────────────────────────────────────────────

  List<LoggedFoodEntry> entriesForMeal(MealType type) =>
      loggedEntries.where((e) => e.mealType == type).toList();

  int caloriesForMeal(MealType type) =>
      entriesForMeal(type).fold(0, (sum, e) => sum + e.totalCalories);

  double proteinForMeal(MealType type) =>
      entriesForMeal(type).fold(0.0, (sum, e) => sum + e.totalProteinG);

  DailyNutritionLog copyWith({
    DateTime? date,
    MacroTarget? target,
    List<LoggedFoodEntry>? loggedEntries,
    int? waterIntakeMl,
  }) {
    return DailyNutritionLog(
      date: date ?? this.date,
      target: target ?? this.target,
      loggedEntries: loggedEntries ?? this.loggedEntries,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
    );
  }
}
