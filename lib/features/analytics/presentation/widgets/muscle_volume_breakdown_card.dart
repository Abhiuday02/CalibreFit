import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/analytics/domain/volume_analytics.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';

/// Displays a breakdown of training volume and set counts by muscle group
/// with evidence-based hypertrophy status indicators.
class MuscleVolumeBreakdownCard extends StatelessWidget {
  const MuscleVolumeBreakdownCard({super.key, required this.breakdowns});

  final List<MuscleGroupVolume> breakdowns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Muscle Group Distribution',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Target: 10–20 weekly sets per muscle',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.pie_chart_outline_rounded,
                color: colorScheme.primary,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (breakdowns.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No muscle volume recorded yet.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: breakdowns.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = breakdowns[index];
                return _MuscleVolumeRow(item: item);
              },
            ),
        ],
      ),
    );
  }
}

class _MuscleVolumeRow extends StatelessWidget {
  const _MuscleVolumeRow({required this.item});

  final MuscleGroupVolume item;

  Color _getCategoryColor(ExerciseCategory category) {
    return switch (category) {
      ExerciseCategory.chest => const Color(0xFFE53935), // Red
      ExerciseCategory.back => const Color(0xFF1E88E5), // Blue
      ExerciseCategory.legs => const Color(0xFF43A047), // Green
      ExerciseCategory.shoulders => const Color(0xFFFB8C00), // Orange
      ExerciseCategory.arms => const Color(0xFF8E24AA), // Purple
      ExerciseCategory.core => const Color(0xFF00ACC1), // Cyan
      ExerciseCategory.fullBody => const Color(0xFF3949AB), // Indigo
    };
  }

  (Color, String) _getStatusBadge(VolumeStatus status) {
    return switch (status) {
      VolumeStatus.low => (Colors.amber.shade700, 'Low (<10 sets)'),
      VolumeStatus.optimal => (const Color(0xFF10B981), 'Optimal (10–20 sets)'),
      VolumeStatus.high => (const Color(0xFF8B5CF6), 'High (>20 sets)'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final color = _getCategoryColor(item.category);
    final (statusColor, statusLabel) = _getStatusBadge(item.volumeStatus);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.muscleName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar showing percentage of total volume
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (item.percentageOfTotal / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.totalSets} sets (${item.percentageOfTotal.toStringAsFixed(1)}%)',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${item.totalVolumeKg.toStringAsFixed(0)} kg',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
