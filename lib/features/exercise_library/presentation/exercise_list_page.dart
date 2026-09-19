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

/// Exercise Library List Page.
///
/// Features:
///   - Real-time search by name, muscle, or equipment
///   - Horizontal category filter chips
///   - Exercise card with badges (Difficulty, Equipment, AI Form Ready)
///   - Empty, loading, and error states
class ExerciseListPage extends ConsumerStatefulWidget {
  const ExerciseListPage({super.key});

  @override
  ConsumerState<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends ConsumerState<ExerciseListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(exerciseSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedCategory = ref.watch(selectedCategoryProvider);
    final exercisesAsync = ref.watch(filteredExercisesProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Exercise Library'), centerTitle: false),
      body: Column(
        children: [
          // ── Search Bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises, muscles, equipment...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(exerciseSearchQueryProvider.notifier)
                              .clear();
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() {});
                ref.read(exerciseSearchQueryProvider.notifier).setQuery(val);
              },
            ),
          ),

          // ── Category Filter Chips ─────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: selectedCategory == null,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).select(null);
                    },
                  ),
                ),
                ...ExerciseCategory.values.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(cat.displayName),
                      selected: selectedCategory == cat,
                      onSelected: (selected) {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .select(selected ? cat : null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Exercise List Content ─────────────────────────────────────
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No exercises found',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Try adjusting your search or category filter.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: exercises.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return _ExerciseListItem(
                      exercise: exercise,
                      onTap: () {
                        context.push(
                          '${AppRoutes.exerciseLibrary}/${exercise.id}',
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const AppLoader(label: 'Loading exercises...'),
              error: (err, _) => AppErrorWidget(
                message: 'Failed to load exercises.',
                onRetry: () => ref.invalidate(filteredExercisesProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  const _ExerciseListItem({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  Color _difficultyColor(ExerciseDifficulty diff, ColorScheme scheme) =>
      switch (diff) {
        ExerciseDifficulty.beginner => Colors.green,
        ExerciseDifficulty.intermediate => Colors.orange,
        ExerciseDifficulty.advanced => scheme.error,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Muscle / Category indicator icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Exercise Title & Target Muscles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exercise.primaryMuscles.join(', '),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Badges row: Equipment, Difficulty, and AI Form badge
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              // Equipment badge
              _Badge(
                label: exercise.equipment,
                icon: Icons.handyman_outlined,
                color: colorScheme.surfaceContainerHighest,
                textColor: colorScheme.onSurfaceVariant,
              ),
              // Difficulty badge
              _Badge(
                label: exercise.difficulty.displayName,
                color: _difficultyColor(
                  exercise.difficulty,
                  colorScheme,
                ).withValues(alpha: 0.15),
                textColor: _difficultyColor(exercise.difficulty, colorScheme),
              ),
              // AI Supported Badge
              if (exercise.aiSupported)
                _Badge(
                  label: 'AI Form Ready',
                  icon: Icons.auto_awesome_rounded,
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  textColor: colorScheme.primary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
