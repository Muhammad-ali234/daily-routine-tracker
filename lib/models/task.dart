import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 10)
enum TaskStatus {
  @HiveField(0)
  notStarted,
  
  @HiveField(1)
  inProgress,
  
  @HiveField(2)
  completed
}

@HiveType(typeId: 11)
enum TaskPriority {
  @HiveField(0)
  high,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  low
}

@HiveType(typeId: 12)
enum TimeBlock {
  @HiveField(0)
  morning,
  
  @HiveField(1)
  peakProductivity,
  
  @HiveField(2)
  career,
  
  @HiveField(3)
  evening
}

@HiveType(typeId: 13)
enum EnergyLevel {
  @HiveField(0)
  high,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  low
}

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  TaskStatus status;

  @HiveField(3)
  TaskPriority priority;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  TimeBlock timeBlock;

  @HiveField(6)
  EnergyLevel energyRequired;

  @HiveField(7)
  int timeEstimate; // in minutes

  @HiveField(8)
  bool completed;

  @HiveField(9)
  String? projectId;

  @HiveField(10)
  DateTime createdAt;

  Task({
    required this.id,
    required this.name,
    this.status = TaskStatus.notStarted,
    this.priority = TaskPriority.medium,
    this.dueDate,
    required this.timeBlock,
    this.energyRequired = EnergyLevel.medium,
    this.timeEstimate = 30,
    this.completed = false,
    this.projectId,
    required this.createdAt,
  });
}