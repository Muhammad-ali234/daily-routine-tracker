import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class HabitTracker extends StatelessWidget {
  const HabitTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final habits = habitProvider.habits;
        
        if (habits.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.track_changes,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'You have no habits to track yet',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/habits');
                    },
                    child: const Text('Add Habits'),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Column(
          children: habits.map((habit) {
            return _buildHabitCard(context, habit, today);
          }).toList(),
        );
      },
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, String today) {
    bool completed = false;
    
    switch (today) {
      case 'monday':
        completed = habit.monday;
        break;
      case 'tuesday':
        completed = habit.tuesday;
        break;
      case 'wednesday':
        completed = habit.wednesday;
        break;
      case 'thursday':
        completed = habit.thursday;
        break;
      case 'friday':
        completed = habit.friday;
        break;
      case 'saturday':
        completed = habit.saturday;
        break;
      case 'sunday':
        completed = habit.sunday;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getCategoryColor(habit.category),
              child: const Icon(Icons.repeat, color: Colors.white),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Current streak: ${habit.currentStreak} days',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: completed,
              onChanged: (value) {
                Provider.of<HabitProvider>(context, listen: false).toggleHabitForDay(habit.id, today);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.physical:
        return Colors.green;
      case HabitCategory.mental:
        return Colors.blue;
      case HabitCategory.career:
        return Colors.purple;
      case HabitCategory.social:
        return Colors.orange;
    }
  }
}