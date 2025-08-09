import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;

import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/task_list.dart';
import '../widgets/habit_tracker.dart';
import '../theme/app_theme.dart';
import '../services/notification_manager.dart';
import 'task_screen.dart';
import 'project_screen.dart';
import 'habit_screen.dart';
import 'analytics_screen.dart';
import 'setting_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  static final GlobalKey<_HomeScreenState> globalKey = GlobalKey<_HomeScreenState>();
  const HomeScreen({Key? key}) : super(key: key);

  static _HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isDesktop = false;

  void navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    super.initState();
    // Update notification count every time the screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationManager>(context, listen: false).updateNotificationCount();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDesktop = MediaQuery.of(context).size.width >= 1200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.insights_rounded, size: 28),
            SizedBox(width: 12),
            Text(
              'Daily Routine Tracker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          Consumer<NotificationManager>(
            builder: (context, notificationManager, child) {
              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                showBadge: notificationManager.notificationCount > 0,
                badgeContent: Text(
                  notificationManager.notificationCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/notifications');
                  },
                  tooltip: 'Notifications',
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Navigation Rail
        NavigationRail(
          extended: true,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedIconTheme: const IconThemeData(color: Colors.white),
          unselectedIconTheme: const IconThemeData(color: Colors.black),
          destinations: [
            const NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
              label: Text('Tasks'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: Text('Projects'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.repeat_outlined),
              selectedIcon: Icon(Icons.repeat),
              label: Text('Habits'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: Text('Analytics'),
            ),
            NavigationRailDestination(
              icon: Consumer<NotificationManager>(
                builder: (context, notificationManager, child) {
                  return badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -12, end: -12),
                    showBadge: notificationManager.notificationCount > 0,
                    badgeContent: Text(
                      notificationManager.notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  );
                },
              ),
              selectedIcon: Consumer<NotificationManager>(
                builder: (context, notificationManager, child) {
                  return badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -12, end: -12),
                    showBadge: notificationManager.notificationCount > 0,
                    badgeContent: Text(
                      notificationManager.notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: const Text('Notifications'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        // Vertical Divider
        const VerticalDivider(thickness: 1, width: 1),
        // Main Content
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardTab(),
              const TaskScreen(),
              const ProjectScreen(),
              const HabitScreen(),
              const AnalyticsScreen(),
              const NotificationScreen(),
              const SettingsScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildDashboardTab(),
              const TaskScreen(),
              const ProjectScreen(),
              const HabitScreen(),
              const AnalyticsScreen(),
              const NotificationScreen(),
              const SettingsScreen(),
            ],
          ),
        ),
        NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
            const NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
            const NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
            label: 'Projects',
          ),
            const NavigationDestination(
              icon: Icon(Icons.repeat_outlined),
              selectedIcon: Icon(Icons.repeat),
              label: 'Habits',
            ),
            const NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Consumer<NotificationManager>(
                builder: (context, notificationManager, child) {
                  return badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -8, end: -8),
                    showBadge: notificationManager.notificationCount > 0,
                    badgeContent: Text(
                      notificationManager.notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  );
                },
              ),
              selectedIcon: Consumer<NotificationManager>(
                builder: (context, notificationManager, child) {
                  return badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -8, end: -8),
                    showBadge: notificationManager.notificationCount > 0,
                    badgeContent: Text(
                      notificationManager.notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: 'Notifications',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width >= 1600;
    
    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: _isDesktop ? 48.0 : 24.0,
          vertical: 24.0,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header with date and welcome
            Container(
              margin: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
          Text(
            dateFormat.format(now),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                 
                ],
              ),
            ),
            
            // Dashboard summary card
          const DashboardSummary(),
            const SizedBox(height: 32.0),
            
            // Main content in two or three columns based on screen width
            isWideScreen ? _buildThreeColumnLayout() : _buildTwoColumnLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - 60% width
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: "Today's Schedule",
                icon: Icons.schedule,
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              _buildTasksSection(),
              const SizedBox(height: 32.0),
              
              _buildSectionHeader(
                title: "Current Goals",
                icon: Icons.flag,
                onViewAll: () {
                  // TODO: Navigate to goals screen
                },
              ),
              const SizedBox(height: 16.0),
              _buildGoalsSection(),
            ],
          ),
        ),
        
        const SizedBox(width: 24.0),
        
        // Right column - 40% width
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: "Today's Habits",
                icon: Icons.repeat,
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HabitScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              const HabitTracker(),
              const SizedBox(height: 32.0),
              
              _buildSectionHeader(
                title: "Recent Achievements",
                icon: Icons.emoji_events,
                onViewAll: () {
                  // TODO: Navigate to achievements screen
                },
              ),
              const SizedBox(height: 16.0),
              _buildAchievementsSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThreeColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - 40% width
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: "Today's Schedule",
                icon: Icons.schedule,
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              _buildTasksSection(),
            ],
          ),
        ),
        
        const SizedBox(width: 24.0),
        
        // Middle column - 30% width
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: "Today's Habits",
                icon: Icons.repeat,
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HabitScreen()),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              const HabitTracker(),
              const SizedBox(height: 32.0),
              
              _buildSectionHeader(
                title: "Current Goals",
                icon: Icons.flag,
                onViewAll: () {
                  // TODO: Navigate to goals screen
                },
              ),
              const SizedBox(height: 16.0),
              _buildGoalsSection(),
            ],
          ),
        ),
        
        const SizedBox(width: 24.0),
        
        // Right column - 30% width
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: "Recent Achievements",
                icon: Icons.emoji_events,
                onViewAll: () {
                  // TODO: Navigate to achievements screen
                },
              ),
              const SizedBox(height: 16.0),
              _buildAchievementsSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required VoidCallback onViewAll,
  }) {
    int? tabIndex;
    if (title.contains('Task') || title.contains('Schedule')) tabIndex = 1;
    if (title.contains('Habit')) tabIndex = 3;
    if (title.contains('Project')) tabIndex = 2;
    if (title.contains('Analytics')) tabIndex = 4;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8.0),
          Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: tabIndex != null
              ? () => HomeScreen.globalKey.currentState?.navigateToTab(tabIndex!)
              : onViewAll,
          icon: const Icon(Icons.chevron_right),
          label: const Text('View All'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final todayTasks = taskProvider.getTodayTasks();
            if (todayTasks.isEmpty) {
              return _buildEmptyState(
                icon: Icons.check_circle_outline,
                message: 'No tasks scheduled for today.',
                buttonLabel: 'Add Task',
                onPressed: () {
                  // TODO: Navigate to add task screen
                },
              );
            }
            return TaskList(
              key: const Key('today_tasks'),
              tasks: todayTasks.take(3).toList(),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildGoalsSection() {
    // Show all active projects as goals
    return Consumer2<ProjectProvider, TaskProvider>(
      builder: (context, projectProvider, taskProvider, child) {
        final activeProjects = projectProvider.activeProjects;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: activeProjects.map((project) {
                final projectTasks = taskProvider.getTasksByProjectId(project.id);
                final completed = projectTasks.isNotEmpty && projectTasks.every((t) => t.completed);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: CheckboxListTile(
                    title: Text(
                      project.name,
                      style: TextStyle(
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    value: completed,
                    onChanged: (value) {
                      // Optionally, mark all tasks as complete/incomplete
                      for (final task in projectTasks) {
                        if (task.completed != (value ?? false)) {
                          taskProvider.toggleTaskCompletion(task.id);
                        }
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAchievementsSection() {
    // Show 3 most recently completed tasks
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final completedTasks = taskProvider.tasks
            .where((t) => t.completed && t.dueDate != null)
            .toList();
        completedTasks.sort((a, b) => b.dueDate!.compareTo(a.dueDate!));
        final recentAchievements = completedTasks.take(3).toList();
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: recentAchievements.map((task) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Achieved on: ${task.dueDate != null ? DateFormat('yyyy-MM-dd').format(task.dueDate!) : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}