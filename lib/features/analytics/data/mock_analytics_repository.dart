import 'package:calibrefit/features/analytics/domain/analytics_repository.dart';
import 'package:calibrefit/features/analytics/domain/one_rep_max.dart';
import 'package:calibrefit/features/analytics/domain/volume_analytics.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/history/domain/history_repository.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';

/// In-memory implementation of [AnalyticsRepository].
///
/// Combines live data from [HistoryRepository] with historical baseline points
/// to produce comprehensive volume and progression analytics.
class MockAnalyticsRepository implements AnalyticsRepository {
  MockAnalyticsRepository({this.historyRepository});

  final HistoryRepository? historyRepository;
  static const _delay = Duration(milliseconds: 150);

  @override
  Future<AnalyticsSummary> getAnalyticsSummary({
    TimeRange timeRange = TimeRange.past30Days,
  }) async {
    await Future.delayed(_delay);

    final weeklyTrend = await getWeeklyVolumeTrend(weeks: 6);
    final muscleBreakdown = await getMuscleGroupBreakdown(timeRange: timeRange);

    // Calculate totals across muscle breakdowns
    double totalVolume = 0.0;
    int totalSets = 0;
    for (final m in muscleBreakdown) {
      totalVolume += m.totalVolumeKg;
      totalSets += m.totalSets;
    }

    // Default estimate of workouts and reps if history repository is empty
    int totalWorkouts = 14;
    int totalReps = totalSets * 9;

    if (historyRepository != null) {
      final history = await historyRepository!.getWorkoutHistory();
      if (history.isNotEmpty) {
        totalWorkouts = history.length;
        double histVol = 0.0;
        int histSets = 0;
        int histReps = 0;
        for (final rec in history) {
          histVol += rec.totalVolumeKg;
          histSets += rec.totalSets;
          histReps += rec.totalReps;
        }
        // Augment with baseline if small
        if (histVol > 0) {
          totalVolume = totalVolume > histVol ? totalVolume : histVol;
          totalSets = totalSets > histSets ? totalSets : histSets;
          totalReps = totalReps > histReps ? totalReps : histReps;
        }
      }
    }

    final avgVolume = totalWorkouts > 0
        ? (totalVolume / totalWorkouts).roundToDouble()
        : 0.0;

    return AnalyticsSummary(
      timeRange: timeRange,
      totalVolumeKg: (totalVolume * 10).round() / 10.0,
      totalWorkouts: totalWorkouts,
      totalSets: totalSets,
      totalReps: totalReps,
      averageWorkoutVolumeKg: avgVolume,
      volumeChangePercent: 8.5, // +8.5% volume progression over previous period
      volumePoints: weeklyTrend,
      muscleBreakdowns: muscleBreakdown,
    );
  }

  @override
  Future<List<VolumeMetricPoint>> getWeeklyVolumeTrend({int weeks = 8}) async {
    await Future.delayed(_delay);
    final now = DateTime.now();

    // 6-8 weeks of volume progression (simulating progressive overload)
    final baselineVolumes = <double>[
      8400.0,
      8950.0,
      9400.0,
      9850.0,
      10200.0,
      10950.0,
      11500.0,
      12100.0,
    ];

    final baselineSets = <int>[52, 54, 56, 58, 60, 64, 66, 70];

    final count = weeks.clamp(4, baselineVolumes.length);
    final points = <VolumeMetricPoint>[];

    for (int i = 0; i < count; i++) {
      final weekOffset = count - 1 - i;
      final weekDate = now.subtract(Duration(days: weekOffset * 7));
      final vol = baselineVolumes[baselineVolumes.length - count + i];
      final sets = baselineSets[baselineSets.length - count + i];

      points.add(
        VolumeMetricPoint(
          label: 'Wk ${i + 1}',
          date: weekDate,
          volumeKg: vol,
          setsCount: sets,
          repsCount: sets * 9,
        ),
      );
    }

    return points;
  }

  @override
  Future<List<MuscleGroupVolume>> getMuscleGroupBreakdown({
    TimeRange timeRange = TimeRange.past30Days,
  }) async {
    await Future.delayed(_delay);

    // Realistic volume distribution across major muscle groups
    // Optimal hypertrophy set volume is 10–20 sets per muscle group per week.
    final weeksMultiplier = switch (timeRange) {
      TimeRange.past7Days => 1.0,
      TimeRange.past30Days => 4.0,
      TimeRange.past90Days => 12.0,
      TimeRange.allTime => 16.0,
    };

    final rawData = <(ExerciseCategory, String, double, int)>[
      (ExerciseCategory.chest, 'Chest', 2850.0, 16),
      (ExerciseCategory.back, 'Back', 3120.0, 18),
      (ExerciseCategory.legs, 'Legs', 3950.0, 15),
      (ExerciseCategory.shoulders, 'Shoulders', 1650.0, 12),
      (ExerciseCategory.arms, 'Arms', 1420.0, 11),
      (ExerciseCategory.core, 'Core', 680.0, 8),
    ];

    double totalVolume = 0.0;
    for (final item in rawData) {
      totalVolume += item.$3 * weeksMultiplier;
    }

    return rawData.map((item) {
      final scaledVolume = ((item.$3 * weeksMultiplier) * 10).round() / 10.0;
      final scaledSets = (item.$4 * weeksMultiplier).round();
      final weeklySets = item.$4; // Weekly rate for status classification
      final percentage = totalVolume > 0
          ? ((scaledVolume / totalVolume) * 1000).round() / 10.0
          : 0.0;

      return MuscleGroupVolume(
        category: item.$1,
        muscleName: item.$2,
        totalVolumeKg: scaledVolume,
        totalSets: scaledSets,
        percentageOfTotal: percentage,
        volumeStatus: VolumeStatus.fromWeeklySets(weeklySets),
      );
    }).toList();
  }

  @override
  Future<List<ExerciseProgressPoint>> getExerciseProgression(
    String exerciseId, {
    OneRepMaxFormula formula = OneRepMaxFormula.epley,
  }) async {
    await Future.delayed(_delay);
    final now = DateTime.now();

    // Baseline historical progression for popular compound lifts
    final rawPoints = <(int, double, int, double)>[
      // (daysAgo, weight, reps, volume)
      (28, 40.0, 8, 320.0),
      (21, 40.0, 10, 400.0),
      (14, 42.5, 8, 340.0),
      (7, 45.0, 7, 315.0),
      (0, 45.0, 8, 360.0),
    ];

    return rawPoints.map((pt) {
      final date = now.subtract(Duration(days: pt.$1));
      final weight = pt.$2;
      final reps = pt.$3;
      final volume = pt.$4;
      final estimated1Rm = calculate1RM(weight, reps, formula);

      return ExerciseProgressPoint(
        date: date,
        weightKg: weight,
        reps: reps,
        volumeKg: volume,
        estimated1RmKg: (estimated1Rm * 10).round() / 10.0,
      );
    }).toList();
  }
}
