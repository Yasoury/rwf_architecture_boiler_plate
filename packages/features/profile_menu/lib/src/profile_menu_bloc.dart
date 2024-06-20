import 'dart:ui';

import 'package:domain_models/domain_models.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';

part 'profile_menu_event.dart';

part 'profile_menu_state.dart';

class ProfileMenuBloc extends Bloc<ProfileMenuEvent, ProfileMenuState> {
  ProfileMenuBloc({
    required this.userRepository,
  }) : super(
          const ProfileMenuInProgress(),
        ) {
    on<ProfileMenuStarted>(
      (_, emit) async {
        await emit.onEach(
          Rx.combineLatest2<User?, UserSettings, ProfileMenuLoaded>(
            userRepository.getUser(),
            userRepository.getUserSettings(),
            (user, userSettings) => ProfileMenuLoaded(
              darkModePreference: userSettings.darkModePreference,
              username: user?.displayName,
              appLocale: Locale(userSettings.langugae!),
            ),
          ),
          onData: emit.call,
        );
      },
      transformer: (events, mapper) => events.flatMap(
        mapper,
      ),
    );

    on<ProfileMenuSignedOut>((_, emit) async {
      final currentState = state as ProfileMenuLoaded;
      final newState = currentState.copyWith(
        isSignOutInProgress: true,
      );

      emit(newState);

      await userRepository.signOut();
    });

    on<ProfileMenuDarkModePreferenceChanged>((event, _) async {
      await userRepository.upsertUserSettings(UserSettings(
        darkModePreference: event.preference,
      ));
    });

    on<ProfileMenuLocaleChanged>((event, _) async {
      await userRepository.upsertUserSettings(UserSettings(
        langugae: event.appLocale.languageCode,
      ));
    });

    add(
      const ProfileMenuStarted(),
    );
  }

  final UserRepository userRepository;
}
