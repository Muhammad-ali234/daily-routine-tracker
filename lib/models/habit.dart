import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 4)
enum HabitCategory {
  @HiveField(0)
  physical,
  @HiveField(1)
  mental,
  @HiveField(2)
  career,
  @HiveField(3)
  social
}

@HiveType(typeId: 3)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  HabitCategory category;

  @HiveField(3)
  bool monday;

  @HiveField(4)
  bool tuesday;

  @HiveField(5)
  bool wednesday;

  @HiveField(6)
  bool thursday;

  @HiveField(7)
  bool friday;

  @HiveField(8)
  bool saturday;

  @HiveField(9)
  bool sunday;

  @HiveField(10)
  int currentStreak;

  @HiveField(11)
  int longestStreak;

  @HiveField(12)
  DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.category,
    this.monday = false,
    this.tuesday = false,
    this.wednesday = false,
    this.thursday = false,
    this.friday = false,
    this.saturday = false,
    this.sunday = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.createdAt,
  });
}