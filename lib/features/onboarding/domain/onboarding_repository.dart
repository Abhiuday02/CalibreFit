import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';

/// Contract for persisting and retrieving the [OnboardingProfile].
///
/// Phase 2: implemented by [LocalOnboardingRepository] (in-memory).
/// Phase 6+: will be backed by Drift / secure storage for real persistence.
abstract interface class OnboardingRepository {
  /// Returns the saved profile, or `null` if onboarding has not been completed.
  Future<OnboardingProfile?> loadProfile();

  /// Saves a completed [OnboardingProfile].
  Future<void> saveProfile(OnboardingProfile profile);

  /// Clears the saved profile (e.g. on account deletion or sign-out reset).
  Future<void> clearProfile();
}
