import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, HabitProvider>(
      builder: (context, taskProvider, habitProvider, child) {
        final totalTasks = taskProvider.tasks.length;
        final completedTasks = taskProvider.tasks.where((task) => task.completed).length;
        
        // Calculate average habit streak
        double avgStreak = 0;
        final habits = habitProvider.habits;
        if (habits.isNotEmpty) {
          avgStreak = habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length;
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Progress',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16.0),
                _buildProgressBar(context, 'Progress', completedTasks, totalTasks),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      context,
                      'Weekly Tasks',
                      '$completedTasks/$totalTasks',
                      Icons.task_alt,
                    ),
                    _buildInfoCard(
                      context,
                      'Habit Streak',
                      '${avgStreak.toStringAsFixed(1)} days',
                      Icons.trending_up,
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

  Widget _buildProgressBar(BuildContext context, String label, int value, int total) {
    final progress = total > 0 ? value / total : 0.0;
    final percentage = (progress * 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleLarge),
            Text('$percentage%', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          minHeight: 10,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}