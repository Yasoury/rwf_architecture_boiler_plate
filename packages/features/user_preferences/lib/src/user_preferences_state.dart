part of 'user_preferences_bloc.dart';

abstract class UserPreferencesState extends Equatable {
  const UserPreferencesState();

  @override
  List<Object?> get props => [];
}

class UserPreferencesLoaded extends UserPreferencesState {
  const UserPreferencesLoaded({
    this.darkModePreference,
    this.isSignOutInProgress = false,
    this.username,
    this.appLocale = const Locale('ar'),
  });

  final DarkModePreference? darkModePreference;
  final String? username;
  final bool isSignOutInProgress;
  final Locale? appLocale;
  bool get isUserAuthenticated => username != null;

  UserPreferencesLoaded copyWith({
    DarkModePreference? darkModePreference,
    String? username,
    bool? isSignOutInProgress,
    Locale? appLocale,
  }) {
    return UserPreferencesLoaded(
        darkModePreference: darkModePreference ?? this.darkModePreference,
        username: username ?? this.username,
        isSignOutInProgress: isSignOutInProgress ?? this.isSignOutInProgress,
        appLocale: appLocale ?? const Locale('en'));
  }

  @override
  List<Object?> get props => [
        darkModePreference,
        username,
        isSignOutInProgress,
        appLocale,
      ];
}

class UserPreferencesInProgress extends UserPreferencesState {
  const UserPreferencesInProgress();
}
