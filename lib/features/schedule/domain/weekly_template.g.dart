// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyTemplateAdapter extends TypeAdapter<WeeklyTemplate> {
  @override
  final int typeId = 1;

  @override
  WeeklyTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      schedule: (fields[2] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as List).cast<TemplateActivity>())),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyTemplate obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.schedule);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TemplateActivityAdapter extends TypeAdapter<TemplateActivity> {
  @override
  final int typeId = 2;

  @override
  TemplateActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateActivity(
      title: fields[0] as String,
      startHour: fields[1] as int,
      startMinute: fields[2] as int,
      durationMinutes: fields[3] as int,
      type: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateActivity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.startHour)
      ..writeByte(2)
      ..write(obj.startMinute)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
