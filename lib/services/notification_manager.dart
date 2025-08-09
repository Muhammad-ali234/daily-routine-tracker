import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';

class NotificationManager extends ChangeNotifier {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  
  NotificationManager._internal();
  
  int _notificationCount = 0;
  
  int get notificationCount => _notificationCount;
  
  // Update notification count based on current habits
  Future<void> updateNotificationCount() async {
    final now = DateTime.now();
    final habitsBox = await Hive.openBox<Habit>('habits');
    final habits = habitsBox.values.toList();
    
    int count = 0;
    
    // Count notifications for habits starting or ending today
    for (final habit in habits) {
      if (habit.startTime != null) {
        // Check if this habit is scheduled for today
        bool scheduledForToday = false;
        switch (now.weekday) {
          case DateTime.monday:
            scheduledForToday = habit.monday;
            break;
          case DateTime.tuesday:
            scheduledForToday = habit.tuesday;
            break;
          case DateTime.wednesday:
            scheduledForToday = habit.wednesday;
            break;
          case DateTime.thursday:
            scheduledForToday = habit.thursday;
            break;
          case DateTime.friday:
            scheduledForToday = habit.friday;
            break;
          case DateTime.saturday:
            scheduledForToday = habit.saturday;
            break;
          case DateTime.sunday:
            scheduledForToday = habit.sunday;
            break;
        }
        
        if (scheduledForToday) {
          // Count upcoming notifications only
          final startDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            habit.startTime!.hour,
            habit.startTime!.minute,
          );
          
          if (startDateTime.isAfter(now)) {
            count++;
          }
          
          if (habit.endTime != null) {
            final endDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              habit.endTime!.hour,
              habit.endTime!.minute,
            );
            
            if (endDateTime.isAfter(now)) {
              count++;
            }
          }
        }
      }
    }
    
    if (_notificationCount != count) {
      _notificationCount = count;
      notifyListeners();
    }
  }
} 