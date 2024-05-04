class SignUpWithEmailAndPasswordRequestModel {
  String? email;
  String? password;
  bool? returnSecureToken;

  SignUpWithEmailAndPasswordRequestModel(
      {this.email, this.password, this.returnSecureToken});

  factory SignUpWithEmailAndPasswordRequestModel.fromJson(
      Map<String, dynamic> json) {
    return SignUpWithEmailAndPasswordRequestModel(
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
