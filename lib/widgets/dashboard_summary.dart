import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/habit_provider.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer3<TaskProvider, ProjectProvider, HabitProvider>(
      builder: (context, taskProvider, projectProvider, habitProvider, child) {
        // Tasks
        final todayTasks = taskProvider.getTodayTasks();
        final completedTodayTasks = todayTasks.where((t) => t.completed).length;
        final totalTodayTasks = todayTasks.length;
        // Projects
        final activeProjects = projectProvider.activeProjects.length;
        // Habits
        final habits = habitProvider.habits;
        final today = DateTime.now().weekday;
        int completedHabits = 0;
        for (final habit in habits) {
          switch (today) {
            case DateTime.monday:
              if (habit.monday) completedHabits++;
              break;
            case DateTime.tuesday:
              if (habit.tuesday) completedHabits++;
              break;
            case DateTime.wednesday:
              if (habit.wednesday) completedHabits++;
              break;
            case DateTime.thursday:
              if (habit.thursday) completedHabits++;
              break;
            case DateTime.friday:
              if (habit.friday) completedHabits++;
              break;
            case DateTime.saturday:
              if (habit.saturday) completedHabits++;
              break;
            case DateTime.sunday:
              if (habit.sunday) completedHabits++;
              break;
          }
        }
        final totalHabits = habits.length;
        // Streaks
        final highestStreak = habits.isNotEmpty ? habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b) : 0;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dashboard_rounded,
                          size: 28,
                          color: colorScheme.onPrimary,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Dashboard Overview',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: colorScheme.onPrimary),
                      onPressed: () {
                        // TODO: Implement refresh functionality
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Divider(color: colorScheme.onPrimary.withOpacity(0.3), thickness: 1),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context: context,
                      icon: Icons.check_circle_rounded,
                      iconColor: Colors.greenAccent,
                      label: 'Tasks',
                      value: '$completedTodayTasks/$totalTodayTasks',
                    ),
                    _buildStatItem(
                      context: context,
                      icon: Icons.work_rounded,
                      iconColor: Colors.amberAccent,
                      label: 'Projects',
                      value: '$activeProjects',
                    ),
                    _buildStatItem(
                      context: context,
                      icon: Icons.repeat_rounded,
                      iconColor: Colors.lightBlueAccent,
                      label: 'Habits',
                      value: '$completedHabits/$totalHabits',
                    ),
                    _buildStatItem(
                      context: context,
                      icon: Icons.emoji_events_rounded,
                      iconColor: Colors.orangeAccent,
                      label: 'Streaks',
                      value: '${highestStreak} days',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.onPrimary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 32,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
} 