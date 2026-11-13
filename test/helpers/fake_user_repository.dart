import 'dart:async';

import 'package:domain_models/domain_models.dart';
import 'package:user_repository/user_repository.dart';

/// In-memory [UserRepository] exposing only what navigation depends on.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({
    User? user,
    bool passedOnBoarding = true,
    this.emitsOnListen = true,
  })  : _user = user,
        _settings = UserSettings(
          language: 'en',
          passedOnBoarding: passedOnBoarding,
          darkModePreference: DarkModePreference.useSystemSettings,
        );

  /// When false, nothing is emitted until [emitStoredValues] is called,
  /// mimicking storage that is still being read.
  final bool emitsOnListen;

  final _userController = StreamController<User?>.broadcast();
  final _settingsController = StreamController<UserSettings>.broadcast();
  User? _user;
  UserSettings _settings;

  final upsertedSettings = <UserSettings>[];

  void emitStoredValues() {
    _userController.add(_user);
    _settingsController.add(_settings);
  }

  void failToLoad() {
    _userController.addError(Exception('secure storage unavailable'));
    _settingsController.addError(Exception('database unavailable'));
  }

  @override
  Stream<User?> getUser() async* {
    if (emitsOnListen) {
      yield _user;
    }
    yield* _userController.stream;
  }

  @override
  Stream<UserSettings> getUserSettings() async* {
    if (emitsOnListen) {
      yield _settings;
    }
    yield* _settingsController.stream;
  }

  @override
  Future<void> upsertUserSettings(UserSettings settings) async {
    upsertedSettings.add(settings);
    _settings = _settings.copyWith(
      language: settings.language,
      passedOnBoarding: settings.passedOnBoarding,
      darkModePreference: settings.darkModePreference,
    );
    _settingsController.add(_settings);
  }

  @override
  Future<void> signIn(String email, String password) async {
    _user = User(
      accessToken: 'token',
      email: email,
      displayName: 'Tester',
      userPhotoURL: '',
      userId: 'id',
    );
    _userController.add(_user);
  }

  @override
  Future<void> signUpWithEmailAndPasswordRequestRM(
    String username,
    String email,
    String password,
  ) =>
      signIn(email, password);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final signedInUser = User(
  accessToken: 'token',
  email: 'user@example.com',
  displayName: 'Tester',
  userPhotoURL: '',
  userId: 'id',
);
