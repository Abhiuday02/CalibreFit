import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/auth/domain/auth_user.dart';
import 'package:calibrefit/features/auth/presentation/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top greeting section of the Home Dashboard.
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key, required this.user});

  final AuthUser? user;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final name = user?.displayName?.split(' ').first ?? 'Athlete';
    final greeting = _getGreeting();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar / Brand Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'C',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Greeting & Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                name,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Sign out button
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Sign out',
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
          },
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurfaceVariant,
            minimumSize: const Size(40, 40),
          ),
        ),
      ],
    );
  }
}
