import 'package:calibrefit/features/analytics/data/mock_analytics_repository.dart';
import 'package:calibrefit/features/analytics/domain/one_rep_max.dart';
import 'package:calibrefit/features/analytics/domain/volume_analytics.dart';
import 'package:calibrefit/features/history/data/mock_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAnalyticsRepository repository;

  setUp(() {
    repository = MockAnalyticsRepository(
      historyRepository: MockHistoryRepository(),
    );
  });

  group('MockAnalyticsRepository', () {
    test('getAnalyticsSummary returns complete summary with metrics', () async {
      final summary = await repository.getAnalyticsSummary(
        timeRange: TimeRange.past30Days,
      );

      expect(summary.timeRange, TimeRange.past30Days);
      expect(summary.totalVolumeKg, greaterThan(0));
      expect(summary.totalWorkouts, greaterThan(0));
      expect(summary.totalSets, greaterThan(0));
      expect(summary.totalReps, greaterThan(0));
      expect(summary.averageWorkoutVolumeKg, greaterThan(0));
      expect(summary.volumeChangePercent, 8.5);
      expect(summary.volumePoints.isNotEmpty, isTrue);
      expect(summary.muscleBreakdowns.isNotEmpty, isTrue);
    });

    test('getWeeklyVolumeTrend returns requested number of weeks', () async {
      final trend6 = await repository.getWeeklyVolumeTrend(weeks: 6);
      expect(trend6.length, 6);
      expect(trend6.first.label, 'Wk 1');
      expect(trend6.last.label, 'Wk 6');
      expect(trend6.last.volumeKg, greaterThan(trend6.first.volumeKg));

      final trend8 = await repository.getWeeklyVolumeTrend(weeks: 8);
      expect(trend8.length, 8);
    });

    test('getMuscleGroupBreakdown returns muscle groups and volume status', () async {
      final breakdown = await repository.getMuscleGroupBreakdown(
        timeRange: TimeRange.past30Days,
      );

      expect(breakdown.length, 6);

      final chest = breakdown.firstWhere((m) => m.muscleName == 'Chest');
      expect(chest.totalVolumeKg, greaterThan(0));
      expect(chest.totalSets, greaterThan(0));
      expect(chest.volumeStatus, VolumeStatus.optimal);

      final core = breakdown.firstWhere((m) => m.muscleName == 'Core');
      expect(core.volumeStatus, VolumeStatus.low);

      final totalPct = breakdown
          .map((m) => m.percentageOfTotal)
          .fold<double>(0.0, (a, b) => a + b);
      expect(totalPct, closeTo(100.0, 1.0));
    });

    test('getMuscleGroupBreakdown scales volume by time range', () async {
      final weekBreakdown = await repository.getMuscleGroupBreakdown(
        timeRange: TimeRange.past7Days,
      );
      final monthBreakdown = await repository.getMuscleGroupBreakdown(
        timeRange: TimeRange.past30Days,
      );

      final weekChest =
          weekBreakdown.firstWhere((m) => m.muscleName == 'Chest');
      final monthChest =
          monthBreakdown.firstWhere((m) => m.muscleName == 'Chest');

      expect(monthChest.totalVolumeKg, greaterThan(weekChest.totalVolumeKg));
      expect(monthChest.totalSets, greaterThan(weekChest.totalSets));
    });

    test('getExerciseProgression respects selected 1RM formula', () async {
      final epleyPoints = await repository.getExerciseProgression(
        'ex-bench-press',
        formula: OneRepMaxFormula.epley,
      );
      final brzyckiPoints = await repository.getExerciseProgression(
        'ex-bench-press',
        formula: OneRepMaxFormula.brzycki,
      );

      expect(epleyPoints.length, 5);
      expect(brzyckiPoints.length, 5);

      for (int i = 0; i < epleyPoints.length; i++) {
        expect(epleyPoints[i].weightKg, brzyckiPoints[i].weightKg);
        expect(epleyPoints[i].reps, brzyckiPoints[i].reps);
        expect(epleyPoints[i].estimated1RmKg, greaterThan(0));
        expect(brzyckiPoints[i].estimated1RmKg, greaterThan(0));
      }
    });
  });
}

