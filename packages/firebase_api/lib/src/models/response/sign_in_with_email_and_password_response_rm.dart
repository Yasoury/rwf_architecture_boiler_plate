class SignInWithEmailAndPasswordResponseModel {
  String? localId;
  String? email;
  String? displayName;
  String? idToken;
  bool? registered;
  String? refreshToken;
  String? expiresIn;

  SignInWithEmailAndPasswordResponseModel({
    this.localId,
    this.email,
    this.displayName,
    this.idToken,
    this.registered,
    this.refreshToken,
    this.expiresIn,
  });

  factory SignInWithEmailAndPasswordResponseModel.fromJson(
      Map<String, dynamic> json) {
    return SignInWithEmailAndPasswordResponseModel(
      localId: json['localId'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      idToken: json['idToken'] as String?,
      registered: json['registered'] as bool?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'email': email,
        'displayName': displayName,
        'idToken': idToken,
        'registered': registered,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      };
}
