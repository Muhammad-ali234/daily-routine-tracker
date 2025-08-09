import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'app.dart';
import 'providers/task_provider.dart';
import 'providers/project_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'models/user.dart';
import 'models/task.dart';
import 'models/project.dart';
import 'models/habit.dart';
import 'screens/home_screen.dart';
import 'utils/icon_generator.dart';
import 'services/notification_service.dart';
import 'services/notification_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // For development/testing: Clear existing boxes to avoid type adapter conflicts
  // This is useful during development when the model schema changes frequently
  // Comment out or remove this in production
  // await Hive.deleteBoxFromDisk('users');
  // await Hive.deleteBoxFromDisk('tasks');
  // await Hive.deleteBoxFromDisk('projects');
  // await Hive.deleteBoxFromDisk('habits');

  // Register Hive adapters for all models
  // Make sure to register them in the correct order with proper typeIds

  // Register enum adapters first (these are auto-generated)
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TimeBlockAdapter());
  Hive.registerAdapter(EnergyLevelAdapter());
  Hive.registerAdapter(HabitCategoryAdapter());
  Hive.registerAdapter(ProjectStatusAdapter());
  Hive.registerAdapter(ProjectCategoryAdapter());

  // Then register model adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(HabitAdapter());

  // Open boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Project>('projects');
  await Hive.openBox<Habit>('habits');

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  // // Generate the app icon
  // await IconGenerator.generateAppIcon();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationManager()),
      ],
      child: const ProductivityApp(),
    ),
  );
}
