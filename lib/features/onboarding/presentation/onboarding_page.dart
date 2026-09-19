import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/onboarding/presentation/onboarding_providers.dart';
import 'package:calibrefit/features/onboarding/presentation/onboarding_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding shell page.
///
/// Hosts a [PageView] of all onboarding steps with:
///   - A top progress bar showing how far through the flow the user is.
///   - An animated step counter.
///   - A back button (disabled on step 0).
///   - Steps are driven by [OnboardingNotifier] — the PageView is programmatic
///     and swipes are intentionally disabled to prevent skipping steps.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;

  // Ordered list of all step widgets.
  static const _steps = <Widget>[
    StepBasicInfo(), // 0
    StepFitnessLevel(), // 1
    StepFitnessGoal(), // 2
    StepEquipment(), // 3
    StepTrainingDays(), // 4
    StepSessionDuration(), // 5
    StepCardio(), // 6
    StepLimitations(), // 7
    StepDietaryPreference(), // 8
    StepNutritionTracking(), // 9
    StepReview(), // 10
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sync PageView with notifier step changes
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final obState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // When the notifier's step changes, animate the PageView.
    ref.listen<OnboardingState>(onboardingNotifierProvider, (prev, next) {
      if (prev?.currentStep != next.currentStep) {
        _pageController.animateToPage(
          next.currentStep,
          duration: AppAnimation.defaultDuration,
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: obState.isFirstStep
                        ? null
                        : () => notifier.previousStep(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: obState.isFirstStep
                          ? colorScheme.surfaceContainerLow
                          : colorScheme.surfaceContainerHighest,
                      foregroundColor: obState.isFirstStep
                          ? colorScheme.onSurface.withValues(alpha: 0.3)
                          : colorScheme.onSurface,
                      minimumSize: const Size(40, 40),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Step counter
                  Expanded(
                    child: Text(
                      'Step ${obState.currentStep + 1} of ${OnboardingState.totalSteps}',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  // Skip button (step 7 — limitations only)
                  if (obState.currentStep == 7)
                    TextButton(
                      onPressed: () => notifier.setLimitations(null),
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),

            // ── Progress bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: obState.progress),
                  duration: AppAnimation.defaultDuration,
                  curve: Curves.easeInOut,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Step content ───────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                // Disable swipe — steps must be completed in order.
                physics: const NeverScrollableScrollPhysics(),
                children: _steps,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
