import 'package:calibrefit/features/auth/data/mock_auth_repository.dart';
import 'package:calibrefit/features/auth/presentation/auth_providers.dart';
import 'package:calibrefit/features/nutrition/domain/macro_calculator.dart';
import 'package:calibrefit/features/onboarding/data/local_onboarding_repository.dart';
import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';
import 'package:calibrefit/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('E2E: Auth & Onboarding User Journey', () {
    late ProviderContainer container;
    late MockAuthRepository authRepo;
    late LocalOnboardingRepository onboardingRepo;

    setUp(() {
      authRepo = MockAuthRepository();
      onboardingRepo = LocalOnboardingRepository();

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          onboardingRepositoryProvider.overrideWithValue(onboardingRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('User can register, authenticate, and complete the full 11-step onboarding flow', () async {
      // ── Step 1: Register Account ──────────────────────────────────────────
      final authNotifier = container.read(authNotifierProvider.notifier);
      final regError = await authNotifier.register(
        email: 'champion@calibrefit.app',
        password: 'Password123!',
      );
      expect(regError, isNull);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final authState = container.read(authNotifierProvider);
      expect(authState, isA<AuthStateAuthenticated>());
      final user = (authState as AuthStateAuthenticated).user;
      expect(user.email, 'champion@calibrefit.app');

      // ── Step 2: Step-by-Step Onboarding ───────────────────────────────────
      final onboardingNotifier = container.read(
        onboardingNotifierProvider.notifier,
      );

      // Step 0: Basic Info
      onboardingNotifier.setBasicInfo(
        displayName: 'Marcus Aurelius',
        age: 28,
        heightCm: 182.0,
        weightKg: 84.0,
        biologicalSex: BiologicalSex.male,
      );

      // Step 1: Fitness Level
      onboardingNotifier.setFitnessLevel(FitnessLevel.intermediate);

      // Step 2: Fitness Goal
      onboardingNotifier.setFitnessGoal(FitnessGoal.buildMuscle);

      // Step 3: Equipment
      onboardingNotifier.toggleEquipment(Equipment.barbellAndRack);
      onboardingNotifier.toggleEquipment(Equipment.fullGym);
      onboardingNotifier.confirmEquipment();

      // Step 4: Training Days
      onboardingNotifier.setTrainingDays(5);

      // Step 5: Session Duration
      onboardingNotifier.setSessionDuration(60);

      // Step 6: Cardio Preference
      onboardingNotifier.setCardioPreference(CardioPreference.moderate);

      // Step 7: Limitations
      onboardingNotifier.setLimitations(
        'Mild left knee sensitivity on deep flexion',
      );

      // Step 8: Dietary Preference
      onboardingNotifier.setDietaryPreference(DietaryPreference.nonVegetarian);

      // Step 9: Nutrition Tracking
      onboardingNotifier.setNutritionTracking(
        NutritionTrackingPreference.trackCaloriesAndMacros,
      );

      // ── Step 3: Complete & Save Profile ───────────────────────────────────
      final saveError = await onboardingNotifier.completeOnboarding();
      expect(saveError, isNull);

      final savedProfile = await onboardingRepo.loadProfile();
      expect(savedProfile, isNotNull);
      expect(savedProfile!.displayName, 'Marcus Aurelius');
      expect(savedProfile.weightKg, 84.0);
      expect(savedProfile.fitnessGoal, FitnessGoal.buildMuscle);
      expect(savedProfile.isComplete, isTrue);

      // ── Step 4: Scientific Macro Targets Generated from Profile ───────────
      final macroTarget = MacroCalculator.calculateFromProfile(savedProfile);
      expect(macroTarget.calories, greaterThan(2500));
      expect(macroTarget.proteinG, equals(168)); // 84kg * 2.0g/kg
      expect(macroTarget.waterMl, equals(2940)); // 84kg * 35ml/kg
    });
  });
}
