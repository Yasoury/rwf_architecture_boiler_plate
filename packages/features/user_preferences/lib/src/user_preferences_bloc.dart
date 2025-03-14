import 'dart:ui';

import 'package:domain_models/domain_models.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';

part 'user_preferences_event.dart';

part 'user_preferences_state.dart';

class UserPreferencesBloc
    extends Bloc<UserPreferencesEvent, UserPreferencesState> {
  UserPreferencesBloc({
    required this.userRepository,
  }) : super(
          const UserPreferencesInProgress(),
        ) {
    on<UserPreferencesStarted>(
      (_, emit) async {
        await emit.onEach(
          Rx.combineLatest2<User?, UserSettings, UserPreferencesLoaded>(
            userRepository.getUser(),
            userRepository.getUserSettings(),
            (user, userSettings) => UserPreferencesLoaded(
              darkModePreference: userSettings.darkModePreference,
              username: user?.displayName,
              appLocale: Locale(userSettings.language!),
            ),
          ),
          onData: emit.call,
        );
      },
      transformer: (events, mapper) => events.flatMap(
        mapper,
      ),
    );

    on<UserPreferencesSignedOut>((_, emit) async {
      final currentState = state as UserPreferencesLoaded;
      final newState = currentState.copyWith(
        isSignOutInProgress: true,
      );

      emit(newState);

      await userRepository.signOut();
    });

    on<UserPreferencesDarkModePreferenceChanged>((event, _) async {
      await userRepository.upsertUserSettings(UserSettings(
        darkModePreference: event.preference,
      ));
    });

    on<UserPreferencesLocaleChanged>((event, _) async {
      await userRepository.upsertUserSettings(UserSettings(
        language: event.appLocale.languageCode,
      ));
    });

    add(
      const UserPreferencesStarted(),
    );
  }

  final UserRepository userRepository;
}
