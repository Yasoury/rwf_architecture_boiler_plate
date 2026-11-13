import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around [FirebaseRemoteConfig].
class RemoteValueService {
  static const _gridQuotesViewEnabledKey = 'grid_quotes_view_enabled';

  RemoteValueService({
    @visibleForTesting FirebaseRemoteConfig? remoteConfig,
  }) : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  /// Never throws for a failed or slow fetch: startup awaits this, and the
  /// defaults (or the last activated values) are good enough to run with.
  Future<void> load({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    await _remoteConfig.setDefaults(<String, dynamic>{
      'grid_quotes_view_enabled': true,
    });
    try {
      await _remoteConfig.fetchAndActivate().timeout(timeout);
    } catch (_) {
      // Offline, throttled or timed out.
    }
  }

  bool get isGridQuotesViewEnabled => _remoteConfig.getBool(
        _gridQuotesViewEnabledKey,
      );
}
