/// Application configuration.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Application configuration and environment initialization.
///
/// Centralises any one-time async setup required before [runApp].
/// Add platform-channel initialisation, environment loading, etc. here.
/// Centralises one-time async setup required before [runApp], including
/// global exception boundaries, system UI chrome, and environment flags.
abstract final class AppConfig {
  /// Perform any async initialisation before the Flutter app starts.
  /// Whether the application is running in production release mode.
  static bool get isProduction => kReleaseMode;

  /// Environment name identifier.
  static String get environment => kReleaseMode ? 'production' : 'development';

  /// Performs async initialization and installs global error boundaries before [runApp].
  static Future<void> initialize() async {
    // Phase 0: no async setup required yet.
    // Future phases will add:
    //   - secure storage initialisation
    //   - environment variable loading
    //   - Drift database opening
    // 1. Install global Flutter framework error handler
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(
        'FlutterFrameworkError',
        details.exceptionAsString(),
        details.stack,
      );
    };

    // 2. Install platform dispatcher uncaught async error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('UncaughtPlatformError', error.toString(), stack);
      return true; // Handled
    };

    // 3. Configure system UI overlay styling
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static void _logError(String type, String message, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('[$type] $message');
      if (stack != null) debugPrint(stack.toString());
    }
    // In production, forward to Sentry / Firebase Crashlytics telemetry
  }
}
