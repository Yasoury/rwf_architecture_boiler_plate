class SignInWithEmailAndPasswordRequestRM {
  String? email;
  String? password;
  bool? returnSecureToken;

  SignInWithEmailAndPasswordRequestRM(
      {this.email, this.password, this.returnSecureToken});

  factory SignInWithEmailAndPasswordRequestRM.fromJson(
      Map<String, dynamic> json) {
    return SignInWithEmailAndPasswordRequestRM(
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
