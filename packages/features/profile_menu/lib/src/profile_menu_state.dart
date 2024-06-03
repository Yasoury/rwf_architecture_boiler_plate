part of 'profile_menu_bloc.dart';

abstract class ProfileMenuState extends Equatable {
  const ProfileMenuState();

  @override
  List<Object?> get props => [];
}

class ProfileMenuLoaded extends ProfileMenuState {
  const ProfileMenuLoaded({
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

  ProfileMenuLoaded copyWith({
    DarkModePreference? darkModePreference,
    String? username,
    bool? isSignOutInProgress,
    Locale? appLocale,
  }) {
    return ProfileMenuLoaded(
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

class ProfileMenuInProgress extends ProfileMenuState {
  const ProfileMenuInProgress();
}
