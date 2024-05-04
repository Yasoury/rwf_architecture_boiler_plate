class ChangePasswordRequestModel {
  String? idToken;
  String? password;
  bool? returnSecureToken;

  ChangePasswordRequestModel(
      {this.idToken, this.password, this.returnSecureToken});

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequestModel(
      idToken: json['idToken'] as String?,
      password: json['password'] as String?,
      returnSecureToken: json['returnSecureToken'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        'password': password,
        'returnSecureToken': returnSecureToken,
      };
}
