import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({Key? key}) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ProjectCategory? _selectedCategory;
  ProjectStatus? _selectedStatus;
  ProjectSortOption _sortOption = ProjectSortOption.deadline;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort projects',
            onPressed: _showSortOptionsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter projects',
            onPressed: _showFilterDialog,
          ),
        ],
      ),

      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _buildProjectList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        tooltip: 'Add new project',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search projects...',
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
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          if (_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(_selectedCategory!.toString().split('.').last),
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
                selected: true,
              ),
            ),
          if (_selectedStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(_selectedStatus!.toString().split('.').last),
                onSelected: (_) {
                  setState(() {
                    _selectedStatus = null;
                  });
                },
                selected: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return Consumer2<ProjectProvider, TaskProvider>(
      builder: (context, projectProvider, taskProvider, child) {
        var projects = projectProvider.projects;

        // Apply filters
        if (_searchQuery.isNotEmpty) {
          projects = projects.where((project) =>
            project.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (_selectedCategory != null) {
          projects = projects.where((project) =>
            project.category == _selectedCategory
          ).toList();
        }

        if (_selectedStatus != null) {
          projects = projects.where((project) =>
            project.status == _selectedStatus
          ).toList();
        }

        // Sort projects
        projects.sort((a, b) {
          switch (_sortOption) {
            case ProjectSortOption.name:
              return a.name.compareTo(b.name);
            case ProjectSortOption.deadline:
              if (a.deadline == null) return 1;
              if (b.deadline == null) return -1;
              return a.deadline!.compareTo(b.deadline!);
            case ProjectSortOption.status:
              return a.status.index.compareTo(b.status.index);
            case ProjectSortOption.category:
              return a.category.index.compareTo(b.category.index);
            case ProjectSortOption.createdAt:
              return b.createdAt.compareTo(a.createdAt);
          }
        });

        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or add a new project',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddProjectDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Project'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final projectTasks = taskProvider.getTasksByProjectId(project.id);
            final completedTasks = projectTasks.where((t) => t.completed).length;
            final progress = projectTasks.isNotEmpty
                ? completedTasks / projectTasks.length
                : 0.0;

            Color statusColor;
            switch (project.status) {
              case ProjectStatus.planning:
                statusColor = Colors.blue;
                break;
              case ProjectStatus.active:
                statusColor = Colors.green;
                break;
              case ProjectStatus.completed:
                statusColor = Colors.purple;
                break;
              case ProjectStatus.onHold:
                statusColor = Colors.orange;
                break;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () => _showProjectDetailsDialog(context, project),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  project.category.toString().split('.').last,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              project.status.toString().split('.').last,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Project',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Project'),
                                  content: Text('Are you sure you want to delete "${project.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Provider.of<ProjectProvider>(context, listen: false).deleteProject(project.id);
                                        Navigator.of(context).pop();
                                      },
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (project.deadline != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: _isDeadlineNear(project.deadline!)
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Due ${DateFormat('MMM dd, yyyy').format(project.deadline!)}',
                                    style: TextStyle(
                                      color: _isDeadlineNear(project.deadline!)
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Progress: ${(progress * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress == 1.0 ? Colors.green : statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '$completedTasks/${projectTasks.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isDeadlineNear(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference <= 7 && difference >= 0;
  }

  void _showSortOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort Projects'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ProjectSortOption.values.map((option) {
              return RadioListTile<ProjectSortOption>(
                title: Text(option.toString().split('.').last),
                value: option,
                groupValue: _sortOption,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortOption = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Projects'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category:'),
                  DropdownButton<ProjectCategory?>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<ProjectCategory?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...ProjectCategory.values.map((category) {
                        return DropdownMenuItem<ProjectCategory?>(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Status:'),
                  DropdownButton<ProjectStatus?>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<ProjectStatus?>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...ProjectStatus.values.map((status) {
                        return DropdownMenuItem<ProjectStatus?>(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedStatus = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    ProjectCategory category = ProjectCategory.aiLearning;
    ProjectStatus status = ProjectStatus.planning;
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Project'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        hintText: 'Enter project name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category:'),
                    DropdownButton<ProjectCategory>(
                      value: category,
                      isExpanded: true,
                      items: ProjectCategory.values.map((category) {
                        return DropdownMenuItem<ProjectCategory>(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            category = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Status:'),
                    DropdownButton<ProjectStatus>(
                      value: status,
                      isExpanded: true,
                      items: ProjectStatus.values.map((status) {
                        return DropdownMenuItem<ProjectStatus>(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Deadline:'),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: deadline ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != deadline) {
                              setState(() {
                                deadline = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            deadline == null
                                ? 'Set Deadline'
                                : DateFormat('MMM dd, yyyy').format(deadline!),
                          ),
                        ),
                        if (deadline != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                deadline = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final projectProvider =
                          Provider.of<ProjectProvider>(context, listen: false);
                      final project = Project(
                        id: const Uuid().v4(),
                        name: nameController.text.trim(),
                        category: category,
                        status: status,
                        deadline: deadline,
                        createdAt: DateTime.now(),
                      );
                      projectProvider.addProject(project);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Project'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProjectDetailsDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final projectTasks = taskProvider.getTasksByProjectId(project.id);
            final completedTasks = projectTasks.where((t) => t.completed).length;
            final progress = projectTasks.isNotEmpty
                ? completedTasks / projectTasks.length
                : 0.0;

            return AlertDialog(
              title: Text(project.name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category: ${project.category.toString().split('.').last}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${project.status.toString().split('.').last}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (project.deadline != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Deadline: ${DateFormat('MMM dd, yyyy').format(project.deadline!)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isDeadlineNear(project.deadline!)
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Progress: ${(progress * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tasks: $completedTasks/${projectTasks.length} completed',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tasks:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (projectTasks.isEmpty)
                    const Text('No tasks yet')
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: projectTasks.length,
                        itemBuilder: (context, index) {
                          final task = projectTasks[index];
                          return CheckboxListTile(
                            title: Text(
                              task.name,
                              style: TextStyle(
                                decoration: task.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            value: task.completed,
                            onChanged: (value) {
                              taskProvider.toggleTaskCompletion(task.id);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () => _showEditProjectDialog(context, project),
                  child: const Text('Edit'),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => _showDeleteProjectDialog(context, project),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    final TextEditingController nameController =
        TextEditingController(text: project.name);
    ProjectCategory category = project.category;
    ProjectStatus status = project.status;
    DateTime? deadline = project.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Project'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        hintText: 'Enter project name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category:'),
                    DropdownButton<ProjectCategory>(
                      value: category,
                      isExpanded: true,
                      items: ProjectCategory.values.map((category) {
                        return DropdownMenuItem<ProjectCategory>(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            category = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Status:'),
                    DropdownButton<ProjectStatus>(
                      value: status,
                      isExpanded: true,
                      items: ProjectStatus.values.map((status) {
                        return DropdownMenuItem<ProjectStatus>(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Deadline:'),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: deadline ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != deadline) {
                              setState(() {
                                deadline = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            deadline == null
                                ? 'Set Deadline'
                                : DateFormat('MMM dd, yyyy').format(deadline!),
                          ),
                        ),
                        if (deadline != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                deadline = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final projectProvider =
                          Provider.of<ProjectProvider>(context, listen: false);
                      final updatedProject = Project(
                        id: project.id,
                        name: nameController.text.trim(),
                        category: category,
                        status: status,
                        deadline: deadline,
                        taskIds: project.taskIds,
                        createdAt: project.createdAt,
                      );
                      projectProvider.updateProject(updatedProject);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteProjectDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text(
            'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                final projectProvider =
                    Provider.of<ProjectProvider>(context, listen: false);
                projectProvider.deleteProject(project.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

enum ProjectSortOption {
  name,
  deadline,
  status,
  category,
  createdAt,
}
