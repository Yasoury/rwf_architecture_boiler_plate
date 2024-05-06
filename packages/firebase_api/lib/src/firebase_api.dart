import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_api/src/models/exceptions.dart';
import 'package:firebase_api/src/models/models.dart';
import 'package:firebase_api/src/models/request/change_password_request_rm.dart';
import 'package:firebase_api/src/models/response/change_password_response_rm.dart';
import 'package:firebase_api/src/models/response/sign_in_with_email_and_password_response_rm.dart';
import 'package:firebase_api/src/url_builder.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'models/response/signup_with_email_and_password_response_rm.dart';
import 'models/response/update_profile_info_response_rm.dart';

typedef UserTokenSupplier = Future<String?> Function();

class FirebaseApi {
  static const _errorCodeJsonKey = 'error';
  static const _errorMessageJsonKey = 'message';
  FirebaseApi({
    required UserTokenSupplier userTokenSupplier,
    @visibleForTesting Dio? dio,
    @visibleForTesting UrlBuilder? urlBuilder,
  })  : _dio = dio ?? Dio(),
        userTokenSupplierLocal = userTokenSupplier,
        _urlBuilder = urlBuilder ?? const UrlBuilder() {
    _dio.setUpAuthHeaders(userTokenSupplier);
    _dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestBody: true,
      ),
    );
  }
  final UserTokenSupplier userTokenSupplierLocal;
  final Dio _dio;
  final UrlBuilder _urlBuilder;

  Future<SignInWithEmailAndPasswordResponseModel> signInWithEmailAndPassword(
      String email, String password) async {
    final url = _urlBuilder.buildSignInWithPasswordUrl();
    final requestJsonBody = SignInWithEmailAndPasswordRequestModel(
      email: email,
      password: password,
      returnSecureToken: true,
    ).toJson();
    try {
      final response = await _dio.post(
        url,
        data: requestJsonBody,
      );
      final jsonObject = response.data;

      final user = SignInWithEmailAndPasswordResponseModel.fromJson(jsonObject);
      return user;
    } on DioException catch (dioError) {
      log(dioError.toString());
      final int errorCode = dioError.response!.statusCode!;
      if (errorCode == 400) {
        throw InvalidCredentialsFirebaseException();
      }
      rethrow;
    } catch (error) {
      throw UnkownFirebaseException();
    }
  }

  signUpAnonymously() {}

  Future<SignupWithEmailAndPasswordResponseModel> signUpWithEmailAndPassword(
      String username, String email, String password) async {
    final url = _urlBuilder.buildSignUpUrl();
    final requestJsonBody = SignUpWithEmailAndPasswordRequestModel(
      returnSecureToken: true,
      email: email,
      password: password,
    ).toJson();
    final response = await _dio.post(
      url,
      data: requestJsonBody,
    );
    final jsonObject = response.data;
    try {
      return SignupWithEmailAndPasswordResponseModel.fromJson(jsonObject);
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

  Future<ChangePasswordResponseModel> changePassword(
    String password,
  ) async {
    final url = _urlBuilder.buildUpdateProfileUrl();

    String? userToken = await userTokenSupplierLocal();

    final requestJsonBody = ChangePasswordRequestModel(
      idToken: userToken,
      password: password,
      returnSecureToken: true,
    ).toJson();
    final response = await _dio.post(
      url,
      data: requestJsonBody,
    );
    try {
      final Map<String, dynamic> jsonObject = response.data;
      return ChangePasswordResponseModel.fromJson(jsonObject);
    } on DioException catch (error) {
      log(error.toString());
      throw UnkownFirebaseException();
    }
  }

  Future<UpdateProfileInfoResponseModel> updateProfile(
    String displayName,
    String? photoUrl,
  ) async {
    final url = _urlBuilder.buildUpdateProfileUrl();

    String? userToken = await userTokenSupplierLocal();

    final requestJsonBody = UpdateProfileInfoRequestModel(
      idToken: userToken,
      displayName: displayName,
      photoUrl: photoUrl,
      returnSecureToken: true,
    ).toJson();
    final response = await _dio.post(
      url,
      data: requestJsonBody,
    );
    try {
      final Map<String, dynamic> jsonObject = response.data;
      return UpdateProfileInfoResponseModel.fromJson(jsonObject);
    } on DioException catch (error) {
      log(error.toString());
      throw UnkownFirebaseException();
    }
  }

  /* Future<void> requestPasswordResetEmail(String email) async {
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
  } */
}

extension on Dio {
  static const _firebaseAPIKey = 'firebase-API-KEY';
//TODO to implement "Token-based authentication"
  void setUpAuthHeaders(UserTokenSupplier userTokenSupplier) {
    final appToken = const String.fromEnvironment(
      _firebaseAPIKey,
    );
    options = BaseOptions(headers: {
      'Authorization': 'Token token=$appToken',
    }, queryParameters: {
      "key": appToken,
    });
    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          /*  String? userToken = await userTokenSupplier();
           if (userToken != null) {
            options.headers.addAll({
              'User-Token': userToken,
            });
          } */
          return handler.next(options);
        },
      ),
    );
  }
}
