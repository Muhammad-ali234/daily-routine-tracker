import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? profileImageUrl;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime lastLoginAt;

  @HiveField(6)
  Map<String, dynamic> preferences;

  @HiveField(7)
  String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
    this.bio,
  });
}