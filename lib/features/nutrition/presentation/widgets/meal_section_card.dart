import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/nutrition/domain/daily_nutrition_log.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/presentation/nutrition_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays logged foods for a specific [MealType] and an "+ Add Food" action.
class MealSectionCard extends ConsumerWidget {
  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.log,
    required this.onAddFood,
  });

  final MealType mealType;
  final DailyNutritionLog log;
  final VoidCallback onAddFood;

  IconData get _mealIcon => switch (mealType) {
    MealType.breakfast => Icons.wb_sunny_outlined,
    MealType.lunch => Icons.wb_twilight_outlined,
    MealType.dinner => Icons.nightlight_outlined,
    MealType.snack => Icons.local_cafe_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = log.entriesForMeal(mealType);
    final totalCals = log.caloriesForMeal(mealType);
    final totalProtein = log.proteinForMeal(mealType);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_mealIcon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    mealType.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '$totalCals kcal • ${totalProtein.toStringAsFixed(1)}g P',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.xs),
            ...entries.map(
              (entry) => _LoggedFoodItemRow(
                entry: entry,
                onDelete: () {
                  ref
                      .read(nutritionLogControllerProvider.notifier)
                      .deleteFood(entry.id);
                },
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onAddFood,
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add to ${mealType.displayName}'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedFoodItemRow extends StatelessWidget {
  const _LoggedFoodItemRow({required this.entry, required this.onDelete});

  final LoggedFoodEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final food = entry.foodItem;

    final servingDesc =
        '${entry.numberOfServings} x ${food.servingSize.toInt()}${food.servingUnit}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$servingDesc • ${entry.totalProteinG}g P • ${entry.totalCarbsG}g C • ${entry.totalFatG}g F',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.totalCalories} kcal',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: theme.colorScheme.outline,
            onPressed: onDelete,
            tooltip: 'Remove',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
