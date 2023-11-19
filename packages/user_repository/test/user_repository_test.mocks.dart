// Mocks generated by Mockito 5.4.2 from annotations
// in user_repository/test/user_repository_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:user_repository/src/user_secure_storage.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [UserSecureStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserSecureStorage extends _i1.Mock implements _i2.UserSecureStorage {
  MockUserSecureStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> upsertUserInfo({
    String? displayName,
    String? email,
    String? idToken,
    String? userPhotoURL,
    String? refreshToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #upsertUserInfo,
          [],
          {
            #username: displayName,
            #email: email,
            #idToken: idToken,
            #refreshToken: refreshToken,
            #userPhotoURL: userPhotoURL,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> deleteUserInfo() => (super.noSuchMethod(
        Invocation.method(
          #deleteUserInfo,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<String?> getUserToken() => (super.noSuchMethod(
        Invocation.method(
          #getUserToken,
          [],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);
  @override
  _i3.Future<String?> getUserEmail() => (super.noSuchMethod(
        Invocation.method(
          #getUserEmail,
          [],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);
  @override
  _i3.Future<String?> getPhotoURL() => (super.noSuchMethod(
        Invocation.method(
          #getPhotoURL,
          [],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);
  @override
  _i3.Future<String?> getDisplayName() => (super.noSuchMethod(
        Invocation.method(
          #getUsername,
          [],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);
}
