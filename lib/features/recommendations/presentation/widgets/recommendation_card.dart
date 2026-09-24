import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';

/// Card presenting a progressive overload recommendation for an exercise.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onApply,
  });

  final WeightRecommendation recommendation;
  final VoidCallback? onApply;

  (Color, Color, String) _getDeltaBadge() {
    if (recommendation.isIncrease) {
      return (
        const Color(0xFF10B981), // Emerald
        const Color(0xFF10B981).withValues(alpha: 0.15),
        '+${recommendation.weightChangeKg.toStringAsFixed(1)} kg',
      );
    }
    if (recommendation.isDecrease) {
      return (
        Colors.amber.shade700,
        Colors.amber.withValues(alpha: 0.15),
        '${recommendation.weightChangeKg.toStringAsFixed(1)} kg',
      );
    }
    return (
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF3B82F6).withValues(alpha: 0.15),
      'Hold Load',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final (deltaColor, deltaBg, deltaText) = _getDeltaBadge();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Exercise Name & Strategy Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.exerciseName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recommendation.category.displayName,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: deltaBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: deltaColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      recommendation.isIncrease
                          ? Icons.trending_up
                          : recommendation.isDecrease
                          ? Icons.trending_down
                          : Icons.balance,
                      size: 14,
                      color: deltaColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deltaText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: deltaColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Load Comparison: Current -> Suggested
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LoadColumn(
                  label: 'CURRENT LOAD',
                  weightKg: recommendation.currentWeightKg,
                  repRange: recommendation.currentRepRange,
                  isHighlight: false,
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                _LoadColumn(
                  label: 'SUGGESTED LOAD',
                  weightKg: recommendation.suggestedWeightKg,
                  repRange: recommendation.suggestedRepRange,
                  isHighlight: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Strategy & Reason Chips
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: 4,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.bolt_rounded, size: 14),
                label: Text(
                  recommendation.strategy.displayName,
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.track_changes, size: 14),
                label: Text(
                  'Target: RPE ${recommendation.targetRpe.toStringAsFixed(1)} (${recommendation.targetRir} RIR)',
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Scientific Rationale Box
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    recommendation.explanation,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (onApply != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Accept Recommendation'),
                onPressed: onApply,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadColumn extends StatelessWidget {
  const _LoadColumn({
    required this.label,
    required this.weightKg,
    required this.repRange,
    required this.isHighlight,
  });

  final String label;
  final double weightKg;
  final String repRange;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${weightKg.toStringAsFixed(1)} kg',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        Text(
          '$repRange reps',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
