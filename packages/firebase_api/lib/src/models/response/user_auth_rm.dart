import 'package:json_annotation/json_annotation.dart';

part 'user_rm.g.dart';

@JsonSerializable(createToJson: false)
class UserAuthRM {
  const UserAuthRM({
    required this.idToken,
    required this.refreshToken,
    required this.email,
    required this.registered,
  });

  @JsonKey(name: 'idToken')
  final String idToken;

  @JsonKey(name: 'refreshToken')
  final String refreshToken;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'registered')
  final bool registered;

  static const fromJson = _$UserRMFromJson;
}
