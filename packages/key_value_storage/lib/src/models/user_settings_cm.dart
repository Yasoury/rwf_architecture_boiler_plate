import 'package:hive/hive.dart';
import 'package:key_value_storage/src/models/models.dart';

part 'user_settings_cm.g.dart';

@HiveType(typeId: 2)
class UserSettingsCM {
  @HiveField(0)
  String? langugae;
  @HiveField(1)
  bool? passedOnBoarding;
  @HiveField(2)
  DarkModePreferenceCM? darkModePreference;

  UserSettingsCM({
    this.langugae = "en",
    this.passedOnBoarding = false,
    this.darkModePreference = DarkModePreferenceCM.accordingToSystemPreferences,
  });
}
