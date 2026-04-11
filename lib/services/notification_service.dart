import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';

class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final List<ScheduledNotification> _scheduled = [];
  Timer? _timer;
  bool _mobileReady = false;

  Future<void> init() async {
    if (Platform.isLinux) {
      _startLinuxTimer();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _initMobile();
    }
  }

  // ── Linux ──

  void _startLinuxTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkAndFireLinux();
    });
  }

  void _checkAndFireLinux() {
    final now = DateTime.now();
    final toFire = _scheduled
        .where((n) => n.scheduledAt.isBefore(now))
        .toList();

    for (final notification in toFire) {
      _sendLinuxNotification(notification.title, notification.body);
      _scheduled.remove(notification);
    }
  }

  Future<void> _sendLinuxNotification(String title, String body) async {
    try {
      await Process.run('notify-send', [title, body, '--urgency=normal']);
    } catch (_) {}
  }

  // ── Mobile (Android/iOS) ──

  Future<void> _initMobile() async {
    try {
      await AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'task_due',
          channelName: 'Terminy zadań',
          channelDescription: 'Powiadomienia o terminach zadań',
          importance: NotificationImportance.High,
        ),
      ]);
      _mobileReady = true;
    } catch (_) {}
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      } catch (_) {}
    }
  }

  // ── Public API ──

  /// Send an immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (Platform.isLinux) {
      await _sendLinuxNotification(
        'Test powiadomienia',
        'Jeśli widzisz to, działa!',
      );
    } else if (_mobileReady) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999999,
          channelKey: 'task_due',
          title: 'Test powiadomienia',
          body: 'Jeśli widzisz to, działa!',
        ),
      );
    }
  }

  /// Schedule a notification for a task at its due date
  Future<void> scheduleTaskNotification({
    required int notificationId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    await cancelNotification(notificationId);

    if (dueDate.isBefore(DateTime.now())) {
      return;
    }

    if (Platform.isLinux) {
      _scheduled.add(
        ScheduledNotification(
          id: notificationId,
          title: 'Termin zadania',
          body: taskTitle,
          scheduledAt: dueDate,
        ),
      );
    } else if (_mobileReady) {
      try {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'task_due',
            title: 'Termin zadania',
            body: taskTitle,
            wakeUpScreen: true,
          ),
          schedule: NotificationCalendar(
            year: dueDate.year,
            month: dueDate.month,
            day: dueDate.day,
            hour: dueDate.hour,
            minute: dueDate.minute,
            second: 0,
            millisecond: 0,
            preciseAlarm: true,
            allowWhileIdle: true,
            repeats: false,
          ),
        );
      } catch (_) {}
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int notificationId) async {
    _scheduled.removeWhere((n) => n.id == notificationId);

    if (_mobileReady) {
      try {
        await AwesomeNotifications().cancel(notificationId);
      } catch (_) {}
    }
  }

  /// Generate a deterministic notification ID from task ID
  static int idFromTaskId(String taskId) {
    return taskId.hashCode & 0x7FFFFFFF;
  }

  void dispose() {
    _timer?.cancel();
  }
}
