import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/home/domain/daily_workout.dart';
import 'package:calibrefit/shared/buttons/primary_button.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';

/// Card showing today's planned workout with duration, exercises, sets, reps,
/// suggested load, and a prominent "Start Workout" button.
class TodaysWorkoutCard extends StatelessWidget {
  const TodaysWorkoutCard({
    super.key,
    required this.workout,
    required this.onStartWorkout,
    this.onExerciseTap,
  });

  final DailyWorkout workout;
  final VoidCallback onStartWorkout;
  final ValueChanged<DailyWorkoutExercise>? onExerciseTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tag + Duration & Sets badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  workout.title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${workout.estimatedDurationMinutes} min',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.repeat_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${workout.totalSets} sets',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Workout Title (Target Muscles)
          Text(
            workout.targetMuscles,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Exercises Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'EXERCISE',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'SETS × REPS',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'LOAD',
                    textAlign: TextAlign.end,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Exercise rows
          ...workout.exercises.map(
            (exercise) => _ExerciseRow(
              exercise: exercise,
              onTap: onExerciseTap != null
                  ? () => onExerciseTap!(exercise)
                  : null,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Start Workout CTA
          Semantics(
            label: AppSemantics.startWorkout,
            button: true,
            child: PrimaryButton(
              label: 'Start Workout',
              icon: Icons.play_arrow_rounded,
              onPressed: onStartWorkout,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise, this.onTap});

  final DailyWorkoutExercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ),
            // Sets × Reps
            Expanded(
              flex: 3,
              child: Text(
                '${exercise.sets} × ${exercise.repRange}',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Suggested Load
            Expanded(
              flex: 3,
              child: Text(
                '${exercise.suggestedLoadKg} kg',
                textAlign: TextAlign.end,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
