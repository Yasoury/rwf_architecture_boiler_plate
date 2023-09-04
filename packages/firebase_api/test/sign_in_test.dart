import 'package:dio/dio.dart';
import 'package:firebase_api/src/firebase_api.dart';
import 'package:firebase_api/src/models/models.dart';
import 'package:firebase_api/src/models/response/sign_in_with_email_and_password_response_rm.dart';
import 'package:firebase_api/src/url_builder.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  test(
      'When sign in call completes successfully, returns an instance of UserRM',
      () async {
    // 1
    final dio = Dio(BaseOptions());

    final dioAdapter = DioAdapter(dio: dio);

    // 2
    final remoteApi =
        FirebaseApi(userTokenSupplier: () => Future.value(), dio: dio);

    // 3
    const email = 'email';
    const password = 'password';

    final url = const UrlBuilder().buildSignInWithPasswordUrl();

    final requestJsonBody = SignInWithEmailAndPasswordRequestRM(
      email: email,
      password: password,
    ).toJson();

    dioAdapter.onPost(
      url,
      (server) => server.reply(
        200,
        {"idToken": "token", "login": "login", "email": "email"},
        delay: const Duration(seconds: 1),
      ),
      data: requestJsonBody,
    );

    expect(await remoteApi.signInWithEmailAndPassword(email, password),
        isA<SignInWithEmailAndPasswordResponseRm>());
  });
}
