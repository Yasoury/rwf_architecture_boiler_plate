import 'package:domain_models/domain_models.dart';
import 'package:firebase_api/firebase_api.dart';

extension ProfileRMToDomain on ProfileRM {
  Profile toDomainModel() {
    return Profile(
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
