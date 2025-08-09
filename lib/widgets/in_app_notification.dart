import 'package:flutter/material.dart';
import 'dart:async';

import '../models/habit.dart';

class InAppNotification extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onTap;
  final Duration duration;

  const InAppNotification({
    Key? key,
    required this.title,
    required this.message,
    this.onTap,
    this.duration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<InAppNotification> createState() => _InAppNotificationState();
}

class _InAppNotificationState extends State<InAppNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _timer = Timer(widget.duration, () {
      _controller.reverse().then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                _controller.reverse().then((_) {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                });
              },
              child: Card(
                elevation: 4,
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(widget.message),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.reverse().then((_) {
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class to show in-app notifications
class InAppNotificationService {
  static void showHabitStartNotification(
    BuildContext context,
    Habit habit, {
    VoidCallback? onTap,
  }) {
    _showNotification(
      context,
      title: 'Habit Starting Now',
      message: '${habit.name} is scheduled to start now',
      onTap: onTap,
    );
  }

  static void showHabitEndNotification(
    BuildContext context,
    Habit habit, {
    VoidCallback? onTap,
  }) {
    _showNotification(
      context,
      title: 'Habit Time Ended',
      message: '${habit.name} is scheduled to end now',
      onTap: onTap,
    );
  }

  static void _showNotification(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return InAppNotification(
            title: title,
            message: message,
            onTap: onTap,
          );
        },
      ),
    );
  }
} 