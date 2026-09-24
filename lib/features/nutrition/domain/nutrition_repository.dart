import 'package:calibrefit/features/nutrition/domain/daily_nutrition_log.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';

/// Abstract contract for nutrition tracking, food database search, and meal logging.
abstract class NutritionRepository {
  /// Retrieves the nutrition log and recorded meals for the specified [date].
  Future<DailyNutritionLog> getDailyNutritionLog(DateTime date);

  /// Retrieves the active macro target calculated for the user.
  Future<MacroTarget> getMacroTarget();

  /// Searches the food database by name or keyword.
  Future<List<FoodItem>> searchFoodDatabase(String query);

  /// Logs a food item and serving size under a specific meal for [date].
  Future<void> logFood({
    required DateTime date,
    required MealType mealType,
    required FoodItem food,
    required double servings,
  });

  /// Deletes a logged food entry by [entryId].
  Future<void> deleteFood({required DateTime date, required String entryId});

  /// Adds [amountMl] to the water intake log for [date].
  Future<void> logWater({required DateTime date, required int amountMl});
}
