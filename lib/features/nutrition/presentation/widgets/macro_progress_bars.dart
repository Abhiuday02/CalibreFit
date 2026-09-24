import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/nutrition/domain/daily_nutrition_log.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';

/// Card displaying progress bars and grams consumed vs. target for
/// Protein, Carbohydrates, and Fats.
class MacroProgressBarsCard extends StatelessWidget {
  const MacroProgressBarsCard({super.key, required this.log});

  final DailyNutritionLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Macronutrients',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Consumed / Target',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _MacroBarItem(
            name: 'Protein',
            consumedG: log.consumedProteinG,
            targetG: log.target.proteinG.toDouble(),
            progress: log.proteinProgress,
            color: const Color(0xFFE53935), // Red / Coral
            caloriesPerGram: 4,
          ),
          const SizedBox(height: AppSpacing.md),
          _MacroBarItem(
            name: 'Carbohydrates',
            consumedG: log.consumedCarbsG,
            targetG: log.target.carbsG.toDouble(),
            progress: log.carbsProgress,
            color: const Color(0xFF00ACC1), // Cyan / Teal
            caloriesPerGram: 4,
          ),
          const SizedBox(height: AppSpacing.md),
          _MacroBarItem(
            name: 'Fats',
            consumedG: log.consumedFatG,
            targetG: log.target.fatG.toDouble(),
            progress: log.fatProgress,
            color: const Color(0xFFFB8C00), // Amber / Orange
            caloriesPerGram: 9,
          ),
        ],
      ),
    );
  }
}

class _MacroBarItem extends StatelessWidget {
  const _MacroBarItem({
    required this.name,
    required this.consumedG,
    required this.targetG,
    required this.progress,
    required this.color,
    required this.caloriesPerGram,
  });

  final String name;
  final double consumedG;
  final double targetG;
  final double progress;
  final Color color;
  final int caloriesPerGram;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).round();
    final consumedKcal = (consumedG * caloriesPerGram).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '($consumedKcal kcal)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Text(
              '${consumedG.toStringAsFixed(1)} / ${targetG.toStringAsFixed(0)}g ($percentage%)',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
