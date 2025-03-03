import 'package:key_value_storage/key_value_storage.dart';

import 'package:path_provider/path_provider.dart';

final class KeyValueStorage {
  static final KeyValueStorage _instance = KeyValueStorage._internal();

  factory KeyValueStorage() {
    return _instance;
  }

  KeyValueStorage._internal() {
    initIsarDB();
  }
  late Isar _isar;

  IsarCollection<UserSettingsCM> get userSettingsCollection =>
      _isar.userSettingsCMs;

  Future<void> initIsarDB() async {
    final directory = await getApplicationDocumentsDirectory();
    Isar.open(
      [
        //ADD Isar schema here
        UserSettingsCMSchema,
      ],
      directory: directory.path,
    );
  }
}
/*  Future<Box<UserSettingsCM>> get userSettingsBox =>
      _openHiveBox<UserSettingsCM>(
        userSettingsKey,
        isTemporary: false,
      ); */