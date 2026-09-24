import 'package:calibrefit/features/nutrition/domain/daily_nutrition_log.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';
import 'package:calibrefit/features/nutrition/domain/nutrition_repository.dart';

/// In-memory implementation of [NutritionRepository] with a curated food database.
class MockNutritionRepository implements NutritionRepository {
  MockNutritionRepository({MacroTarget? target})
    : _target = target ?? MacroTarget.defaultTarget {
    _initDatabase();
    _initSeedLog();
  }

  final MacroTarget _target;
  final List<FoodItem> _database = [];
  final Map<String, DailyNutritionLog> _logs = {};
  static const _delay = Duration(milliseconds: 150);

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  @override
  Future<MacroTarget> getMacroTarget() async {
    await Future.delayed(_delay);
    return _target;
  }

  @override
  Future<DailyNutritionLog> getDailyNutritionLog(DateTime date) async {
    await Future.delayed(_delay);
    final key = _dateKey(date);

    return _logs.putIfAbsent(
      key,
      () => DailyNutritionLog(
        date: DateTime(date.year, date.month, date.day),
        target: _target,
      ),
    );
  }

  @override
  Future<List<FoodItem>> searchFoodDatabase(String query) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _database;

    return _database
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              (f.brand?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Future<void> logFood({
    required DateTime date,
    required MealType mealType,
    required FoodItem food,
    required double servings,
  }) async {
    await Future.delayed(_delay);
    final key = _dateKey(date);
    final currentLog = await getDailyNutritionLog(date);

    final entry = LoggedFoodEntry(
      id: 'entry-${DateTime.now().millisecondsSinceEpoch}',
      foodItem: food,
      numberOfServings: servings,
      mealType: mealType,
      loggedAt: DateTime.now(),
    );

    final updatedEntries = [...currentLog.loggedEntries, entry];
    _logs[key] = currentLog.copyWith(loggedEntries: updatedEntries);
  }

  @override
  Future<void> deleteFood({
    required DateTime date,
    required String entryId,
  }) async {
    await Future.delayed(_delay);
    final key = _dateKey(date);
    final currentLog = await getDailyNutritionLog(date);

    final updatedEntries = currentLog.loggedEntries
        .where((e) => e.id != entryId)
        .toList();
    _logs[key] = currentLog.copyWith(loggedEntries: updatedEntries);
  }

  @override
  Future<void> logWater({required DateTime date, required int amountMl}) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final key = _dateKey(date);
    final currentLog = await getDailyNutritionLog(date);

    final nextWater = (currentLog.waterIntakeMl + amountMl).clamp(0, 10000);
    _logs[key] = currentLog.copyWith(waterIntakeMl: nextWater);
  }

  void _initDatabase() {
    _database.addAll(const [
      FoodItem(
        id: 'food-chicken-breast',
        name: 'Chicken Breast (Grilled)',
        servingSize: 100,
        servingUnit: 'g',
        calories: 165,
        proteinG: 31.0,
        carbsG: 0.0,
        fatG: 3.6,
      ),
      FoodItem(
        id: 'food-egg',
        name: 'Whole Large Egg',
        servingSize: 1,
        servingUnit: 'egg',
        calories: 72,
        proteinG: 6.3,
        carbsG: 0.4,
        fatG: 4.8,
      ),
      FoodItem(
        id: 'food-egg-white',
        name: 'Liquid Egg Whites',
        servingSize: 100,
        servingUnit: 'g',
        calories: 52,
        proteinG: 11.0,
        carbsG: 0.7,
        fatG: 0.2,
      ),
      FoodItem(
        id: 'food-whey-protein',
        name: '100% Whey Protein Isolate',
        brand: 'Optimum Nutrition',
        servingSize: 30,
        servingUnit: 'scoop',
        calories: 120,
        proteinG: 25.0,
        carbsG: 2.0,
        fatG: 1.0,
      ),
      FoodItem(
        id: 'food-oats',
        name: 'Rolled Oats',
        servingSize: 40,
        servingUnit: 'g',
        calories: 150,
        proteinG: 5.0,
        carbsG: 27.0,
        fatG: 3.0,
        fiberG: 4.0,
      ),
      FoodItem(
        id: 'food-brown-rice',
        name: 'Brown Rice (Cooked)',
        servingSize: 150,
        servingUnit: 'g',
        calories: 168,
        proteinG: 3.5,
        carbsG: 35.0,
        fatG: 1.4,
        fiberG: 2.5,
      ),
      FoodItem(
        id: 'food-salmon',
        name: 'Atlantic Salmon (Baked)',
        servingSize: 100,
        servingUnit: 'g',
        calories: 208,
        proteinG: 20.0,
        carbsG: 0.0,
        fatG: 13.0,
      ),
      FoodItem(
        id: 'food-greek-yogurt',
        name: 'Non-fat Greek Yogurt',
        servingSize: 150,
        servingUnit: 'g',
        calories: 90,
        proteinG: 15.0,
        carbsG: 6.0,
        fatG: 0.0,
      ),
      FoodItem(
        id: 'food-banana',
        name: 'Medium Banana',
        servingSize: 1,
        servingUnit: 'banana',
        calories: 105,
        proteinG: 1.3,
        carbsG: 27.0,
        fatG: 0.3,
        fiberG: 3.1,
      ),
      FoodItem(
        id: 'food-peanut-butter',
        name: 'Natural Peanut Butter',
        servingSize: 32,
        servingUnit: 'g (2 tbsp)',
        calories: 190,
        proteinG: 8.0,
        carbsG: 7.0,
        fatG: 16.0,
      ),
      FoodItem(
        id: 'food-sweet-potato',
        name: 'Sweet Potato (Baked)',
        servingSize: 150,
        servingUnit: 'g',
        calories: 130,
        proteinG: 2.0,
        carbsG: 30.0,
        fatG: 0.2,
        fiberG: 4.0,
      ),
      FoodItem(
        id: 'food-broccoli',
        name: 'Steamed Broccoli',
        servingSize: 100,
        servingUnit: 'g',
        calories: 35,
        proteinG: 2.4,
        carbsG: 7.0,
        fatG: 0.4,
        fiberG: 2.6,
      ),
      FoodItem(
        id: 'food-almonds',
        name: 'Raw Almonds',
        servingSize: 30,
        servingUnit: 'g',
        calories: 170,
        proteinG: 6.0,
        carbsG: 6.0,
        fatG: 15.0,
      ),
    ]);
  }

