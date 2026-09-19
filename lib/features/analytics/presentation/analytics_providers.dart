import 'package:calibrefit/features/analytics/data/mock_analytics_repository.dart';
import 'package:calibrefit/features/analytics/domain/analytics_repository.dart';
import 'package:calibrefit/features/analytics/domain/one_rep_max.dart';
import 'package:calibrefit/features/analytics/domain/volume_analytics.dart';
import 'package:calibrefit/features/history/presentation/history_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final historyRepo = ref.watch(historyRepositoryProvider);
  return MockAnalyticsRepository(historyRepository: historyRepo);
});

// ---------------------------------------------------------------------------
// Filter & Preference Providers
// ---------------------------------------------------------------------------

/// Selected time range for analytics views.
class SelectedTimeRangeNotifier extends Notifier<TimeRange> {
  @override
  TimeRange build() => TimeRange.past30Days;

  void select(TimeRange range) => state = range;
}

final selectedTimeRangeProvider =
    NotifierProvider<SelectedTimeRangeNotifier, TimeRange>(
      SelectedTimeRangeNotifier.new,
    );

/// User's preferred 1RM estimation formula.
class Selected1RmFormulaNotifier extends Notifier<OneRepMaxFormula> {
  @override
  OneRepMaxFormula build() => OneRepMaxFormula.epley;

  void select(OneRepMaxFormula formula) => state = formula;
}

final selected1RmFormulaProvider =
    NotifierProvider<Selected1RmFormulaNotifier, OneRepMaxFormula>(
      Selected1RmFormulaNotifier.new,
    );

// ---------------------------------------------------------------------------
// Analytics Data Providers
// ---------------------------------------------------------------------------

/// Aggregated analytics summary for the currently selected time range.
final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final timeRange = ref.watch(selectedTimeRangeProvider);
  return repo.getAnalyticsSummary(timeRange: timeRange);
});

/// Weekly volume trend points for charting.
final weeklyVolumeTrendProvider = FutureProvider<List<VolumeMetricPoint>>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getWeeklyVolumeTrend(weeks: 8);
});

/// Muscle group volume distribution for the selected time range.
final muscleGroupBreakdownProvider = FutureProvider<List<MuscleGroupVolume>>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final timeRange = ref.watch(selectedTimeRangeProvider);
  return repo.getMuscleGroupBreakdown(timeRange: timeRange);
});

// ---------------------------------------------------------------------------
// Interactive 1RM Calculator Provider
// ---------------------------------------------------------------------------

class OneRepMaxCalculatorState {
  const OneRepMaxCalculatorState({
    required this.weightKg,
    required this.reps,
    required this.formula,
    required this.estimate,
  });

  final double weightKg;
  final int reps;
  final OneRepMaxFormula formula;
  final OneRepMaxEstimate estimate;

  OneRepMaxCalculatorState copyWith({
    double? weightKg,
    int? reps,
    OneRepMaxFormula? formula,
  }) {
    final nextWeight = weightKg ?? this.weightKg;
    final nextReps = reps ?? this.reps;
    final nextFormula = formula ?? this.formula;

    return OneRepMaxCalculatorState(
      weightKg: nextWeight,
      reps: nextReps,
      formula: nextFormula,
      estimate: calculateOneRepMaxEstimate(
        weight: nextWeight,
        reps: nextReps,
        formula: nextFormula,
      ),
    );
  }
}

class OneRepMaxCalculatorNotifier extends Notifier<OneRepMaxCalculatorState> {
  @override
  OneRepMaxCalculatorState build() {
    return OneRepMaxCalculatorState(
      weightKg: 80.0,
      reps: 8,
      formula: OneRepMaxFormula.epley,
      estimate: calculateOneRepMaxEstimate(
        weight: 80.0,
        reps: 8,
        formula: OneRepMaxFormula.epley,
      ),
    );
  }

  void setWeight(double weight) {
    if (weight < 0) return;
    state = state.copyWith(weightKg: weight);
  }

  void setReps(int reps) {
    if (reps < 1 || reps > 50) return;
    state = state.copyWith(reps: reps);
  }

  void setFormula(OneRepMaxFormula formula) {
    state = state.copyWith(formula: formula);
  }
}

final oneRepMaxCalculatorProvider =
    NotifierProvider<OneRepMaxCalculatorNotifier, OneRepMaxCalculatorState>(
      OneRepMaxCalculatorNotifier.new,
    );
