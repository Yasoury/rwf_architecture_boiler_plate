# Routing & Navigation (GoRouter)

The project uses **GoRouter** for declarative routing with Navigator 2.0. Feature packages NEVER import GoRouter — they use callbacks.

## Routing Table Architecture

`lib/routing_table.dart` holds two functions:

- `buildRoutes()` returns the `List<RouteBase>` and wires feature callbacks to navigation.
- `buildRouter()` wraps those routes in a `GoRouter` guarded by the redirect below. `main.dart` and the routing tests both use it.

```dart
GoRouter buildRouter({
  required UserRepository userRepository,
  required AppSession appSession,
  String initialLocation = AppRoutes.splash,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: appSession,
    redirect: (context, state) => appRedirect(
      location: state.uri,
      isReady: appSession.isReady,
      isSignedIn: appSession.isSignedIn,
      hasPassedOnboarding: appSession.hasPassedOnboarding,
    ),
    onException: (context, state, router) => router.go(AppRoutes.homePath),
    routes: buildRoutes(
      userRepository: userRepository,
      appSession: appSession,
    ),
  );
}
```

## Startup and Route Guards

Which screen may be shown is decided in one place, not by individual screens.

| Piece | File | Role |
|-------|------|------|
| `AppSession` | `lib/app_session.dart` | Loads the user and settings, enforces the minimum splash time, exposes `isReady`, `isSignedIn`, `hasPassedOnboarding`. Notifies only when `isReady` flips. |
| `appRedirect` | `lib/app_redirect.dart` | Pure function mapping a location + session state to the location to show instead (or null). |
| `SplashScreen` | `packages/features/splash` | Pure loading UI. No repository, no navigation callbacks. |

Rules applied by `appRedirect`, in order:

1. Not ready → splash. Any other requested location is parked in `?from=`.
2. Ready and on splash → the parked location, else home.
3. Onboarding not passed → onboarding (parking the requested location).
4. Guest on a path in `_signedInOnlyPaths` → sign-in (parking the requested location).

Auth is optional: guests can use every tab. To protect a route, add its path to `_signedInOnlyPaths`.

GoRouter runs the top-level redirect **once** per navigation, so `appRedirect` follows its own rules to the end instead of relying on GoRouter to chain them.

On a refresh GoRouter only re-checks the base location, not pushed routes. That is why `AppSession` notifies for readiness only and the other flags are read at navigation time.

## Finishing a Screen: `_popOrGo`

A screen can be reached by `push` (something is underneath) or by a redirect / deep link (it is the only route). Success callbacks must work in both cases, so they never call `context.pop()` directly:

```dart
GoRoute(
  path: AppRoutes.signIn,
  name: 'sign-in',
  builder: (context, state) {
    void onSignedIn() => _popOrGo(
          context,
          continueLocationOf(state.uri) ?? AppRoutes.homePath,
        );

    return SignInScreen(
      userRepository: userRepository,
      onSignInSuccess: onSignedIn,
      onSignUpTap: () async {
        // Signing up signs the user in, so sign-in is done as well.
        final didSignUp = await context.push<bool>(AppRoutes.signUp);
        if (didSignUp == true && context.mounted) {
          onSignedIn();
        }
      },
      // ...
    );
  },
),
```

`_popOrGo(context, fallback, {result})` pops when `context.canPop()`, otherwise does `context.go(fallback)`.

## Navigator Keys

```dart
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');
```

## AppRoutes Path Constants

```dart
class AppRoutes {
  const AppRoutes._();

  // Root paths (outside tabs)
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String updateProfile = '/update-profile';

  // Tab container base
  static const String tabContainer = '/app';

  // Tab branch paths
  static String get homePath => '$tabContainer/home';
  static String get profileMenuPath => '$tabContainer/profile';
  static String get userPreferencesPath => '$tabContainer/settings';

  // Parameterized routes (example)
  static String quoteDetailsPath(int id) => '$homePath/quote/$id';
}
```

## Navigation Rules

1. Only the main app package (`lib/`) imports `go_router`
2. Feature packages use `VoidCallback` or typed callbacks for navigation — NEVER GoRouter directly
3. Decide *whether* a screen may be shown in `appRedirect`, never inside a feature
4. Use `context.push()` for pushing on the navigation stack
5. Close a screen with `_popOrGo()`, not a bare `context.pop()` — the screen may be the only route
6. Do NOT wrap routes in `PopScope(canPop: false)`: on a root route it only stops Android back from leaving the app, on a pushed route it traps the user
7. Use `GoRoute(name: 'screen-name')` to enable analytics screen tracking
8. Tab navigation uses `StatefulShellRoute.indexedStack` with `StatefulShellBranch` per tab
9. For dialogs within routes, use `showDialog()` with `Navigator.of(dialogContext).pop()` (not GoRouter)

## Tab Container Screen

```dart
class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [/* tab items */],
      ),
    );
  }
}
```

## Router Setup in Main App

```dart
late final AppSession _appSession = AppSession(
  userRepository: _userRepository,
);

late final GoRouter _router = buildRouter(
  userRepository: _userRepository,
  appSession: _appSession,
);

// In initState()
_screenViewObserver = ScreenViewObserver(
  analyticsService: _analyticsService,
  router: _router,
);

// In build()
MaterialApp.router(
  routerConfig: _router,
)
```

Dispose `_screenViewObserver`, `_router` and `_appSession` in `dispose()`.

## Screen View Observer

`ScreenViewObserver` listens to the router delegate, not to a `Navigator`. A `NavigatorObserver` on the root navigator never sees tab switches or screens inside tab branches.

```dart
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

  void dispose() => _routerDelegate.removeListener(_onLocationChanged);
}
```

## Testing

- `test/app_redirect_test.dart` — the guard rules, as plain unit tests
- `test/app_session_test.dart` — readiness, storage failures, onboarding flag
- `test/routing_table_test.dart` — drives the real routing table end to end with a fake `UserRepository`
