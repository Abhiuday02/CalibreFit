import 'package:calibrefit/features/exercise_library/data/mock_exercise_repository.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return const MockExerciseRepository();
});

// ---------------------------------------------------------------------------
// Filter Notifiers
// ---------------------------------------------------------------------------

/// Holds the current text search query.
class ExerciseSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final exerciseSearchQueryProvider =
    NotifierProvider<ExerciseSearchNotifier, String>(
      ExerciseSearchNotifier.new,
    );

/// Holds the currently selected category filter, or `null` for All.
class SelectedCategoryNotifier extends Notifier<ExerciseCategory?> {
  @override
  ExerciseCategory? build() => null;

  void select(ExerciseCategory? category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, ExerciseCategory?>(
      SelectedCategoryNotifier.new,
    );

// ---------------------------------------------------------------------------
// Exercise List & Detail Providers
// ---------------------------------------------------------------------------

/// Provides the filtered list of exercises reacting to search query and category.
final filteredExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);

  return repo.getExercises(query: query, category: category);
});

/// Provides detail for a specific exercise by ID.
final exerciseDetailProvider = FutureProvider.family<Exercise?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getExerciseById(id);
});
