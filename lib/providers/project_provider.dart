import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  late Box<Project> _projectsBox;
  List<Project> _projects = [];

  ProjectProvider() {
    _initBox();
  }

  Future<void> _initBox() async {
    _projectsBox = Hive.box<Project>('projects');
    _loadProjects();
  }

  void _loadProjects() {
    _projects = _projectsBox.values.toList();
    notifyListeners();
  }

  // Public method to reload projects (used after import/clear data)
  void loadProjects() {
    _loadProjects();
  }

  List<Project> get projects => _projects;

  List<Project> getProjectsByCategory(ProjectCategory category) {
    return _projects.where((project) => project.category == category).toList();
  }

  List<Project> get activeProjects {
    return _projects.where((project) => project.status == ProjectStatus.active).toList();
  }

  Future<void> addProject(Project project) async {
    final id = const Uuid().v4();
    final newProject = Project(
      id: id,
      name: project.name,
      status: project.status,
      deadline: project.deadline,
      category: project.category,
      taskIds: project.taskIds,
      createdAt: DateTime.now(),
    );
    
    await _projectsBox.put(id, newProject);
    _loadProjects();
  }

  Future<void> updateProject(Project project) async {
    await _projectsBox.put(project.id, project);
    _loadProjects();
  }

  Future<void> deleteProject(String id) async {
    await _projectsBox.delete(id);
    _loadProjects();
  }

  Future<void> addTaskToProject(String projectId, String taskId) async {
    final project = _projectsBox.get(projectId);
    if (project != null) {
      project.taskIds.add(taskId);
      await _projectsBox.put(projectId, project);
      _loadProjects();
    }
  }

  Future<void> removeTaskFromProject(String projectId, String taskId) async {
    final project = _projectsBox.get(projectId);
    if (project != null) {
      project.taskIds.remove(taskId);
      await _projectsBox.put(projectId, project);
      _loadProjects();
    }
  }
}