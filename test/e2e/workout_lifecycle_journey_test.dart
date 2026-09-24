import 'package:calibrefit/features/analytics/data/mock_analytics_repository.dart';
import 'package:calibrefit/features/analytics/domain/one_rep_max.dart';
import 'package:calibrefit/features/history/data/mock_history_repository.dart';
import 'package:calibrefit/features/history/presentation/history_providers.dart';
import 'package:calibrefit/features/home/presentation/home_providers.dart';
import 'package:calibrefit/features/recommendations/data/mock_recommendations_repository.dart';
import 'package:calibrefit/features/set_logging/data/local_set_log_repository.dart';
import 'package:calibrefit/features/set_logging/presentation/set_log_providers.dart';
import 'package:calibrefit/features/workouts/presentation/active_workout_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('E2E: Workout Lifecycle & Analytics Flow', () {
    late ProviderContainer container;
    late MockHistoryRepository historyRepo;
    late LocalSetLogRepository setLogRepo;
    late MockAnalyticsRepository analyticsRepo;
    late MockRecommendationsRepository recommendationsRepo;

    setUp(() {
      historyRepo = MockHistoryRepository();
      setLogRepo = LocalSetLogRepository();
      analyticsRepo = MockAnalyticsRepository(historyRepository: historyRepo);
      recommendationsRepo = MockRecommendationsRepository();

      container = ProviderContainer(
        overrides: [
          historyRepositoryProvider.overrideWithValue(historyRepo),
          setLogRepositoryProvider.overrideWithValue(setLogRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('User can start today\'s workout, log sets with RPE/RIR, finish, and reflect volume in history & analytics', () async {
      // ── Step 1: Fetch Today's Workout ─────────────────────────────────────
      final workoutPlan = await container.read(todaysWorkoutProvider.future);
      expect(workoutPlan.exercises, isNotEmpty);
      expect(workoutPlan.title, equals("Today's Workout"));
      expect(workoutPlan.targetMuscles, contains('Chest'));

      // ── Step 2: Start Active Workout Session ──────────────────────────────
      final activeNotifier = container.read(activeWorkoutProvider.notifier);
      activeNotifier.startWorkout(workoutPlan);

      final initialSession = container.read(activeWorkoutProvider);
      expect(initialSession, isNotNull);
      expect(initialSession!.exercises.length, equals(workoutPlan.exercises.length));
      expect(initialSession.completedSetsCount, equals(0));

      // ── Step 3: Log Sets with Actual Weight, Reps, RPE, and RIR ───────────
      // Complete Exercise 0, Set 0: 80kg x 8 reps, RPE 8.5, RIR 1
      activeNotifier.updateSetActuals(
        exerciseIndex: 0,
        setIndex: 0,
        actualWeight: 80.0,
        actualReps: 8,
        rpe: 8.5,
        rir: 1,
        notes: 'Felt solid and controlled.',
      );
      activeNotifier.toggleSet(0, 0);

      // Complete Exercise 0, Set 1: 82.5kg x 8 reps, RPE 9.0, RIR 1
      activeNotifier.updateSetActuals(
        exerciseIndex: 0,
        setIndex: 1,
        actualWeight: 82.5,
        actualReps: 8,
        rpe: 9.0,
        rir: 1,
      );
      activeNotifier.toggleSet(0, 1);

      final sessionAfterSets = container.read(activeWorkoutProvider);
      expect(sessionAfterSets, isNotNull);
      expect(sessionAfterSets!.completedSetsCount, equals(2));

      // ── Step 4: Finish Workout Session ────────────────────────────────────
      final summary = activeNotifier.finishWorkout();
      expect(summary, isNotNull);
      expect(summary!.totalSetsCompleted, equals(2));
      expect(
        summary.totalVolumeKg,
        equals((80.0 * 8) + (82.5 * 8)),
      ); // 640 + 660 = 1300kg

      // ── Step 5: Verify History Record Persisted ───────────────────────────
      final historyRecords = await historyRepo.getWorkoutHistory();
      expect(historyRecords.any((r) => r.id == sessionAfterSets.id), isTrue);
      final recorded = historyRecords.firstWhere((r) => r.id == sessionAfterSets.id);
      expect(recorded.totalVolumeKg, equals(1300.0));

      // ── Step 6: Verify 1RM & Analytics Calculation ────────────────────────
      final estimate = calculateOneRepMaxEstimate(
        weight: 82.5,
        reps: 8,
        formula: OneRepMaxFormula.epley,
      );
      expect(estimate.selected1RmKg, greaterThan(100.0));

      final volumeTrend = await analyticsRepo.getWeeklyVolumeTrend(weeks: 4);
      expect(volumeTrend, isNotEmpty);

      // ── Step 7: Verify Progressive Overload Recommendation ────────────────
      final recommendations = await recommendationsRepo.getAllActiveRecommendations();
      expect(recommendations, isNotEmpty);
      expect(recommendations.first.explanation, isNotEmpty);
    });
  });
}
