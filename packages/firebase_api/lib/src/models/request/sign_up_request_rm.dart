import 'package:firebase_api/firebase_api.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sign_up_request_rm.g.dart';

@JsonSerializable(createFactory: false)
class SignUpWithEmailAndPasswordRequestRM {
  const SignUpWithEmailAndPasswordRequestRM({
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

  Map<String, dynamic> toJson() => _$SignUpRequestRMToJson(this);
}
