import 'package:calibrefit/features/nutrition/data/mock_nutrition_repository.dart';
import 'package:calibrefit/features/nutrition/domain/daily_nutrition_log.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';
import 'package:calibrefit/features/nutrition/domain/nutrition_repository.dart';
import 'package:calibrefit/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final profile = ref.watch(savedOnboardingProfileProvider).asData?.value;
  final target = profile != null
      ? MacroCalculator.calculateFromProfile(profile)
      : MacroTarget.defaultTarget;
  return MockNutritionRepository(target: target);
});

// ---------------------------------------------------------------------------
// Selected Date Provider
// ---------------------------------------------------------------------------

class SelectedNutritionDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }
}

final selectedNutritionDateProvider =
    NotifierProvider<SelectedNutritionDateNotifier, DateTime>(
      SelectedNutritionDateNotifier.new,
    );

// ---------------------------------------------------------------------------
// Daily Log Provider
// ---------------------------------------------------------------------------

final dailyNutritionLogProvider = FutureProvider<DailyNutritionLog>((
  ref,
) async {
  final repo = ref.watch(nutritionRepositoryProvider);
  final date = ref.watch(selectedNutritionDateProvider);
  return repo.getDailyNutritionLog(date);
});

// ---------------------------------------------------------------------------
// Food Database Search Providers
// ---------------------------------------------------------------------------

class FoodSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final foodSearchQueryProvider =
    NotifierProvider<FoodSearchQueryNotifier, String>(
      FoodSearchQueryNotifier.new,
    );

final foodSearchResultsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final repo = ref.watch(nutritionRepositoryProvider);
  final query = ref.watch(foodSearchQueryProvider);
  return repo.searchFoodDatabase(query);
});

// ---------------------------------------------------------------------------
// Mutation Controller Provider
// ---------------------------------------------------------------------------

class NutritionLogController extends Notifier<void> {
  @override
  void build() {}

  Future<void> logFood({
    required MealType mealType,
    required FoodItem food,
    required double servings,
  }) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final date = ref.read(selectedNutritionDateProvider);
    await repo.logFood(
      date: date,
      mealType: mealType,
      food: food,
      servings: servings,
    );
    ref.invalidate(dailyNutritionLogProvider);
  }

  Future<void> deleteFood(String entryId) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final date = ref.read(selectedNutritionDateProvider);
    await repo.deleteFood(date: date, entryId: entryId);
    ref.invalidate(dailyNutritionLogProvider);
  }

  Future<void> logWater(int amountMl) async {
    final repo = ref.read(nutritionRepositoryProvider);
    final date = ref.read(selectedNutritionDateProvider);
    await repo.logWater(date: date, amountMl: amountMl);
    ref.invalidate(dailyNutritionLogProvider);
  }
}

final nutritionLogControllerProvider =
    NotifierProvider<NutritionLogController, void>(NutritionLogController.new);
