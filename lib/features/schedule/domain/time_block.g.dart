// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeBlockAdapter extends TypeAdapter<TimeBlock> {
  @override
  final int typeId = 3;

  @override
  TimeBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeBlock(
      id: fields[0] as String,
      title: fields[1] as String,
      startTime: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      type: fields[4] as String,
      isCompleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TimeBlock obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isCompleted);
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
