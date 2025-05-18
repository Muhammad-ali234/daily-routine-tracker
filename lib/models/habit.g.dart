// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 3;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as HabitCategory,
      monday: fields[3] as bool,
      tuesday: fields[4] as bool,
      wednesday: fields[5] as bool,
      thursday: fields[6] as bool,
      friday: fields[7] as bool,
      saturday: fields[8] as bool,
      sunday: fields[9] as bool,
      currentStreak: fields[10] as int,
      longestStreak: fields[11] as int,
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.monday)
      ..writeByte(4)
      ..write(obj.tuesday)
      ..writeByte(5)
      ..write(obj.wednesday)
      ..writeByte(6)
      ..write(obj.thursday)
      ..writeByte(7)
      ..write(obj.friday)
      ..writeByte(8)
      ..write(obj.saturday)
      ..writeByte(9)
      ..write(obj.sunday)
      ..writeByte(10)
      ..write(obj.currentStreak)
      ..writeByte(11)
      ..write(obj.longestStreak)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitCategoryAdapter extends TypeAdapter<HabitCategory> {
  @override
  final int typeId = 4;

  @override
  HabitCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitCategory.physical;
      case 1:
        return HabitCategory.mental;
      case 2:
        return HabitCategory.career;
      case 3:
        return HabitCategory.social;
      default:
        return HabitCategory.physical;
    }
  }

  @override
  void write(BinaryWriter writer, HabitCategory obj) {
    switch (obj) {
      case HabitCategory.physical:
        writer.writeByte(0);
        break;
      case HabitCategory.mental:
        writer.writeByte(1);
        break;
      case HabitCategory.career:
        writer.writeByte(2);
        break;
      case HabitCategory.social:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
