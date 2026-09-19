import 'package:calibrefit/features/exercise_library/data/mock_exercise_repository.dart';
import 'package:calibrefit/features/exercise_library/domain/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockExerciseRepository repository;

  setUp(() {
    repository = const MockExerciseRepository();
  });

  group('MockExerciseRepository.getExercises', () {
    test('returns all seed exercises when no filter is applied', () async {
      final exercises = await repository.getExercises();

      expect(exercises.length, 10);
      expect(exercises.any((e) => e.name == 'Barbell Bench Press'), isTrue);
      expect(exercises.any((e) => e.name == 'Barbell Back Squat'), isTrue);
      expect(exercises.any((e) => e.name == 'Barbell Deadlift'), isTrue);
    });

    test('filters exercises by category', () async {
      final chestExercises = await repository.getExercises(
        category: ExerciseCategory.chest,
      );

      expect(chestExercises.isNotEmpty, isTrue);
      for (final e in chestExercises) {
        expect(e.category, ExerciseCategory.chest);
      }
      expect(
        chestExercises.any((e) => e.name == 'Barbell Bench Press'),
        isTrue,
      );
      expect(
        chestExercises.any((e) => e.name == 'Incline Dumbbell Press'),
        isTrue,
      );
      expect(chestExercises.any((e) => e.name == 'Cable Fly'), isTrue);
      expect(chestExercises.any((e) => e.name == 'Push-up'), isTrue);
    });

    test('filters exercises by query matching name', () async {
      final results = await repository.getExercises(query: 'Barbell Bench');

      expect(results.length, 1);
      expect(results.first.name, 'Barbell Bench Press');
    });

    test('filters exercises by query matching primary muscles', () async {
      final results = await repository.getExercises(query: 'pectoralis');

      expect(results.length, 3); // Bench Press, Cable Fly, Push-up
    });

    test('filters exercises by query matching equipment', () async {
      final results = await repository.getExercises(query: 'dumbbells');

      expect(
        results.length,
        4,
      ); // Incline DB Press, Shoulder Press, Bicep Curl, Lunges
    });

    test('filters by both category and query', () async {
      final results = await repository.getExercises(
        category: ExerciseCategory.legs,
        query: 'squat',
      );

      expect(results.length, 1);
      expect(results.first.name, 'Barbell Back Squat');
    });

    test('returns empty list when no exercise matches', () async {
      final results = await repository.getExercises(query: 'nonexistent_xyz');

      expect(results, isEmpty);
    });
  });

  group('MockExerciseRepository.getExerciseById', () {
    test('returns correct exercise when valid ID is passed', () async {
      final exercise = await repository.getExerciseById('ex-bench-press');

      expect(exercise, isNotNull);
      expect(exercise!.id, 'ex-bench-press');
      expect(exercise.name, 'Barbell Bench Press');
      expect(exercise.slug, 'barbell-bench-press');
      expect(exercise.category, ExerciseCategory.chest);
      expect(exercise.primaryMuscles, contains('Pectoralis Major'));
      expect(exercise.secondaryMuscles, contains('Triceps Brachii'));
      expect(exercise.equipment, 'Barbell & Flat Bench');
      expect(exercise.difficulty, ExerciseDifficulty.intermediate);
      expect(exercise.instructions.length, 5);
      expect(exercise.correctPosture.length, 3);
      expect(exercise.breathing, isNotEmpty);
      expect(exercise.tempo, isNotEmpty);
      expect(exercise.commonMistakes.length, 3);
      expect(exercise.aiSupported, isTrue);
      expect(exercise.defaultSets, 4);
      expect(exercise.defaultRepRange, '6–8');
      expect(exercise.defaultSuggestedLoadKg, 42.5);
      expect(exercise.defaultRestSeconds, 120);
    });

    test('returns null when ID is not found', () async {
      final exercise = await repository.getExerciseById('unknown-id-123');

      expect(exercise, isNull);
    });
  });

  group('Exercise model properties', () {
    test('equality and hashcode are based on id', () {
      const e1 = Exercise(
        id: 'test-1',
        name: 'Exercise One',
        slug: 'exercise-one',
        category: ExerciseCategory.chest,
        primaryMuscles: ['Chest'],
        secondaryMuscles: [],
        equipment: 'Barbell',
        difficulty: ExerciseDifficulty.beginner,
        instructions: [],
        correctPosture: [],
        breathing: '',
        tempo: '',
        commonMistakes: [],
      );

      const e2 = Exercise(
        id: 'test-1',
        name: 'Different Name Same ID',
        slug: 'diff',
        category: ExerciseCategory.back,
        primaryMuscles: [],
        secondaryMuscles: [],
        equipment: 'Dumbbells',
        difficulty: ExerciseDifficulty.advanced,
        instructions: [],
        correctPosture: [],
        breathing: '',
        tempo: '',
        commonMistakes: [],
      );

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
    });
  });
}
