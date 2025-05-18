import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  
  const TaskList({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(context, task);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = AppTheme.highPriorityColor;
        break;
      case TaskPriority.medium:
        priorityColor = AppTheme.mediumPriorityColor;
        break;
      case TaskPriority.low:
        priorityColor = AppTheme.lowPriorityColor;
        break;
    }
    
    Color timeBlockColor;
    switch (task.timeBlock) {
      case TimeBlock.morning:
        timeBlockColor = AppTheme.morningColor;
        break;
      case TimeBlock.peakProductivity:
        timeBlockColor = AppTheme.productivityColor;
        break;
      case TimeBlock.career:
        timeBlockColor = AppTheme.careerColor;
        break;
      case TimeBlock.evening:
        timeBlockColor = AppTheme.eveningColor;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          _showTaskDetailsDialog(context, task);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: timeBlockColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            task.priority.toString().split('.').last,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.timeBlock.toString().split('.').last,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (task.dueDate != null)
                          Text(
                            DateFormat('MMM dd').format(task.dueDate!),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              Checkbox(
                value: task.completed,
                onChanged: (value) {
                  Provider.of<TaskProvider>(context, listen: false).toggleTaskCompletion(task.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.dueDate != null) ...[
                const Text('Due Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text(DateFormat('EEEE, MMM dd, yyyy').format(task.dueDate!)),
                const SizedBox(height: 16.0),
              ],
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4.0),
              Text(task.status.toString().split('.').last),
              const SizedBox(height: 16.0),
              const Text('Priority:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4.0),
              Text(task.priority.toString().split('.').last),
              const SizedBox(height: 16.0),
              const Text('Time Block:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4.0),
              Text(task.timeBlock.toString().split('.').last),
              const SizedBox(height: 16.0),
              const Text('Estimated Time:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4.0),
              Text('${task.timeEstimate} minutes'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditTaskDialog(context, task);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                taskProvider.toggleTaskCompletion(task.id);
                Navigator.of(context).pop();
              },
              child: Text(task.completed ? 'Mark Incomplete' : 'Mark Complete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final TextEditingController taskNameController = TextEditingController(text: task.name);
    DateTime? selectedDate = task.dueDate;
    TaskPriority priority = task.priority;
    TimeBlock timeBlock = task.timeBlock;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: taskNameController,
                      decoration: const InputDecoration(
                        labelText: 'Task Name',
                        hintText: 'Enter task name',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Text('Due Date: '),
                        TextButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Text(
                            selectedDate == null
                                ? 'Select Date'
                                : DateFormat('MMM dd, yyyy').format(selectedDate!),
                          ),
                        ),
                        if (selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Priority:'),
                    DropdownButton<TaskPriority>(
                      value: priority,
                      isExpanded: true,
                      onChanged: (TaskPriority? newValue) {
                        if (newValue != null) {
                          setState(() {
                            priority = newValue;
                          });
                        }
                      },
                      items: TaskPriority.values.map((TaskPriority priority) {
                        return DropdownMenuItem<TaskPriority>(
                          value: priority,
                          child: Text(priority.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Time Block:'),
                    DropdownButton<TimeBlock>(
                      value: timeBlock,
                      isExpanded: true,
                      onChanged: (TimeBlock? newValue) {
                        if (newValue != null) {
                          setState(() {
                            timeBlock = newValue;
                          });
                        }
                      },
                      items: TimeBlock.values.map((TimeBlock block) {
                        return DropdownMenuItem<TimeBlock>(
                          value: block,
                          child: Text(block.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, task);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (taskNameController.text.trim().isNotEmpty) {
                      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                      final updatedTask = Task(
                        id: task.id,
                        name: taskNameController.text.trim(),
                        status: task.status,
                        priority: priority,
                        dueDate: selectedDate,
                        timeBlock: timeBlock,
                        energyRequired: task.energyRequired,
                        timeEstimate: task.timeEstimate,
                        projectId: task.projectId,
                        completed: task.completed,
                        createdAt: task.createdAt,
                      );
                      
                      taskProvider.updateTask(updatedTask);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                taskProvider.deleteTask(task.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close edit dialog as well
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}