import 'package:domain_models/domain_models.dart';

import 'package:key_value_storage/key_value_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/src/mappers/mappers.dart';
import 'package:user_repository/src/user_local_storage.dart';
import 'package:user_repository/src/user_secure_storage.dart';

class UserRepository {
  UserRepository({
    required KeyValueStorage noSqlStorage,
    @visibleForTesting UserLocalStorage? localStorage,
    @visibleForTesting UserSecureStorage? secureStorage,
  })  : _localStorage = localStorage ??
            UserLocalStorage(
              noSqlStorage: noSqlStorage,
            ),
        _secureStorage = secureStorage ?? const UserSecureStorage();

  final UserLocalStorage _localStorage;
  final UserSecureStorage _secureStorage;
  final BehaviorSubject<User?> _userSubject = BehaviorSubject();

  final BehaviorSubject<UserSettings> _userSettingsSubject = BehaviorSubject();
  final UserSettings _defaultSettings = UserSettings(
    language: 'en',
    passedOnBoarding: false,
    darkModePreference: DarkModePreference.useSystemSettings,
  );

  Future<void> upsertUserSettings(UserSettings settings) async {
    var savedSettings = await getUserSettings().first;

    // If any setting is null, use the default value for that setting
    var settingsToBeSaved = UserSettings(
      darkModePreference: settings.darkModePreference ??
          savedSettings.darkModePreference ??
          _defaultSettings.darkModePreference,
      language: settings.language ??
          savedSettings.language ??
          _defaultSettings.language,
      passedOnBoarding: settings.passedOnBoarding ??
          savedSettings.passedOnBoarding ??
          _defaultSettings.passedOnBoarding,
    );

    await _localStorage.upsertUserSettings(
      settingsToBeSaved.toCacheModel(),
    );
    _userSettingsSubject.add(settingsToBeSaved);
  }

  Stream<UserSettings> getUserSettings() async* {
    if (!_userSettingsSubject.hasValue) {
      final storedPreference = await _localStorage.getUserSettings();
      final domainModel = storedPreference?.toDomainModel();

      // If any stored setting is null, merge with default settings
      final settings =
          domainModel != null && domainModel.anyUserSettingsIsNull()
              ? UserSettings(
                  language: domainModel.language ?? _defaultSettings.language,
                  passedOnBoarding: domainModel.passedOnBoarding ??
                      _defaultSettings.passedOnBoarding,
                  darkModePreference: domainModel.darkModePreference ??
                      _defaultSettings.darkModePreference,
                )
              : domainModel ?? _defaultSettings;

      _userSettingsSubject.add(settings);
    }

    yield* _userSettingsSubject.stream;
  }

  Stream<User?> getUser() async* {
    if (!_userSubject.hasValue) {
      final userInfo = await Future.wait([
        _secureStorage.getUserEmail(),
        _secureStorage.getDisplayName(),
        _secureStorage.getPhotoURL(),
        _secureStorage.getAccessToken(),
        _secureStorage.getUserId(),
      ]);

      final email = userInfo[0];
      final username = userInfo[1];
      final userPhotoURL = userInfo[2];
      final accessToken = userInfo[3];
      final userId = userInfo[4]; // Fetch userId

      if (accessToken != null) {
        _userSubject.add(
          User(
            accessToken: accessToken,
            email: email ?? "",
            displayName: username ?? "",
            userPhotoURL: userPhotoURL ?? "",
            userId: userId ?? "", // Set userId in the User object
          ),
        );
      } else {
        _userSubject.add(
          null,
        );
      }
    }

    yield* _userSubject.stream;
  }

  Future<String?> getUserToken() {
    return _secureStorage.getAccessToken(); // Adjusted to use getAccessToken
  }
}
