import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  static const String _boxName = 'tasks';
  late Box<Task> _box;
  List<Task> _tasks = [];
  final NotificationService _notificationService = NotificationService();

  List<Task> get tasks => _tasks;

  TaskProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox<Task>(_boxName);
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _box.values.toList();
    notifyListeners();
  }

  List<Task> getTodayTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == now.year &&
             task.dueDate!.month == now.month &&
             task.dueDate!.day == now.day;
    }).toList();
  }

  List<Task> getHighPriorityTasks() {
    return _tasks.where((task) => 
      task.priority == TaskPriority.high && !task.completed
    ).toList();
  }

  List<Task> getTasksByProjectId(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task);
    
    // Schedule notification for the task
    if (task.dueDate != null && task.startTime != null) {
      await _notificationService.scheduleTaskNotification(task);
    }
    
    _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
    
    // Cancel existing notification and reschedule
    await _notificationService.cancelNotificationForTask(task);
    if (task.dueDate != null && task.startTime != null && !task.completed) {
      await _notificationService.scheduleTaskNotification(task);
    }
    
    _loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    final task = _box.get(taskId);
    if (task != null) {
      // Cancel notification for the task
      await _notificationService.cancelNotificationForTask(task);
      await _box.delete(taskId);
    }
    _loadTasks();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _box.get(taskId);
    if (task != null) {
      task.completed = !task.completed;
      await _box.put(taskId, task);
      
      // If task is completed, cancel the notification
      if (task.completed) {
        await _notificationService.cancelNotificationForTask(task);
      } else {
        // If task is marked incomplete again and has a future date, reschedule
        if (task.dueDate != null && task.startTime != null) {
          DateTime scheduledTime = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
            task.startTime!.hour,
            task.startTime!.minute,
          );
          
          if (scheduledTime.isAfter(DateTime.now())) {
            await _notificationService.scheduleTaskNotification(task);
          }
        }
      }
      
      _loadTasks();
    }
  }

  Future<void> deleteAllTasks() async {
    // Cancel all task notifications
    for (final task in _tasks) {
      await _notificationService.cancelNotificationForTask(task);
    }
    
    await _box.clear();
    _loadTasks();
  }
}
