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
    this.passedOnBoarding = true,
    this.appLocale = const Locale('ar'),
  });

  final DarkModePreference? darkModePreference;
  final String? username;
  final bool isSignOutInProgress;
  final bool passedOnBoarding;
  final Locale? appLocale;
  bool get isUserAuthenticated => username != null;

  UserPreferencesLoaded copyWith({
    DarkModePreference? darkModePreference,
    String? username,
    bool? isSignOutInProgress,
    Locale? appLocale,
    bool? passedOnBoarding,
  }) {
    return UserPreferencesLoaded(
        darkModePreference: darkModePreference ?? this.darkModePreference,
        username: username ?? this.username,
        isSignOutInProgress: isSignOutInProgress ?? this.isSignOutInProgress,
        passedOnBoarding: passedOnBoarding ?? this.passedOnBoarding,
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
