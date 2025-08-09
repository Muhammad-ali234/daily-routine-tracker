import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../widgets/in_app_notification.dart';
import 'notification_manager.dart';

class HabitMonitorService {
  static final HabitMonitorService _instance = HabitMonitorService._internal();
  factory HabitMonitorService() => _instance;
  
  HabitMonitorService._internal();
  
  Timer? _timer;
  BuildContext? _context;
  
  // Initialize the service with the app's context
  void init(BuildContext context) {
    _context = context;
    _startMonitoring();
  }
  
  // Start monitoring habits
  void _startMonitoring() {
    // Check habits every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkHabits();
      
      // Also update notification count periodically
      if (_context != null) {
        Provider.of<NotificationManager>(_context!, listen: false).updateNotificationCount();
      }
    });
    
    // Initial check
    _checkHabits();
  }
  
  // Cancel the timer when the app is closed
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
  
  // Check habits for start/end times matching the current time
  Future<void> _checkHabits() async {
    if (_context == null) return;
    
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentDay = _getWeekdayFromDate(now);
    
    // Get all habits
    final habitsBox = await Hive.openBox<Habit>('habits');
    final habits = habitsBox.values.toList();
    
    for (final habit in habits) {
      // Check if the habit is scheduled for today
      bool isScheduledForToday = false;
      
      switch (currentDay) {
        case 'monday':
          isScheduledForToday = habit.monday;
          break;
        case 'tuesday':
          isScheduledForToday = habit.tuesday;
          break;
        case 'wednesday':
          isScheduledForToday = habit.wednesday;
          break;
        case 'thursday':
          isScheduledForToday = habit.thursday;
          break;
        case 'friday':
          isScheduledForToday = habit.friday;
          break;
        case 'saturday':
          isScheduledForToday = habit.saturday;
          break;
        case 'sunday':
          isScheduledForToday = habit.sunday;
          break;
      }
      
      if (!isScheduledForToday) continue;
      
      // Check start time
      if (habit.startTime != null && 
          habit.startTime!.hour == currentHour && 
          habit.startTime!.minute == currentMinute) {
        _showStartNotification(habit);
      }
      
      // Check end time
      if (habit.endTime != null && 
          habit.endTime!.hour == currentHour && 
          habit.endTime!.minute == currentMinute) {
        _showEndNotification(habit);
      }
    }
  }
  
  // Show notification when a habit starts
  void _showStartNotification(Habit habit) {
    if (_context != null) {
      InAppNotificationService.showHabitStartNotification(_context!, habit);
    }
  }
  
  // Show notification when a habit ends
  void _showEndNotification(Habit habit) {
    if (_context != null) {
      InAppNotificationService.showHabitEndNotification(_context!, habit);
    }
  }
  
  // Helper method to get weekday from date
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
} 