part of 'user_preferences_bloc.dart';

abstract class UserPreferencesEvent extends Equatable {
  const UserPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class UserPreferencesStarted extends UserPreferencesEvent {
  const UserPreferencesStarted();
}

class UserPreferencesDarkModePreferenceChanged extends UserPreferencesEvent {
  const UserPreferencesDarkModePreferenceChanged(
    this.preference,
  );

  final DarkModePreference preference;

  @override
  List<Object?> get props => [
        preference,
      ];
}

class UserPreferencesLocaleChanged extends UserPreferencesEvent {
  const UserPreferencesLocaleChanged(this.appLocale);

  final Locale appLocale;

  @override
  List<Object?> get props => [
        appLocale,
      ];
}

class UserPreferencesSignedOut extends UserPreferencesEvent {
  const UserPreferencesSignedOut();
}
