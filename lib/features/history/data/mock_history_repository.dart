import 'package:calibrefit/features/history/domain/history_repository.dart';
import 'package:calibrefit/features/history/domain/workout_history_record.dart';
import 'package:calibrefit/features/set_logging/domain/set_log.dart';

/// In-memory mock implementation of [HistoryRepository].
///
/// Pre-populated with realistic historical workout sessions and progression points.
class MockHistoryRepository implements HistoryRepository {
  MockHistoryRepository() {
    _initSeedHistory();
  }

  static const _delay = Duration(milliseconds: 150);
  final List<WorkoutHistoryRecord> _historyRecords = [];

  void _initSeedHistory() {
    final now = DateTime.now();

    // Workout 1: 2 days ago — Chest + Triceps
    final date1 = now.subtract(const Duration(days: 2));
    _historyRecords.add(
      WorkoutHistoryRecord(
        id: 'hist-01',
        workoutTitle: 'Chest + Triceps Hypertrophy',
        targetMuscles: 'Chest + Triceps',
        date: DateTime(date1.year, date1.month, date1.day, 8, 30),
        durationSeconds: 2520, // 42 min
        totalVolumeKg: 1480.0,
        totalReps: 76,
        totalSets: 10,
        exerciseSummaries: [
          ExerciseHistorySummary(
            exerciseId: 'ex-bench-press',
            exerciseName: 'Barbell Bench Press',
            setsCount: 4,
            bestSetWeightKg: 42.5,
            bestSetReps: 8,
            totalVolumeKg: 1280.0,
            sets: [
              SetLog(
                id: 's1',
                sessionId: 'hist-01',
                exerciseId: 'ex-bench-press',
                exerciseName: 'Barbell Bench Press',
                setNumber: 1,
                plannedWeight: 42.5,
                plannedReps: 8,
                actualWeight: 40.0,
                actualReps: 10,
                rir: 2,
                rpe: 8.0,
                restSeconds: 90,
                timestamp: date1,
              ),
              SetLog(
                id: 's2',
                sessionId: 'hist-01',
                exerciseId: 'ex-bench-press',
                exerciseName: 'Barbell Bench Press',
                setNumber: 2,
                plannedWeight: 42.5,
                plannedReps: 8,
                actualWeight: 40.0,
                actualReps: 9,
                rir: 1,
                rpe: 8.5,
                restSeconds: 90,
                timestamp: date1,
              ),
              SetLog(
                id: 's3',
                sessionId: 'hist-01',
                exerciseId: 'ex-bench-press',
                exerciseName: 'Barbell Bench Press',
                setNumber: 3,
                plannedWeight: 42.5,
                plannedReps: 8,
                actualWeight: 40.0,
                actualReps: 8,
                rir: 1,
                rpe: 9.0,
                restSeconds: 90,
                timestamp: date1,
              ),
              SetLog(
                id: 's4',
                sessionId: 'hist-01',
                exerciseId: 'ex-bench-press',
                exerciseName: 'Barbell Bench Press',
                setNumber: 4,
                plannedWeight: 42.5,
                plannedReps: 6,
                actualWeight: 42.5,
                actualReps: 6,
                rir: 0,
                rpe: 9.5,
                restSeconds: 120,
                timestamp: date1,
              ),
            ],
          ),
          ExerciseHistorySummary(
            exerciseId: 'ex-incline-db-press',
            exerciseName: 'Incline Dumbbell Press',
            setsCount: 3,
            bestSetWeightKg: 17.5,
            bestSetReps: 10,
            totalVolumeKg: 510.0,
            sets: [
              SetLog(
                id: 's5',
                sessionId: 'hist-01',
                exerciseId: 'ex-incline-db-press',
                exerciseName: 'Incline Dumbbell Press',
                setNumber: 1,
                plannedWeight: 17.5,
                plannedReps: 10,
                actualWeight: 17.5,
                actualReps: 10,
                rir: 2,
                rpe: 8.0,
                timestamp: date1,
              ),
            ],
          ),
        ],
      ),
    );

    // Workout 2: 4 days ago — Back + Biceps
    final date2 = now.subtract(const Duration(days: 4));
    _historyRecords.add(
      WorkoutHistoryRecord(
        id: 'hist-02',
        workoutTitle: 'Back & Pull Power',
        targetMuscles: 'Back + Biceps',
        date: DateTime(date2.year, date2.month, date2.day, 18, 15),
        durationSeconds: 2880, // 48 min
        totalVolumeKg: 2340.0,
        totalReps: 68,
        totalSets: 9,
        exerciseSummaries: [
          ExerciseHistorySummary(
            exerciseId: 'ex-deadlift',
            exerciseName: 'Barbell Deadlift',
            setsCount: 3,
            bestSetWeightKg: 80.0,
            bestSetReps: 5,
            totalVolumeKg: 1200.0,
            sets: [
              SetLog(
                id: 's6',
                sessionId: 'hist-02',
                exerciseId: 'ex-deadlift',
                exerciseName: 'Barbell Deadlift',
                setNumber: 1,
                plannedWeight: 80.0,
                plannedReps: 5,
                actualWeight: 80.0,
                actualReps: 5,
                timestamp: date2,
              ),
            ],
          ),
          ExerciseHistorySummary(
            exerciseId: 'ex-lat-pulldown',
            exerciseName: 'Lat Pulldown',
            setsCount: 3,
            bestSetWeightKg: 35.0,
            bestSetReps: 12,
            totalVolumeKg: 840.0,
            sets: [],
          ),
        ],
      ),
    );

    // Workout 3: 6 days ago — Legs & Core
    final date3 = now.subtract(const Duration(days: 6));
    _historyRecords.add(
      WorkoutHistoryRecord(
        id: 'hist-03',
        workoutTitle: 'Leg Day Strength',
        targetMuscles: 'Quadriceps + Glutes',
        date: DateTime(date3.year, date3.month, date3.day, 7, 45),
        durationSeconds: 2700, // 45 min
        totalVolumeKg: 2850.0,
        totalReps: 64,
        totalSets: 8,
        exerciseSummaries: [
          ExerciseHistorySummary(
            exerciseId: 'ex-squat',
            exerciseName: 'Barbell Back Squat',
            setsCount: 4,
            bestSetWeightKg: 60.0,
            bestSetReps: 8,
            totalVolumeKg: 1840.0,
            sets: [],
          ),
        ],
      ),
    );
  }

