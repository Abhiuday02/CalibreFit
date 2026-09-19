// ---------------------------------------------------------------------------
// Enumerations
// ---------------------------------------------------------------------------

/// Biological sex — used for BMR and macro calculations.
enum BiologicalSex { male, female, preferNotToSay }

/// High-level fitness goal.
enum FitnessGoal {
  loseWeight,
  buildMuscle,
  improveEndurance,
  maintainFitness,
  improveFlexibility,
  generalHealth,
}

/// Self-reported experience level.
enum FitnessLevel { beginner, intermediate, advanced, athlete }

/// Available training equipment.
enum Equipment {
  fullGym,
  homeGym,
  dumbbellsOnly,
  barbellAndRack,
  resistanceBands,
  bodyweightOnly,
  cables,
  machines,
}

/// Cardio preference.
enum CardioPreference { none, light, moderate, heavy }

/// Dietary preference.
enum DietaryPreference {
  nonVegetarian,
  vegetarian,
  vegan,
  eggetarian,
  pescatarian,
  noPreference,
}

/// Calorie/macro tracking preference.
enum NutritionTrackingPreference {
  trackCaloriesAndMacros,
  trackCaloriesOnly,
  noTracking,
}

// ---------------------------------------------------------------------------
// OnboardingProfile
// ---------------------------------------------------------------------------

/// Complete user onboarding data captured across all onboarding steps.
///
/// Immutable — create a modified copy with [copyWith] for each step update.
/// This is the domain model; it has no Flutter or serialisation dependencies.
class OnboardingProfile {
  const OnboardingProfile({
    // Step 1 — Basic Information
    this.displayName,
    this.age,
    this.heightCm,
    this.weightKg,
    this.biologicalSex,

    // Step 2 — Fitness experience
    this.fitnessLevel,

    // Step 3 — Goal
    this.fitnessGoal,

    // Step 4 — Equipment
    this.availableEquipment = const [],

    // Step 5 — Training days
    this.trainingDaysPerWeek,

    // Step 6 — Session duration
    this.preferredSessionMinutes,

    // Step 7 — Cardio
    this.cardioPreference,

    // Step 8 — Limitations / injuries
    this.limitationsNotes,

    // Step 9 — Dietary preference
    this.dietaryPreference,

    // Step 10 — Nutrition tracking
    this.nutritionTrackingPreference,
  });

  // Basic info
  final String? displayName;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final BiologicalSex? biologicalSex;

  // Experience
  final FitnessLevel? fitnessLevel;

  // Goal
  final FitnessGoal? fitnessGoal;

  // Equipment
  final List<Equipment> availableEquipment;

  // Schedule
  final int? trainingDaysPerWeek;
  final int? preferredSessionMinutes;

  // Cardio
  final CardioPreference? cardioPreference;

  // Health
  final String? limitationsNotes;

  // Nutrition
  final DietaryPreference? dietaryPreference;
  final NutritionTrackingPreference? nutritionTrackingPreference;

  // ---------------------------------------------------------------------------
  // Derived helpers
  // ---------------------------------------------------------------------------

  /// Returns true when all mandatory fields are filled.
  bool get isComplete =>
      displayName != null &&
      displayName!.isNotEmpty &&
      age != null &&
      heightCm != null &&
      weightKg != null &&
      biologicalSex != null &&
      fitnessLevel != null &&
      fitnessGoal != null &&
      availableEquipment.isNotEmpty &&
      trainingDaysPerWeek != null &&
      preferredSessionMinutes != null &&
      cardioPreference != null &&
      dietaryPreference != null &&
      nutritionTrackingPreference != null;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  OnboardingProfile copyWith({
    String? displayName,
    int? age,
    double? heightCm,
    double? weightKg,
    BiologicalSex? biologicalSex,
    FitnessLevel? fitnessLevel,
    FitnessGoal? fitnessGoal,
    List<Equipment>? availableEquipment,
    int? trainingDaysPerWeek,
    int? preferredSessionMinutes,
    CardioPreference? cardioPreference,
    String? limitationsNotes,
    DietaryPreference? dietaryPreference,
    NutritionTrackingPreference? nutritionTrackingPreference,
  }) {
    return OnboardingProfile(
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      preferredSessionMinutes:
          preferredSessionMinutes ?? this.preferredSessionMinutes,
      cardioPreference: cardioPreference ?? this.cardioPreference,
      limitationsNotes: limitationsNotes ?? this.limitationsNotes,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      nutritionTrackingPreference:
          nutritionTrackingPreference ?? this.nutritionTrackingPreference,
    );
  }

  @override
  String toString() =>
      'OnboardingProfile('
      'name: $displayName, '
      'age: $age, '
      'goal: $fitnessGoal, '
      'level: $fitnessLevel'
      ')';
}
