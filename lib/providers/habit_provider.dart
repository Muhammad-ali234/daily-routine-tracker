import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';
import '../services/notification_service.dart';

class HabitProvider with ChangeNotifier {
  Box<Habit>? _habitsBox;
  List<Habit> _habits = [];
  bool _isInitialized = false;
  final NotificationService _notificationService = NotificationService();

  HabitProvider() {
    _initBox();
  }

  Future<void> _initBox() async {
    try {
      _habitsBox = await Hive.openBox<Habit>('habits');
      _loadHabits();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing habits box: $e');
      // You might want to handle this error appropriately
    }
  }

  void _loadHabits() {
    if (_habitsBox != null) {
      _habits = _habitsBox!.values.toList();
      notifyListeners();
    }
  }

  // Public method to reload habits (used after import/clear data)
  void loadHabits() {
    _loadHabits();
  }

  List<Habit> get habits => _habits;

  List<Habit> getHabitsByCategory(HabitCategory category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  Future<void> addHabit(Habit habit) async {
    if (!_isInitialized) {
      await _initBox();
    }
    
    if (_habitsBox == null) {
      throw Exception('Habits box not initialized');
    }

    final id = const Uuid().v4();
    final newHabit = Habit(
      id: id,
      name: habit.name,
      category: habit.category,
      monday: habit.monday,
      tuesday: habit.tuesday,
      wednesday: habit.wednesday,
      thursday: habit.thursday,
      friday: habit.friday,
      saturday: habit.saturday,
      sunday: habit.sunday,
      createdAt: DateTime.now(),
      startTime: habit.startTime,
      endTime: habit.endTime,
    );
    
    await _habitsBox!.put(id, newHabit);
    
    // Schedule notifications for the habit
    if (newHabit.startTime != null) {
      await _notificationService.scheduleWeeklyHabitNotifications(newHabit);
    }
    
    _loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    if (!_isInitialized) {
      await _initBox();
    }
    
    if (_habitsBox == null) {
      throw Exception('Habits box not initialized');
    }

    await _habitsBox!.put(habit.id, habit);
    
    // Cancel existing notifications and reschedule
    await _notificationService.cancelNotificationForHabit(habit);
    if (habit.startTime != null) {
      await _notificationService.scheduleWeeklyHabitNotifications(habit);
    }
    
    _loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    if (!_isInitialized) {
      await _initBox();
    }
    
    if (_habitsBox == null) {
      throw Exception('Habits box not initialized');
    }

    final habit = _habitsBox!.get(id);
    if (habit != null) {
      // Cancel notifications for the habit
      await _notificationService.cancelNotificationForHabit(habit);
      await _habitsBox!.delete(id);
    }
    
    _loadHabits();
  }

  Future<void> toggleHabitForDay(String id, String day) async {
    if (!_isInitialized) {
      await _initBox();
    }
    
    if (_habitsBox == null) {
      throw Exception('Habits box not initialized');
    }

    final habit = _habitsBox!.get(id);
    if (habit != null) {
      bool previousState = false;
      
      switch (day.toLowerCase()) {
        case 'monday':
          previousState = habit.monday;
          habit.monday = !habit.monday;
          break;
        case 'tuesday':
          previousState = habit.tuesday;
          habit.tuesday = !habit.tuesday;
          break;
        case 'wednesday':
          previousState = habit.wednesday;
          habit.wednesday = !habit.wednesday;
          break;
        case 'thursday':
          previousState = habit.thursday;
          habit.thursday = !habit.thursday;
          break;
        case 'friday':
          previousState = habit.friday;
          habit.friday = !habit.friday;
          break;
        case 'saturday':
          previousState = habit.saturday;
          habit.saturday = !habit.saturday;
          break;
        case 'sunday':
          previousState = habit.sunday;
          habit.sunday = !habit.sunday;
          break;
      }
      
      // Update streak logic
      _updateStreaks(habit);
      
      await _habitsBox!.put(id, habit);
      
      // Update the in-memory list to immediately reflect changes
      final index = _habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _habits[index] = habit;
        notifyListeners(); // Notify UI to rebuild immediately
      }
      
      // Cancel and reschedule notifications if the day pattern changed
      if (habit.startTime != null) {
        // If the habit was toggled off for the day, cancel that day's notification
        // If it was toggled on, schedule a notification if time hasn't passed
        await _notificationService.cancelNotificationForHabit(habit);
        await _notificationService.scheduleWeeklyHabitNotifications(habit);
      }
      
      // No need to _loadHabits() since we already updated _habits and notified listeners
    }
  }
  
  void _updateStreaks(Habit habit) {
    // Simple streak calculation - this should be enhanced for real usage
    int currentStreak = 0;
    
    // Check if today's habit is marked
    final now = DateTime.now();
    final today = now.weekday;
    
    bool todayCompleted = false;
    switch (today) {
      case DateTime.monday:
        todayCompleted = habit.monday;
        break;
      case DateTime.tuesday:
        todayCompleted = habit.tuesday;
        break;
      case DateTime.wednesday:
        todayCompleted = habit.wednesday;
        break;
      case DateTime.thursday:
        todayCompleted = habit.thursday;
        break;
      case DateTime.friday:
        todayCompleted = habit.friday;
        break;
      case DateTime.saturday:
        todayCompleted = habit.saturday;
        break;
      case DateTime.sunday:
        todayCompleted = habit.sunday;
        break;
    }
    
    if (todayCompleted) {
      currentStreak = habit.currentStreak + 1;
    } else {
      currentStreak = 0;
    }
    
    habit.currentStreak = currentStreak;
    
    if (currentStreak > habit.longestStreak) {
      habit.longestStreak = currentStreak;
    }
  }
}