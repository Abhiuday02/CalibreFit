import 'package:calibrefit/features/history/data/mock_history_repository.dart';
import 'package:calibrefit/features/history/domain/history_repository.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return MockHistoryRepository();
});

// ---------------------------------------------------------------------------
// History Query Providers
// ---------------------------------------------------------------------------

/// Provides the full list of completed workouts ordered by date descending.
final workoutHistoryListProvider = FutureProvider<List<WorkoutHistoryRecord>>((
  ref,
) async {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.getWorkoutHistory();
});

/// Provides details for a single completed workout record by ID.
final workoutHistoryDetailProvider =
    FutureProvider.family<WorkoutHistoryRecord?, String>((ref, id) async {
      final repo = ref.watch(historyRepositoryProvider);
      return repo.getWorkoutHistoryById(id);
    });

/// Provides progression data points over time for an exercise.
final exerciseProgressProvider =
    FutureProvider.family<List<ExerciseProgressPoint>, String>((
      ref,
      exerciseId,
    ) async {
      final repo = ref.watch(historyRepositoryProvider);
      return repo.getExerciseProgress(exerciseId);
    });

/// Selected date filter for week/calendar view (null for all).
class SelectedHistoryDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void select(DateTime? date) => state = date;
}

final selectedHistoryDateProvider =
    NotifierProvider<SelectedHistoryDateNotifier, DateTime?>(
      SelectedHistoryDateNotifier.new,
    );
