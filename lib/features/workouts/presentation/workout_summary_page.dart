import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/core/utils/date_time_utils.dart';
import 'package:calibrefit/features/workouts/presentation/active_workout_providers.dart';
import 'package:calibrefit/shared/buttons/primary_button.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Workout Summary Screen displayed upon completing an active workout.
class WorkoutSummaryPage extends ConsumerWidget {
  const WorkoutSummaryPage({super.key});

  String _formatVolume(double volumeKg) {
    if (volumeKg >= 1000) {
      return '${(volumeKg / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volumeKg.toStringAsFixed(0)} kg';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(lastWorkoutSummaryProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Summary')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No workout summary data found.'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final duration = Duration(seconds: summary.totalDurationSeconds);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ── Trophy / Celebration Icon ───────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('🏆', style: TextStyle(fontSize: 40)),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'Workout Complete!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                '${summary.workoutTitle} • ${summary.targetMuscles}',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Metrics Card ────────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    _StatTile(
                      icon: Icons.timer_outlined,
                      iconColor: colorScheme.primary,
                      label: 'DURATION',
                      value: DateTimeUtils.formatDuration(duration),
                    ),
                    Container(
                      height: 48,
                      width: 1,
                      color: colorScheme.outlineVariant,
                    ),
                    _StatTile(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: Colors.green,
                      label: 'SETS COMPLETED',
                      value:
                          '${summary.totalSetsCompleted}/${summary.totalSetsPlanned}',
                    ),
                    Container(
                      height: 48,
                      width: 1,
                      color: colorScheme.outlineVariant,
                    ),
                    _StatTile(
                      icon: Icons.fitness_center_rounded,
                      iconColor: Colors.amber.shade800,
                      label: 'VOLUME',
                      value: _formatVolume(summary.totalVolumeKg),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Exercises Completed Card ────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exercises Completed',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.xs),
                    if (summary.completedExercises.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          'No sets marked as completed.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...summary.completedExercises.map(
                        (name) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Colors.green,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  name,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Return to Home Button ───────────────────────────────
              PrimaryButton(
                label: 'Done & Return Home',
                icon: Icons.home_rounded,
                onPressed: () {
                  ref.read(lastWorkoutSummaryProvider.notifier).clear();
                  context.go(AppRoutes.home);
                },
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
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
