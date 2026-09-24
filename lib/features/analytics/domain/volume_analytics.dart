import 'package:calibrefit/features/exercise_library/domain/exercise.dart';

/// Time filter ranges for analytics summaries and progression charts.
enum TimeRange {
  past7Days,
  past30Days,
  past90Days,
  allTime;

  String get displayName => switch (this) {
    TimeRange.past7Days => '7 Days',
    TimeRange.past30Days => '30 Days',
    TimeRange.past90Days => '90 Days',
    TimeRange.allTime => 'All Time',
  };

  int? get inDays => switch (this) {
    TimeRange.past7Days => 7,
    TimeRange.past30Days => 30,
    TimeRange.past90Days => 90,
    TimeRange.allTime => null,
  };
}

/// Volume tier status based on evidence-based weekly hypertrophy set volume:
/// - Low: < 10 sets/week (maintenance or minimal effective dose)
/// - Optimal: 10–20 sets/week (maximum adaptive volume for hypertrophy)
/// - High: > 20 sets/week (high volume / overreaching risk)
enum VolumeStatus {
  low,
  optimal,
  high;

  String get label => switch (this) {
    VolumeStatus.low => 'Low Volume',
    VolumeStatus.optimal => 'Optimal Hypertrophy',
    VolumeStatus.high => 'High Volume',
  };

  static VolumeStatus fromWeeklySets(int sets) {
    if (sets < 10) return VolumeStatus.low;
    if (sets <= 20) return VolumeStatus.optimal;
    return VolumeStatus.high;
  }
}

/// A point in time representing workout volume for charting.
class VolumeMetricPoint {
  const VolumeMetricPoint({
    required this.label,
    required this.date,
    required this.volumeKg,
    required this.setsCount,
    required this.repsCount,
  });

  final String label; // e.g. "Mon", "Wk 1", "Sep 12"
  final DateTime date;
  final double volumeKg;
  final int setsCount;
  final int repsCount;
}

/// Muscle group volume distribution and hypertrophy status.
class MuscleGroupVolume {
  const MuscleGroupVolume({
    required this.category,
    required this.muscleName,
    required this.totalVolumeKg,
    required this.totalSets,
    required this.percentageOfTotal,
    required this.volumeStatus,
  });

  final ExerciseCategory category;
  final String muscleName;
  final double totalVolumeKg;
  final int totalSets;
  final double percentageOfTotal; // 0.0 to 100.0
  final VolumeStatus volumeStatus;
}

/// Comprehensive summary of fitness analytics and progression.
class AnalyticsSummary {
  const AnalyticsSummary({
    required this.timeRange,
    required this.totalVolumeKg,
    required this.totalWorkouts,
    required this.totalSets,
    required this.totalReps,
    required this.averageWorkoutVolumeKg,
    required this.volumeChangePercent,
    required this.volumePoints,
    required this.muscleBreakdowns,
  });

  final TimeRange timeRange;
  final double totalVolumeKg;
  final int totalWorkouts;
  final int totalSets;
  final int totalReps;
  final double averageWorkoutVolumeKg;
  final double volumeChangePercent; // e.g. +12.5% vs previous period
  final List<VolumeMetricPoint> volumePoints;
  final List<MuscleGroupVolume> muscleBreakdowns;
}
