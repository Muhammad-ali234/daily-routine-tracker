import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../models/task.dart';
import '../models/habit.dart';
import '../models/project.dart';

class DataService {
  // Export all data to a JSON file
  static Future<bool> exportData(BuildContext context) async {
    try {
      final data = await _getAllData();
      final jsonData = jsonEncode(data);

      // For Windows, use file_picker to save the file
      if (!kIsWeb && Platform.isWindows) {
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Export File',
          fileName:
              'daily_routine_tracker_export_${DateTime.now().millisecondsSinceEpoch}.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputPath == null) {
          return false; // User cancelled the save dialog
        }

        final file = File(outputPath);
        await file.writeAsString(jsonData);
        return true;
      } else {
        // For other platforms, use the Share functionality
        final directory = await getTemporaryDirectory();
        final fileName =
            'daily_routine_tracker_export_${DateTime.now().millisecondsSinceEpoch}.json';
        final file = File('${directory.path}/$fileName');

        // Write data to the file
        await file.writeAsString(jsonData);

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Daily Routine Tracker Data Export',
        );

        return true;
      }
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return false;
    }
  }

  // Import data from a JSON file
  static Future<bool> importData(BuildContext context) async {
    try {
      // Show file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();

      // Parse the JSON data
      final data = jsonDecode(jsonString);

      // First validate the data structure
      if (!_validateImportData(data)) {
        return false;
      }

      // Import the data
      await _importAllData(data);

      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  // Clear all data
  static Future<bool> clearAllData() async {
    try {
      // Clear all Hive boxes
      await Hive.box<Task>('tasks').clear();
      await Hive.box<Habit>('habits').clear();
      await Hive.box<Project>('projects').clear();

      return true;
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return false;
    }
  }

  // Gather all data from Hive boxes
  static Future<Map<String, dynamic>> _getAllData() async {
    final tasksBox = Hive.box<Task>('tasks');
    final habitsBox = Hive.box<Habit>('habits');
    final projectsBox = Hive.box<Project>('projects');

    // Convert Hive objects to Maps
    final tasks = tasksBox.values.map((task) => _taskToMap(task)).toList();
    final habits = habitsBox.values.map((habit) => _habitToMap(habit)).toList();
    final projects =
        projectsBox.values.map((project) => _projectToMap(project)).toList();

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'tasks': tasks,
      'habits': habits,
      'projects': projects,
    };
  }

  // Validate import data structure
  static bool _validateImportData(Map<String, dynamic> data) {
    return data.containsKey('tasks') &&
        data.containsKey('habits') &&
        data.containsKey('projects') &&
        data.containsKey('version');
  }

  // Import all data into Hive boxes
  static Future<void> _importAllData(Map<String, dynamic> data) async {
    final tasksBox = Hive.box<Task>('tasks');
    final habitsBox = Hive.box<Habit>('habits');
    final projectsBox = Hive.box<Project>('projects');

    // Clear existing data
    await tasksBox.clear();
    await habitsBox.clear();
    await projectsBox.clear();

    // Import tasks
    final tasksList = List<Map<String, dynamic>>.from(data['tasks']);
    for (var taskMap in tasksList) {
      final task = _mapToTask(taskMap);
      await tasksBox.put(task.id, task);
    }

    // Import habits
    final habitsList = List<Map<String, dynamic>>.from(data['habits']);
    for (var habitMap in habitsList) {
      final habit = _mapToHabit(habitMap);
      await habitsBox.put(habit.id, habit);
    }

    // Import projects
    final projectsList = List<Map<String, dynamic>>.from(data['projects']);
    for (var projectMap in projectsList) {
      final project = _mapToProject(projectMap);
      await projectsBox.put(project.id, project);
    }
  }

  // Convert Task object to Map
  static Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'name': task.name,
      'status': task.status.index,
      'completed': task.completed,
      'dueDate': task.dueDate?.toIso8601String(),
      'priority': task.priority.index,
      'timeBlock': task.timeBlock.index,
      'projectId': task.projectId,
      'energyRequired': task.energyRequired.index,
      'timeEstimate': task.timeEstimate,
      'createdAt': task.createdAt.toIso8601String(),
      'startTimeMinutes': task.startTimeMinutes,
      'endTimeMinutes': task.endTimeMinutes,
    };
  }

  // Convert Habit object to Map
  static Map<String, dynamic> _habitToMap(Habit habit) {
    return {
      'id': habit.id,
      'name': habit.name,
      'category': habit.category.index,
      'monday': habit.monday,
      'tuesday': habit.tuesday,
      'wednesday': habit.wednesday,
      'thursday': habit.thursday,
      'friday': habit.friday,
      'saturday': habit.saturday,
      'sunday': habit.sunday,
      'currentStreak': habit.currentStreak,
      'longestStreak': habit.longestStreak,
      'createdAt': habit.createdAt.toIso8601String(),
      'startTimeMinutes': habit.startTimeMinutes,
      'endTimeMinutes': habit.endTimeMinutes,
    };
  }

  // Convert Project object to Map
  static Map<String, dynamic> _projectToMap(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'status': project.status.index,
      'category': project.category.index,
      'deadline': project.deadline?.toIso8601String(),
      'taskIds': project.taskIds,
      'createdAt': project.createdAt.toIso8601String(),
    };
  }

  // Convert Map to Task object
  static Task _mapToTask(Map<String, dynamic> map) {
    TimeOfDay? startTime;
    if (map['startTimeMinutes'] != null) {
      final hour = map['startTimeMinutes'] ~/ 60;
      final minute = map['startTimeMinutes'] % 60;
      startTime = TimeOfDay(hour: hour, minute: minute);
    }

    TimeOfDay? endTime;
    if (map['endTimeMinutes'] != null) {
      final hour = map['endTimeMinutes'] ~/ 60;
      final minute = map['endTimeMinutes'] % 60;
      endTime = TimeOfDay(hour: hour, minute: minute);
    }

    return Task(
      id: map['id'],
      name: map['name'],
      status: TaskStatus.values[map['status']],
      completed: map['completed'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      priority: TaskPriority.values[map['priority']],
      timeBlock: TimeBlock.values[map['timeBlock']],
      projectId: map['projectId'],
      energyRequired: EnergyLevel.values[map['energyRequired'] ?? 1],
      timeEstimate: map['timeEstimate'] ?? 30,
      createdAt: DateTime.parse(map['createdAt']),
      startTime: startTime,
      endTime: endTime,
    );
  }

  // Convert Map to Habit object
  static Habit _mapToHabit(Map<String, dynamic> map) {
    TimeOfDay? startTime;
    if (map['startTimeMinutes'] != null) {
      final hour = map['startTimeMinutes'] ~/ 60;
      final minute = map['startTimeMinutes'] % 60;
      startTime = TimeOfDay(hour: hour, minute: minute);
    }

    TimeOfDay? endTime;
    if (map['endTimeMinutes'] != null) {
      final hour = map['endTimeMinutes'] ~/ 60;
      final minute = map['endTimeMinutes'] % 60;
      endTime = TimeOfDay(hour: hour, minute: minute);
    }

    return Habit(
      id: map['id'],
      name: map['name'],
      category: HabitCategory.values[map['category']],
      monday: map['monday'],
      tuesday: map['tuesday'],
      wednesday: map['wednesday'],
      thursday: map['thursday'],
      friday: map['friday'],
      saturday: map['saturday'],
      sunday: map['sunday'],
      currentStreak: map['currentStreak'],
      longestStreak: map['longestStreak'],
      createdAt: DateTime.parse(map['createdAt']),
      startTime: startTime,
      endTime: endTime,
    );
  }

  // Convert Map to Project object
  static Project _mapToProject(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      status: ProjectStatus.values[map['status']],
      category: ProjectCategory.values[map['category']],
      deadline:
          map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      taskIds: List<String>.from(map['taskIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
