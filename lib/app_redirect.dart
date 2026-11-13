import 'routing_table.dart';

/// Query parameter carrying the location to continue to once a gate
/// (splash, onboarding, sign-in) has been passed.
const fromQueryParameter = 'from';

/// Locations that require a signed-in user. Everything else is open to guests.
const _signedInOnlyPaths = {AppRoutes.updateProfile};

/// The single place that decides whether [location] may be shown.
///
/// Returns the location to show instead, or null to let [location] through.
/// The rules are followed to the end here (splash → onboarding → requested
/// screen) because GoRouter runs its top-level redirect only once per
/// navigation.
String? appRedirect({
  required Uri location,
  required bool isReady,
  required bool isSignedIn,
  required bool hasPassedOnboarding,
}) {
  var current = location;
  // Each rule moves strictly forward, so this settles in a few steps; the
  // bound only guards against a future rule introducing a cycle.
  for (var step = 0; step < _maxRedirectSteps; step++) {
    final next = _redirectOnce(
      location: current,
      isReady: isReady,
      isSignedIn: isSignedIn,
      hasPassedOnboarding: hasPassedOnboarding,
    );
    if (next == null) {
      break;
    }
    current = Uri.parse(next);
  }
  return current == location ? null : current.toString();
}

const _maxRedirectSteps = 5;

String? _redirectOnce({
  required Uri location,
  required bool isReady,
  required bool isSignedIn,
  required bool hasPassedOnboarding,
}) {
  final path = location.path;

  if (!isReady) {
    return path == AppRoutes.splash
        ? null
        : _gate(AppRoutes.splash, continueTo: location);
  }

  if (path == AppRoutes.splash) {
    return continueLocationOf(location) ?? AppRoutes.homePath;
  }

  if (!hasPassedOnboarding) {
    if (path == AppRoutes.onboarding) {
      return null;
    }
    return path == AppRoutes.homePath
        ? AppRoutes.onboarding
        : _gate(AppRoutes.onboarding, continueTo: location);
  }

  if (!isSignedIn && _signedInOnlyPaths.contains(path)) {
    return _gate(AppRoutes.signIn, continueTo: location);
  }

  return null;
}

/// The location a gate screen at [location] should continue to, if it carries
/// a usable one.
String? continueLocationOf(Uri location) {
  final from = location.queryParameters[fromQueryParameter];
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  final fromPath = Uri.tryParse(from)?.path;
  if (fromPath == null || fromPath == AppRoutes.splash) {
    return null;
  }
  return from;
}

String _gate(String gatePath, {required Uri continueTo}) {
  return Uri(
    path: gatePath,
    queryParameters: {fromQueryParameter: continueTo.toString()},
  ).toString();
}
