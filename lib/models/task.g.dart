// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      name: fields[1] as String,
      status: fields[2] as TaskStatus,
      priority: fields[3] as TaskPriority,
      dueDate: fields[4] as DateTime?,
      timeBlock: fields[5] as TimeBlock,
      energyRequired: fields[6] as EnergyLevel,
      timeEstimate: fields[7] as int,
      completed: fields[8] as bool,
      projectId: fields[9] as String?,
      createdAt: fields[10] as DateTime,
    )
      ..startTimeMinutes = fields[11] as int?
      ..endTimeMinutes = fields[12] as int?;
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.timeBlock)
      ..writeByte(6)
      ..write(obj.energyRequired)
      ..writeByte(7)
      ..write(obj.timeEstimate)
      ..writeByte(8)
      ..write(obj.completed)
      ..writeByte(9)
      ..write(obj.projectId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.startTimeMinutes)
      ..writeByte(12)
      ..write(obj.endTimeMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 10;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.notStarted;
      case 1:
        return TaskStatus.inProgress;
      case 2:
        return TaskStatus.completed;
      default:
        return TaskStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.notStarted:
        writer.writeByte(0);
        break;
      case TaskStatus.inProgress:
        writer.writeByte(1);
        break;
      case TaskStatus.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 11;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.high;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.low;
      default:
        return TaskPriority.high;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.high:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeBlockAdapter extends TypeAdapter<TimeBlock> {
  @override
  final int typeId = 12;

  @override
  TimeBlock read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TimeBlock.morning;
      case 1:
        return TimeBlock.peakProductivity;
      case 2:
        return TimeBlock.career;
      case 3:
        return TimeBlock.evening;
      default:
        return TimeBlock.morning;
    }
  }

  @override
  void write(BinaryWriter writer, TimeBlock obj) {
    switch (obj) {
      case TimeBlock.morning:
        writer.writeByte(0);
        break;
      case TimeBlock.peakProductivity:
        writer.writeByte(1);
        break;
      case TimeBlock.career:
        writer.writeByte(2);
        break;
      case TimeBlock.evening:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnergyLevelAdapter extends TypeAdapter<EnergyLevel> {
  @override
  final int typeId = 13;

  @override
  EnergyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EnergyLevel.high;
      case 1:
        return EnergyLevel.medium;
      case 2:
        return EnergyLevel.low;
      default:
        return EnergyLevel.high;
    }
  }

  @override
  void write(BinaryWriter writer, EnergyLevel obj) {
    switch (obj) {
      case EnergyLevel.high:
        writer.writeByte(0);
        break;
      case EnergyLevel.medium:
        writer.writeByte(1);
        break;
      case EnergyLevel.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnergyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
