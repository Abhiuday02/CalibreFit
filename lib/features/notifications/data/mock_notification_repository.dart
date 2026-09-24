import 'package:calibrefit/features/notifications/domain/notification_models.dart';
import 'package:calibrefit/features/notifications/domain/notification_repository.dart';

/// In-memory implementation of [NotificationRepository] simulating local
/// notification scheduling, preference persistence, and inbox delivery.
class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository({NotificationPreferences? initialPreferences})
    : _preferences = initialPreferences ?? const NotificationPreferences() {
    _initDefaultReminders();
    _initSeedDelivered();
  }

  NotificationPreferences _preferences;
  final List<ScheduledReminder> _reminders = [];
  final List<DeliveredNotification> _delivered = [];
  static const _delay = Duration(milliseconds: 100);

  @override
  Future<NotificationPreferences> getPreferences() async {
    await Future.delayed(_delay);
    return _preferences;
  }

  @override
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    await Future.delayed(_delay);
    _preferences = preferences;

    // Synchronize corresponding reminder rules
    _updateReminderFromPreferences();
  }

  @override
  Future<List<ScheduledReminder>> getScheduledReminders() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_reminders);
  }

  @override
  Future<void> toggleReminder({
    required int id,
    required bool isEnabled,
  }) async {
    await Future.delayed(_delay);
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(isEnabled: isEnabled);

      // Sync back to preferences
      final type = _reminders[index].type;
      switch (type) {
        case NotificationType.workoutReminder:
          _preferences = _preferences.copyWith(
            workoutRemindersEnabled: isEnabled,
          );
          break;
        case NotificationType.hydrationPing:
          _preferences = _preferences.copyWith(
            hydrationRemindersEnabled: isEnabled,
          );
          break;
        case NotificationType.restDayAlert:
          _preferences = _preferences.copyWith(restDayAlertsEnabled: isEnabled);
          break;
        case NotificationType.streakSaver:
          _preferences = _preferences.copyWith(streakSaverEnabled: isEnabled);
          break;
      }
    }
  }

  @override
  Future<void> updateReminderTime({
    required int id,
    required int hour,
    required int minute,
  }) async {
    await Future.delayed(_delay);
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        hour: hour.clamp(0, 23),
        minute: minute.clamp(0, 59),
      );

      final type = _reminders[index].type;
      if (type == NotificationType.workoutReminder) {
        _preferences = _preferences.copyWith(
          workoutReminderHour: hour,
          workoutReminderMinute: minute,
        );
      } else if (type == NotificationType.streakSaver) {
        _preferences = _preferences.copyWith(
          streakSaverHour: hour,
          streakSaverMinute: minute,
        );
      }
    }
  }

  @override
  Future<void> updateReminderDays({
    required int id,
    required List<int> daysOfWeek,
  }) async {
    await Future.delayed(_delay);
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(daysOfWeek: daysOfWeek);

      if (_reminders[index].type == NotificationType.workoutReminder) {
        _preferences = _preferences.copyWith(workoutReminderDays: daysOfWeek);
      }
    }
  }

  @override
  Future<List<DeliveredNotification>> getDeliveredNotifications() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_delivered);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _delivered.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _delivered[index] = _delivered[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 50));
    for (var i = 0; i < _delivered.length; i++) {
      _delivered[i] = _delivered[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _delivered.clear();
  }

  @override
  Future<DeliveredNotification> sendTestNotification(
    NotificationType type,
  ) async {
    await Future.delayed(const Duration(milliseconds: 80));

    final (title, body) = switch (type) {
      NotificationType.workoutReminder => (
        'Workout Time! 🏋️',
        "Today's scheduled session: Upper Body Push. Let's get after it!",
      ),
      NotificationType.hydrationPing => (
        'Hydration Check 💧',
        'Drink a glass of water (250ml) to stay hydrated and hit your target.',
      ),
      NotificationType.restDayAlert => (
        'Active Recovery Day 🧘',
        'Focus on mobility, light stretching, and hitting your protein goal today.',
      ),
      NotificationType.streakSaver => (
        'Keep the Streak Alive! 🔥',
        "Don't lose your 5-day workout streak! Log a quick session tonight.",
      ),
    };

    final notification = DeliveredNotification(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _delivered.insert(0, notification);
    return notification;
  }

  void _initDefaultReminders() {
    _reminders.addAll([
      ScheduledReminder(
        id: 1,
        title: 'Workout Reminder',
        body: "Time for your scheduled workout session. Let's make progress!",
        type: NotificationType.workoutReminder,
        hour: _preferences.workoutReminderHour,
        minute: _preferences.workoutReminderMinute,
        daysOfWeek: _preferences.workoutReminderDays,
        isEnabled: _preferences.workoutRemindersEnabled,
      ),
      ScheduledReminder(
        id: 2,
        title: 'Hydration Ping',
        body: 'Hydration reminder: Drink a glass of water (250ml).',
        type: NotificationType.hydrationPing,
        hour: 10,
        minute: 0,
        daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
        isEnabled: _preferences.hydrationRemindersEnabled,
      ),
      ScheduledReminder(
        id: 3,
        title: 'Rest & Recovery Alert',
        body: 'Scheduled rest day: Prioritize mobility and optimal nutrition.',
        type: NotificationType.restDayAlert,
        hour: 9,
        minute: 0,
        daysOfWeek: const [7], // Sunday
        isEnabled: _preferences.restDayAlertsEnabled,
      ),
      ScheduledReminder(
        id: 4,
        title: 'Streak Saver Alert',
        body: 'Evening reminder: Log your workout today to keep your streak!',
        type: NotificationType.streakSaver,
        hour: _preferences.streakSaverHour,
        minute: _preferences.streakSaverMinute,
        daysOfWeek: const [1, 2, 3, 4, 5, 6, 7],
        isEnabled: _preferences.streakSaverEnabled,
      ),
    ]);
  }

  void _initSeedDelivered() {
    final now = DateTime.now();
    _delivered.addAll([
      DeliveredNotification(
        id: 'seed-notif-1',
        title: "Today's Workout: Push Focus 🏋️",
        body: 'Your scheduled workout is ready: Bench Press, Overhead Press, and Tricep Dips.',
        type: NotificationType.workoutReminder,
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      DeliveredNotification(
        id: 'seed-notif-2',
        title: 'Hydration Check 💧',
        body: "You've logged 1,750ml of your 2,500ml daily target. Keep going!",
        type: NotificationType.hydrationPing,
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      DeliveredNotification(
        id: 'seed-notif-3',
        title: 'Recovery Insight 🧘',
        body: 'Great intensity yesterday! Ensure 8 hours of sleep for muscle protein synthesis.',
        type: NotificationType.restDayAlert,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
      ),
    ]);
  }

  void _updateReminderFromPreferences() {
    for (var i = 0; i < _reminders.length; i++) {
      final r = _reminders[i];
      switch (r.type) {
        case NotificationType.workoutReminder:
          _reminders[i] = r.copyWith(
            isEnabled: _preferences.workoutRemindersEnabled,
            hour: _preferences.workoutReminderHour,
            minute: _preferences.workoutReminderMinute,
            daysOfWeek: _preferences.workoutReminderDays,
          );
          break;
        case NotificationType.hydrationPing:
          _reminders[i] = r.copyWith(
            isEnabled: _preferences.hydrationRemindersEnabled,
          );
          break;
        case NotificationType.restDayAlert:
          _reminders[i] = r.copyWith(
            isEnabled: _preferences.restDayAlertsEnabled,
          );
          break;
        case NotificationType.streakSaver:
          _reminders[i] = r.copyWith(
            isEnabled: _preferences.streakSaverEnabled,
            hour: _preferences.streakSaverHour,
            minute: _preferences.streakSaverMinute,
          );
          break;
      }
    }
  }
}
