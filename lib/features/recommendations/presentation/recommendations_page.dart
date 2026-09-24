import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/recommendations/presentation/recommendations_providers.dart';
import 'package:calibrefit/features/recommendations/presentation/widgets/recommendation_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen displaying all AI-powered progressive overload recommendations.
class RecommendationsPage extends ConsumerWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final recommendationsAsync = ref.watch(filteredRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Intelligent Overload')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeRecommendationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          children: [
            // ── 1. Hero Educational Banner ───────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.7),
                    colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Double Progression Engine',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Analyzes actual reps, RIR, and RPE from your logged sets to calculate micro-load progressions and prevent overtraining.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── 2. Category Filter Chips ─────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: const Text('All Groups'),
                      selected: selectedCategory == null,
                      onSelected: (_) {
                        ref
                            .read(selectedCategoryFilterProvider.notifier)
                            .select(null);
                      },
                    ),
                  ),
                  ...ExerciseCategory.values.map((category) {
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        label: Text(category.displayName),
                        selected: isSelected,
                        onSelected: (_) {
                          ref
                              .read(selectedCategoryFilterProvider.notifier)
                              .select(category);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── 3. Recommendations List ──────────────────────────────
            recommendationsAsync.when(
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No pending recommendations',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log more workout sets to trigger progressive overload insights.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recommendations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final rec = recommendations[index];
                    return RecommendationCard(
                      recommendation: rec,
                      onApply: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Accepted recommendation: ${rec.exerciseName} at ${rec.suggestedWeightKg.toStringAsFixed(1)} kg',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: Center(
                  child: AppLoader(
                    label: 'Analyzing progressive overload metrics...',
                  ),
                ),
              ),
              error: (err, _) => AppErrorWidget(
                message: 'Failed to load recommendations.',
                onRetry: () => ref.invalidate(activeRecommendationsProvider),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
