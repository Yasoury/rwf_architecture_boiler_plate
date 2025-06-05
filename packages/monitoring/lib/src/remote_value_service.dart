import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around [FirebaseRemoteConfig].
class RemoteValueService {
  static const _gridNewssViewEnabledKey = 'grid_quotes_view_enabled';

  RemoteValueService({
    @visibleForTesting FirebaseRemoteConfig? remoteConfig,
  }) : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  Future<void> load() async {
    await _remoteConfig.setDefaults(<String, dynamic>{
      'grid_quotes_view_enabled': true,
    });
    await _remoteConfig.fetchAndActivate();
  }

  bool get isGridNewssViewEnabled => _remoteConfig.getBool(
        _gridNewssViewEnabledKey,
      );
}
