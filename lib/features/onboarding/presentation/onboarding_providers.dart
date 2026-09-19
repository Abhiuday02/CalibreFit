import 'package:calibrefit/features/onboarding/data/local_onboarding_repository.dart';
import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';
import 'package:calibrefit/features/onboarding/domain/onboarding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return LocalOnboardingRepository();
});

// ---------------------------------------------------------------------------
// Saved profile provider
// ---------------------------------------------------------------------------

/// Loads the persisted [OnboardingProfile] on startup.
///
/// Returns `null` if onboarding has not yet been completed.
final savedOnboardingProfileProvider = FutureProvider<OnboardingProfile?>((
  ref,
) async {
  return ref.watch(onboardingRepositoryProvider).loadProfile();
});

// ---------------------------------------------------------------------------
// Onboarding step state
// ---------------------------------------------------------------------------

class OnboardingState {
  const OnboardingState({
    this.profile = const OnboardingProfile(),
    this.currentStep = 0,
    this.isSaving = false,
  });

  static const totalSteps = 11;

  final OnboardingProfile profile;
  final int currentStep;
  final bool isSaving;

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;
  double get progress => (currentStep + 1) / totalSteps;

  OnboardingState copyWith({
    OnboardingProfile? profile,
    int? currentStep,
    bool? isSaving,
  }) {
    return OnboardingState(
      profile: profile ?? this.profile,
      currentStep: currentStep ?? this.currentStep,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// ---------------------------------------------------------------------------
// OnboardingNotifier
// ---------------------------------------------------------------------------

/// Manages the step-by-step onboarding flow.
///
/// Encapsulates all state mutations so calling code never reads or writes
/// the protected `state` field directly.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void nextStep() {
    if (state.isLastStep) return;
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.isFirstStep) return;
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  // ---------------------------------------------------------------------------
  // Step-specific mutations (encapsulate copyWith internally)
  // ---------------------------------------------------------------------------

  void setBasicInfo({
    required String displayName,
    required int age,
    required double heightCm,
    required double weightKg,
    required BiologicalSex biologicalSex,
  }) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        displayName: displayName,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        biologicalSex: biologicalSex,
      ),
    );
    nextStep();
  }

  void setFitnessLevel(FitnessLevel level) {
    state = state.copyWith(
      profile: state.profile.copyWith(fitnessLevel: level),
    );
    nextStep();
  }

  void setFitnessGoal(FitnessGoal goal) {
    state = state.copyWith(profile: state.profile.copyWith(fitnessGoal: goal));
    nextStep();
  }

  void toggleEquipment(Equipment equipment) {
    final current = List<Equipment>.from(state.profile.availableEquipment);
    if (current.contains(equipment)) {
      current.remove(equipment);
    } else {
      current.add(equipment);
    }
    state = state.copyWith(
      profile: state.profile.copyWith(availableEquipment: current),
    );
  }

  void confirmEquipment() {
    if (state.profile.availableEquipment.isNotEmpty) {
      nextStep();
    }
  }

  void setTrainingDays(int days) {
    state = state.copyWith(
      profile: state.profile.copyWith(trainingDaysPerWeek: days),
    );
    nextStep();
  }

  void setSessionDuration(int minutes) {
    state = state.copyWith(
      profile: state.profile.copyWith(preferredSessionMinutes: minutes),
    );
    nextStep();
  }

  void setCardioPreference(CardioPreference preference) {
    state = state.copyWith(
      profile: state.profile.copyWith(cardioPreference: preference),
    );
    nextStep();
  }

  void setLimitations(String? notes) {
    state = state.copyWith(
      profile: state.profile.copyWith(limitationsNotes: notes),
    );
    nextStep();
  }

  void setDietaryPreference(DietaryPreference preference) {
    state = state.copyWith(
      profile: state.profile.copyWith(dietaryPreference: preference),
    );
    nextStep();
  }

  void setNutritionTracking(NutritionTrackingPreference preference) {
    state = state.copyWith(
      profile: state.profile.copyWith(nutritionTrackingPreference: preference),
    );
    nextStep();
  }

  // ---------------------------------------------------------------------------
  // Completion
  // ---------------------------------------------------------------------------

  Future<String?> completeOnboarding() async {
    if (!state.profile.isComplete) {
      return 'Please complete all required fields before continuing.';
    }

    state = state.copyWith(isSaving: true);
    try {
      final repo = ref.read(onboardingRepositoryProvider);
      await repo.saveProfile(state.profile);
      ref.invalidate(savedOnboardingProfileProvider);
      return null;
    } catch (e) {
      return 'Failed to save your profile. Please try again.';
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
