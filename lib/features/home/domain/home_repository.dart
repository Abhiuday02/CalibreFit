import 'package:calibrefit/features/home/domain/daily_workout.dart';

/// Contract for fetching home dashboard data.
///
/// In Phase 3, this is implemented by [MockHomeRepository].
/// Later phases will source this from the local database (Drift) and remote API.
abstract interface class HomeRepository {
  /// Returns the scheduled or suggested workout for today.
  Future<DailyWorkout> getTodaysWorkout();

  /// Returns the user's high-level training consistency and volume summary.
  Future<QuickProgressSummary> getQuickProgressSummary();
}
