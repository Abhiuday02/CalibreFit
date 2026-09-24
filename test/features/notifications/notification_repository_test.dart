import 'package:calibrefit/features/notifications/data/mock_notification_repository.dart';
import 'package:calibrefit/features/notifications/domain/notification_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockNotificationRepository', () {
    late MockNotificationRepository repository;

    setUp(() {
      repository = MockNotificationRepository();
    });

    test('getPreferences returns default notification preferences', () async {
      final prefs = await repository.getPreferences();

      expect(prefs.workoutRemindersEnabled, isTrue);
      expect(prefs.workoutReminderHour, equals(8));
      expect(prefs.hydrationRemindersEnabled, isTrue);
      expect(prefs.restDayAlertsEnabled, isTrue);
      expect(prefs.streakSaverEnabled, isTrue);
    });

    test(
      'updatePreferences updates preferences and synchronizes reminders',
      () async {
        final updated = const NotificationPreferences(
          workoutRemindersEnabled: false,
          workoutReminderHour: 6,
          workoutReminderMinute: 30,
          workoutReminderDays: [2, 4, 6],
        );

        await repository.updatePreferences(updated);
        final prefs = await repository.getPreferences();
        expect(prefs.workoutRemindersEnabled, isFalse);
        expect(prefs.workoutReminderHour, equals(6));
        expect(prefs.workoutReminderMinute, equals(30));
        expect(prefs.workoutReminderDays, equals([2, 4, 6]));

        final reminders = await repository.getScheduledReminders();
        final workoutReminder = reminders.firstWhere(
          (r) => r.type == NotificationType.workoutReminder,
        );
        expect(workoutReminder.isEnabled, isFalse);
        expect(workoutReminder.hour, equals(6));
        expect(workoutReminder.minute, equals(30));
        expect(workoutReminder.daysOfWeek, equals([2, 4, 6]));
      },
    );

    test(
      'toggleReminder toggles reminder state and syncs to preferences',
      () async {
        final initialReminders = await repository.getScheduledReminders();
        final target = initialReminders.first;

        await repository.toggleReminder(id: target.id, isEnabled: false);

        final updatedReminders = await repository.getScheduledReminders();
        final updated = updatedReminders.firstWhere((r) => r.id == target.id);
        expect(updated.isEnabled, isFalse);

        final prefs = await repository.getPreferences();
        expect(prefs.workoutRemindersEnabled, isFalse);
      },
    );

    test(
      'updateReminderTime updates scheduled reminder hour and minute',
      () async {
        final reminders = await repository.getScheduledReminders();
        final target = reminders.firstWhere(
          (r) => r.type == NotificationType.workoutReminder,
        );

        await repository.updateReminderTime(id: target.id, hour: 7, minute: 45);

        final updatedReminders = await repository.getScheduledReminders();
        final updated = updatedReminders.firstWhere((r) => r.id == target.id);
        expect(updated.hour, equals(7));
        expect(updated.minute, equals(45));

        final prefs = await repository.getPreferences();
        expect(prefs.workoutReminderHour, equals(7));
        expect(prefs.workoutReminderMinute, equals(45));
      },
    );

    test('updateReminderDays updates scheduled reminder active days', () async {
      final reminders = await repository.getScheduledReminders();
      final target = reminders.firstWhere(
        (r) => r.type == NotificationType.workoutReminder,
      );

      await repository.updateReminderDays(id: target.id, daysOfWeek: [1, 3, 5]);

      final updatedReminders = await repository.getScheduledReminders();
      final updated = updatedReminders.firstWhere((r) => r.id == target.id);
      expect(updated.daysOfWeek, equals([1, 3, 5]));

      final prefs = await repository.getPreferences();
      expect(prefs.workoutReminderDays, equals([1, 3, 5]));
    });

    test('getDeliveredNotifications loads seeded inbox alerts', () async {
      final delivered = await repository.getDeliveredNotifications();
      expect(delivered, isNotEmpty);
      expect(delivered.any((n) => !n.isRead), isTrue);
    });

    test(
      'sendTestNotification inserts new notification at the top of inbox',
      () async {
        final before = await repository.getDeliveredNotifications();
        final initialCount = before.length;

        final testNotif = await repository.sendTestNotification(
          NotificationType.workoutReminder,
        );

        expect(testNotif.title, contains('Workout'));
        expect(testNotif.isRead, isFalse);

        final after = await repository.getDeliveredNotifications();
        expect(after.length, equals(initialCount + 1));
        expect(after.first.id, equals(testNotif.id));
      },
    );

    test('markAsRead marks specific notification as read', () async {
      final delivered = await repository.getDeliveredNotifications();
      final unread = delivered.firstWhere((n) => !n.isRead);

      await repository.markAsRead(unread.id);

      final updated = await repository.getDeliveredNotifications();
      final item = updated.firstWhere((n) => n.id == unread.id);
      expect(item.isRead, isTrue);
    });

    test('markAllAsRead marks all notifications as read', () async {
      await repository.markAllAsRead();

      final updated = await repository.getDeliveredNotifications();
      expect(updated.every((n) => n.isRead), isTrue);
    });

    test(
      'clearAllNotifications clears the delivered notification history',
      () async {
        await repository.clearAllNotifications();

        final updated = await repository.getDeliveredNotifications();
        expect(updated, isEmpty);
      },
    );
  });
}
