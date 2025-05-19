import 'dart:math';

import 'package:daily_routine_tracker/widgets/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/habit_provider.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TimeRange _selectedTimeRange = TimeRange.week;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom:  MyTabBarWidget(
  controller: _tabController,
  tabNames: const['Tasks', 'Projects', 'Habits'],

),
// add line 

        actions: [
          PopupMenuButton<TimeRange>(
            initialValue: _selectedTimeRange,
            onSelected: (TimeRange value) {
              setState(() {
                _selectedTimeRange = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<TimeRange>>[
              const PopupMenuItem<TimeRange>(
                value: TimeRange.week,
                child: Text('Last 7 Days'),
              ),
              const PopupMenuItem<TimeRange>(
                value: TimeRange.month,
                child: Text('Last 30 Days'),
              ),
              const PopupMenuItem<TimeRange>(
                value: TimeRange.year,
                child: Text('Last 365 Days'),
              ),
            ],
          ),
        ],
      ),
      // drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksAnalytics(),
          _buildProjectsAnalytics(),
          _buildHabitsAnalytics(),
        ],
      ),
    );
  }

  Widget _buildTasksAnalytics() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;
        final completedTasks = tasks.where((t) => t.completed).length;
        final totalTasks = tasks.length;
        final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).toInt() : 0;

        // Get tasks within the selected time range
        final DateTime now = DateTime.now();
        final DateTime startDate = _getStartDate(now);
        final tasksInRange = tasks.where((task) =>
          task.createdAt.isAfter(startDate) && task.createdAt.isBefore(now)
        ).toList();

        // Group tasks by priority
        final tasksByPriority = _groupTasksByPriority(tasksInRange);
        
        // Group tasks by time block
        final tasksByTimeBlock = _groupTasksByTimeBlock(tasksInRange);

        // Calculate daily completion trend
        final completionTrend = _calculateDailyCompletionTrend(tasksInRange);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(
                completedTasks: completedTasks,
                totalTasks: totalTasks,
                completionRate: completionRate,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Task Completion Trend'),
              SizedBox(
                height: 200,
                child: LineChart(
                  _buildCompletionTrendData(completionTrend),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tasks by Priority'),
              SizedBox(
                height: 200,
                child: PieChart(
                  _buildPriorityChartData(tasksByPriority),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tasks by Time Block'),
              SizedBox(
                height: 200,
                child: BarChart(
                  _buildTimeBlockChartData(tasksByTimeBlock),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectsAnalytics() {
    return Consumer2<ProjectProvider, TaskProvider>(
      builder: (context, projectProvider, taskProvider, child) {
        final projects = projectProvider.projects;
        final completedProjects = projects.where((p) => p.status == ProjectStatus.completed).length;
        final activeProjects = projects.where((p) => p.status == ProjectStatus.active).length;

        // Calculate project completion rates
        final projectCompletionRates = projects.map((project) {
          final projectTasks = taskProvider.getTasksByProjectId(project.id);
          final completedTasks = projectTasks.where((t) => t.completed).length;
          return MapEntry(
            project,
            projectTasks.isNotEmpty ? completedTasks / projectTasks.length : 0.0,
          );
        }).toList();

        // Sort projects by completion rate
        projectCompletionRates.sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Active Projects',
                      activeProjects.toString(),
                      Icons.folder,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Completed Projects',
                      completedProjects.toString(),
                      Icons.task_alt,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Project Completion Rates'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projectCompletionRates.length,
                itemBuilder: (context, index) {
                  final project = projectCompletionRates[index].key;
                  final completionRate = projectCompletionRates[index].value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: completionRate,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    completionRate == 1.0 ? Colors.green : AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${(completionRate * 100).toInt()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitsAnalytics() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habits = habitProvider.habits;
        final activeHabits = habits.length;
        final totalStreak = habits.fold<int>(0, (sum, habit) => sum + habit.currentStreak);
        final averageStreak = activeHabits > 0 ? (totalStreak / activeHabits).round() : 0;

        // Group habits by category
        final habitsByCategory = _groupHabitsByCategory(habits);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Active Habits',
                      activeHabits.toString(),
                      Icons.repeat,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Avg. Streak',
                      averageStreak.toString(),
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Habits by Category'),
              SizedBox(
                height: 200,
                child: PieChart(
                  _buildHabitCategoryChartData(habitsByCategory),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Top Streaks'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(habit.name),
                      subtitle: Text(habit.category.toString().split('.').last),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards({
    required int completedTasks,
    required int totalTasks,
    required int completionRate,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Completed Tasks',
            completedTasks.toString(),
            Icons.task_alt,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Tasks',
            totalTasks.toString(),
            Icons.assignment,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Completion Rate',
            '$completionRate%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  DateTime _getStartDate(DateTime now) {
    switch (_selectedTimeRange) {
      case TimeRange.week:
        return now.subtract(const Duration(days: 7));
      case TimeRange.month:
        return now.subtract(const Duration(days: 30));
      case TimeRange.year:
        return now.subtract(const Duration(days: 365));
    }
  }

  Map<TaskPriority, int> _groupTasksByPriority(List<Task> tasks) {
    final Map<TaskPriority, int> result = {};
    for (final task in tasks) {
      result[task.priority] = (result[task.priority] ?? 0) + 1;
    }
    return result;
  }

  Map<TimeBlock, int> _groupTasksByTimeBlock(List<Task> tasks) {
    final Map<TimeBlock, int> result = {};
    for (final task in tasks) {
      result[task.timeBlock] = (result[task.timeBlock] ?? 0) + 1;
    }
    return result;
  }

  Map<HabitCategory, int> _groupHabitsByCategory(List<Habit> habits) {
    final Map<HabitCategory, int> result = {};
    for (final habit in habits) {
      result[habit.category] = (result[habit.category] ?? 0) + 1;
    }
    return result;
  }

  List<MapEntry<DateTime, int>> _calculateDailyCompletionTrend(List<Task> tasks) {
    final Map<DateTime, int> completionsByDay = {};
    final startDate = _getStartDate(DateTime.now());

    // Initialize all dates in range with 0
    for (var i = 0; i <= startDate.difference(DateTime.now()).abs().inDays; i++) {
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + i,
      );
      completionsByDay[date] = 0;
    }

    // Count completed tasks by day
    for (final task in tasks.where((t) => t.completed)) {
      final date = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      completionsByDay[date] = (completionsByDay[date] ?? 0) + 1;
    }

    return completionsByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  LineChartData _buildCompletionTrendData(List<MapEntry<DateTime, int>> trend) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < trend.length) {
                return Text(
                  DateFormat('MM/dd').format(trend[value.toInt()].key),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: trend.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
          }).toList(),
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  PieChartData _buildPriorityChartData(Map<TaskPriority, int> tasksByPriority) {
    final List<PieChartSectionData> sections = [];
    final colors = [Colors.red, Colors.orange, Colors.green];
    
    TaskPriority.values.asMap().forEach((index, priority) {
      final count = tasksByPriority[priority] ?? 0;
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[index],
            value: count.toDouble(),
            title: '${priority.toString().split('.').last}\n$count',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });

    return PieChartData(
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 0,
    );
  }

  BarChartData _buildTimeBlockChartData(Map<TimeBlock, int> tasksByTimeBlock) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: tasksByTimeBlock.values.fold(0, max) + 1,
      barTouchData: const BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < TimeBlock.values.length) {
                return RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    TimeBlock.values[value.toInt()].toString().split('.').last,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
            reservedSize: 42,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: TimeBlock.values.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: tasksByTimeBlock[entry.value]?.toDouble() ?? 0,
              color: AppTheme.primaryColor,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  PieChartData _buildHabitCategoryChartData(Map<HabitCategory, int> habitsByCategory) {
    final List<PieChartSectionData> sections = [];
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    
    HabitCategory.values.asMap().forEach((index, category) {
      final count = habitsByCategory[category] ?? 0;
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[index],
            value: count.toDouble(),
            title: '${category.toString().split('.').last}\n$count',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });

    return PieChartData(
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 0,
    );
  }
}

enum TimeRange {
  week,
  month,
  year,
}
