// Application-wide constants.
// Organised into separate top-level classes to keep call-sites readable:
//   AppSpacing.md
//   AppRadius.lg
//   AppAnimation.defaultDuration

// ---------------------------------------------------------------------------
// Spacing
// ---------------------------------------------------------------------------

abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ---------------------------------------------------------------------------
// Border radius
// ---------------------------------------------------------------------------

abstract final class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

// ---------------------------------------------------------------------------
// Animation durations
// ---------------------------------------------------------------------------

abstract final class AppAnimation {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// ---------------------------------------------------------------------------
// Workout defaults
// ---------------------------------------------------------------------------

abstract final class AppWorkoutDefaults {
  /// Default rest period between sets in seconds.
  static const int defaultRestSeconds = 90;

  /// Minimum reps recorded per set.
  static const int minReps = 1;

  /// Maximum reps recorded per set.
  static const int maxReps = 100;
}

// ---------------------------------------------------------------------------
// App info
// ---------------------------------------------------------------------------

abstract final class AppInfo {
  static const String appName = 'CalibreFit';
  static const String appVersion = '1.0.0';
}
