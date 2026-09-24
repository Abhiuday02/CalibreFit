import 'package:calibrefit/features/analytics/domain/one_rep_max.dart';
import 'package:calibrefit/features/analytics/domain/volume_analytics.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';

/// Abstract contract for workout analytics, volume tracking, and progression.
abstract class AnalyticsRepository {
  /// Fetches an aggregated analytics summary for the specified [timeRange].
  Future<AnalyticsSummary> getAnalyticsSummary({
    TimeRange timeRange = TimeRange.past30Days,
  });

  /// Fetches the weekly volume trend data points for charting over [weeks].
  Future<List<VolumeMetricPoint>> getWeeklyVolumeTrend({int weeks = 8});

  /// Fetches the muscle group volume and set breakdown for [timeRange].
  Future<List<MuscleGroupVolume>> getMuscleGroupBreakdown({
    TimeRange timeRange = TimeRange.past30Days,
  });

  /// Fetches exercise progression points with estimated 1RM calculated
  /// using the specified [formula].
  Future<List<ExerciseProgressPoint>> getExerciseProgression(
    String exerciseId, {
    OneRepMaxFormula formula = OneRepMaxFormula.epley,
  });
}
