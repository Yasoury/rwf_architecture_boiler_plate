import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _tokenKey = 'firebase-token';
  static const _displayNameKey = 'firebase-displayName';
  static const _emailKey = 'firebase-email';
  static const _photoUrlKey = 'firebase-photoUrl';

  const UserSecureStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<void> upsertUserInfo({
    required String displayName,
    required String photoUrl,
    required String email,
    String? token,
  }) =>
      Future.wait([
        _secureStorage.write(
          key: _emailKey,
          value: email,
        ),
        _secureStorage.write(
          key: _displayNameKey,
          value: displayName,
        ),
        _secureStorage.write(
          key: _photoUrlKey,
          value: photoUrl,
        ),
        if (token != null)
          _secureStorage.write(
            key: _tokenKey,
            value: token,
          )
      ]);

  Future<void> deleteUserInfo() => Future.wait([
        _secureStorage.delete(
          key: _tokenKey,
        ),
        _secureStorage.delete(
          key: _displayNameKey,
        ),
        _secureStorage.delete(
          key: _emailKey,
        ),
        _secureStorage.delete(
          key: _photoUrlKey,
        ),
      ]);

  Future<String?> getUserToken() => _secureStorage.read(
        key: _tokenKey,
      );

  Future<String?> getUserEmail() => _secureStorage.read(
        key: _emailKey,
      );

  Future<String?> getUsername() => _secureStorage.read(
        key: _displayNameKey,
      );

  Future<String?> getUserPhotoUrl() => _secureStorage.read(
        key: _photoUrlKey,
      );
}
