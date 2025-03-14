import 'package:key_value_storage/key_value_storage.dart';

part 'user_settings_cm.g.dart';

@collection
class UserSettingsCM {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? language;

  bool? passedOnBoarding;

  @enumerated // same as EnumType.ordinal
  DarkModePreferenceCM darkModePreference;

  UserSettingsCM({
    this.language,
    this.passedOnBoarding,
    this.darkModePreference = DarkModePreferenceCM.accordingToSystemPreferences,
  });
}
