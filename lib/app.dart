import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/task_screen.dart';
import 'screens/project_screen.dart';
import 'screens/habit_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/notification_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'services/habit_monitor_service.dart';
import 'services/notification_manager.dart';

class ProductivityApp extends StatefulWidget {
  const ProductivityApp({Key? key}) : super(key: key);

  @override
  State<ProductivityApp> createState() => _ProductivityAppState();
}

class _ProductivityAppState extends State<ProductivityApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize habit monitor service after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigatorKey.currentContext != null) {
        HabitMonitorService().init(_navigatorKey.currentContext!);
        
        // Initialize notification count
        NotificationManager().updateNotificationCount();
      }
    });
  }
  
  @override
  void dispose() {
    HabitMonitorService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Consumer2<ThemeProvider, UserProvider>(
        builder: (context, themeProvider, userProvider, child) {
          // Display a loading indicator while UserProvider is initializing
          if (userProvider.isInitializing)  {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing...')
                    ],
                  ),
                ),
              ),
            );
          }

          final primaryColor = themeProvider.primaryColor ?? Colors.blue;
          final themeMode = themeProvider.themeMode ?? ThemeMode.system;

          debugPrint('Theme primary color: $primaryColor');
          debugPrint('User: ${userProvider.user}');

          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Deep Work Planner',
            theme: AppTheme.lightTheme.copyWith(
              primaryColor: primaryColor,
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                secondary: primaryColor,
              ),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              primaryColor: primaryColor,
              colorScheme: ColorScheme.dark(
                primary: primaryColor,
                secondary: primaryColor,
              ),
            ),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/tasks': (context) => const TaskScreen(),
              '/projects': (context) => const ProjectScreen(),
              '/habits': (context) => const HabitScreen(),
              '/analytics': (context) => const AnalyticsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/notifications': (context) => const NotificationScreen(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text('Page not found'),
                ),
              ),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Error building app: $e');
      debugPrint('Stack trace: $stackTrace');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('An error occurred: $e'),
          ),
        ),
      );
    }
  }
}