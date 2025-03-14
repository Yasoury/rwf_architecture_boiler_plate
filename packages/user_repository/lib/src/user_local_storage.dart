import 'package:key_value_storage/key_value_storage.dart';

class UserLocalStorage {
  UserLocalStorage({
    required this.noSqlStorage,
  });

  final KeyValueStorage noSqlStorage;

  Future<void> upsertUserSettings(UserSettingsCM settings) async {
    await noSqlStorage.writeIsarTxn(() async {
      noSqlStorage.userSettingsCollection.clear();
      noSqlStorage.userSettingsCollection.put(settings);
    });
  }

  Future<UserSettingsCM?> getUserSettings() async {
    return await noSqlStorage.userSettingsCollection.where().findFirst();
  }
}
