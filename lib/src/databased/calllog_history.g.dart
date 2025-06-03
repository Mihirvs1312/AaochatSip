// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calllog_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallLogHistoryAdapter extends TypeAdapter<CallLogHistory> {
  @override
  final int typeId = 1;

  @override
  CallLogHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallLogHistory(
      id: fields[0] as String?,
      myCallId: fields[1] as int?,
      displName: fields[2] as String?,
      remoteExt: fields[3] as String?,
      accUri: fields[4] as String?,
      duration: fields[5] as String?,
      hasVideo: fields[6] as bool?,
      incoming: fields[7] as bool?,
      connected: fields[8] as bool?,
      statusCode: fields[9] as int?,
      madeAtDate: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CallLogHistory obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.myCallId)
      ..writeByte(2)
      ..write(obj.displName)
      ..writeByte(3)
      ..write(obj.remoteExt)
      ..writeByte(4)
      ..write(obj.accUri)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.hasVideo)
      ..writeByte(7)
      ..write(obj.incoming)
      ..writeByte(8)
      ..write(obj.connected)
      ..writeByte(9)
      ..write(obj.statusCode)
      ..writeByte(10)
      ..write(obj.madeAtDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallLogHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
