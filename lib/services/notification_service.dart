import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io' show Platform;
import 'package:hive/hive.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/task.dart';
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const channelId = 'daily_routine_tracker_channel';
  static const channelName = 'Daily Routine Tracker';
  static const channelDescription =
      'Notifications for your daily routines and habits';

  Future<void> init() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();

    String timeZoneName;
    try {
      // Get timezone from DateTime offset instead of using flutter_native_timezone
      final DateTime now = DateTime.now();
      final Duration offset = now.timeZoneOffset;
      final int hours = offset.inHours;

      // Fix the timezone format: GMT+5 should be Etc/GMT-5 (negative for positive offset)
      final String sign = hours >= 0 ? '-' : '+';
      final String hoursStr = hours.abs().toString().padLeft(2, '0');
      timeZoneName = 'Etc/GMT$sign$hoursStr';
      debugPrint('Using timezone: $timeZoneName');
    } catch (e) {
      debugPrint('Error determining timezone: $e');
      // Ultimate fallback - use UTC
      timeZoneName = 'UTC';
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Error setting timezone: $e');
      // Ultimate fallback - use UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS notification received when app is in foreground
      },
    );

    // Windows notification settings
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    // Initialize unified settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
          // You can navigate to a specific screen based on the payload
          // e.g., if the payload is 'task:123', navigate to the task details screen
        }
      },
    );

    // Request permissions for iOS and macOS (only if not on web)
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.dueDate == null || task.startTime == null) return;

    final now = DateTime.now();
    final scheduledDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      task.startTime!.hour,
      task.startTime!.minute,
    );

    // Don't schedule if the time has already passed
    if (scheduledDate.isBefore(now)) return;

    // Create platform-specific notification details
    final NotificationDetails notificationDetails =
        _getPlatformNotificationDetails(
      title: 'Task Reminder: ${task.name}',
      body: 'It\'s time for your scheduled task',
    );

    try {
      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id.hashCode, // Use task ID's hash as notification ID
        'Task Reminder: ${task.name}',
        'It\'s time for your scheduled task',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'task:${task.id}',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      debugPrint(
          'Task "${task.name}" would be scheduled for ${scheduledDate.toString()}');
    }
  }

  // Helper method to get platform-specific notification details
  NotificationDetails _getPlatformNotificationDetails(
      {required String title, required String body}) {
    if (!kIsWeb && Platform.isAndroid) {
      return const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );
    } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
    } else if (!kIsWeb && Platform.isLinux) {
      return const NotificationDetails(
        linux: LinuxNotificationDetails(
          actions: [LinuxNotificationAction(key: 'open', label: 'Open')],
        ),
      );
    } else {
      // Windows, Web, and others
      return const NotificationDetails();
    }
  }

  Future<void> scheduleHabitNotification(Habit habit, DateTime date) async {
    if (habit.startTime == null) return;

    // Check if the habit should occur on this day
    String weekday = _getWeekdayFromDate(date);
    bool shouldNotify = false;

    switch (weekday) {
      case 'monday':
        shouldNotify = habit.monday;
        break;
      case 'tuesday':
        shouldNotify = habit.tuesday;
        break;
      case 'wednesday':
        shouldNotify = habit.wednesday;
        break;
      case 'thursday':
        shouldNotify = habit.thursday;
        break;
      case 'friday':
        shouldNotify = habit.friday;
        break;
      case 'saturday':
        shouldNotify = habit.saturday;
        break;
      case 'sunday':
        shouldNotify = habit.sunday;
        break;
    }

    if (!shouldNotify) return;

    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      habit.startTime!.hour,
      habit.startTime!.minute,
    );

    // Don't schedule if the time has already passed
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;

    // Get platform-specific notification details
    final NotificationDetails notificationDetails =
        _getPlatformNotificationDetails(
      title: 'Habit Reminder: ${habit.name}',
      body:
          'It\'s time for your ${habit.category.toString().split('.').last} habit',
    );

    try {
      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        habit.id.hashCode, // Use habit ID's hash as notification ID
        'Habit Reminder: ${habit.name}',
        'It\'s time for your ${habit.category.toString().split('.').last} habit',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'habit:${habit.id}',
      );
    } catch (e) {
      debugPrint('Error scheduling habit notification: $e');
      debugPrint(
          'Habit "${habit.name}" would be scheduled for ${scheduledDate.toString()}');
    }
  }

  Future<void> scheduleWeeklyHabitNotifications(Habit habit) async {
    // Schedule for today and the next 7 days
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      await scheduleHabitNotification(habit, date);
    }
  }

  Future<void> cancelNotificationForTask(Task task) async {
    await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
  }

  Future<void> cancelNotificationForHabit(Habit habit) async {
    await flutterLocalNotificationsPlugin.cancel(habit.id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  String _getWeekdayFromDate(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  // Display an immediate notification for testing
  Future<void> showTestNotification() async {
    // Platform-specific notification details
    final NotificationDetails platformChannelSpecifics;

    if (!kIsWeb && Platform.isAndroid) {
      platformChannelSpecifics = const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
    } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      platformChannelSpecifics = const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
    } else if (!kIsWeb && Platform.isLinux) {
      platformChannelSpecifics = const NotificationDetails(
        linux: LinuxNotificationDetails(
          actions: [LinuxNotificationAction(key: 'open', label: 'Open')],
        ),
      );
    } else {
      // Windows, Web, and others
      platformChannelSpecifics = const NotificationDetails();
    }

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Test Notification',
        'This is a test notification from Daily Routine Tracker',
        platformChannelSpecifics,
        payload: 'test',
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
      // Fallback for platforms that don't fully support notifications
      debugPrint(
          'Notification would have shown: Test Notification - This is a test notification from Daily Routine Tracker');
    }
  }

  // New method for immediate Windows notifications while app is running
  Future<void> checkAndSendHabitNotifications() async {
    // This should be called periodically by the app to check if any habits need notifications
    if (kIsWeb || !Platform.isWindows) return; // Only run this on Windows

    // Get all habits
    final habitsBox = await Hive.openBox<Habit>('habits');
    final habits = habitsBox.values.toList();

    // Only show notification for one random habit to avoid overwhelming
    if (habits.isNotEmpty) {
      // Get a random habit
      final random = Random();
      final habit = habits[random.nextInt(habits.length)];

      try {
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails();

        await flutterLocalNotificationsPlugin.show(
          habit.id.hashCode,
          'Habit Reminder: ${habit.name}',
          'It\'s time for your ${habit.category.toString().split('.').last} habit',
          platformChannelSpecifics,
          payload: 'habit:${habit.id}',
        );

        debugPrint('Showing Windows notification for habit: ${habit.name}');
      } catch (e) {
        debugPrint('Error showing Windows notification: $e');
      }
    }
  }
}
