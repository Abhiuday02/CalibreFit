import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/features/auth/presentation/auth_providers.dart';
import 'package:calibrefit/shared/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Login page.
///
/// Responsibilities:
///   - Collect email + password.
///   - Validate fields inline before hitting the repository.
///   - Delegate sign-in to [AuthNotifier].
///   - Show inline error on failure.
///   - Navigation to Home is handled by GoRouter redirect on auth state change.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _serverError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    // Clear previous server error and validate form.
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final error = await ref
        .read(authNotifierProvider.notifier)
        .signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _serverError = error);
    }
    // On success: GoRouter redirect handles navigation automatically.
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // ── Header ────────────────────────────────────────────────
              _BrandHeader(colorScheme: colorScheme, textTheme: textTheme),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                'Welcome back',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to continue your journey.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Form ──────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      validator: _emailValidator,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'you@example.com',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: _passwordValidator,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),

                    // Server-side error banner
                    if (_serverError != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _ErrorBanner(message: _serverError!),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Demo credentials hint
                    _DemoHint(colorScheme: colorScheme, textTheme: textTheme),

                    const SizedBox(height: AppSpacing.lg),

                    // Sign in button
                    PrimaryButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      icon: Icons.login_rounded,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Register link ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text('Create one'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal widgets
// ---------------------------------------------------------------------------

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: colorScheme.onPrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          AppInfo.appName,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Demo account',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Email: demo@calibrefit.app',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          Text(
            'Password: Password1',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
