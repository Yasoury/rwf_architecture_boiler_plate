class User {
  User({
    this.displayName,
    this.email,
    this.userPhotoURL,
    this.accessToken,
    this.userId,
  });

  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? userPhotoURL;
  final String? userId;
}
