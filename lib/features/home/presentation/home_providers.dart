import 'package:calibrefit/features/home/data/mock_home_repository.dart';
import 'package:calibrefit/features/home/domain/daily_workout.dart';
import 'package:calibrefit/features/home/domain/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const MockHomeRepository();
});

// ---------------------------------------------------------------------------
// Dashboard Data Providers
// ---------------------------------------------------------------------------

/// Provides today's workout plan preview.
final todaysWorkoutProvider = FutureProvider<DailyWorkout>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getTodaysWorkout();
});

/// Provides the quick progress summary (consistency, streak, weekly volume).
final quickProgressSummaryProvider = FutureProvider<QuickProgressSummary>((
  ref,
) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getQuickProgressSummary();
});
