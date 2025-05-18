import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  static const String _boxName = 'tasks';
  late Box<Task> _box;
  List<Task> _tasks = [];

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
    _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
    _loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
    _loadTasks();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _box.get(taskId);
    if (task != null) {
      task.completed = !task.completed;
      await _box.put(taskId, task);
      _loadTasks();
    }
  }

  Future<void> deleteAllTasks() async {
    await _box.clear();
    _loadTasks();
  }
}
