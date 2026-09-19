import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/core/utils/date_time_utils.dart';
import 'package:calibrefit/features/workouts/domain/workout_session.dart';
import 'package:calibrefit/features/workouts/presentation/active_workout_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Active Workout Session Screen.
///
/// Supports full set logging with planned vs. actual data preservation:
///   - Real-time workout duration timer
///   - Exercise navigation
///   - Displays planned targets (load & reps) alongside actual performance
///   - Interactive set adjustment (actual weight, actual reps, RIR, RPE, notes)
///   - Automated rest timer countdown
///   - Finish workout with SetLog persistence and summary display
class ActiveWorkoutPage extends ConsumerWidget {
  const ActiveWorkoutPage({super.key});

  Future<void> _showDiscardDialog(
    BuildContext context,
    ActiveWorkoutNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text(
          'Are you sure you want to end this workout without saving? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      notifier.discardWorkout();
      context.go(AppRoutes.home);
    }
  }

  void _finishWorkout(BuildContext context, ActiveWorkoutNotifier notifier) {
    final summary = notifier.finishWorkout();
    if (summary != null && context.mounted) {
      context.go(AppRoutes.workoutSummary);
    }
  }

  void _showEditSetSheet(
    BuildContext context,
    ActiveWorkoutNotifier notifier,
    int exerciseIndex,
    int setIndex,
    ActiveExerciseSet setItem,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => _EditSetBottomSheet(
        setItem: setItem,
        onSave: (actualWeight, actualReps, rir, rpe, notes) {
          notifier.updateSetActuals(
            exerciseIndex: exerciseIndex,
            setIndex: setIndex,
            actualWeight: actualWeight,
            actualReps: actualReps,
            rir: rir,
            rpe: rpe,
            notes: notes,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Workout')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No active workout session.'),
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

    final currentExercise = session.currentExercise;
    final elapsedDuration = Duration(seconds: session.elapsedSeconds);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _showDiscardDialog(context, notifier);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Discard workout',
            onPressed: () => _showDiscardDialog(context, notifier),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.workoutPlanTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                session.targetMuscles,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            // Elapsed Timer Badge
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    DateTimeUtils.formatDuration(elapsedDuration),
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Workout Progress Bar ─────────────────────────────────
            LinearProgressIndicator(
              value: session.sessionProgress,
              minHeight: 4,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),

            // ── Exercise Tabs / Stepper ──────────────────────────────
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: session.exercises.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final ex = session.exercises[index];
                  final isSelected = index == session.currentExerciseIndex;
                  final isCompleted = ex.isAllSetsCompleted;

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCompleted) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text('${index + 1}. ${ex.name}'),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => notifier.goToExercise(index),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // ── Current Exercise & Sets List ─────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Exercise Name Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exercise ${session.currentExerciseIndex + 1} of ${session.exercises.length}',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentExercise.name,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rest preset indicator
                      Chip(
                        avatar: const Icon(
                          Icons.hourglass_empty_rounded,
                          size: 16,
                        ),
                        label: Text(
                          '${currentExercise.restDurationSeconds}s rest',
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Sets Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        // Table Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                                flex: 4,
                                child: Text(
                                  'ACTUAL (KG × REPS)',
                                  textAlign: TextAlign.center,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 44,
                                child: Text(
                                  'DONE',
                                  textAlign: TextAlign.center,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Set Rows
                        ...currentExercise.sets.asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final setItem = entry.value;

                          return _SetRow(
                            set: setItem,
                            onToggle: () {
                              notifier.toggleSet(
                                session.currentExerciseIndex,
                                setIndex,
                              );
                            },
                            onEdit: () {
                              _showEditSetSheet(
                                context,
                                notifier,
                                session.currentExerciseIndex,
                                setIndex,
                                setItem,
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Rest Timer Bar (when resting) ────────────────────
                  if (session.isResting)
                    _RestTimerCard(
                      secondsRemaining: session.restSecondsRemaining,
                      onSkip: notifier.skipRest,
                      onAdd30: () => notifier.addRestSeconds(30),
                    ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),

            // ── Bottom Navigation Controls ───────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Previous Exercise button
                  if (!session.isFirstExercise) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: notifier.previousExercise,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],

                  // Next Exercise or Finish button
                  Expanded(
                    flex: 2,
                    child: session.isLastExercise
                        ? ElevatedButton.icon(
                            onPressed: () => _finishWorkout(context, notifier),
                            icon: const Icon(Icons.done_all_rounded),
                            label: const Text('Finish Workout'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: notifier.nextExercise,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Next Exercise'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Set Row Component
// ---------------------------------------------------------------------------

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.set,
    required this.onToggle,
    required this.onEdit,
  });

  final ActiveExerciseSet set;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 32,
            child: Text(
              '${set.setNumber}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: set.isCompleted ? Colors.green : colorScheme.onSurface,
              ),
            ),
          ),
          // Planned Load & Reps
          Expanded(
            flex: 3,
            child: Text(
              '${set.plannedWeightKg}kg × ${set.plannedRepsDisplay}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          // Actual recorded values (Tappable to edit)
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: set.isCompleted
                        ? Colors.green.withValues(alpha: 0.5)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${set.actualWeightKg} kg × ${set.actualReps}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: set.isCompleted
                            ? Colors.green.shade700
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_outlined,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Done Checkbox Button
          SizedBox(
            width: 44,
            child: Center(
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: set.isCompleted
                        ? Colors.green
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: set.isCompleted
                        ? Colors.white
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit Set Bottom Sheet (Actuals, RIR, RPE, Notes)
// ---------------------------------------------------------------------------

class _EditSetBottomSheet extends StatefulWidget {
  const _EditSetBottomSheet({required this.setItem, required this.onSave});

  final ActiveExerciseSet setItem;
  final void Function(
    double actualWeight,
    int actualReps,
    int? rir,
    double? rpe,
    String? notes,
  )
  onSave;

  @override
  State<_EditSetBottomSheet> createState() => _EditSetBottomSheetState();
}

class _EditSetBottomSheetState extends State<_EditSetBottomSheet> {
  late double _weight;
  late int _reps;
  int? _rir;
  double? _rpe;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _weight = widget.setItem.actualWeightKg;
    _reps = widget.setItem.actualReps;
    _rir = widget.setItem.rir;
    _rpe = widget.setItem.rpe;
    _notesController = TextEditingController(text: widget.setItem.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record Set ${widget.setItem.setNumber}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // ── Actual Weight Stepper ─────────────────────────────────
            Text(
              'Actual Weight (kg)',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _weight > 2.5
                      ? () => setState(() => _weight -= 2.5)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_weight.toStringAsFixed(1)} kg',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _weight += 2.5),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Actual Reps Stepper ───────────────────────────────────
            Text(
              'Actual Reps',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _reps > 1 ? () => setState(() => _reps--) : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_reps reps',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _reps++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── RIR (Reps in Reserve) ─────────────────────────────────
            Text(
              'Reps in Reserve (RIR)',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [0, 1, 2, 3, 4].map((val) {
                final isSelected = _rir == val;
                return ChoiceChip(
                  label: Text('$val RIR'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _rir = val),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── RPE ───────────────────────────────────────────────────
            Text(
              'RPE (Rate of Perceived Exertion)',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [6.0, 7.0, 8.0, 8.5, 9.0, 9.5, 10.0].map((val) {
                final isSelected = _rpe == val;
                return ChoiceChip(
                  label: Text(val.toStringAsFixed(1)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _rpe = val),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Notes ─────────────────────────────────────────────────
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. felt strong, slight shoulder tightness...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Save Button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final notes = _notesController.text.trim();
                  widget.onSave(
                    _weight,
                    _reps,
                    _rir,
                    _rpe,
                    notes.isEmpty ? null : notes,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Save Set Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rest Timer Widget
// ---------------------------------------------------------------------------

class _RestTimerCard extends StatelessWidget {
  const _RestTimerCard({
    required this.secondsRemaining,
    required this.onSkip,
    required this.onAdd30,
  });

  final int secondsRemaining;
  final VoidCallback onSkip;
  final VoidCallback onAdd30;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final duration = Duration(seconds: secondsRemaining);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_bottom_rounded,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rest Timer',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  DateTimeUtils.formatDuration(duration),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onAdd30, child: const Text('+30s')),
          ElevatedButton(
            onPressed: onSkip,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(70, 36),
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
