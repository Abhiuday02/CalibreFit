import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/core/utils/date_time_utils.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';
import 'package:calibrefit/features/history/presentation/history_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Detailed view of a single historical workout session.
class WorkoutHistoryDetailPage extends ConsumerWidget {
  const WorkoutHistoryDetailPage({super.key, required this.recordId});

  final String recordId;

  String _formatVolume(double volumeKg) {
    if (volumeKg >= 1000) {
      return '${(volumeKg / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volumeKg.toStringAsFixed(0)} kg';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(workoutHistoryDetailProvider(recordId));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Workout Details'), centerTitle: false),
      body: recordAsync.when(
        data: (record) {
          if (record == null) {
            return const AppErrorWidget(message: 'Workout record not found.');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Workout Header ─────────────────────────────────
                Text(
                  record.workoutTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.targetMuscles} • ${DateTimeUtils.relativeLabel(record.date)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── 2. Metric Cards Strip ─────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      _MetricStat(
                        icon: Icons.timer_outlined,
                        iconColor: colorScheme.primary,
                        label: 'DURATION',
                        value: '${(record.durationSeconds / 60).round()} min',
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      _MetricStat(
                        icon: Icons.fitness_center_rounded,
                        iconColor: Colors.amber.shade800,
                        label: 'TOTAL VOLUME',
                        value: _formatVolume(record.totalVolumeKg),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      _MetricStat(
                        icon: Icons.repeat_rounded,
                        iconColor: Colors.teal,
                        label: 'TOTAL REPS',
                        value: '${record.totalReps}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── 3. Exercises Breakdown ────────────────────────────
                Text(
                  'Exercises Performed',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                ...record.exerciseSummaries.map((exercise) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ExerciseHistoryCard(
                      exercise: exercise,
                      onViewProgress: () {
                        context.push(
                          '${AppRoutes.workoutHistory}/exercise/${exercise.exerciseId}',
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
        loading: () => const AppLoader(label: 'Loading workout details...'),
        error: (err, _) => AppErrorWidget(
          message: 'Failed to load workout details.',
          onRetry: () => ref.invalidate(workoutHistoryDetailProvider(recordId)),
        ),
      ),
    );
  }
}

class _MetricStat extends StatelessWidget {
  const _MetricStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 2),
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
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseHistoryCard extends StatelessWidget {
  const _ExerciseHistoryCard({
    required this.exercise,
    required this.onViewProgress,
  });

  final ExerciseHistorySummary exercise;
  final VoidCallback onViewProgress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Exercise name, best set badge & view progress button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exercise.setsCount} sets • Best: ${exercise.bestSetWeightKg} kg × ${exercise.bestSetReps}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.show_chart_rounded),
                tooltip: 'View progression',
                color: colorScheme.primary,
                onPressed: onViewProgress,
              ),
            ],
          ),

          if (exercise.sets.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.xs),

            // Sets Table Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      'SET',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'PLANNED',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'ACTUAL',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text(
                      'RIR/RPE',
                      textAlign: TextAlign.end,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Set Rows
            ...exercise.sets.map((set) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${set.setNumber}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${set.plannedWeight}kg × ${set.plannedReps}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${set.actualWeight}kg × ${set.actualReps}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${set.rir ?? '—'} / ${set.rpe ?? '—'}',
                        textAlign: TextAlign.end,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
