// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleCMAdapter extends TypeAdapter<ArticleCM> {
  @override
  final int typeId = 3;

  @override
  ArticleCM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleCM(
      source: fields[1] as SourceCM?,
      author: fields[2] as String?,
      title: fields[0] as String?,
      description: fields[3] as String?,
      url: fields[4] as String?,
      urlToImage: fields[5] as String?,
      publishedAt: fields[6] as String?,
      content: fields[7] as String?,
      isTemp: fields[8] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleCM obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.source)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.urlToImage)
      ..writeByte(6)
      ..write(obj.publishedAt)
      ..writeByte(7)
      ..write(obj.content)
      ..writeByte(8)
      ..write(obj.isTemp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleCMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
