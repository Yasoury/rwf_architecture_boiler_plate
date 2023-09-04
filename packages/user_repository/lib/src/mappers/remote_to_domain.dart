import 'package:domain_models/domain_models.dart';
import 'package:firebase_api/firebase_api.dart';

extension UserRMToDomain on SignInWithEmailAndPasswordResponseRm {
  User toDomainModel() {
    return User(
      accessToken: idToken!,
      displayName: displayName ?? "",
      email: email ?? "",
      userPhotoURL: "",
    );
  }
}
