import 'package:dio/dio.dart';
import 'package:firebase_api/src/models/exceptions.dart';
import 'package:firebase_api/src/models/models.dart';
import 'package:firebase_api/src/url_builder.dart';
import 'package:meta/meta.dart';

typedef UserTokenSupplier = Future<String?> Function();

class FirebaseApi {
  FirebaseApi({
    required UserTokenSupplier userTokenSupplier,
    @visibleForTesting Dio? dio,
    @visibleForTesting UrlBuilder? urlBuilder,
  })  : _dio = dio ?? Dio(),
        _urlBuilder = urlBuilder ?? const UrlBuilder() {
    _dio.setUpAuthHeaders(userTokenSupplier);
    _dio.interceptors.add(
      LogInterceptor(responseBody: false),
    );
  }

  final Dio _dio;
  final UrlBuilder _urlBuilder;

  Future<ProfileRM> signIn(String email, String password) async {
    final url = _urlBuilder.buildRequestPasswordResetEmailUrl();
    final requestJsonBody = SignInWithEmailAndPasswordRequestRM(
      email: email,
      password: password,
      returnSecureToken: true,
    ).toJson();
    final response = await _dio.post(
      url,
      data: requestJsonBody,
    );
    final jsonObject = response.data;
    try {
      final user = ProfileRM.fromJson(jsonObject);
      return user;
    } catch (error) {
      final int errorCode = jsonObject[_errorCodeJsonKey];
      if (errorCode == 21) {
        throw InvalidCredentialsFirebaseException();
      }
      rethrow;
    }
  }

  Future<String> signUp(
      String username, String email, String password, bool anonymously) async {
    final url = _urlBuilder.buildSignUpUrl();
    final requestJsonBody = SignUpWithEmailAndPasswordRequestRM(
      returnSecureToken: true,
      email: email,
      password: password,
    ).toJson();
    final response = await _dio.post(
      url,
      data: anonymously ? {} : requestJsonBody,
    );
    final jsonObject = response.data;
    try {
      return jsonObject['User-Token'];
    } catch (error) {
      final int errorCode = jsonObject[_errorCodeJsonKey];
      if (errorCode == 32) {
        final String errorMessage = jsonObject[_errorMessageJsonKey];
        if (errorMessage.toLowerCase().contains('email')) {
          throw EmailAlreadyRegisteredFirebaseException();
        }
      }
      rethrow;
    }
  }

  Future<void> updateProfile(
    String displayName,
    String? photoUrl,
  ) async {
    final url = _urlBuilder.buildUpdateProfileUrl();
    final requestJsonBody = AccountInfoRequestRM(
      displayName: displayName,
      photoUrl: photoUrl,
      returnSecureToken: true,
    ).toJson();
    final response = await _dio.post(
      url,
      data: requestJsonBody,
    );
    final Map<String, dynamic> jsonObject = response.data;
    if (jsonObject.containsKey(_errorCodeJsonKey)) {}
  }

  Future<void> requestPasswordResetEmail(String email) async {
    final url = _urlBuilder.buildRequestPasswordResetEmailUrl();
    try {
      await _dio.post(
        url,
        data: PasswordResetEmailRequestRM(
          email: email,
        ).toJson(),
      );
    } on DioException catch (error) {
      // When an unregistered email is sent to the API, it returns 404.
      // That can be considered a security breach, so we prefer handling an
      // unregistered email just like a registered one.
      if (error.response?.statusCode == 404) {
        return;
      }
      rethrow;
    }
  }
}

extension on Dio {
  static const _firebaseAPIKey = 'firebase-API-KEY';

  void setUpAuthHeaders(UserTokenSupplier userTokenSupplier) {
    final appToken = const String.fromEnvironment(
      _firebaseAPIKey,
    );
    options = BaseOptions(headers: {
      'Authorization': 'Token token=$appToken',
    });
    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? userToken = await userTokenSupplier();
          if (userToken != null) {
            options.headers.addAll({
              'User-Token': userToken,
            });
          }
          return handler.next(options);
        },
      ),
    );
  }
}
