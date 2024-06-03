part of 'profile_menu_bloc.dart';

abstract class ProfileMenuEvent extends Equatable {
  const ProfileMenuEvent();

  @override
  List<Object?> get props => [];
}

class ProfileMenuStarted extends ProfileMenuEvent {
  const ProfileMenuStarted();
}

class ProfileMenuDarkModePreferenceChanged extends ProfileMenuEvent {
  const ProfileMenuDarkModePreferenceChanged(
    this.preference,
  );

  final DarkModePreference preference;

  @override
  List<Object?> get props => [
        preference,
      ];
}

class ProfileMenuLocaleChanged extends ProfileMenuEvent {
  const ProfileMenuLocaleChanged(this.appLocale);

  final Locale appLocale;

  @override
  List<Object?> get props => [
        appLocale,
      ];
}

class ProfileMenuSignedOut extends ProfileMenuEvent {
  const ProfileMenuSignedOut();
}
