// Domain models for the Exercise Library.

/// Category grouping for exercises.
enum ExerciseCategory {
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
  fullBody;

  String get displayName => switch (this) {
    ExerciseCategory.chest => 'Chest',
    ExerciseCategory.back => 'Back',
    ExerciseCategory.legs => 'Legs',
    ExerciseCategory.shoulders => 'Shoulders',
    ExerciseCategory.arms => 'Arms',
    ExerciseCategory.core => 'Core',
    ExerciseCategory.fullBody => 'Full Body',
  };
}

/// Difficulty level of an exercise.
enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced;

  String get displayName => switch (this) {
    ExerciseDifficulty.beginner => 'Beginner',
    ExerciseDifficulty.intermediate => 'Intermediate',
    ExerciseDifficulty.advanced => 'Advanced',
  };
}

/// Comprehensive Exercise domain model.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.correctPosture,
    required this.breathing,
    required this.tempo,
    required this.commonMistakes,
    this.videoUrl,
    this.animationUrl,
    this.aiSupported = false,
    this.defaultSets = 3,
    this.defaultRepRange = '8–12',
    this.defaultSuggestedLoadKg = 20.0,
    this.defaultRestSeconds = 90,
  });

  final String id;
  final String name;
  final String slug;
  final ExerciseCategory category;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final ExerciseDifficulty difficulty;
  final List<String> instructions;
  final List<String> correctPosture;
  final String breathing;
  final String tempo;
  final List<String> commonMistakes;
  final String? videoUrl;
  final String? animationUrl;
  final bool aiSupported;

  // Default prescription guidelines
  final int defaultSets;
  final String defaultRepRange;
  final double defaultSuggestedLoadKg;
  final int defaultRestSeconds;

  @override
  String toString() => 'Exercise(id: $id, name: $name, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
