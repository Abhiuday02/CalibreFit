import 'package:calibrefit/features/nutrition/data/mock_nutrition_repository.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockNutritionRepository', () {
    late MockNutritionRepository repository;
    final testDate = DateTime.now();

    setUp(() {
      repository = MockNutritionRepository(
        target: const MacroTarget(
          calories: 2200,
          proteinG: 160,
          carbsG: 240,
          fatG: 60,
          waterMl: 2800,
          bmr: 1700,
          tdee: 2400,
        ),
      );
    });

    test('getMacroTarget returns configured targets', () async {
      final target = await repository.getMacroTarget();

      expect(target.calories, equals(2200));
      expect(target.proteinG, equals(160));
      expect(target.carbsG, equals(240));
      expect(target.fatG, equals(60));
      expect(target.waterMl, equals(2800));
    });

    test('getDailyNutritionLog loads seeded data for today', () async {
      final log = await repository.getDailyNutritionLog(testDate);

      expect(log.loggedEntries, isNotEmpty);
      expect(log.consumedCalories, greaterThan(0));
      expect(log.consumedProteinG, greaterThan(0));
      expect(log.consumedCarbsG, greaterThan(0));
      expect(log.consumedFatG, greaterThan(0));
      expect(log.waterIntakeMl, equals(1750));
      expect(log.remainingCalories, equals(2200 - log.consumedCalories));
    });

    test('searchFoodDatabase filters food items by name and brand', () async {
      final allFoods = await repository.searchFoodDatabase('');
      expect(allFoods.length, greaterThanOrEqualTo(10));

      final chicken = await repository.searchFoodDatabase('chicken');
      expect(chicken, isNotEmpty);
      expect(chicken.first.name.toLowerCase(), contains('chicken'));

      final whey = await repository.searchFoodDatabase('optimum');
      expect(whey, isNotEmpty);
      expect(whey.first.brand?.toLowerCase(), contains('optimum'));

      final empty = await repository.searchFoodDatabase('nonexistentfoodxyz');
      expect(empty, isEmpty);
    });

    test('logFood appends new entry to the daily meal log', () async {
      final foods = await repository.searchFoodDatabase('salmon');
      final salmon = foods.first;

      final initialLog = await repository.getDailyNutritionLog(testDate);
      final initialCount = initialLog.loggedEntries.length;
      final initialCalories = initialLog.consumedCalories;

      await repository.logFood(
        date: testDate,
        mealType: MealType.dinner,
        food: salmon,
        servings: 2.0,
      );

      final updatedLog = await repository.getDailyNutritionLog(testDate);
      expect(updatedLog.loggedEntries.length, equals(initialCount + 1));
      expect(
        updatedLog.consumedCalories,
        equals(initialCalories + (salmon.calories * 2)),
      );

      final dinnerEntries = updatedLog.entriesForMeal(MealType.dinner);
      expect(dinnerEntries, isNotEmpty);
      expect(dinnerEntries.last.foodItem.id, equals(salmon.id));
      expect(dinnerEntries.last.numberOfServings, equals(2.0));
    });

    test('deleteFood removes entry from the daily log', () async {
      final initialLog = await repository.getDailyNutritionLog(testDate);
      expect(initialLog.loggedEntries, isNotEmpty);

      final entryToDelete = initialLog.loggedEntries.first;
      final initialCalories = initialLog.consumedCalories;

      await repository.deleteFood(date: testDate, entryId: entryToDelete.id);

      final updatedLog = await repository.getDailyNutritionLog(testDate);
      expect(
        updatedLog.loggedEntries.any((e) => e.id == entryToDelete.id),
        isFalse,
      );
      expect(
        updatedLog.consumedCalories,
        equals(initialCalories - entryToDelete.totalCalories),
      );
    });

    test('logWater updates total hydration for the date', () async {
      final initialLog = await repository.getDailyNutritionLog(testDate);
      final initialWater = initialLog.waterIntakeMl;

      await repository.logWater(date: testDate, amountMl: 250);
      var updatedLog = await repository.getDailyNutritionLog(testDate);
      expect(updatedLog.waterIntakeMl, equals(initialWater + 250));

      await repository.logWater(date: testDate, amountMl: 500);
      updatedLog = await repository.getDailyNutritionLog(testDate);
      expect(updatedLog.waterIntakeMl, equals(initialWater + 750));
    });
  });
}
