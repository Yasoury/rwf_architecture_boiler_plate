import 'profile_menu_localizations.dart';

/// The translations for English (`en`).
class ProfileMenuLocalizationsEn extends ProfileMenuLocalizations {
  ProfileMenuLocalizationsEn([super.locale = 'en']);

  @override
  String get signInButtonLabel => 'Sign In';

  @override
  String signedInUserGreeting(String username) {
    return 'Hi, $username!';
  }

  @override
  String get updateProfileTileLabel => 'Update Profile';

  @override
  String get darkModePreferencesHeaderTileLabel => 'Dark Mode Preferences';

  @override
  String get languageHeaderTileLabel => 'Language';

  @override
  String get darkModePreferencesAlwaysDarkTileLabel => 'Always Dark';

  @override
  String get darkModePreferencesAlwaysLightTileLabel => 'Always Light';

  @override
  String get darkModePreferencesUseSystemSettingsTileLabel => 'Use System Settings';

  @override
  String get signOutButtonLabel => 'Sign Out';

  @override
  String get signUpOpeningText => 'Don\'t have an account?';

  @override
  String get signUpButtonLabel => 'Sign up';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get portuguese => 'Portuguese';
}
