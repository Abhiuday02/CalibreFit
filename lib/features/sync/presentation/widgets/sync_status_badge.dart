import 'package:calibrefit/app/app_router.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:calibrefit/features/sync/presentation/sync_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Compact sync status indicator badge displayed in navigation bars and headers.
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key, this.showLabel = false});

  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final syncState = ref.watch(syncEngineProvider);

    final (icon, iconColor, tooltip) = switch (syncState.status) {
      SyncStatus.idle => (
        Icons.cloud_done_rounded,
        const Color(0xFF10B981), // Emerald
        'Cloud Synced',
      ),
      SyncStatus.syncing => (
        Icons.sync_rounded,
        theme.colorScheme.primary,
        'Syncing ${syncState.pendingCount} items...',
      ),
      SyncStatus.offline => (
        Icons.cloud_off_rounded,
        theme.colorScheme.outline,
        'Offline Mode (${syncState.pendingCount} queued)',
      ),
      SyncStatus.error => (
        Icons.sync_problem_rounded,
        theme.colorScheme.error,
        'Sync Error: tap to retry',
      ),
    };

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => context.push(AppRoutes.sync),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: iconColor.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (syncState.status == SyncStatus.syncing)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(iconColor),
                  ),
                )
              else
                Icon(icon, size: 16, color: iconColor),
              if (syncState.pendingCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${syncState.pendingCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  syncState.status.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
