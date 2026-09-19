import 'package:calibrefit/features/analytics/presentation/analytics_page.dart';
import 'package:calibrefit/features/auth/presentation/auth_providers.dart';
import 'package:calibrefit/features/auth/presentation/login_page.dart';
import 'package:calibrefit/features/auth/presentation/register_page.dart';
import 'package:calibrefit/features/auth/presentation/splash_page.dart';
import 'package:calibrefit/features/exercise_library/presentation/exercise_detail_page.dart';
import 'package:calibrefit/features/exercise_library/presentation/exercise_list_page.dart';
import 'package:calibrefit/features/history/presentation/exercise_progress_page.dart';
import 'package:calibrefit/features/history/presentation/history_page.dart';
import 'package:calibrefit/features/history/presentation/workout_history_detail_page.dart';
import 'package:calibrefit/features/home/presentation/home_page.dart';
import 'package:calibrefit/features/onboarding/presentation/onboarding_page.dart';
import 'package:calibrefit/features/onboarding/presentation/onboarding_providers.dart';
import 'package:calibrefit/features/workouts/presentation/active_workout_page.dart';
import 'package:calibrefit/features/workouts/presentation/workout_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------

/// Centralised route path constants.
///
/// Always use these instead of raw strings to prevent typos and enable
/// safe, IDE-assisted refactoring.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const exerciseLibrary = '/exercises';
  static const activeWorkout = '/workout/active';
  static const workoutSummary = '/workout/summary';
  static const workoutHistory = '/history';
  static const analytics = '/analytics';
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

/// Exposes the [GoRouter] as a Riverpod provider.
///
/// Redirect logic (in priority order):
///  1. Unauthenticated  → /login  (unless already on an auth page / splash)
///  2. Authenticated + no profile → /onboarding
///  3. Authenticated + profile + on auth/splash/onboarding → /home
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _RouterChangeNotifier();
  ref.onDispose(authListenable.dispose);

  // Re-evaluate redirect on auth state change.
  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    authListenable.notify();
  });

  // Re-evaluate redirect when onboarding profile load completes.
  ref.listen(savedOnboardingProfileProvider, (previous, next) {
    authListenable.notify();
  });

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: authListenable,

    // ── Global redirect ───────────────────────────────────────────────────
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState is AuthStateAuthenticated;

      final location = state.matchedLocation;
      final onSplash = location == AppRoutes.splash;
      final onAuthPage =
          location == AppRoutes.login || location == AppRoutes.register;
      final onOnboarding = location == AppRoutes.onboarding;

      // 1. Not authenticated → go to login (allow splash and auth pages).
      if (!isAuthenticated && !onAuthPage && !onSplash) {
        return AppRoutes.login;
      }

      if (isAuthenticated) {
        // 2. Check onboarding status (async — may still be loading).
        final profileAsync = ref.read(savedOnboardingProfileProvider);

        // While the profile loads, stay put.
        if (profileAsync.isLoading) return null;

        final hasProfile = profileAsync.asData?.value != null;

        // 3. No profile yet → must complete onboarding.
        if (!hasProfile && !onOnboarding) {
          return AppRoutes.onboarding;
        }

        // 4. Profile exists → must not linger on auth/splash/onboarding pages.
        if (hasProfile && (onAuthPage || onSplash || onOnboarding)) {
          return AppRoutes.home;
        }
      }

      return null;
    },

    // ── Routes ───────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterPage()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomePage()),
      ),
      GoRoute(
        path: AppRoutes.exerciseLibrary,
        name: 'exerciseLibrary',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ExerciseListPage()),
        routes: [
          GoRoute(
            path: ':id',
            name: 'exerciseDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: ExerciseDetailPage(exerciseId: id),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.activeWorkout,
        name: 'activeWorkout',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ActiveWorkoutPage()),
      ),
      GoRoute(
        path: AppRoutes.workoutSummary,
        name: 'workoutSummary',
        pageBuilder: (context, state) =>
            const MaterialPage(child: WorkoutSummaryPage()),
      ),
      GoRoute(
        path: AppRoutes.workoutHistory,
        name: 'workoutHistory',
        pageBuilder: (context, state) =>
            const MaterialPage(child: HistoryPage()),
        routes: [
          GoRoute(
            path: 'exercise/:exerciseId',
            name: 'exerciseProgress',
            pageBuilder: (context, state) {
              final exerciseId = state.pathParameters['exerciseId'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: ExerciseProgressPage(exerciseId: exerciseId),
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'workoutHistoryDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return MaterialPage(
                key: state.pageKey,
                child: WorkoutHistoryDetailPage(recordId: id),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        pageBuilder: (context, state) =>
            const MaterialPage(child: AnalyticsPage()),
      ),
    ],

    errorBuilder: (context, state) => _RouteErrorPage(error: state.error),
  );
});

// ---------------------------------------------------------------------------
// Router change notifier
// ---------------------------------------------------------------------------

/// Thin [ChangeNotifier] used as GoRouter's [refreshListenable].
///
/// The provider body calls [notify] on auth or onboarding state changes,
/// which triggers GoRouter to re-evaluate its `redirect` callback.
class _RouterChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// ---------------------------------------------------------------------------
// Error page
// ---------------------------------------------------------------------------

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Text(
          error?.toString() ?? 'Unknown routing error.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
