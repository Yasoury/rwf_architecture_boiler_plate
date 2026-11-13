import 'dart:async';

import 'package:domain_models/domain_models.dart';
import 'package:flutter/foundation.dart';
import 'package:user_repository/user_repository.dart';

/// App-level state the router's `redirect` depends on.
///
/// Notifies listeners only when [isReady] flips, which is the one change that
/// has to re-run the redirect for the location already on screen (leaving the
/// splash). [isSignedIn] and [hasPassedOnboarding] are kept current and read by
/// the redirect on every navigation, so they need no notification.
class AppSession extends ChangeNotifier {
  AppSession({
    required UserRepository userRepository,
    Duration minimumSplashDuration = const Duration(seconds: 2),
  }) : _userRepository = userRepository {
    _userSubscription = _userRepository.getUser().listen(
      (user) {
        _isSignedIn = user?.accessToken?.isNotEmpty ?? false;
        _isUserLoaded = true;
        _updateReadiness();
      },
      onError: (Object _) {
        // Unreadable credentials are treated as signed out.
        _isSignedIn = false;
        _isUserLoaded = true;
        _updateReadiness();
      },
    );

    _settingsSubscription = _userRepository.getUserSettings().listen(
      (settings) {
        _hasPassedOnboarding = settings.passedOnBoarding ?? false;
        _areSettingsLoaded = true;
        _updateReadiness();
      },
      onError: (Object _) {
        // Unreadable settings fall back to showing the onboarding again.
        _areSettingsLoaded = true;
        _updateReadiness();
      },
    );

    _minimumSplashTimer = Timer(minimumSplashDuration, () {
      _hasMinimumSplashElapsed = true;
      _updateReadiness();
    });
  }

  final UserRepository _userRepository;
  late final StreamSubscription<User?> _userSubscription;
  late final StreamSubscription<UserSettings> _settingsSubscription;
  late final Timer _minimumSplashTimer;

  bool _isUserLoaded = false;
  bool _areSettingsLoaded = false;
  bool _hasMinimumSplashElapsed = false;
  bool _isReady = false;
  bool _isSignedIn = false;
  bool _hasPassedOnboarding = false;

  /// Whether the startup data is loaded and the splash may be left.
  bool get isReady => _isReady;

  bool get isSignedIn => _isSignedIn;

  bool get hasPassedOnboarding => _hasPassedOnboarding;

  /// Marks the onboarding as seen. The flag flips synchronously so the caller
  /// can navigate right away; the returned future completes once it is stored.
  Future<void> completeOnboarding() {
    _hasPassedOnboarding = true;
    return _userRepository.upsertUserSettings(
      UserSettings(passedOnBoarding: true),
    );
  }

  void _updateReadiness() {
    final isReady =
        _isUserLoaded && _areSettingsLoaded && _hasMinimumSplashElapsed;
    if (isReady == _isReady) {
      return;
    }
    _isReady = isReady;
    notifyListeners();
  }

  @override
  void dispose() {
    _minimumSplashTimer.cancel();
    _userSubscription.cancel();
    _settingsSubscription.cancel();
    super.dispose();
  }
}
