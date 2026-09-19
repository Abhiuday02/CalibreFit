import 'package:calibrefit/features/onboarding/data/local_onboarding_repository.dart';
import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalOnboardingRepository repo;

  setUp(() => repo = LocalOnboardingRepository());

  // ---------------------------------------------------------------------------
  // loadProfile
  // ---------------------------------------------------------------------------

  group('LocalOnboardingRepository.loadProfile', () {
    test('returns null when no profile has been saved', () async {
      final profile = await repo.loadProfile();
      expect(profile, isNull);
    });

    test('returns the saved profile after saveProfile', () async {
      const profile = OnboardingProfile(
        displayName: 'Alex',
        age: 28,
        heightCm: 175,
        weightKg: 75,
      );
      await repo.saveProfile(profile);
      final loaded = await repo.loadProfile();
      expect(loaded?.displayName, 'Alex');
      expect(loaded?.age, 28);
    });
  });

  // ---------------------------------------------------------------------------
  // saveProfile / clearProfile
  // ---------------------------------------------------------------------------

  group('LocalOnboardingRepository.saveProfile', () {
    test('overwrites existing profile', () async {
      await repo.saveProfile(const OnboardingProfile(displayName: 'First'));
      await repo.saveProfile(const OnboardingProfile(displayName: 'Second'));
      final loaded = await repo.loadProfile();
      expect(loaded?.displayName, 'Second');
    });
  });

  group('LocalOnboardingRepository.clearProfile', () {
    test('clears a saved profile', () async {
      await repo.saveProfile(const OnboardingProfile(displayName: 'ToClear'));
      await repo.clearProfile();
      final loaded = await repo.loadProfile();
      expect(loaded, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // OnboardingProfile domain logic
  // ---------------------------------------------------------------------------

  group('OnboardingProfile.isComplete', () {
    test('returns false for empty profile', () {
      expect(const OnboardingProfile().isComplete, isFalse);
    });

    test('returns true for fully populated profile', () {
      const profile = OnboardingProfile(
        displayName: 'Alex',
        age: 28,
        heightCm: 175,
        weightKg: 75,
        biologicalSex: BiologicalSex.male,
        fitnessLevel: FitnessLevel.intermediate,
        fitnessGoal: FitnessGoal.buildMuscle,
        availableEquipment: [Equipment.fullGym],
        trainingDaysPerWeek: 4,
        preferredSessionMinutes: 60,
        cardioPreference: CardioPreference.light,
        dietaryPreference: DietaryPreference.nonVegetarian,
        nutritionTrackingPreference:
            NutritionTrackingPreference.trackCaloriesAndMacros,
      );
      expect(profile.isComplete, isTrue);
    });

    test('returns false when equipment list is empty', () {
      const profile = OnboardingProfile(
        displayName: 'Alex',
        age: 28,
        heightCm: 175,
        weightKg: 75,
        biologicalSex: BiologicalSex.male,
        fitnessLevel: FitnessLevel.intermediate,
        fitnessGoal: FitnessGoal.buildMuscle,
        availableEquipment: [],
        trainingDaysPerWeek: 4,
        preferredSessionMinutes: 60,
        cardioPreference: CardioPreference.light,
        dietaryPreference: DietaryPreference.nonVegetarian,
        nutritionTrackingPreference:
            NutritionTrackingPreference.trackCaloriesAndMacros,
      );
      expect(profile.isComplete, isFalse);
    });

    test('returns false when name is empty string', () {
      const profile = OnboardingProfile(
        displayName: '',
        age: 28,
        heightCm: 175,
        weightKg: 75,
        biologicalSex: BiologicalSex.female,
        fitnessLevel: FitnessLevel.beginner,
        fitnessGoal: FitnessGoal.loseWeight,
        availableEquipment: [Equipment.bodyweightOnly],
        trainingDaysPerWeek: 3,
        preferredSessionMinutes: 45,
        cardioPreference: CardioPreference.moderate,
        dietaryPreference: DietaryPreference.vegan,
        nutritionTrackingPreference: NutritionTrackingPreference.noTracking,
      );
      expect(profile.isComplete, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // OnboardingProfile.copyWith
  // ---------------------------------------------------------------------------

  group('OnboardingProfile.copyWith', () {
    test('updates only the specified fields', () {
      const original = OnboardingProfile(displayName: 'Alice', age: 30);
      final updated = original.copyWith(age: 31);
      expect(updated.displayName, 'Alice');
      expect(updated.age, 31);
    });

    test('equipment list replaces correctly', () {
      const original = OnboardingProfile(
        availableEquipment: [Equipment.fullGym],
      );
      final updated = original.copyWith(
        availableEquipment: [Equipment.fullGym, Equipment.cables],
      );
      expect(updated.availableEquipment.length, 2);
      expect(updated.availableEquipment, contains(Equipment.cables));
    });
  });
}
