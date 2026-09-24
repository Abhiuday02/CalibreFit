import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/nutrition/domain/food_item.dart';
import 'package:calibrefit/features/nutrition/presentation/nutrition_providers.dart';
import 'package:calibrefit/features/nutrition/presentation/widgets/add_food_bottom_sheet.dart';
import 'package:calibrefit/features/nutrition/presentation/widgets/calorie_ring_card.dart';
import 'package:calibrefit/features/nutrition/presentation/widgets/macro_progress_bars.dart';
import 'package:calibrefit/features/nutrition/presentation/widgets/meal_section_card.dart';
import 'package:calibrefit/features/nutrition/presentation/widgets/water_tracker_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Complete Diet & Nutrition Planning dashboard screen.
class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (target == today.add(const Duration(days: 1))) return 'Tomorrow';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedNutritionDateProvider);
    final dateNotifier = ref.read(selectedNutritionDateProvider.notifier);
    final logAsync = ref.watch(dailyNutritionLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet & Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dailyNutritionLogProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Date Navigation Bar ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            color: theme.colorScheme.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: dateNotifier.previousDay,
                  tooltip: 'Previous Day',
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      dateNotifier.setDate(picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _formatDate(selectedDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: dateNotifier.nextDay,
                  tooltip: 'Next Day',
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: logAsync.when(
              loading: () => const Center(child: AppLoader()),
              error: (err, _) => Center(
                child: AppErrorWidget(
                  message: 'Failed to load nutrition log: $err',
                  onRetry: () => ref.invalidate(dailyNutritionLogProvider),
                ),
              ),
              data: (log) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // 1. Calorie Ring & Energy Balance
                    CalorieRingCard(log: log),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Macronutrient Progress Bars
                    MacroProgressBarsCard(log: log),
                    const SizedBox(height: AppSpacing.md),

                    // 3. Hydration Tracker
                    WaterTrackerCard(log: log),
                    const SizedBox(height: AppSpacing.md),

                    // 4. Meal Sections
                    for (final meal in MealType.values) ...[
                      MealSectionCard(
                        mealType: meal,
                        log: log,
                        onAddFood: () => AddFoodBottomSheet.show(context, meal),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
