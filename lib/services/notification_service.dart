import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'dart:io' show Platform;

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
  static const channelDescription = 'Notifications for your daily routines and habits';

  Future<void> init() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
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

    // Request permissions for iOS and macOS
    if (Platform.isIOS || Platform.isMacOS) {
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

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode, // Use task ID's hash as notification ID
      'Task Reminder: ${task.name}',
      'It\'s time for your scheduled task',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('notification_sound'),
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task:${task.id}',
    );
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

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      habit.id.hashCode, // Use habit ID's hash as notification ID
      'Habit Reminder: ${habit.name}',
      'It\'s time for your ${habit.category.toString().split('.').last} habit',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'habit:${habit.id}',
    );
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
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification from Daily Routine Tracker',
      platformChannelSpecifics,
      payload: 'test',
    );
  }
} 