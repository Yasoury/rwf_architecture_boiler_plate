# Routing & Navigation (GoRouter)

The project uses **GoRouter** for declarative routing with Navigator 2.0. Feature packages NEVER import GoRouter — they use callbacks.

## Routing Table Architecture

All routes are defined in a `buildRoutes()` function in `lib/routing_table.dart` that returns `List<RouteBase>`.

```dart
List<RouteBase> buildRoutes({
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  required UserRepository userRepository,
}) {
  return [
    // Top-level routes (outside tab container)
    GoRoute(
      path: AppRoutes.splash,
      name: 'Splash-Screen',
      builder: (context, state) => PopScope(
        canPop: false,
        child: SplashScreen(
          userRepository: userRepository,
          navigateToHomeScreen: () => context.go(AppRoutes.homePath),
          navigateToOnBarding: () => context.go(AppRoutes.onboarding),
          navigateAuthIntro: () => context.go(AppRoutes.signIn),
        ),
      ),
    ),

    GoRoute(
      path: AppRoutes.signIn,
      name: 'sign-in',
      builder: (context, state) => PopScope(
        canPop: false,
        child: Builder(
          builder: (context) => SignInScreen(
            userRepository: userRepository,
            onSignInSuccess: () => context.pop(),
            onSignUpTap: () => context.push(AppRoutes.signUp),
            onForgotMyPasswordTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => ForgotMyPasswordDialog(
                  userRepository: userRepository,
                  onCancelTap: () => Navigator.of(dialogContext).pop(),
                  onEmailRequestSuccess: () => Navigator.of(dialogContext).pop(),
                ),
              );
            },
          ),
        ),
      ),
    ),

    // Tab Container with StatefulShellRoute
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) => PopScope(
        canPop: false,
        child: TabContainerScreen(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.homePath,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.profileMenuPath,
              name: 'profile-menu',
              builder: (context, state) => ProfileMenuScreen(
                userRepository: userRepository,
                onSignInTap: () => context.push(AppRoutes.signIn),
                onUpdateProfileTap: () => context.push(AppRoutes.updateProfile),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.userPreferencesPath,
              name: 'user-preferences',
              builder: (context, state) => UserPreferencesScreen(
                userRepository: userRepository,
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}
```

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
3. Use `context.go()` for full replacement navigation (e.g., splash → home)
4. Use `context.push()` for pushing on the navigation stack
5. Use `context.pop()` to go back
6. Use `PopScope(canPop: false)` to prevent back navigation on root screens
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
late final GoRouter _router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  observers: [
    ScreenViewObserver(analyticsService: _analyticsService),
  ],
  routes: buildRoutes(
    userRepository: _userRepository,
    remoteValueService: widget.remoteValueService,
    dynamicLinkService: _dynamicLinkService,
  ),
);

// In build()
MaterialApp.router(
  routerConfig: _router,
)
```

## Screen View Observer (GoRouter-compatible)

```dart
class ScreenViewObserver extends NavigatorObserver {
  ScreenViewObserver({required this.analyticsService});
  final AnalyticsService analyticsService;

  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null) {
      analyticsService.setCurrentScreen(screenName);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) _sendScreenView(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
```
