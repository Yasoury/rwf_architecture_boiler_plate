import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _displayNameKey = 'display_name_key';
  static const _userEmailKey = 'user_email_key';
  static const _userPhotoURLKey = 'user_photo_url_key';
  static const _refreshTokenKey = 'refresh_token_key';
  static const _userIdKey = 'user_id_key';
  static const _accessTokenKey = 'access_token_key';

  const UserSecureStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<void> upsertUserInfo({
    String? displayName,
    String? userPhotoURL,
    String? email,
    String? refreshToken,
    String? userId,
    String? accessToken,
  }) {
    final futures = <Future<void>>[];

    if (email != null) {
      futures.add(_secureStorage.write(key: _userEmailKey, value: email));
    }
    if (userPhotoURL != null) {
      futures.add(
          _secureStorage.write(key: _userPhotoURLKey, value: userPhotoURL));
    }
    if (displayName != null) {
      futures
          .add(_secureStorage.write(key: _displayNameKey, value: displayName));
    }
    if (refreshToken != null) {
      futures.add(
          _secureStorage.write(key: _refreshTokenKey, value: refreshToken));
    }
    if (userId != null) {
      futures.add(_secureStorage.write(key: _userIdKey, value: userId));
    }
    if (accessToken != null) {
      futures
          .add(_secureStorage.write(key: _accessTokenKey, value: accessToken));
    }

    return futures.isEmpty
        ? Future.value()
        : Future.wait(futures); // Return early if no data
  }

  Future<void> deleteUserInfo() {
    return Future.wait([
      _secureStorage.delete(key: _displayNameKey),
      _secureStorage.delete(key: _userEmailKey),
      _secureStorage.delete(key: _userPhotoURLKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _accessTokenKey),
    ]);
  }

  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);
  Future<String?> getPhotoURL() => _secureStorage.read(key: _userPhotoURLKey);
  Future<String?> getUserEmail() => _secureStorage.read(key: _userEmailKey);
  Future<String?> getDisplayName() => _secureStorage.read(key: _displayNameKey);
  Future<String?> getUserId() => _secureStorage.read(key: _userIdKey);
  Future<String?> getAccessToken() => _secureStorage.read(key: _accessTokenKey);
}
