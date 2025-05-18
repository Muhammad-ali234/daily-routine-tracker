import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 5)
enum ProjectStatus {
  @HiveField(0)
  planning,
  @HiveField(1)
  active,
  @HiveField(2)
  completed,
  @HiveField(3)
  onHold
}

@HiveType(typeId: 6)
enum ProjectCategory {
  @HiveField(0)
  aiLearning,
  @HiveField(1)
  portfolio,
  @HiveField(2)
  freelance,
  @HiveField(3)
  career
}

@HiveType(typeId: 1)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  ProjectStatus status;

  @HiveField(3)
  DateTime? deadline;

  @HiveField(4)
  ProjectCategory category;

  @HiveField(5)
  List<String> taskIds;

  @HiveField(6)
  DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    this.status = ProjectStatus.planning,
    this.deadline,
    required this.category,
    this.taskIds = const [],
    required this.createdAt,
  });
}
