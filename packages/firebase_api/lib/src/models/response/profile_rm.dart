import 'package:json_annotation/json_annotation.dart';

part 'profile_rm.g.dart';

@JsonSerializable(createToJson: false)
class ProfileRM {
  const ProfileRM({
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'displayName')
  final String displayName;

  @JsonKey(name: 'photoUrl')
  final String photoUrl;

  static const fromJson = _$UserRMFromJson;
}
