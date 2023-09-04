class User {
  User({
    required this.displayName,
    required this.email,
    required this.userPhotoURL,
    required this.accessToken,
  });
  final String accessToken;
  final String email;
  final String displayName;
  final String userPhotoURL;
}