  void _initSeedLog() {
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    final oats = _database.firstWhere((f) => f.id == 'food-oats');
    final whey = _database.firstWhere((f) => f.id == 'food-whey-protein');
    final banana = _database.firstWhere((f) => f.id == 'food-banana');
    final chicken = _database.firstWhere((f) => f.id == 'food-chicken-breast');
    final rice = _database.firstWhere((f) => f.id == 'food-brown-rice');
    final broccoli = _database.firstWhere((f) => f.id == 'food-broccoli');
    final yogurt = _database.firstWhere((f) => f.id == 'food-greek-yogurt');
    final almonds = _database.firstWhere((f) => f.id == 'food-almonds');

    _logs[todayKey] = DailyNutritionLog(
      date: DateTime(now.year, now.month, now.day),
      target: _target,
      waterIntakeMl: 1750,
      loggedEntries: [
        LoggedFoodEntry(
          id: 'seed-1',
          foodItem: oats,
          numberOfServings: 1.5,
          mealType: MealType.breakfast,
          loggedAt: DateTime(now.year, now.month, now.day, 8, 15),
        ),
        LoggedFoodEntry(
          id: 'seed-2',
          foodItem: whey,
          numberOfServings: 1.0,
          mealType: MealType.breakfast,
          loggedAt: DateTime(now.year, now.month, now.day, 8, 15),
        ),
        LoggedFoodEntry(
          id: 'seed-3',
          foodItem: banana,
          numberOfServings: 1.0,
          mealType: MealType.breakfast,
          loggedAt: DateTime(now.year, now.month, now.day, 8, 15),
        ),
        LoggedFoodEntry(
          id: 'seed-4',
          foodItem: chicken,
          numberOfServings: 1.5,
          mealType: MealType.lunch,
          loggedAt: DateTime(now.year, now.month, now.day, 13, 0),
        ),
        LoggedFoodEntry(
          id: 'seed-5',
          foodItem: rice,
          numberOfServings: 1.0,
          mealType: MealType.lunch,
          loggedAt: DateTime(now.year, now.month, now.day, 13, 0),
        ),
        LoggedFoodEntry(
          id: 'seed-6',
          foodItem: broccoli,
          numberOfServings: 1.0,
          mealType: MealType.lunch,
          loggedAt: DateTime(now.year, now.month, now.day, 13, 0),
        ),
        LoggedFoodEntry(
          id: 'seed-7',
          foodItem: yogurt,
          numberOfServings: 1.0,
          mealType: MealType.snack,
          loggedAt: DateTime(now.year, now.month, now.day, 16, 30),
        ),
        LoggedFoodEntry(
          id: 'seed-8',
          foodItem: almonds,
          numberOfServings: 1.0,
          mealType: MealType.snack,
          loggedAt: DateTime(now.year, now.month, now.day, 16, 30),
        ),
      ],
    );
  }
}
