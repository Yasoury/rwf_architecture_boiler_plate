class SignInWithEmailAndPasswordRequestModel {
  String? email;
  String? password;
  bool? returnSecureToken;

  SignInWithEmailAndPasswordRequestModel(
      {this.email, this.password, this.returnSecureToken});

  factory SignInWithEmailAndPasswordRequestModel.fromJson(
      Map<String, dynamic> json) {
    return SignInWithEmailAndPasswordRequestModel(
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
