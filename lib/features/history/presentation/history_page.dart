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

/// Workout History Screen.
///
/// Features:
///   - Week calendar view showing workout activity dots
///   - Overall volume, reps, and workout count summary
///   - Workout history list displaying duration, volume, reps, and exercises
///   - Tap navigation to detailed workout breakdown
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  String _formatVolume(double volumeKg) {
    if (volumeKg >= 1000) {
      return '${(volumeKg / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volumeKg.toStringAsFixed(0)} kg';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryListProvider);
    final selectedDate = ref.watch(selectedHistoryDateProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Workout History'), centerTitle: false),
      body: historyAsync.when(
        data: (allRecords) {
          // Filter records by selected date if one is picked
          final records = selectedDate == null
              ? allRecords
              : allRecords.where((r) {
                  return r.date.year == selectedDate.year &&
                      r.date.month == selectedDate.month &&
                      r.date.day == selectedDate.day;
                }).toList();

          final totalVolume = allRecords.fold(
            0.0,
            (sum, r) => sum + r.totalVolumeKg,
          );
          final totalReps = allRecords.fold(0, (sum, r) => sum + r.totalReps);

          return Column(
            children: [
              // ── 1. Week Calendar Strip ──────────────────────────────
              _WeekCalendarStrip(
                records: allRecords,
                selectedDate: selectedDate,
                onSelectDate: (date) {
                  final notifier = ref.read(
                    selectedHistoryDateProvider.notifier,
                  );
                  if (selectedDate != null &&
                      selectedDate.year == date.year &&
                      selectedDate.month == date.month &&
                      selectedDate.day == date.day) {
                    notifier.select(null); // toggle off
                  } else {
                    notifier.select(date);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── 2. Summary Metrics Strip ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'WORKOUTS',
                        value: '${allRecords.length}',
                        color: colorScheme.primary,
                      ),
                      Container(
                        height: 32,
                        width: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      _StatColumn(
                        label: 'TOTAL VOLUME',
                        value: _formatVolume(totalVolume),
                        color: Colors.amber.shade800,
                      ),
                      Container(
                        height: 32,
                        width: 1,
                        color: colorScheme.outlineVariant,
                      ),
                      _StatColumn(
                        label: 'TOTAL REPS',
                        value: '$totalReps',
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── 3. History List ─────────────────────────────────────
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 56,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No workouts for this date',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextButton(
                              onPressed: () => ref
                                  .read(selectedHistoryDateProvider.notifier)
                                  .select(null),
                              child: const Text('Show All History'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: records.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return _WorkoutHistoryCard(
                            record: record,
                            onTap: () {
                              context.push(
                                '${AppRoutes.workoutHistory}/${record.id}',
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const AppLoader(label: 'Loading workout history...'),
        error: (err, _) => AppErrorWidget(
          message: 'Failed to load workout history.',
          onRetry: () => ref.invalidate(workoutHistoryListProvider),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week Calendar Strip Component
// ---------------------------------------------------------------------------

class _WeekCalendarStrip extends StatelessWidget {
  const _WeekCalendarStrip({
    required this.records,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final List<WorkoutHistoryRecord> records;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Generate current week starting 6 days ago up to today
    final days = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final isSelected =
              selectedDate != null &&
              selectedDate!.year == day.year &&
              selectedDate!.month == day.month &&
              selectedDate!.day == day.day;

          final hasWorkout = records.any(
            (r) =>
                r.date.year == day.year &&
                r.date.month == day.month &&
                r.date.day == day.day,
          );

          final dayName = _dayOfWeekName(day.weekday);

          return GestureDetector(
            onTap: () => onSelectDate(day),
            child: AnimatedContainer(
              duration: AppAnimation.fast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : (hasWorkout
                          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : (hasWorkout
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              )),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Workout Indicator Dot
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: hasWorkout
                          ? (isSelected ? Colors.white : colorScheme.primary)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _dayOfWeekName(int weekday) => switch (weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    DateTime.sunday => 'Sun',
    _ => '',
  };
}

// ---------------------------------------------------------------------------
// Stat Column Helper
// ---------------------------------------------------------------------------

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Workout History Card
// ---------------------------------------------------------------------------

class _WorkoutHistoryCard extends StatelessWidget {
  const _WorkoutHistoryCard({required this.record, required this.onTap});

  final WorkoutHistoryRecord record;
  final VoidCallback onTap;

  String _formatVolume(double volumeKg) {
    if (volumeKg >= 1000) {
      return '${(volumeKg / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volumeKg.toStringAsFixed(0)} kg';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final durationMin = (record.durationSeconds / 60).round();

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Relative Date & Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  DateTimeUtils.relativeLabel(record.date),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$durationMin min',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Workout Title & Target Muscles
          Text(
            record.workoutTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            record.targetMuscles,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Metrics row: Volume, Reps, Sets
          Row(
            children: [
              _MetricBadge(
                icon: Icons.fitness_center_rounded,
                label: _formatVolume(record.totalVolumeKg),
                color: Colors.amber.shade800,
              ),
              const SizedBox(width: AppSpacing.md),
              _MetricBadge(
                icon: Icons.repeat_rounded,
                label: '${record.totalReps} reps',
                color: Colors.teal,
              ),
              const SizedBox(width: AppSpacing.md),
              _MetricBadge(
                icon: Icons.format_list_numbered_rounded,
                label: '${record.totalSets} sets',
                color: colorScheme.primary,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Exercise names preview chips
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: 4,
            children: record.exerciseSummaries.map((ex) {
              return Text(
                '• ${ex.exerciseName} (${ex.setsCount})',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
