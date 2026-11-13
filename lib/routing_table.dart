import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:go_router/go_router.dart';
import 'package:on_boarding/on_boarding.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:splash/splash.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_preferences/user_preferences.dart';
import 'package:user_repository/user_repository.dart';
import 'app_redirect.dart';
import 'app_session.dart';
import 'tab_container_screen.dart';

/// Builds the app's router: the routing table guarded by [appRedirect].
GoRouter buildRouter({
  required UserRepository userRepository,
  required AppSession appSession,
  String initialLocation = AppRoutes.splash,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    // Re-runs the redirect once the session is ready, leaving the splash.
    refreshListenable: appSession,
    redirect: (context, state) => appRedirect(
      location: state.uri,
      isReady: appSession.isReady,
      isSignedIn: appSession.isSignedIn,
      hasPassedOnboarding: appSession.hasPassedOnboarding,
    ),
    // Unknown locations (e.g. a stale deep link) land on the home tab.
    onException: (context, state, router) => router.go(AppRoutes.homePath),
    routes: buildRoutes(
      userRepository: userRepository,
      appSession: appSession,
    ),
  );
}

List<RouteBase> buildRoutes({
  required UserRepository userRepository,
  required AppSession appSession,
  //TODOTip add the neassery Repository
}) {
  return [
    // Splash: shown while [AppSession] loads. The router's redirect moves on
    // from here, so the screen needs no navigation callbacks.
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding: the first-launch gate, also pushed from the settings tab.
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'on-boarding',
      builder: (context, state) => OnBoardingScreen(
        navigateToHome: () {
          unawaited(appSession.completeOnboarding());
          _popOrGo(
            context,
            continueLocationOf(state.uri) ?? AppRoutes.homePath,
          );
        },
      ),
    ),

    // Sign In
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
            // Signing up signs the user in, so this screen is done as well.
            final didSignUp = await context.push<bool>(AppRoutes.signUp);
            if (didSignUp == true && context.mounted) {
              onSignedIn();
            }
          },
          onForgotMyPasswordTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return ForgotMyPasswordDialog(
                  userRepository: userRepository,
                  onCancelTap: () {
                    Navigator.of(dialogContext).pop();
                  },
                  onEmailRequestSuccess: () {
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            );
          },
        );
      },
    ),

    // Sign Up
    GoRoute(
      path: AppRoutes.signUp,
      name: 'sign-up',
      builder: (context, state) => SignUpScreen(
        userRepository: userRepository,
        onSignUpSuccess: () {
          _popOrGo(context, AppRoutes.homePath, result: true);
        },
      ),
    ),

    // Update Profile
    GoRoute(
      path: AppRoutes.updateProfile,
      name: 'update-profile',
      builder: (context, state) => UpdateProfileScreen(
        userRepository: userRepository,
        onUpdateProfileSuccess: () {
          _popOrGo(context, AppRoutes.profileMenuPath);
        },
      ),
    ),

    // Tab Container with StatefulShellRoute (3 tabs: Home, Profile, Settings)
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return TabContainerScreen(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.homePath,
              name: 'home',
              builder: (context, state) => const Scaffold(
                body: Center(
                  child: Text('Home Screen'),
                ),
              ),
            ),
          ],
        ),

        // Profile branch
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.profileMenuPath,
              name: 'profile-menu',
              builder: (context, state) => ProfileMenuScreen(
                userRepository: userRepository,
                onSignInTap: () {
                  context.push(AppRoutes.signIn);
                },
                onSignUpTap: () {
                  context.push(AppRoutes.signUp);
                },
                onUpdateProfileTap: () {
                  context.push(AppRoutes.updateProfile);
                },
              ),
            ),
          ],
        ),

        // Settings branch
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: AppRoutes.userPreferencesPath,
              name: 'user-preferences',
              builder: (context, state) => UserPreferencesScreen(
                userRepository: userRepository,
                //TODOTips change later
                onUpdateProfileTap: () {
                  context.push(AppRoutes.updateProfile);
                },
                onShowOnBoardingClicked: () {
                  context.push(AppRoutes.onboarding);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}

/// Closes the current screen, or replaces it with [fallbackLocation] when it
/// is the only one on the stack (reached by a redirect or a deep link).
void _popOrGo(
  BuildContext context,
  String fallbackLocation, {
  Object? result,
}) {
  if (context.canPop()) {
    context.pop(result);
  } else {
    context.go(fallbackLocation);
  }
}

// Navigator keys for StatefulShellRoute branches
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Path constants for navigation
class AppRoutes {
  const AppRoutes._();

  // Root paths
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String updateProfile = '/update-profile';

  // Tab container base path
  static const String tabContainer = '/app';

  // Tab paths (3 tabs)
  static String get homePath => '$tabContainer/home';
  static String get profileMenuPath => '$tabContainer/profile';
  static String get userPreferencesPath => '$tabContainer/settings';
}
