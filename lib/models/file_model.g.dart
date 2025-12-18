// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadedFileAdapter extends TypeAdapter<UploadedFile> {
  @override
  final int typeId = 1;

  @override
  UploadedFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadedFile(
      fileName: fields[0] as String,
      hash: fields[1] as String,
      uploadUrl: fields[2] as String,
      uploadDate: fields[3] as DateTime,
      accessCount: fields[4] as int,
      expiryDate: fields[5] as DateTime?,
      sharePassword: fields[6] as String?,
      fileType: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UploadedFile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fileName)
      ..writeByte(1)
      ..write(obj.hash)
      ..writeByte(2)
      ..write(obj.uploadUrl)
      ..writeByte(3)
      ..write(obj.uploadDate)
      ..writeByte(4)
      ..write(obj.accessCount)
      ..writeByte(5)
      ..write(obj.expiryDate)
      ..writeByte(6)
      ..write(obj.sharePassword)
      ..writeByte(7)
      ..write(obj.fileType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadedFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
