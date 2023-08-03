import 'package:firebase_api/src/models/request/user_email_rm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'password_reset_email_request_rm.g.dart';

@JsonSerializable(createFactory: false)
class PasswordResetEmailRequestRM {
  const PasswordResetEmailRequestRM({
    required this.email,
  });

  @JsonKey(name: 'email')
  final String email;

  Map<String, dynamic> toJson() => _$PasswordResetEmailRequestRMToJson(this);
}
