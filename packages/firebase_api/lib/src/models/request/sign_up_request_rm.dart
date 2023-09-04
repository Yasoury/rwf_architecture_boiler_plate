class SignUpWithEmailAndPasswordRequestRM {
  String? email;
  String? password;
  bool? returnSecureToken;

  SignUpWithEmailAndPasswordRequestRM(
      {this.email, this.password, this.returnSecureToken});

  factory SignUpWithEmailAndPasswordRequestRM.fromJson(
      Map<String, dynamic> json) {
    return SignUpWithEmailAndPasswordRequestRM(
      email: json['email'] as String?,
      password: json['password'] as String?,
      returnSecureToken: json['returnSecureToken'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'returnSecureToken': returnSecureToken,
      };
}
