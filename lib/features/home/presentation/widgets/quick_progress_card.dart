import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/home/domain/daily_workout.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';

/// Quick progress summary card showing consistency, streak, and weekly volume.
class QuickProgressCard extends StatelessWidget {
  const QuickProgressCard({super.key, required this.summary});

  final QuickProgressSummary summary;

  String _formatVolume(double volumeKg) {
    if (volumeKg >= 1000) {
      return '${(volumeKg / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volumeKg.toStringAsFixed(0)} kg';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${summary.currentStreakDays} day streak',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _ProgressStatTile(
                  icon: Icons.calendar_today_rounded,
                  iconColor: colorScheme.primary,
                  label: 'Workouts',
                  value:
                      '${summary.completedWorkoutsThisWeek}/${summary.targetWorkoutsPerWeek}',
                  subtitle: 'This week',
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: colorScheme.outlineVariant,
              ),
              Expanded(
                child: _ProgressStatTile(
                  icon: Icons.fitness_center_rounded,
                  iconColor: Colors.amber.shade700,
                  label: 'Volume',
                  value: _formatVolume(summary.weeklyVolumeKg),
                  subtitle: 'Total lifted',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar towards target
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: summary.weeklyCompletionRate,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStatTile extends StatelessWidget {
  const _ProgressStatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
