import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/sync/domain/sync_models.dart';
import 'package:calibrefit/features/sync/presentation/sync_providers.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Complete synchronization and offline-first management dashboard.
class SyncDashboardPage extends ConsumerWidget {
  const SyncDashboardPage({super.key});

  String _formatTime(DateTime? time) {
    if (time == null) return 'Never';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final syncState = ref.watch(syncEngineProvider);
    final engine = ref.read(syncEngineProvider.notifier);
    final pendingAsync = ref.watch(pendingMutationsProvider);
    final conflictsAsync = ref.watch(conflictLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync & Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync Now',
            onPressed: syncState.status == SyncStatus.syncing
                ? null
                : () => engine.syncNow(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── 1. Status & Connectivity Control ─────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          syncState.isOnline
                              ? Icons.wifi_rounded
                              : Icons.wifi_off_rounded,
                          color: syncState.isOnline
                              ? const Color(0xFF10B981)
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          syncState.isOnline ? 'Online' : 'Offline Mode',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: syncState.isOnline,
                      onChanged: (val) => engine.setOnline(val),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  syncState.isOnline
                      ? 'Connected to CalibreFit Cloud. Changes sync automatically in real-time.'
                      : 'Network disabled. All operations are queued locally and will sync when reconnected.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Synchronized',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatTime(syncState.lastSyncTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Pending Mutations',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${syncState.pendingCount} in queue',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: syncState.pendingCount > 0
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: syncState.status == SyncStatus.syncing
                        ? null
                        : () => engine.syncNow(),
                    icon: syncState.status == SyncStatus.syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded),
                    label: Text(
                      syncState.status == SyncStatus.syncing
                          ? 'Synchronizing...'
                          : 'Sync Now',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 2. Offline Mutation Queue ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offline Mutation Queue',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: syncState.pendingCount > 0
                    ? () => engine.clearQueue()
                    : null,
                child: const Text('Clear Queue'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          pendingAsync.when(
            loading: () => const Center(child: AppLoader()),
            error: (err, _) => AppErrorWidget(
              message: 'Failed to load queue: $err',
              onRetry: () => ref.invalidate(pendingMutationsProvider),
            ),
            data: (mutations) {
              if (mutations.isEmpty) {
                return AppCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 36,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Queue is empty',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'All local actions are synchronized with the cloud.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: mutations.map((mutation) {
                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            mutation.action.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${mutation.entityType.displayName}: ${mutation.entityId}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Queued ${_formatTime(mutation.createdAt)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Discard',
                          onPressed: () => engine.discardMutation(mutation.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () {
              engine.enqueueMutation(
                entityType: EntityType.workout,
                action: MutationAction.create,
                entityId: 'workout-test-${DateTime.now().millisecond}',
                payload: {
                  'name': 'Test Workout Session',
                  'completedAt': DateTime.now().toIso8601String(),
                  'totalVolume': 3500.0,
                },
              );
            },
            icon: const Icon(Icons.add_task_rounded, size: 18),
            label: const Text('Enqueue Test Mutation'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 3. Conflict Resolution Audit Log ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conflict Resolution Audit Log',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => engine.clearConflictLogs(),
                child: const Text('Clear Logs'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          conflictsAsync.when(
            loading: () => const Center(child: AppLoader()),
            error: (err, _) => AppErrorWidget(
              message: 'Failed to load conflicts: $err',
              onRetry: () => ref.invalidate(conflictLogsProvider),
            ),
            data: (conflicts) {
              if (conflicts.isEmpty) {
                return AppCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.handshake_outlined,
                            size: 36,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'No conflicts detected',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Local and remote records are completely reconciled.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: conflicts.map((conflict) {
                  final localWon = conflict.winner == 'local';

                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${conflict.entityType.displayName} Conflict',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: localWon
                                    ? Colors.blue.withAlpha(30)
                                    : Colors.purple.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                localWon ? 'Local Preserved' : 'Remote Applied',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: localWon ? Colors.blue : Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Entity ID: ${conflict.entityId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          conflict.strategy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
