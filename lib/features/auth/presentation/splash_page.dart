import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/features/auth/presentation/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Splash screen — first page the user sees on launch.
///
/// Behaviour:
///   - Shows the brand logo and a loading indicator.
///   - Waits for [AuthNotifier] to resolve the initial auth state.
///   - Redirects automatically once state is known:
///       - Authenticated  →  Home
///       - Unauthenticated →  Login
///
/// The redirect is handled by GoRouter's `redirect` callback (in
/// [app_router.dart]), which reacts to [authStateChangesProvider].
/// This page therefore only needs to show a branded waiting state.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppAnimation.slow);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Trigger navigation once auth state is resolved.
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    // Small minimum display time so the splash doesn't flash.
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    switch (authState) {
      case AuthStateAuthenticated():
        // GoRouter redirect will send to /onboarding if no profile exists,
        // or /home if onboarding is already complete.
        context.go(AppRoutes.home);
      case AuthStateUnauthenticated():
      case AuthStateLoading():
        context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Brand icon ─────────────────────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: colorScheme.onPrimary,
                  size: 52,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── App name ───────────────────────────────────────────────
              Text(
                AppInfo.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Train smarter. Progress faster.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Loading indicator ──────────────────────────────────────
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
