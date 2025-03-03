import 'package:key_value_storage/key_value_storage.dart';

class UserLocalStorage {
  UserLocalStorage({
    required this.noSqlStorage,
  });

  final KeyValueStorage noSqlStorage;

  Future<void> upsertUserSettings(UserSettingsCM settings) async {
    await noSqlStorage.userSettingsCollection.put(settings);
  }

  Future<UserSettingsCM?> getUserSettings() async {
    return await noSqlStorage.userSettingsCollection.get(1);
  }
}
