/// Category of automated notifications and reminders in CalibreFit.
enum NotificationType {
  workoutReminder,
  hydrationPing,
  restDayAlert,
  streakSaver;

  String get displayName => switch (this) {
    NotificationType.workoutReminder => 'Workout Reminder',
    NotificationType.hydrationPing => 'Hydration Alert',
    NotificationType.restDayAlert => 'Rest & Recovery',
    NotificationType.streakSaver => 'Streak Saver',
  };
}

/// A scheduled reminder rule configured by the user.
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    this.isEnabled = true,
  });

  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final int hour; // 0-23
  final int minute; // 0-59
  final List<int> daysOfWeek; // 1 = Monday ... 7 = Sunday
  final bool isEnabled;

  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  ScheduledReminder copyWith({
    int? id,
    String? title,
    String? body,
    NotificationType? type,
    int? hour,
    int? minute,
    List<int>? daysOfWeek,
    bool? isEnabled,
  }) {
    return ScheduledReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// A notification that has been delivered to the user's in-app inbox.
class DeliveredNotification {
  const DeliveredNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  DeliveredNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return DeliveredNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// User's global preferences for reminders and notification triggers.
class NotificationPreferences {
  const NotificationPreferences({
    this.workoutRemindersEnabled = true,
    this.workoutReminderHour = 8,
    this.workoutReminderMinute = 0,
    this.workoutReminderDays = const [1, 2, 3, 4, 5],
    this.hydrationRemindersEnabled = true,
    this.hydrationIntervalHours = 2,
    this.restDayAlertsEnabled = true,
    this.streakSaverEnabled = true,
    this.streakSaverHour = 20,
    this.streakSaverMinute = 0,
  });

  final bool workoutRemindersEnabled;
  final int workoutReminderHour;
  final int workoutReminderMinute;
  final List<int> workoutReminderDays;

  final bool hydrationRemindersEnabled;
  final int hydrationIntervalHours; // e.g. every 1, 2, 3, 4 hours

  final bool restDayAlertsEnabled;

  final bool streakSaverEnabled;
  final int streakSaverHour;
  final int streakSaverMinute;

  String get formattedWorkoutTime {
    final h = workoutReminderHour % 12 == 0 ? 12 : workoutReminderHour % 12;
    final m = workoutReminderMinute.toString().padLeft(2, '0');
    final period = workoutReminderHour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String get formattedStreakSaverTime {
    final h = streakSaverHour % 12 == 0 ? 12 : streakSaverHour % 12;
    final m = streakSaverMinute.toString().padLeft(2, '0');
    final period = streakSaverHour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  NotificationPreferences copyWith({
    bool? workoutRemindersEnabled,
    int? workoutReminderHour,
    int? workoutReminderMinute,
    List<int>? workoutReminderDays,
    bool? hydrationRemindersEnabled,
    int? hydrationIntervalHours,
    bool? restDayAlertsEnabled,
    bool? streakSaverEnabled,
    int? streakSaverHour,
    int? streakSaverMinute,
  }) {
    return NotificationPreferences(
      workoutRemindersEnabled:
          workoutRemindersEnabled ?? this.workoutRemindersEnabled,
      workoutReminderHour: workoutReminderHour ?? this.workoutReminderHour,
      workoutReminderMinute:
          workoutReminderMinute ?? this.workoutReminderMinute,
      workoutReminderDays: workoutReminderDays ?? this.workoutReminderDays,
      hydrationRemindersEnabled:
          hydrationRemindersEnabled ?? this.hydrationRemindersEnabled,
      hydrationIntervalHours:
          hydrationIntervalHours ?? this.hydrationIntervalHours,
      restDayAlertsEnabled: restDayAlertsEnabled ?? this.restDayAlertsEnabled,
      streakSaverEnabled: streakSaverEnabled ?? this.streakSaverEnabled,
      streakSaverHour: streakSaverHour ?? this.streakSaverHour,
      streakSaverMinute: streakSaverMinute ?? this.streakSaverMinute,
    );
  }
}
