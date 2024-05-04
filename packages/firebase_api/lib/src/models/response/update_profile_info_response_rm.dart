class UpdateProfileInfoResponseModel {
  String? localId;
  String? email;
  String? displayName;
  String? photoUrl;
  String? passwordHash;
  List<ProviderUserInfo>? providerUserInfo;
  String? idToken;
  String? refreshToken;
  String? expiresIn;

  UpdateProfileInfoResponseModel({
    this.localId,
    this.email,
    this.displayName,
    this.photoUrl,
    this.passwordHash,
    this.providerUserInfo,
    this.idToken,
    this.refreshToken,
    this.expiresIn,
  });

  factory UpdateProfileInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileInfoResponseModel(
      localId: json['localId'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      passwordHash: json['passwordHash'] as String?,
      providerUserInfo: (json['providerUserInfo'] as List<dynamic>?)
          ?.map((e) => ProviderUserInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      idToken: json['idToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'passwordHash': passwordHash,
        'providerUserInfo': providerUserInfo?.map((e) => e.toJson()).toList(),
        'idToken': idToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      };
}

class ProviderUserInfo {
  String? providerId;
  String? federatedId;
  String? displayName;
  String? photoUrl;

  ProviderUserInfo({
    this.providerId,
    this.federatedId,
    this.displayName,
    this.photoUrl,
  });

  factory ProviderUserInfo.fromJson(Map<String, dynamic> json) {
    return ProviderUserInfo(
      providerId: json['providerId'] as String?,
      federatedId: json['federatedId'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'federatedId': federatedId,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };
}
