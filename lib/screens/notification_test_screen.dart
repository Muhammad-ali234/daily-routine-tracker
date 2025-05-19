import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/notification_service.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Test Notifications",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await notificationService.showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Test notification sent!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Send Test Notification Now"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final inFiveSeconds = now.add(const Duration(seconds: 5));
                
                // Create a temporary task for the notification
                final task = Task(
                  id: "test-task",
                  name: "Test Scheduled Task",
                  timeBlock: TimeBlock.morning,
                  createdAt: now,
                  dueDate: DateTime(
                    inFiveSeconds.year,
                    inFiveSeconds.month,
                    inFiveSeconds.day,
                  ),
                  startTime: TimeOfDay(
                    hour: inFiveSeconds.hour,
                    minute: inFiveSeconds.minute,
                  ),
                );
                
                await notificationService.scheduleTaskNotification(task);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Notification scheduled for 5 seconds from now!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Schedule Notification (5 seconds)"),
            ),
            const SizedBox(height: 40),
            const Text(
              "Manage Notifications",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                
                // Reschedule all task notifications
                for (final task in taskProvider.tasks) {
                  if (!task.completed && task.dueDate != null && task.startTime != null) {
                    await notificationService.scheduleTaskNotification(task);
                  }
                }
                
                // Reschedule all habit notifications
                for (final habit in habitProvider.habits) {
                  if (habit.startTime != null) {
                    await notificationService.scheduleWeeklyHabitNotifications(habit);
                  }
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All notifications have been rescheduled!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Reschedule All Notifications"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await notificationService.cancelAllNotifications();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All notifications have been cancelled!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Cancel All Notifications"),
            ),
          ],
        ),
      ),
    );
  }
} 