  @override
  Future<List<WorkoutHistoryRecord>> getWorkoutHistory() async {
    await Future<void>.delayed(_delay);
    final sorted = List<WorkoutHistoryRecord>.from(_historyRecords)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Future<WorkoutHistoryRecord?> getWorkoutHistoryById(String id) async {
    await Future<void>.delayed(_delay);
    try {
      return _historyRecords.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ExerciseProgressPoint>> getExerciseProgress(
    String exerciseId,
  ) async {
    await Future<void>.delayed(_delay);
    final now = DateTime.now();

    // Return realistic progression over past 4 weeks
    return [
      ExerciseProgressPoint(
        date: now.subtract(const Duration(days: 28)),
        weightKg: 35.0,
        reps: 10,
        volumeKg: 350.0,
        estimated1RmKg: 46.7,
      ),
      ExerciseProgressPoint(
        date: now.subtract(const Duration(days: 21)),
        weightKg: 37.5,
        reps: 8,
        volumeKg: 300.0,
        estimated1RmKg: 47.5,
      ),
      ExerciseProgressPoint(
        date: now.subtract(const Duration(days: 14)),
        weightKg: 40.0,
        reps: 8,
        volumeKg: 320.0,
        estimated1RmKg: 50.7,
      ),
      ExerciseProgressPoint(
        date: now.subtract(const Duration(days: 2)),
        weightKg: 42.5,
        reps: 8,
        volumeKg: 340.0,
        estimated1RmKg: 53.8,
      ),
    ];
  }

  @override
  Future<void> recordCompletedWorkout(WorkoutHistoryRecord record) async {
    await Future<void>.delayed(_delay);
    _historyRecords.insert(0, record);
  }
}
