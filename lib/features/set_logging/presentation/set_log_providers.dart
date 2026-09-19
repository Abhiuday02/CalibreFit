import 'package:calibrefit/features/set_logging/data/local_set_log_repository.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';
import 'package:calibrefit/features/set_logging/domain/set_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final setLogRepositoryProvider = Provider<SetLogRepository>((ref) {
  return LocalSetLogRepository();
});

// ---------------------------------------------------------------------------
// Query Providers
// ---------------------------------------------------------------------------

/// Provides all logged sets recorded for a given workout session.
final sessionSetLogsProvider = FutureProvider.family<List<SetLog>, String>((
  ref,
  sessionId,
) async {
  final repo = ref.watch(setLogRepositoryProvider);
  return repo.getSetLogsForSession(sessionId);
});

/// Provides historical set logs recorded for a specific exercise.
final exerciseHistoryLogsProvider = FutureProvider.family<List<SetLog>, String>(
  (ref, exerciseId) async {
    final repo = ref.watch(setLogRepositoryProvider);
    return repo.getSetLogsForExercise(exerciseId);
  },
);

/// Provides all recorded set logs.
final allSetLogsProvider = FutureProvider<List<SetLog>>((ref) async {
  final repo = ref.watch(setLogRepositoryProvider);
  return repo.getAllSetLogs();
});
