import 'package:calibrefit/features/set_logging/domain/set_log.dart';
import 'package:calibrefit/features/set_logging/domain/set_log_repository.dart';

/// Local offline-first implementation of [SetLogRepository].
///
/// Records all workout set logs locally in memory with simulated local storage delay.
/// Later phases will bind this directly to Drift/SQLite for disk-level persistence.
class LocalSetLogRepository implements SetLogRepository {
  LocalSetLogRepository();

  final List<SetLog> _storage = [];
  static const _delay = Duration(milliseconds: 30);

  @override
  Future<void> saveSetLog(SetLog setLog) async {
    await Future<void>.delayed(_delay);
    final index = _storage.indexWhere((item) => item.id == setLog.id);
    if (index >= 0) {
      _storage[index] = setLog;
    } else {
      _storage.add(setLog);
    }
  }

  @override
  Future<void> saveSetLogs(List<SetLog> setLogs) async {
    await Future<void>.delayed(_delay);
    for (final log in setLogs) {
      final index = _storage.indexWhere((item) => item.id == log.id);
      if (index >= 0) {
        _storage[index] = log;
      } else {
        _storage.add(log);
      }
    }
  }

  @override
  Future<List<SetLog>> getSetLogsForSession(String sessionId) async {
    await Future<void>.delayed(_delay);
    return _storage.where((log) => log.sessionId == sessionId).toList()
      ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
  }

  @override
  Future<List<SetLog>> getSetLogsForExercise(String exerciseId) async {
    await Future<void>.delayed(_delay);
    return _storage.where((log) => log.exerciseId == exerciseId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<List<SetLog>> getAllSetLogs() async {
    await Future<void>.delayed(_delay);
    return List<SetLog>.from(_storage)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> deleteSetLog(String id) async {
    await Future<void>.delayed(_delay);
    _storage.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }
}
