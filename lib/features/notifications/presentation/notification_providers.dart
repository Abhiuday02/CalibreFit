import 'package:calibrefit/features/notifications/data/mock_notification_repository.dart';
import 'package:calibrefit/features/notifications/domain/notification_models.dart';
import 'package:calibrefit/features/notifications/domain/notification_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});

// ---------------------------------------------------------------------------
// Data Providers
// ---------------------------------------------------------------------------

final notificationPreferencesProvider = FutureProvider<NotificationPreferences>(
  (ref) async {
    final repo = ref.watch(notificationRepositoryProvider);
    return repo.getPreferences();
  },
);

final scheduledRemindersProvider = FutureProvider<List<ScheduledReminder>>((
  ref,
) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getScheduledReminders();
});

final deliveredNotificationsProvider =
    FutureProvider<List<DeliveredNotification>>((ref) async {
      final repo = ref.watch(notificationRepositoryProvider);
      return repo.getDeliveredNotifications();
    });

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications =
      ref.watch(deliveredNotificationsProvider).asData?.value ?? [];
  return notifications.where((n) => !n.isRead).length;
});

// ---------------------------------------------------------------------------
// Controller Provider
// ---------------------------------------------------------------------------

class NotificationController extends Notifier<void> {
  @override
  void build() {}

  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    await _repo.updatePreferences(preferences);
    ref.invalidate(notificationPreferencesProvider);
    ref.invalidate(scheduledRemindersProvider);
  }

  Future<void> toggleReminder(int id, bool isEnabled) async {
    await _repo.toggleReminder(id: id, isEnabled: isEnabled);
    ref.invalidate(scheduledRemindersProvider);
    ref.invalidate(notificationPreferencesProvider);
  }

  Future<void> updateReminderTime(int id, int hour, int minute) async {
    await _repo.updateReminderTime(id: id, hour: hour, minute: minute);
    ref.invalidate(scheduledRemindersProvider);
    ref.invalidate(notificationPreferencesProvider);
  }

  Future<void> updateReminderDays(int id, List<int> daysOfWeek) async {
    await _repo.updateReminderDays(id: id, daysOfWeek: daysOfWeek);
    ref.invalidate(scheduledRemindersProvider);
    ref.invalidate(notificationPreferencesProvider);
  }

  Future<DeliveredNotification> sendTestNotification(
    NotificationType type,
  ) async {
    final notification = await _repo.sendTestNotification(type);
    ref.invalidate(deliveredNotificationsProvider);
    return notification;
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    ref.invalidate(deliveredNotificationsProvider);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    ref.invalidate(deliveredNotificationsProvider);
  }

  Future<void> clearAll() async {
    await _repo.clearAllNotifications();
    ref.invalidate(deliveredNotificationsProvider);
  }
}

final notificationControllerProvider =
    NotifierProvider<NotificationController, void>(NotificationController.new);
