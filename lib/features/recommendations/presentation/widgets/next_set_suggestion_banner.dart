import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/recommendations/domain/recommendation_models.dart';
import 'package:flutter/material.dart';

/// Live intra-workout suggestion banner shown between sets in an active workout.
class NextSetSuggestionBanner extends StatelessWidget {
  const NextSetSuggestionBanner({
    super.key,
    required this.adjustment,
    this.onApply,
  });

  final NextSetAdjustment adjustment;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.6),
            colorScheme.tertiaryContainer.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI NEXT SET SUGGESTION',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${adjustment.suggestedWeightKg.toStringAsFixed(1)} kg × ${adjustment.suggestedReps}',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  adjustment.message,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (onApply != null) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.check_rounded, size: 18),
              tooltip: 'Apply to next set',
              onPressed: onApply,
            ),
          ],
        ],
      ),
    );
  }
}
