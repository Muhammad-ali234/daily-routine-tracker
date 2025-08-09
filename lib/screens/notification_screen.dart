import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final now = DateTime.now();
    final habitsBox = await Hive.openBox<Habit>('habits');
    final habits = habitsBox.values.toList();
    
    final notifications = <NotificationItem>[];
    
    // Create notifications for habits starting today
    for (final habit in habits) {
      if (habit.startTime != null) {
        final startDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          habit.startTime!.hour,
          habit.startTime!.minute,
        );
        
        // Check if this habit is scheduled for today
        bool scheduledForToday = false;
        switch (now.weekday) {
          case DateTime.monday:
            scheduledForToday = habit.monday;
            break;
          case DateTime.tuesday:
            scheduledForToday = habit.tuesday;
            break;
          case DateTime.wednesday:
            scheduledForToday = habit.wednesday;
            break;
          case DateTime.thursday:
            scheduledForToday = habit.thursday;
            break;
          case DateTime.friday:
            scheduledForToday = habit.friday;
            break;
          case DateTime.saturday:
            scheduledForToday = habit.saturday;
            break;
          case DateTime.sunday:
            scheduledForToday = habit.sunday;
            break;
        }
        
        if (scheduledForToday) {
          notifications.add(
            NotificationItem(
              title: 'Habit Starting',
              message: '${habit.name} starts at ${habit.startTime!.format(context)}',
              time: startDateTime,
              type: NotificationType.habitStart,
              habitId: habit.id,
            ),
          );
          
          // Add end time notification if available
          if (habit.endTime != null) {
            final endDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              habit.endTime!.hour,
              habit.endTime!.minute,
            );
            
            notifications.add(
              NotificationItem(
                title: 'Habit Ending',
                message: '${habit.name} ends at ${habit.endTime!.format(context)}',
                time: endDateTime,
                type: NotificationType.habitEnd,
                habitId: habit.id,
              ),
            );
          }
        }
      }
    }
    
    // Sort by time
    notifications.sort((a, b) => a.time.compareTo(b.time));
    
    setState(() {
      _notifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text('No notifications for today'),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final isPast = notification.time.isBefore(DateTime.now());
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getNotificationColor(notification.type),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat.jm().format(notification.time),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPast ? Colors.grey : Colors.black,
                          ),
                        ),
                        Text(
                          isPast ? 'Past' : 'Upcoming',
                          style: TextStyle(
                            fontSize: 12,
                            color: isPast ? Colors.grey : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.habitStart:
        return Colors.green;
      case NotificationType.habitEnd:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.habitStart:
        return Icons.play_arrow;
      case NotificationType.habitEnd:
        return Icons.stop;
      default:
        return Icons.notifications;
    }
  }
}

enum NotificationType {
  habitStart,
  habitEnd,
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final String habitId;
  
  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.habitId,
  });
} 