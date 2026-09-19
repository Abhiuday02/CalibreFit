import 'package:calibrefit/features/onboarding/domain/onboarding_profile.dart';
import 'package:calibrefit/features/onboarding/domain/onboarding_repository.dart';

/// In-memory implementation of [OnboardingRepository].
///
/// Stores the profile for the lifetime of the app session.
/// Phase 6 will replace this with Drift-backed persistence so the
/// profile survives app restarts.
class LocalOnboardingRepository implements OnboardingRepository {
  OnboardingProfile? _profile;

  @override
  Future<OnboardingProfile?> loadProfile() async {
    // Simulate an async read (e.g. disk I/O) with a minimal delay.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return _profile;
  }

  @override
  Future<void> saveProfile(OnboardingProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _profile = profile;
  }

  @override
  Future<void> clearProfile() async {
    _profile = null;
  }
}
