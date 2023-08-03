import 'package:json_annotation/json_annotation.dart';

part 'user_info_rm.g.dart';

@JsonSerializable(createFactory: false)
class ProfileInfoRequestRM {
  const ProfileInfoRequestRM({
    required this.displayName,
    required this.photoUrl,
    required this.returnSecureToken,
    required this.idToken,
  });
//TODO make all the models genreateted from the firebase json
  @JsonKey(name: 'idToken')
  final String? idToken;

  @JsonKey(name: 'displayName')
  final String? displayName;

  @JsonKey(name: 'photoUrl')
  final String? photoUrl;

  @JsonKey(name: 'returnSecureToken')
  final bool returnSecureToken;

  Map<String, dynamic> toJson() => _$UserInfoRMToJson(this);
}
