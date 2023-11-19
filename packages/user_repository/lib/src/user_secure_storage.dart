import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _idToken = 'id_token_key';
  static const _displayNameKey = 'display_name_key';
  static const _userEmailKey = 'user_email_key';
  static const _userPhotoURLKey = 'user_photo_url_key';
  static const _refreshToken = '_refresh_token_key';

  const UserSecureStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<void> upsertUserInfo({
    String? displayName,
    String? userPhotoURL,
    String? email,
    String? idToken,
    String? refreshToken,
  }) =>
      Future.wait([
        if (email != null)
          _secureStorage.write(
            key: _userEmailKey,
            value: email,
          ),
        if (userPhotoURL != null)
          _secureStorage.write(
            key: _userPhotoURLKey,
            value: userPhotoURL,
          ),
        if (displayName != null)
          _secureStorage.write(
            key: _displayNameKey,
            value: displayName,
          ),
        if (idToken != null)
          _secureStorage.write(
            key: _idToken,
            value: idToken,
          ),
        if (refreshToken != null)
          _secureStorage.write(
            key: _refreshToken,
            value: refreshToken,
          )
      ]);

  Future<void> deleteUserInfo() => Future.wait([
        _secureStorage.delete(
          key: _idToken,
        ),
        _secureStorage.delete(
          key: _displayNameKey,
        ),
        _secureStorage.delete(
          key: _userEmailKey,
        ),
        _secureStorage.delete(
          key: _userPhotoURLKey,
        ),
      ]);

  Future<String?> getUserToken() => _secureStorage.read(
        key: _idToken,
      );

  Future<String?> getRefreshToken() => _secureStorage.read(
        key: _refreshToken,
      );

  Future<String?> getPhotoURL() => _secureStorage.read(
        key: _userPhotoURLKey,
      );

  Future<String?> getUserEmail() => _secureStorage.read(
        key: _userEmailKey,
      );

  Future<String?> getDisplayName() => _secureStorage.read(
        key: _displayNameKey,
      );
}
