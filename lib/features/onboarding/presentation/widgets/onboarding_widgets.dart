import 'package:calibrefit/app/app_constants.dart';
import 'package:flutter/material.dart';

/// Step header shown at the top of every onboarding step.
class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji,
  });

  final String title;
  final String subtitle;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (emoji != null) ...[
          Text(emoji!, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// A tappable selection chip used across many onboarding steps.
class OnboardingChip extends StatelessWidget {
  const OnboardingChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.description,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimation.fast,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.75,
                              )
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Number stepper widget for selecting a numeric value.
class OnboardingNumberStepper extends StatelessWidget {
  const OnboardingNumberStepper({
    super.key,
    required this.value,
    required this.label,
    required this.onDecrement,
    required this.onIncrement,
    this.min = 1,
    this.max = 100,
  });

  final int value;
  final String label;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? onDecrement : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: colorScheme.primary,
                iconSize: 28,
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? onIncrement : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: colorScheme.primary,
                iconSize: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
