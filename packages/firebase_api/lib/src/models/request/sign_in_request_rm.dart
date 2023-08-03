import 'package:firebase_api/src/models/request/user_credentials_rm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sign_in_request_rm.g.dart';

@JsonSerializable(createFactory: false)
class SignInWithEmailAndPasswordRequestRM {
  const SignInWithEmailAndPasswordRequestRM({
    required this.email,
    required this.password,
    required this.returnSecureToken,
  });

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'password')
  final String password;

  @JsonKey(name: 'returnSecureToken')
  final bool returnSecureToken;

  Map<String, dynamic> toJson() => _$SignInRequestRMToJson(this);
}
