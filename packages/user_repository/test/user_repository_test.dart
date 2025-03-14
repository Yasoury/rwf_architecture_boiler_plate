import 'package:firebase_api/firebase_api.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:user_repository/src/user_secure_storage.dart';
import 'package:user_repository/user_repository.dart';

import 'user_repository_test.mocks.dart';

@GenerateMocks([UserSecureStorage])
void main() {
  test(
      'When calling getUserToken after successful authentication,return authentication token',
      () async {
    final userSecureStorage = MockUserSecureStorage();

    final userRepository = UserRepository(
      secureStorage: userSecureStorage,
      noSqlStorage: KeyValueStorage(),
      remoteApi: FirebaseApi(userTokenSupplier: () => Future.value()),
    );

    when(userSecureStorage.getAccessToken()).thenAnswer((_) async => 'idToken');
    expect(await userRepository.getUserToken(), 'idToken');
  });
  // Challenge
}
