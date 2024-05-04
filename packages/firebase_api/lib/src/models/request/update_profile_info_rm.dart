class UpdateProfileInfoRequestModel {
  String? idToken;
  String? displayName;
  String? photoUrl;
  List<String>? deleteAttribute;
  bool? returnSecureToken;

  UpdateProfileInfoRequestModel({
    this.idToken,
    this.displayName,
    this.photoUrl,
    this.deleteAttribute,
    this.returnSecureToken,
  });

  factory UpdateProfileInfoRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileInfoRequestModel(
      idToken: json['idToken'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      deleteAttribute: json['deleteAttribute'] as List<String>?,
      returnSecureToken: json['returnSecureToken'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'deleteAttribute': deleteAttribute,
        'returnSecureToken': returnSecureToken,
      };
}
