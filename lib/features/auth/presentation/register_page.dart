import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/features/auth/presentation/auth_providers.dart';
import 'package:calibrefit/shared/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Register page — creates a new user account.
///
/// Responsibilities:
///   - Collect display name, email, password, confirm password.
///   - Client-side validation before hitting the repository.
///   - Delegate registration to [AuthNotifier].
///   - Show inline error on failure.
///   - Navigation to Home is handled by GoRouter redirect on auth state change.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _serverError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final error = await ref
        .read(authNotifierProvider.notifier)
        .register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text.trim().isEmpty
              ? null
              : _nameCtrl.text.trim(),
        );

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

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required.';
    if (value.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

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

  String? _confirmValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != _passwordCtrl.text) return 'Passwords do not match.';
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
              const SizedBox(height: AppSpacing.xl),

              // ── Back button ───────────────────────────────────────────
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go(AppRoutes.login),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  minimumSize: const Size(44, 44),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Header ────────────────────────────────────────────────
              Text(
                'Create account',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Start your fitness journey with ${AppInfo.appName}.',
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
                    // Display name
                    TextFormField(
                      controller: _nameCtrl,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: _nameValidator,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        hintText: 'Alex Smith',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

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
                      textInputAction: TextInputAction.next,
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
                        helperText: 'Minimum 8 characters',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Confirm password
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: _confirmValidator,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
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

                    PrimaryButton(
                      label: 'Create Account',
                      isLoading: _isLoading,
                      icon: Icons.person_add_rounded,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Login link ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Sign in'),
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
// Internal widget
// ---------------------------------------------------------------------------

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
