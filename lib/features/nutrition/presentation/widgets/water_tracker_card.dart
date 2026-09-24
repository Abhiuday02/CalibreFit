import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/nutrition/domain/daily_nutrition_log.dart';
import 'package:calibrefit/features/nutrition/presentation/nutrition_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Card for tracking hydration with quick-add buttons for water intake.
class WaterTrackerCard extends ConsumerWidget {
  const WaterTrackerCard({super.key, required this.log});

  final DailyNutritionLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final current = log.waterIntakeMl;
    final target = log.target.waterMl;
    final progress = log.waterProgress;
    final percent = (progress * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 20,
                    color: Color(0xFF29B6F6), // Sky blue
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Hydration Tracker',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '$current / $target ml ($percent%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0288D1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF29B6F6),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(nutritionLogControllerProvider.notifier)
                        .logWater(250);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+250 ml (Cup)'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(nutritionLogControllerProvider.notifier)
                        .logWater(500);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+500 ml (Bottle)'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
