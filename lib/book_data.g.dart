// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookRecordAdapter extends TypeAdapter<BookRecord> {
  @override
  final int typeId = 0;

  @override
  BookRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookRecord(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BookRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isbn)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.publisher)
      ..writeByte(4)
      ..write(obj.pubYear)
      ..writeByte(5)
      ..write(obj.dewey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
