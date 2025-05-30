// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      category: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteCategoryAdapter extends TypeAdapter<NoteCategory> {
  @override
  final int typeId = 1;

  @override
  NoteCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteCategory.work;
      case 1:
        return NoteCategory.personal;
      case 2:
        return NoteCategory.ideas;
      case 3:
        return NoteCategory.archive;
      default:
        return NoteCategory.work;
    }
  }

  @override
  void write(BinaryWriter writer, NoteCategory obj) {
    switch (obj) {
      case NoteCategory.work:
        writer.writeByte(0);
        break;
      case NoteCategory.personal:
        writer.writeByte(1);
        break;
      case NoteCategory.ideas:
        writer.writeByte(2);
        break;
      case NoteCategory.archive:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
