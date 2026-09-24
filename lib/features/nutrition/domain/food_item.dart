/// Category of meal within a daily nutrition plan.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName => switch (this) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snacks',
  };
}

/// A food item in the nutrition database with per-serving macronutrient values.
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    this.brand,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0.0,
  });

  final String id;
  final String name;
  final String? brand;
  final double servingSize;
  final String servingUnit; // e.g. "g", "ml", "scoop", "egg", "slice"
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
}

/// An individual logged food entry within a specific meal.
class LoggedFoodEntry {
  const LoggedFoodEntry({
    required this.id,
    required this.foodItem,
    required this.numberOfServings,
    required this.mealType,
    required this.loggedAt,
  });

  final String id;
  final FoodItem foodItem;
  final double numberOfServings;
  final MealType mealType;
  final DateTime loggedAt;

  int get totalCalories => (foodItem.calories * numberOfServings).round();
  double get totalProteinG =>
      ((foodItem.proteinG * numberOfServings) * 10).round() / 10.0;
  double get totalCarbsG =>
      ((foodItem.carbsG * numberOfServings) * 10).round() / 10.0;
  double get totalFatG =>
      ((foodItem.fatG * numberOfServings) * 10).round() / 10.0;
}
