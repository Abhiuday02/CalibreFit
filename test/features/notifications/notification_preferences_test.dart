import 'package:calibrefit/features/notifications/domain/notification_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPreferences', () {
    test('default preferences are configured correctly', () {
      const prefs = NotificationPreferences();

      expect(prefs.workoutRemindersEnabled, isTrue);
      expect(prefs.workoutReminderHour, equals(8));
      expect(prefs.workoutReminderMinute, equals(0));
      expect(prefs.workoutReminderDays, equals([1, 2, 3, 4, 5]));
      expect(prefs.hydrationRemindersEnabled, isTrue);
      expect(prefs.hydrationIntervalHours, equals(2));
      expect(prefs.restDayAlertsEnabled, isTrue);
      expect(prefs.streakSaverEnabled, isTrue);
      expect(prefs.streakSaverHour, equals(20));
      expect(prefs.streakSaverMinute, equals(0));
    });

    test('formattedWorkoutTime formats 12-hour AM/PM correctly', () {
      const morning = NotificationPreferences(
        workoutReminderHour: 7,
        workoutReminderMinute: 30,
      );
      expect(morning.formattedWorkoutTime, equals('7:30 AM'));

      const noon = NotificationPreferences(
        workoutReminderHour: 12,
        workoutReminderMinute: 0,
      );
      expect(noon.formattedWorkoutTime, equals('12:00 PM'));

      const midnight = NotificationPreferences(
        workoutReminderHour: 0,
        workoutReminderMinute: 45,
      );
      expect(midnight.formattedWorkoutTime, equals('12:45 AM'));

      const evening = NotificationPreferences(
        streakSaverHour: 20,
        streakSaverMinute: 15,
      );
      expect(evening.formattedStreakSaverTime, equals('8:15 PM'));
    });

    test('copyWith updates specified fields while keeping others', () {
      const initial = NotificationPreferences();
      final updated = initial.copyWith(
        workoutReminderHour: 6,
        workoutReminderDays: [1, 3, 5],
        hydrationIntervalHours: 3,
      );

      expect(updated.workoutReminderHour, equals(6));
      expect(updated.workoutReminderDays, equals([1, 3, 5]));
      expect(updated.hydrationIntervalHours, equals(3));
      // Preserved fields
      expect(updated.workoutRemindersEnabled, isTrue);
      expect(updated.restDayAlertsEnabled, isTrue);
      expect(updated.streakSaverHour, equals(20));
    });
  });

  group('ScheduledReminder', () {
    test('formattedTime formats time properly', () {
      const reminder = ScheduledReminder(
        id: 1,
        title: 'Morning Push',
        body: 'Start the day strong.',
        type: NotificationType.workoutReminder,
        hour: 9,
        minute: 5,
        daysOfWeek: [1, 2, 3],
      );

      expect(reminder.formattedTime, equals('9:05 AM'));
    });

    test('copyWith properly mutates properties', () {
      const reminder = ScheduledReminder(
        id: 1,
        title: 'Morning Push',
        body: 'Start the day strong.',
        type: NotificationType.workoutReminder,
        hour: 9,
        minute: 0,
        daysOfWeek: [1, 2, 3],
      );

      final modified = reminder.copyWith(isEnabled: false, hour: 10);
      expect(modified.isEnabled, isFalse);
      expect(modified.hour, equals(10));
      expect(modified.title, equals('Morning Push'));
    });
  });
}
