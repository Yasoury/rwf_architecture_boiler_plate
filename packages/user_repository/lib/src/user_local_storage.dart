import 'package:key_value_storage/key_value_storage.dart';

class UserLocalStorage {
  UserLocalStorage({
    required this.noSqlStorage,
  });

  final KeyValueStorage noSqlStorage;

  Future<void> upsertUserSettings(UserSettingsCM settings) async {
    final box = await noSqlStorage.userSettingsBox;
    await box.put(0, settings);
  }

  Future<UserSettingsCM?> getUserSettings() async {
    final box = await noSqlStorage.userSettingsBox;
    return box.get(0);
  }
}
