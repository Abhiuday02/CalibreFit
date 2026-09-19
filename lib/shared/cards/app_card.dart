import 'package:calibrefit/app/app_constants.dart';
import 'package:flutter/material.dart';

/// A styled card used throughout the application.
///
/// Wraps Flutter's [Card] with consistent padding and elevation.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}
