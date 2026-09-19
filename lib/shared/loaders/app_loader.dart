import 'package:calibrefit/app/app_constants.dart';
import 'package:flutter/material.dart';

/// A full-screen loading indicator with an optional label.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
