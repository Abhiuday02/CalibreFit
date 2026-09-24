import 'package:calibrefit/features/notifications/domain/notification_models.dart';

/// Abstract contract for managing user notification preferences, scheduled
/// reminder rules, and in-app notification inbox history.
abstract class NotificationRepository {
  /// Loads the active notification and reminder preferences.
  Future<NotificationPreferences> getPreferences();

  /// Updates and persists the user's notification preferences.
  Future<void> updatePreferences(NotificationPreferences preferences);

  /// Retrieves the list of currently scheduled reminder rules.
  Future<List<ScheduledReminder>> getScheduledReminders();

  /// Toggles whether a specific reminder rule is enabled.
  Future<void> toggleReminder({required int id, required bool isEnabled});

  /// Updates the time of day for a scheduled reminder rule.
  Future<void> updateReminderTime({
    required int id,
    required int hour,
    required int minute,
  });

  /// Updates the active days of the week for a scheduled reminder rule.
  Future<void> updateReminderDays({
    required int id,
    required List<int> daysOfWeek,
  });

  /// Retrieves all notifications delivered to the user's inbox.
  Future<List<DeliveredNotification>> getDeliveredNotifications();

  /// Marks a specific delivered notification as read.
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications in the inbox as read.
  Future<void> markAllAsRead();

  /// Clears the entire delivered notification history.
  Future<void> clearAllNotifications();

  /// Simulates scheduling and dispatching a test notification of [type].
  Future<DeliveredNotification> sendTestNotification(NotificationType type);
}
