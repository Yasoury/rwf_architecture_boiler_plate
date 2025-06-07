// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_cm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsCMAdapter extends TypeAdapter<UserSettingsCM> {
  @override
  final int typeId = 2;

  @override
  UserSettingsCM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingsCM(
      language: fields[0] as String?,
      passedOnBoarding: fields[1] as bool?,
      darkModePreference: fields[2] as DarkModePreferenceCM?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsCM obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.passedOnBoarding)
      ..writeByte(2)
      ..write(obj.darkModePreference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsCMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
