class SignupWithEmailAndPasswordResponseModel {
  String? idToken;
  String? email;
  String? refreshToken;
  String? expiresIn;
  String? localId;

  SignupWithEmailAndPasswordResponseModel({
    this.idToken,
    this.email,
    this.refreshToken,
    this.expiresIn,
    this.localId,
  });

  factory SignupWithEmailAndPasswordResponseModel.fromJson(
      Map<String, dynamic> json) {
    return SignupWithEmailAndPasswordResponseModel(
      idToken: json['idToken'] as String?,
      email: json['email'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as String?,
      localId: json['localId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        'email': email,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
        'localId': localId,
      };
}
