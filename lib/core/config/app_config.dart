/// Application configuration.
///
/// Centralises any one-time async setup required before [runApp].
/// Add platform-channel initialisation, environment loading, etc. here.
abstract final class AppConfig {
  /// Perform any async initialisation before the Flutter app starts.
  static Future<void> initialize() async {
    // Phase 0: no async setup required yet.
    // Future phases will add:
    //   - secure storage initialisation
    //   - environment variable loading
    //   - Drift database opening
  }
}
