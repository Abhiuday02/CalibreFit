import 'package:calibrefit/features/set_logging/domain/set_log.dart';

/// Contract for persistent set log storage.
///
/// Ensures workouts can be recorded and reviewed without internet connectivity.
abstract interface class SetLogRepository {
  /// Saves a single [SetLog].
  Future<void> saveSetLog(SetLog setLog);

  /// Saves a batch of [SetLog] records.
  Future<void> saveSetLogs(List<SetLog> setLogs);

  /// Retrieves all logged sets for a specific workout [sessionId].
  Future<List<SetLog>> getSetLogsForSession(String sessionId);

  /// Retrieves all historical logs for a given [exerciseId].
  Future<List<SetLog>> getSetLogsForExercise(String exerciseId);

  /// Retrieves all recorded set logs ordered by timestamp.
  Future<List<SetLog>> getAllSetLogs();

  /// Deletes a specific set log by [id].
  Future<void> deleteSetLog(String id);

  /// Clears all stored set logs (for reset/testing).
  Future<void> clearAll();
}
