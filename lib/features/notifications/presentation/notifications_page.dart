import 'package:calibrefit/app/app_constants.dart';
import 'package:calibrefit/features/notifications/domain/notification_models.dart';
import 'package:calibrefit/features/notifications/presentation/notification_providers.dart';
import 'package:calibrefit/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:calibrefit/features/notifications/presentation/widgets/reminder_day_chips.dart';
import 'package:calibrefit/shared/cards/app_card.dart';
import 'package:calibrefit/shared/loaders/app_loader.dart';
import 'package:calibrefit/shared/widgets/app_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Complete Notifications & Reminders screen with Reminders management
/// and Delivered Notifications Inbox.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications & Reminders'),
          bottom: TabBar(
            tabs: [
              const Tab(
                icon: Icon(Icons.alarm_rounded, size: 20),
                text: 'Reminders',
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.notifications_rounded, size: 20),
                ),
                text: 'Inbox',
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_RemindersTab(), _InboxTab()]),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Reminders & Settings Tab
// -----------------------------------------------------------------------------

class _RemindersTab extends ConsumerWidget {
  const _RemindersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);
    final controller = ref.read(notificationControllerProvider.notifier);

    return prefsAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (err, _) => Center(
        child: AppErrorWidget(
          message: 'Failed to load preferences: $err',
          onRetry: () => ref.invalidate(notificationPreferencesProvider),
        ),
      ),
      data: (prefs) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // ── 1. Workout Reminder Card ─────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Workout Reminders',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Daily alert to prepare and begin your training session.',
                    ),
                    value: prefs.workoutRemindersEnabled,
                    onChanged: (val) {
                      controller.updatePreferences(
                        prefs.copyWith(workoutRemindersEnabled: val),
                      );
                    },
                  ),
                  if (prefs.workoutRemindersEnabled) ...[
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reminder Time',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: prefs.workoutReminderHour,
                                minute: prefs.workoutReminderMinute,
                              ),
                            );
                            if (picked != null) {
                              controller.updatePreferences(
                                prefs.copyWith(
                                  workoutReminderHour: picked.hour,
                                  workoutReminderMinute: picked.minute,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.access_time, size: 16),
                          label: Text(prefs.formattedWorkoutTime),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Active Days',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ReminderDayChips(
                      selectedDays: prefs.workoutReminderDays,
                      onDaysChanged: (days) {
                        controller.updatePreferences(
                          prefs.copyWith(workoutReminderDays: days),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── 2. Hydration Pings Card ──────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Hydration Reminders',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Recurring prompts to drink water and hit your hydration target.',
                    ),
                    value: prefs.hydrationRemindersEnabled,
                    onChanged: (val) {
                      controller.updatePreferences(
                        prefs.copyWith(hydrationRemindersEnabled: val),
                      );
                    },
                  ),
                  if (prefs.hydrationRemindersEnabled) ...[
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Reminder Interval',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [1, 2, 3, 4].map((hours) {
                        final isSelected =
                            prefs.hydrationIntervalHours == hours;
                        return ChoiceChip(
                          label: Text(
                            'Every $hours ${hours == 1 ? 'hr' : 'hrs'}',
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            controller.updatePreferences(
                              prefs.copyWith(hydrationIntervalHours: hours),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── 3. Rest & Recovery Card ──────────────────────────────────────
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Rest Day Recovery Tips',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Mobility, stretching, and nutrition recommendations on non-training days.',
                ),
                value: prefs.restDayAlertsEnabled,
                onChanged: (val) {
                  controller.updatePreferences(
                    prefs.copyWith(restDayAlertsEnabled: val),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── 4. Streak Saver Card ─────────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Streak Saver Alert',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Evening alert if no workout has been recorded today.',
                    ),
                    value: prefs.streakSaverEnabled,
                    onChanged: (val) {
                      controller.updatePreferences(
                        prefs.copyWith(streakSaverEnabled: val),
                      );
                    },
                  ),
                  if (prefs.streakSaverEnabled) ...[
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Alert Time',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: prefs.streakSaverHour,
                                minute: prefs.streakSaverMinute,
                              ),
                            );
                            if (picked != null) {
                              controller.updatePreferences(
                                prefs.copyWith(
                                  streakSaverHour: picked.hour,
                                  streakSaverMinute: picked.minute,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.access_time, size: 16),
                          label: Text(prefs.formattedStreakSaverTime),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── 5. Test Notification Triggers ────────────────────────────────
            Text(
              'Test Notification Triggers',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Instantly dispatch a test reminder to verify alerts and inbox delivery.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.fitness_center, size: 16),
                  label: const Text('Workout'),
                  onPressed: () => _triggerTestNotification(
                    context,
                    ref,
                    NotificationType.workoutReminder,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.water_drop, size: 16),
                  label: const Text('Hydration'),
                  onPressed: () => _triggerTestNotification(
                    context,
                    ref,
                    NotificationType.hydrationPing,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.self_improvement, size: 16),
                  label: const Text('Recovery'),
                  onPressed: () => _triggerTestNotification(
                    context,
                    ref,
                    NotificationType.restDayAlert,
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.local_fire_department, size: 16),
                  label: const Text('Streak'),
                  onPressed: () => _triggerTestNotification(
                    context,
                    ref,
                    NotificationType.streakSaver,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }

  void _triggerTestNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationType type,
  ) async {
    final notif = await ref
        .read(notificationControllerProvider.notifier)
        .sendTestNotification(type);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivered: ${notif.title}'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              DefaultTabController.of(context).animateTo(1);
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// -----------------------------------------------------------------------------
// Inbox Tab
// -----------------------------------------------------------------------------

class _InboxTab extends ConsumerWidget {
  const _InboxTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final deliveredAsync = ref.watch(deliveredNotificationsProvider);
    final controller = ref.read(notificationControllerProvider.notifier);

    return deliveredAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (err, _) => Center(
        child: AppErrorWidget(
          message: 'Failed to load inbox: $err',
          onRetry: () => ref.invalidate(deliveredNotificationsProvider),
        ),
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No notifications yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Reminders and alerts will appear here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Top action bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${notifications.length} Total',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: controller.markAllAsRead,
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('Mark all read'),
                      ),
                      TextButton.icon(
                        onPressed: controller.clearAll,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Notification feed list
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return NotificationTile(
                    notification: notif,
                    onTap: () {
                      if (!notif.isRead) {
                        controller.markAsRead(notif.id);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
