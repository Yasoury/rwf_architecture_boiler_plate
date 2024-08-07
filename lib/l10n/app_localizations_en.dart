import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get quotesBottomNavigationBarItemLabel => 'Home screen';

  @override
  String get profileBottomNavigationBarItemLabel => 'Profile';

  @override
  String get userPreferencesBottomNavigationBarItemLabel => 'Settings';
}
