import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/core/utils/date_time_utils.dart';
import 'package:calibrefit/features/exercise_library/presentation/exercise_library_providers.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';
import 'package:calibrefit/features/history/presentation/history_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exercise Progress View displaying load and volume progression over time.
class ExerciseProgressPage extends ConsumerWidget {
  const ExerciseProgressPage({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(exerciseProgressProvider(exerciseId));
    final exerciseAsync = ref.watch(exerciseDetailProvider(exerciseId));

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final exerciseName =
        exerciseAsync.asData?.value?.name ?? 'Exercise Progress';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(exerciseName), centerTitle: false),
      body: progressAsync.when(
        data: (points) {
          if (points.isEmpty) {
            return const Center(
              child: Text('No historical progression data yet.'),
            );
          }

          final startingPoint = points.first;
          final latestPoint = points.last;
          final weightGain = latestPoint.weightKg - startingPoint.weightKg;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Progress Headline Card ─────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _HeadlineStat(
                        label: 'STARTING LOAD',
                        value: '${startingPoint.weightKg} kg',
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      _HeadlineStat(
                        label: 'CURRENT LOAD',
                        value: '${latestPoint.weightKg} kg',
                        valueColor: colorScheme.primary,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      _HeadlineStat(
                        label: 'PROGRESS',
                        value:
                            '${weightGain >= 0 ? '+' : ''}${weightGain.toStringAsFixed(1)} kg',
                        valueColor: weightGain >= 0
                            ? Colors.green.shade700
                            : colorScheme.error,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Progression Timeline',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── 2. Chronological Progression List ─────────────────
                ...points.reversed.map((point) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ProgressPointCard(point: point),
                  );
                }),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
        loading: () => const AppLoader(label: 'Loading progression...'),
        error: (err, _) => AppErrorWidget(
          message: 'Failed to load exercise progression.',
          onRetry: () => ref.invalidate(exerciseProgressProvider(exerciseId)),
        ),
      ),
    );
  }
}

class _HeadlineStat extends StatelessWidget {
  const _HeadlineStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProgressPointCard extends StatelessWidget {
  const _ProgressPointCard({required this.point});

  final ExerciseProgressPoint point;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${point.weightKg} kg × ${point.reps} reps',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Est. 1RM: ${point.estimated1RmKg.toStringAsFixed(1)} kg • Volume: ${point.volumeKg.toStringAsFixed(0)} kg',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateTimeUtils.relativeLabel(point.date),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
