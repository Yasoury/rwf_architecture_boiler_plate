import 'package:key_value_storage/key_value_storage.dart';

import 'package:path_provider/path_provider.dart';

final class KeyValueStorage {
  static final KeyValueStorage _instance = KeyValueStorage._internal();

  factory KeyValueStorage() {
    return _instance;
  }

  KeyValueStorage._internal();

  late Isar _isar;

  IsarCollection<UserSettingsCM> get userSettingsCollection =>
      _isar.userSettingsCMs;

  Future<void> writeIsarTxn(Function() function) async {
    await _isar.writeTxn(() async {
      await function();
    });
  }

  Future<void> initIsarDB() async {
    final directory = await getApplicationDocumentsDirectory();
    if (!Isar.instanceNames.contains('default')) {
      _isar = await Isar.open(
        [
          //ADD Isar schema here
          UserSettingsCMSchema,
        ],
        directory: directory.path,
      );
    } else {
      _isar = Isar.getInstance()!;
    }
  }
}
