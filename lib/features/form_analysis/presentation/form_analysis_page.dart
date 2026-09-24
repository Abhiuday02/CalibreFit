import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/form_analysis/domain/form_feedback.dart';
import 'package:calibrefit/features/form_analysis/presentation/form_analysis_providers.dart';
import 'package:calibrefit/features/form_analysis/presentation/widgets/form_feedback_banner.dart';
import 'package:calibrefit/features/form_analysis/presentation/widgets/pose_canvas_painter.dart';
import 'package:calibrefit/features/form_analysis/presentation/widgets/rep_counter_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen AI Exercise Form Analysis camera viewport.
class FormAnalysisPage extends ConsumerStatefulWidget {
  const FormAnalysisPage({super.key, this.initialExercise = 'squat'});

  final String initialExercise;

  @override
  ConsumerState<FormAnalysisPage> createState() => _FormAnalysisPageState();
}

class _FormAnalysisPageState extends ConsumerState<FormAnalysisPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(formAnalysisExerciseTypeProvider.notifier)
          .select(widget.initialExercise);
      ref.read(formAnalysisStateProvider.notifier).startTracking();
    });
  }

  void _showSetSummaryModal(BuildContext context, FormSetSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Analysis Complete',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        summary.exerciseName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      summary.qualityTier,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    label: 'TOTAL REPS',
                    value: '${summary.totalReps}',
                  ),
                  _SummaryStat(
                    label: 'FORM SCORE',
                    value: '${summary.averageFormScore.toStringAsFixed(0)}%',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'AI Feedback Breakdown',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (summary.feedbackList.isEmpty)
                Text(
                  'No form faults detected.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...summary.feedbackList.take(4).map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          f.severity == FeedbackSeverity.good
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: f.severity == FeedbackSeverity.good
                              ? const Color(0xFF10B981)
                              : Colors.amber.shade700,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(f.message, style: textTheme.bodySmall),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Done & Return'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedExercise = ref.watch(formAnalysisExerciseTypeProvider);
    final formState = ref.watch(formAnalysisStateProvider);
    final notifier = ref.read(formAnalysisStateProvider.notifier);

    // Listen for set completion to display summary modal
    ref.listen<FormAnalysisState>(formAnalysisStateProvider, (prev, next) {
      if (!prev!.isCompleted && next.isCompleted && next.summary != null) {
        _showSetSummaryModal(context, next.summary!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Camera / Skeleton Viewport ────────────────────────
          Container(
            color: const Color(0xFF0F172A), // Dark slate camera backdrop
            child: Center(
              child: Semantics(
                label: AppSemantics.formCamera,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PoseCanvasPainter(
                      frame: formState.latestFrame,
                      boneColor: const Color(
                        0xFF10B981,
                      ), // Emerald green skeleton
                      jointColor: colorScheme.primary,
                      accentColor: colorScheme.tertiary,
                      keyAngles: formState.keyAngles,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          // ── 2. Top Header Overlay ────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'MediaPipe Pose • 15 FPS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Exercise Selector Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ExerciseChip(
                          title: 'Squats',
                          value: 'squat',
                          selectedValue: selectedExercise,
                          onSelected: (val) => ref
                              .read(formAnalysisExerciseTypeProvider.notifier)
                              .select(val),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _ExerciseChip(
                          title: 'Push-ups',
                          value: 'pushup',
                          selectedValue: selectedExercise,
                          onSelected: (val) => ref
                              .read(formAnalysisExerciseTypeProvider.notifier)
                              .select(val),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _ExerciseChip(
                          title: 'Bicep Curls',
                          value: 'curl',
                          selectedValue: selectedExercise,
                          onSelected: (val) => ref
                              .read(formAnalysisExerciseTypeProvider.notifier)
                              .select(val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ── 3. Rep Counter HUD ─────────────────────────────
                  RepCounterHud(
                    reps: formState.reps,
                    phase: formState.phase,
                    keyAngles: formState.keyAngles,
                  ),
                ],
              ),
            ),
          ),

          // ── 4. Floating Real-Time Feedback Banner ────────────────
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 96,
            child: FormFeedbackBanner(feedback: formState.latestFeedback),
          ),

          // ── 5. Bottom Action Controls ────────────────────────────
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 24,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: formState.isActive
                          ? Colors.amber.shade800
                          : const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(
                      formState.isActive ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(
                      formState.isActive ? 'Pause' : 'Start Tracking',
                    ),
                    onPressed: () {
                      if (formState.isActive) {
                        notifier.pauseTracking();
                      } else {
                        notifier.startTracking();
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Finish Set'),
                    onPressed: () => notifier.finishSet(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip({
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  final String title;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: const Color(0xFF10B981),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.black : Colors.white,
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.6),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
