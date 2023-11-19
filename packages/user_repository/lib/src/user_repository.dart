import 'package:domain_models/domain_models.dart';
import 'package:firebase_api/firebase_api.dart';
import 'package:key_value_storage/key_value_storage.dart';
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
  final BehaviorSubject<DarkModePreference> _darkModePreferenceSubject =
      BehaviorSubject();

  Future<void> upsertDarkModePreference(DarkModePreference preference) async {
    await _localStorage.upsertDarkModePreference(
      preference.toCacheModel(),
    );
    _darkModePreferenceSubject.add(preference);
  }

  Stream<DarkModePreference> getDarkModePreference() async* {
    if (!_darkModePreferenceSubject.hasValue) {
      final storedPreference = await _localStorage.getDarkModePreference();
      _darkModePreferenceSubject.add(
        storedPreference?.toDomainModel() ??
            DarkModePreference.useSystemSettings,
      );
    }

    yield* _darkModePreferenceSubject.stream;
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
        idToken: apiUser.idToken,
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
        _secureStorage.getUserToken(),
      ]);

      final email = userInfo[0];
      final username = userInfo[1];
      final userPhotoURL = userInfo[2];
      final accessToken = userInfo[3];

      if (accessToken != null) {
        _userSubject.add(
          User(
            accessToken: accessToken,
            email: email ?? "",
            displayName: username ?? "",
            userPhotoURL: userPhotoURL ?? "",
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
    return _secureStorage.getUserToken();
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
        idToken: response.idToken,
      );

      _userSubject.add(
        User(
          accessToken: response.idToken!,
          displayName: username,
          email: email,
          userPhotoURL: "",
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
        idToken: response.idToken,
        refreshToken: response.refreshToken,
      );
      var userPhotoURL = await _secureStorage.getPhotoURL() ?? "";
      var displayName = await _secureStorage.getDisplayName() ?? "";

      _userSubject.add(
        User(
          accessToken: response.idToken!,
          displayName: displayName,
          userPhotoURL: userPhotoURL,
          email: _userSubject.value!.email,
        ),
      );
    } catch (_) {
      throw UnkownFirebaseException();
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String photoUrl,
  }) async {
    try {
      final response = await remoteApi.updateProfile(
        displayName,
        photoUrl,
      );
      //response have null token thats why we used the local one to upsert the new user auth
      await _secureStorage.upsertUserInfo(
        displayName: displayName,
        userPhotoURL: photoUrl,
        email: response.email,
      );
      var accessToken = await getUserToken();
      _userSubject.add(
        User(
          accessToken: accessToken!,
          displayName: displayName,
          userPhotoURL: photoUrl,
          email: response.email!,
        ),
      );
    } catch (_) {
      throw UnkownFirebaseException();
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

  Future<void> signUpAnonymously() async {
    await remoteApi.signUpAnonymously();
  }
}
