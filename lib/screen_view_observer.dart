import 'package:go_router/go_router.dart';
import 'package:monitoring/monitoring.dart';

/// Reports the visible screen to analytics whenever the router's location
/// changes.
///
/// It listens to the router itself rather than to a `Navigator`, so it also
/// sees tab switches and screens inside tab branches, which never reach the
/// root navigator's observers.
class ScreenViewObserver {
  ScreenViewObserver({
    required this.analyticsService,
    required GoRouter router,
  }) : _routerDelegate = router.routerDelegate {
    _routerDelegate.addListener(_onLocationChanged);
  }

  final AnalyticsService analyticsService;
  final GoRouterDelegate _routerDelegate;
  String? _lastScreenName;

  void _onLocationChanged() {
    final screenName =
        _routerDelegate.currentConfiguration.lastOrNull?.route.name;

    if (screenName == null || screenName == _lastScreenName) {
      return;
    }
    _lastScreenName = screenName;
    analyticsService.setCurrentScreen(screenName);
  }

  void dispose() {
    _routerDelegate.removeListener(_onLocationChanged);
  }
}
