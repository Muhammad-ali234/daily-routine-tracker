// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 1;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      status: fields[2] as ProjectStatus,
      deadline: fields[3] as DateTime?,
      category: fields[4] as ProjectCategory,
      taskIds: (fields[5] as List).cast<String>(),
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.taskIds)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectStatusAdapter extends TypeAdapter<ProjectStatus> {
  @override
  final int typeId = 5;

  @override
  ProjectStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectStatus.planning;
      case 1:
        return ProjectStatus.active;
      case 2:
        return ProjectStatus.completed;
      case 3:
        return ProjectStatus.onHold;
      default:
        return ProjectStatus.planning;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectStatus obj) {
    switch (obj) {
      case ProjectStatus.planning:
        writer.writeByte(0);
        break;
      case ProjectStatus.active:
        writer.writeByte(1);
        break;
      case ProjectStatus.completed:
        writer.writeByte(2);
        break;
      case ProjectStatus.onHold:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectCategoryAdapter extends TypeAdapter<ProjectCategory> {
  @override
  final int typeId = 6;

  @override
  ProjectCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectCategory.aiLearning;
      case 1:
        return ProjectCategory.portfolio;
      case 2:
        return ProjectCategory.freelance;
      case 3:
        return ProjectCategory.career;
      default:
        return ProjectCategory.aiLearning;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectCategory obj) {
    switch (obj) {
      case ProjectCategory.aiLearning:
        writer.writeByte(0);
        break;
      case ProjectCategory.portfolio:
        writer.writeByte(1);
        break;
      case ProjectCategory.freelance:
        writer.writeByte(2);
        break;
      case ProjectCategory.career:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
