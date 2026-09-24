import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/exercise_library/presentation/exercise_library_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Comprehensive Exercise Detail Page.
///
/// Displays:
///   - Name, Category, Equipment, Difficulty, AI Supported badge
///   - Target muscles (Primary & Secondary)
///   - Video/Animation preview banner
///   - Prescription: Sets, Reps, Suggested Load, Rest
///   - Correct posture & setup
///   - Step-by-step instructions
///   - Breathing technique
///   - Tempo breakdown
///   - Common mistakes to avoid
class ExerciseDetailPage extends ConsumerWidget {
  const ExerciseDetailPage({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseDetailProvider(exerciseId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Exercise Details'), centerTitle: false),
      body: exerciseAsync.when(
        data: (exercise) {
          if (exercise == null) {
            return const AppErrorWidget(
              message: 'Exercise not found in the library.',
            );
          }
          return _ExerciseDetailContent(exercise: exercise);
        },
        loading: () => const AppLoader(label: 'Loading exercise details...'),
        error: (err, _) => AppErrorWidget(
          message: 'Failed to load exercise details.',
          onRetry: () => ref.invalidate(exerciseDetailProvider(exerciseId)),
        ),
      ),
    );
  }
}

class _ExerciseDetailContent extends StatelessWidget {
  const _ExerciseDetailContent({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Video / Animation Preview ────────────────────────────
          _MediaPreview(exercise: exercise),

          const SizedBox(height: AppSpacing.lg),

          // ── 2. Exercise Title & Category ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.category.displayName} • ${exercise.equipment}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (exercise.aiSupported)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Ready',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          if (exercise.aiSupported) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Analyze Form with AI Camera'),
                onPressed: () {
                  final exKey = exercise.name.toLowerCase().contains('squat')
                      ? 'squat'
                      : exercise.name.toLowerCase().contains('push')
                      ? 'pushup'
                      : 'curl';
                  context.push('${AppRoutes.formAnalysis}?exercise=$exKey');
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── 3. Target Prescription (Sets, Reps, Load, Rest) ─────────
          _PrescriptionGrid(exercise: exercise),

          const SizedBox(height: AppSpacing.lg),

          // ── 4. Target Muscles ───────────────────────────────────────
          _SectionCard(
            title: 'Target Muscles',
            icon: Icons.accessibility_new_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primary Muscles',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: exercise.primaryMuscles
                      .map(
                        (m) => Chip(
                          label: Text(m),
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Secondary Muscles',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: exercise.secondaryMuscles
                        .map(
                          (m) => Chip(
                            label: Text(m),
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── 5. Correct Posture & Setup ──────────────────────────────
          _SectionCard(
            title: 'Correct Posture & Setup',
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.teal,
            child: Column(
              children: exercise.correctPosture
                  .map((item) => _BulletPoint(text: item, icon: Icons.check))
                  .toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── 6. Step-by-Step Instructions ────────────────────────────
          _SectionCard(
            title: 'Instructions',
            icon: Icons.format_list_numbered_rounded,
            child: Column(
              children: exercise.instructions.asMap().entries.map((entry) {
                return _NumberedPoint(number: entry.key + 1, text: entry.value);
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── 7. Breathing Technique & Tempo ──────────────────────────
          _SectionCard(
            title: 'Breathing & Tempo',
            icon: Icons.air_rounded,
            iconColor: Colors.lightBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tempo',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exercise.tempo,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.air_rounded,
                      size: 20,
                      color: Colors.lightBlue,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Breathing',
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exercise.breathing,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── 8. Common Mistakes ──────────────────────────────────────
          _SectionCard(
            title: 'Common Mistakes',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.amber.shade800,
            child: Column(
              children: exercise.commonMistakes
                  .map(
                    (item) => _BulletPoint(
                      text: item,
                      icon: Icons.close_rounded,
                      color: colorScheme.error,
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal Components
// ---------------------------------------------------------------------------

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text(
                'Animation / Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionGrid extends StatelessWidget {
  const _PrescriptionGrid({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Prescription',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _PrescriptionTile(
                label: 'SETS',
                value: '${exercise.defaultSets}',
                subtitle: 'working sets',
              ),
              _PrescriptionTile(
                label: 'REPS',
                value: exercise.defaultRepRange,
                subtitle: 'per set',
              ),
              _PrescriptionTile(
                label: 'LOAD',
                value: '${exercise.defaultSuggestedLoadKg} kg',
                subtitle: 'suggested',
                valueColor: colorScheme.primary,
              ),
              _PrescriptionTile(
                label: 'REST',
                value: '${exercise.defaultRestSeconds}s',
                subtitle: 'between sets',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  const _PrescriptionTile({
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text, required this.icon, this.color});

  final String text;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.teal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedPoint extends StatelessWidget {
  const _NumberedPoint({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
