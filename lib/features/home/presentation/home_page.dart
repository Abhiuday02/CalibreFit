import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/features/auth/presentation/auth_providers.dart';
import 'package:calibrefit/features/home/presentation/home_providers.dart';
import 'package:calibrefit/features/home/presentation/widgets/greeting_header.dart';
import 'package:calibrefit/features/home/presentation/widgets/quick_progress_card.dart';
import 'package:calibrefit/features/home/presentation/widgets/todays_workout_card.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:calibrefit/features/workouts/presentation/active_workout_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Phase 3 & 4 — Home Dashboard with Exercise Library integration.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final workoutAsync = ref.watch(todaysWorkoutProvider);
    final progressAsync = ref.watch(quickProgressSummaryProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final user = switch (authState) {
      AuthStateAuthenticated(:final user) => user,
      _ => null,
    };

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todaysWorkoutProvider);
            ref.invalidate(quickProgressSummaryProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // ── 1. Greeting & Profile Header ──────────────────────────
                GreetingHeader(user: user),

                const SizedBox(height: AppSpacing.lg),

                // ── 2. Quick Progress Summary ──────────────────────────────
                progressAsync.when(
                  data: (summary) => QuickProgressCard(summary: summary),
                  loading: () => const SizedBox(
                    height: 120,
                    child: AppLoader(label: 'Loading progress...'),
                  ),
                  error: (err, _) => AppErrorWidget(
                    message: 'Could not load progress summary.',
                    onRetry: () => ref.invalidate(quickProgressSummaryProvider),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── 3. Quick Navigation Cards ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        onTap: () => context.push(AppRoutes.exerciseLibrary),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Exercises',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Library',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppCard(
                        onTap: () => context.push(AppRoutes.workoutHistory),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: Colors.teal.shade700,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'History',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Calendar',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppCard(
                        onTap: () => context.push(AppRoutes.analytics),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Icon(
                                Icons.insights_rounded,
                                color: Colors.purple.shade700,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Analytics',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '1RM & Vol',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── 4. Today's Workout ────────────────────────────────────
                workoutAsync.when(
                  data: (workout) => TodaysWorkoutCard(
                    workout: workout,
                    onStartWorkout: () {
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .startWorkout(workout);
                      context.push(AppRoutes.activeWorkout);
                    },
                    onExerciseTap: (exercise) {
                      context.push(AppRoutes.exerciseLibrary);
                    },
                  ),
                  loading: () => const SizedBox(
                    height: 250,
                    child: AppLoader(label: "Loading today's workout..."),
                  ),
                  error: (err, _) => AppErrorWidget(
                    message: "Could not load today's workout.",
                    onRetry: () => ref.invalidate(todaysWorkoutProvider),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
