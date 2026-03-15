import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:go_router/go_router.dart';
import 'package:monitoring/monitoring.dart';
import 'package:on_boarding/on_boarding.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:splash/splash.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_preferences/user_preferences.dart';
import 'package:user_repository/user_repository.dart';
import 'tab_container_screen.dart';

List<RouteBase> buildRoutes({
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  required UserRepository userRepository,
  //TODOTip add the neassery Repository
}) {
  return [
    // Splash screen (root)
    GoRoute(
      path: AppRoutes.splash,
      name: 'Splash-Screen',
      builder: (context, state) => PopScope(
        canPop: false,
        child: SplashScreen(
          userRepository: userRepository,
          navigateToOnBarding: () {
            context.go(AppRoutes.onboarding);
          },
          navigateAuthIntro: () {
            context.go(AppRoutes.signIn);
          },
          navigateToHomeScreen: () {
            context.go(AppRoutes.homePath);
          },
        ),
      ),
    ),

    // Onboarding
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'on-boarding',
      builder: (context, state) => PopScope(
        canPop: false,
        child: OnBoardingScreen(
          navigateToHome: () {
            userRepository.upsertUserSettings(
              UserSettings(
                passedOnBoarding: true,
              ),
            );
            context.go(AppRoutes.homePath);
          },
        ),
      ),
    ),

    // Sign In
    GoRoute(
      path: AppRoutes.signIn,
      name: 'sign-in',
      builder: (context, state) => PopScope(
        canPop: false,
        child: Builder(
          builder: (context) {
            return SignInScreen(
              userRepository: userRepository,
              onSignInSuccess: () {
                context.pop();
              },
              onSignUpTap: () {
                context.push(AppRoutes.signUp);
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
      ),
    ),

    // Sign Up
    GoRoute(
      path: AppRoutes.signUp,
      name: 'sign-up',
      builder: (context, state) => SignUpScreen(
        userRepository: userRepository,
        onSignUpSuccess: () {
          context.pop();
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
          context.pop();
        },
      ),
    ),

    // Tab Container with StatefulShellRoute (3 tabs: Home, Profile, Settings)
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return PopScope(
          canPop: false,
          child: TabContainerScreen(navigationShell: navigationShell),
        );
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
                  userRepository.upsertUserSettings(
                    UserSettings(
                      passedOnBoarding: false,
                    ),
                  );
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
