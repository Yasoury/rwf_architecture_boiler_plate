import 'package:dio/dio.dart';
import 'package:firebase_api/src/firebase_api.dart';
import 'package:firebase_api/src/models/models.dart';
import 'package:firebase_api/src/url_builder.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('Sign in:', () {
    final dio = Dio(BaseOptions());
    final dioAdapter = DioAdapter(dio: dio);

    const email = 'email';
    const password = 'password';

    final remoteApi =
        FirebaseApi(userTokenSupplier: () => Future.value(), dio: dio);

    final url = const UrlBuilder().buildRequestPasswordResetEmailUrl();

    final requestJsonBody = const SignInWithEmailAndPasswordRequestRM(
      returnSecureToken: true,
      credentials: UserCredentialsRM(
          email: email, password: password, returnSecureToken: true),
    ).toJson();

    test(
        'When sign in call completes successfully, returns an instance of UserRM',
        () async {
      dioAdapter.onPost(
        url,
        (server) => server.reply(
          200,
          {"User-Token": "token", "login": "login", "email": "email"},
          delay: const Duration(seconds: 1),
        ),
        data: requestJsonBody,
      );

      expect(await remoteApi.signIn(email, password), isA<ProfileRM>());
    });
  });
}
