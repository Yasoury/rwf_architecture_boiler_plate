class ChangePasswordResponseRm {
  String? localId;
  String? email;
  String? passwordHash;
  List<ProviderUserInfo>? providerUserInfo;
  String? idToken;
  String? refreshToken;
  String? expiresIn;

  ChangePasswordResponseRm({
    this.localId,
    this.email,
    this.passwordHash,
    this.providerUserInfo,
    this.idToken,
    this.refreshToken,
    this.expiresIn,
  });

  factory ChangePasswordResponseRm.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseRm(
      localId: json['localId'] as String?,
      email: json['email'] as String?,
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

  ProviderUserInfo({this.providerId, this.federatedId});

  factory ProviderUserInfo.fromJson(Map<String, dynamic> json) {
    return ProviderUserInfo(
      providerId: json['providerId'] as String?,
      federatedId: json['federatedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'federatedId': federatedId,
      };
}
