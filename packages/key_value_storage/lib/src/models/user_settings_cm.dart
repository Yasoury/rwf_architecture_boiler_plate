import 'package:key_value_storage/key_value_storage.dart';

part 'user_settings_cm.g.dart';

@collection
class UserSettingsCM {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? langugae;

  bool? passedOnBoarding;

  @enumerated // same as EnumType.ordinal
  DarkModePreferenceCM darkModePreference;

  UserSettingsCM({
    this.langugae = "en",
    this.passedOnBoarding = false,
    this.darkModePreference = DarkModePreferenceCM.accordingToSystemPreferences,
  });
}
