import 'dart:math';

import 'package:domain_models/domain_models.dart';
import 'package:firebase_api/firebase_api.dart';
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
    required this.remoteApi,
    @visibleForTesting UserLocalStorage? localStorage,
    @visibleForTesting UserSecureStorage? secureStorage,
  })  : _localStorage = localStorage ??
            UserLocalStorage(
              noSqlStorage: noSqlStorage,
            ),
        _secureStorage = secureStorage ?? const UserSecureStorage();

  final FirebaseApi remoteApi;
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

  Future<void> signIn(String email, String password) async {
    try {
      final apiUser = await remoteApi.signInWithEmailAndPassword(
        email,
        password,
      );

      await _secureStorage.upsertUserInfo(
        displayName: apiUser.displayName,
        email: apiUser.email,
        accessToken: apiUser.idToken, // Using accessToken from idToken
        userId: apiUser.localId, // Using userId from localId
      );

      final domainUser = apiUser.toDomainModel();

      _userSubject.add(
        domainUser,
      );
    } on InvalidCredentialsFirebaseException catch (_) {
      throw InvalidCredentialsException();
    } catch (e) {
      throw UnknownException();
    }
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

  Future<void> signUpWithEmailAndPasswordRequestRM(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response =
          await remoteApi.signUpWithEmailAndPassword(username, email, password);

      await _secureStorage.upsertUserInfo(
        displayName: username,
        email: email,
        accessToken: response.idToken, // Using accessToken from idToken
        userId: response.localId, // Using userId from localId
        refreshToken: response.refreshToken,
      );

      _userSubject.add(
        User(
          accessToken: response.idToken!,
          displayName: username,
          email: email,
          userPhotoURL: "",
          userId: response.localId!, // Set userId in the User object
        ),
      );
    } catch (error) {
      if (error is UsernameAlreadyTakenException) {
        throw UsernameAlreadyTakenException();
      } else if (error is EmailAlreadyRegisteredFirebaseException) {
        throw EmailAlreadyRegisteredException();
      }
      rethrow;
    }
  }

  Future<void> changePassword({
    required String password,
  }) async {
    try {
      final response = await remoteApi.changePassword(
        password,
      );

      await _secureStorage.upsertUserInfo(
        accessToken: response.idToken, // Using accessToken from idToken
        refreshToken: response.refreshToken,
        userId: await _secureStorage.getUserId(), // Keep existing userId
      );
      var userPhotoURL = await _secureStorage.getPhotoURL() ?? "";
      var displayName = await _secureStorage.getDisplayName() ?? "";

      _userSubject.add(
        User(
          accessToken: response.idToken!,
          displayName: displayName,
          userPhotoURL: userPhotoURL,
          email: _userSubject.value!.email,
          userId: response.localId!, // Set userId in the User object
        ),
      );
    } catch (_) {
      throw UnkownFirebaseException();
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? email,
  }) async {
    if (displayName != null) {
      try {
        final response = await remoteApi.updateNameAndPic(
          displayName,
          photoUrl,
        );
        var accessToken = await getUserToken();

        //response have null token thats why we used the local one to upsert the new user auth
        await _secureStorage.upsertUserInfo(
          accessToken: response.idToken ?? accessToken,
          displayName: displayName,
          userPhotoURL: photoUrl,
          email: email,
          userId: await _secureStorage.getUserId(), // Keep existing userId
        );
        _userSubject.add(
          User(
            email: email,
            accessToken: response.idToken ?? accessToken,
            displayName: displayName,
            userPhotoURL: photoUrl,
            userId: response.localId!, // Set userId in the User object
          ),
        );
      } catch (_) {
        throw UnkownFirebaseException();
      }
    }
  }

  Future<void> signOut() async {
    //await remoteApi.signOut();
    await _secureStorage.deleteUserInfo();
    _userSubject.add(null);
  }

  Future<void> requestPasswordResetEmail(String email) async {
    //await remoteApi.requestPasswordResetEmail(email);
  }
/* 
  Future<void> signUpAnonymously() async {
    try {
      final response = remoteApi.signUpAnonymously();

      final String randomName = "Guest#${generateRandomSixDigitNumber()}";
      await _secureStorage.upsertUserInfo(
        displayName: randomName,
        email: response.email,
        accessToken: response.idToken,
        userId: response.localId,
        refreshToken: response.refreshToken,
      );

      _userSubject.add(
        User(
          accessToken: response.idToken!,
          displayName: randomName,
          email: response.email,
          userPhotoURL: "",
          userId: response.localId!, // Set userId in the User object
        ),
      );
    } catch (error) {
      if (error is UsernameAlreadyTakenException) {
        throw UsernameAlreadyTakenException();
      } else if (error is EmailAlreadyRegisteredFirebaseException) {
        throw EmailAlreadyRegisteredException();
      }
      rethrow;
    }
  } */

  int generateRandomSixDigitNumber() {
    Random random = Random();
    int min = 100000; // The smallest 6-digit number
    int max = 999999; // The largest 6-digit number
    return min + random.nextInt(max - min + 1);
  }
}
