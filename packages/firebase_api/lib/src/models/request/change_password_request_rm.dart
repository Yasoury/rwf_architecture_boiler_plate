class ChangePasswordRequestRM {
  String? idToken;
  String? password;
  bool? returnSecureToken;

  ChangePasswordRequestRM(
      {this.idToken, this.password, this.returnSecureToken});

  factory ChangePasswordRequestRM.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequestRM(
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
