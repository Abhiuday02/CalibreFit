import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/analytics/domain/volume_analytics.dart';
import 'package:calibrefit/features/analytics/presentation/analytics_providers.dart';
import 'package:calibrefit/features/analytics/presentation/widgets/muscle_volume_breakdown_card.dart';
import 'package:calibrefit/features/analytics/presentation/widgets/one_rep_max_calculator_card.dart';
import 'package:calibrefit/features/analytics/presentation/widgets/progression_chart.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Comprehensive Analytics & Progression dashboard.
class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  int _selectedChartTab = 0; // 0 = Weekly Volume, 1 = 1RM Progression

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selectedRange = ref.watch(selectedTimeRangeProvider);
    final summaryAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Progression')),
      body: summaryAsync.when(
        data: (summary) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(analyticsSummaryProvider);
            ref.invalidate(weeklyVolumeTrendProvider);
            ref.invalidate(muscleGroupBreakdownProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            children: [
              // ── 1. Time Range Filter Chips ─────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TimeRange.values.map((range) {
                    final isSelected = selectedRange == range;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        label: Text(range.displayName),
                        selected: isSelected,
                        onSelected: (_) {
                          ref
                              .read(selectedTimeRangeProvider.notifier)
                              .select(range);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── 2. Summary Metric Cards ────────────────────────────────
              _AnalyticsSummaryBanner(summary: summary),

              const SizedBox(height: AppSpacing.md),

              // ── 3. Progression Chart Card ──────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progression Trends',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        // Segmented button for chart toggle
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                              value: 0,
                              label: Text('Volume'),
                              icon: Icon(Icons.bar_chart, size: 16),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text('1RM'),
                              icon: Icon(Icons.show_chart, size: 16),
                            ),
                          ],
                          selected: {_selectedChartTab},
                          onSelectionChanged: (val) {
                            setState(() => _selectedChartTab = val.first);
                          },
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: WidgetStatePropertyAll(
                              textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _selectedChartTab == 0
                          ? 'Weekly total tonnage lifted (kg) over time'
                          : 'Bench Press estimated 1RM progression curve',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_selectedChartTab == 0)
                      WeeklyVolumeChart(points: summary.volumePoints)
                    else
                      Consumer(
                        builder: (context, ref, _) {
                          final repo = ref.watch(analyticsRepositoryProvider);
                          return FutureBuilder(
                            future: repo.getExerciseProgression(
                              'ex-bench-press',
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 180,
                                  child: AppLoader(
                                    label: 'Loading progression...',
                                  ),
                                );
                              }
                              final points = snapshot.data ?? [];
                              return ProgressionLineChart(points: points);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── 4. Muscle Group Distribution Breakdown ─────────────────
              MuscleVolumeBreakdownCard(breakdowns: summary.muscleBreakdowns),

              const SizedBox(height: AppSpacing.md),

              // ── 5. 1RM Calculator Card ─────────────────────────────────
              const OneRepMaxCalculatorCard(),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        loading: () => const Center(
          child: AppLoader(label: 'Analyzing workout volume & progression...'),
        ),
        error: (err, _) => AppErrorWidget(
          message: 'Failed to load analytics data.',
          onRetry: () => ref.invalidate(analyticsSummaryProvider),
        ),
      ),
    );
  }
}

class _AnalyticsSummaryBanner extends StatelessWidget {
  const _AnalyticsSummaryBanner({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL VOLUME',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${summary.totalVolumeKg.toStringAsFixed(0)} kg',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${summary.volumeChangePercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricColumn(
                label: 'Workouts',
                value: '${summary.totalWorkouts}',
              ),
              _MetricColumn(label: 'Total Sets', value: '${summary.totalSets}'),
              _MetricColumn(label: 'Total Reps', value: '${summary.totalReps}'),
              _MetricColumn(
                label: 'Avg / Workout',
                value:
                    '${summary.averageWorkoutVolumeKg.toStringAsFixed(0)} kg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
