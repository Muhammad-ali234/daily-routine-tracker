import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../models/project.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/task_list.dart';
import '../theme/app_theme.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedProjectFilter;
  TimeBlock? _selectedTimeBlockFilter;
  TaskSortOption _sortOption = TaskSortOption.dueDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium!.color,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_getAllTasks),
                _buildTaskList(_getTodayTasks),
                _buildTaskList(_getUpcomingTasks),
                _buildTaskList(_getCompletedTasks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildProjectFilter(),
              const SizedBox(width: 16.0),
              _buildTimeBlockFilter(),
              const SizedBox(width: 16.0),
              _buildSortOption(),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildProjectFilter() {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        return DropdownButton<String?>(
          value: _selectedProjectFilter,
          hint: const Text('All Projects'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Projects'),
            ),
            ...projectProvider.projects.map((project) {
              return DropdownMenuItem<String?>(
                value: project.id,
                child: Text(project.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedProjectFilter = value;
            });
          },
        );
      },
    );
  }

  Widget _buildTimeBlockFilter() {
    return DropdownButton<TimeBlock?>(
      value: _selectedTimeBlockFilter,
      hint: const Text('All Time Blocks'),
      items: [
        const DropdownMenuItem<TimeBlock?>(
          value: null,
          child: Text('All Time Blocks'),
        ),
        ...TimeBlock.values.map((block) {
          return DropdownMenuItem<TimeBlock?>(
            value: block,
            child: Text(block.toString().split('.').last),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedTimeBlockFilter = value;
        });
      },
    );
  }

  Widget _buildSortOption() {
    return DropdownButton<TaskSortOption>(
      value: _sortOption,
      items: TaskSortOption.values.map((option) {
        return DropdownMenuItem<TaskSortOption>(
          value: option,
          child: Text(option.toString().split('.').last),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortOption = value;
          });
        }
      },
    );
  }

  List<Task> _getAllTasks(TaskProvider provider) {
    var tasks = provider.tasks;
    return _filterAndSortTasks(tasks);
  }

  List<Task> _getTodayTasks(TaskProvider provider) {
    var tasks = provider.getTodayTasks();
    return _filterAndSortTasks(tasks);
  }

  List<Task> _getUpcomingTasks(TaskProvider provider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var tasks = provider.tasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate.isAfter(today) && !task.completed;
    }).toList();
    
    return _filterAndSortTasks(tasks);
  }

  List<Task> _getCompletedTasks(TaskProvider provider) {
    var tasks = provider.tasks.where((task) => task.completed).toList();
    return _filterAndSortTasks(tasks);
  }

  List<Task> _filterAndSortTasks(List<Task> tasks) {
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) => 
        task.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply project filter
    if (_selectedProjectFilter != null) {
      tasks = tasks.where((task) => 
        task.projectId == _selectedProjectFilter
      ).toList();
    }

    // Apply time block filter
    if (_selectedTimeBlockFilter != null) {
      tasks = tasks.where((task) => 
        task.timeBlock == _selectedTimeBlockFilter
      ).toList();
    }

    // Sort tasks
    tasks.sort((a, b) {
      switch (_sortOption) {
        case TaskSortOption.dueDate:
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case TaskSortOption.priority:
          return b.priority.index.compareTo(a.priority.index);
        case TaskSortOption.timeBlock:
          return a.timeBlock.index.compareTo(b.timeBlock.index);
        case TaskSortOption.energyLevel:
          return b.energyRequired.index.compareTo(a.energyRequired.index);
        case TaskSortOption.name:
          return a.name.compareTo(b.name);
      }
    });

    return tasks;
  }

  Widget _buildTaskList(List<Task> Function(TaskProvider) getFilteredTasks) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = getFilteredTasks(taskProvider);
        
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No tasks found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or add a new task',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddTaskDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
          );
        }
        
        return TaskList(tasks: tasks);
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskNameController = TextEditingController();
    DateTime? selectedDate;
    TaskPriority priority = TaskPriority.medium;
    TimeBlock timeBlock = TimeBlock.peakProductivity;
    EnergyLevel energyLevel = EnergyLevel.medium;
    String? selectedProjectId;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task'),
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
                    const SizedBox(height: 16.0),
                    const Text('Energy Level:'),
                    DropdownButton<EnergyLevel>(
                      value: energyLevel,
                      isExpanded: true,
                      onChanged: (EnergyLevel? newValue) {
                        if (newValue != null) {
                          setState(() {
                            energyLevel = newValue;
                          });
                        }
                      },
                      items: EnergyLevel.values.map((EnergyLevel level) {
                        return DropdownMenuItem<EnergyLevel>(
                          value: level,
                          child: Text(level.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Project (Optional):'),
                    Consumer<ProjectProvider>(
                      builder: (context, projectProvider, child) {
                        return DropdownButton<String?>(
                          value: selectedProjectId,
                          isExpanded: true,
                          hint: const Text('Select Project'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('No Project'),
                            ),
                            ...projectProvider.projects.map((project) {
                              return DropdownMenuItem<String?>(
                                value: project.id,
                                child: Text(project.name),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProjectId = newValue;
                            });
                          },
                        );
                      },
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
                ElevatedButton(
                  onPressed: () {
                    if (taskNameController.text.trim().isNotEmpty) {
                      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                      final task = Task(
                        id: const Uuid().v4(),
                        name: taskNameController.text.trim(),
                        priority: priority,
                        timeBlock: timeBlock,
                        dueDate: selectedDate,
                        energyRequired: energyLevel,
                        projectId: selectedProjectId,
                        createdAt: DateTime.now(),
                      );
                      
                      taskProvider.addTask(task);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

enum TaskSortOption {
  dueDate,
  priority,
  timeBlock,
  energyLevel,
  name,
}