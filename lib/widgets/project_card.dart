import 'package:flutter/material.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final int taskCount;
  final int completedTaskCount;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.taskCount,
    required this.completedTaskCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = taskCount > 0 ? completedTaskCount / taskCount : 0.0;
    final progressPercentage = (progress * 100).toInt();
    
    Color categoryColor;
    switch (project.category) {
      case ProjectCategory.aiLearning:
        categoryColor = AppTheme.productivityColor;
        break;
      case ProjectCategory.portfolio:
        categoryColor = AppTheme.careerColor;
        break;
      case ProjectCategory.freelance:
        categoryColor = AppTheme.morningColor;
        break;
      case ProjectCategory.career:
        categoryColor = AppTheme.eveningColor;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(right: 16.0),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    project.category.toString().split('.').last,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (project.deadline != null)
                  Text(
                    'Due ${_formatDeadline(project.deadline!)}',
                    style: TextStyle(
                      color: _isDeadlineNear(project.deadline!) 
                          ? Colors.red 
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16.0),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$completedTaskCount of $taskCount tasks completed ($progressPercentage%)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 0) {
      return 'Overdue';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    }
  }

  bool _isDeadlineNear(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays <= 3 && difference.inDays >= 0;
  }
}
