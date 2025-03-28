import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:monitoring/monitoring.dart';
import 'package:on_boarding/on_boarding.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:splash/splash.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_preferences/user_preferences.dart';
import 'package:user_repository/user_repository.dart';
import 'tab_container_screen.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
  required UserRepository userRepository,
  //TODOTip add the neassery Repository
}) {
  return {
    _PathConstants.tabContainerPath: (_) => CupertinoTabPage(
          child: const TabContainerScreen(),
          paths: [
            _PathConstants.homePath,
            _PathConstants.profileMenuPath,
            _PathConstants.userPreferencesPath,
          ],
        ),
    _PathConstants.onboardingPath: (_) => MaterialPage(
          name: 'on-boarding',
          child: OnBoardingScreen(
            navigateToHome: () {
              userRepository.upsertUserSettings(
                UserSettings(
                  passedOnBoarding: true,
                ),
              );
              routerDelegate.replace(_PathConstants.tabContainerPath);
            },
          ),
        ),
    _PathConstants.userPreferencesPath: (_) {
      return MaterialPage(
        name: 'user-preferences',
        child: UserPreferencesScreen(
          userRepository: userRepository,
          //TODOTips change later
          onUpdateProfileTap: () {
            routerDelegate.push(
              _PathConstants.updateProfilePath,
            );
          },
          onShowOnBoardingClicked: () {
            userRepository.upsertUserSettings(
              UserSettings(
                passedOnBoarding: false,
              ),
            );
            routerDelegate.push(_PathConstants.onboardingPath);
          },
        ),
      );
    },
    _PathConstants.profileMenuPath: (_) {
      return MaterialPage(
        name: 'profile-menu',
        child: ProfileMenuScreen(
          userRepository: userRepository,
          onSignInTap: () {
            routerDelegate.push(
              _PathConstants.signInPath,
            );
          },
          onSignUpTap: () {
            routerDelegate.push(
              _PathConstants.signUpPath,
            );
          },
          onUpdateProfileTap: () {
            routerDelegate.push(
              _PathConstants.updateProfilePath,
            );
          },
        ),
      );
    },
    _PathConstants.updateProfilePath: (_) => MaterialPage(
          name: 'update-profile',
          child: UpdateProfileScreen(
            userRepository: userRepository,
            onUpdateProfileSuccess: () {
              routerDelegate.pop();
            },
          ),
        ),
    _PathConstants.signInPath: (_) {
      return MaterialPage(
        name: 'sign-in',
        fullscreenDialog: true,
        child: Builder(
          builder: (context) {
            return SignInScreen(
              userRepository: userRepository,
              onSignInSuccess: () {
                routerDelegate.pop();
              },
              onSignUpTap: () {
                routerDelegate.push(_PathConstants.signUpPath);
              },
              onForgotMyPasswordTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ForgotMyPasswordDialog(
                          userRepository: userRepository,
                          onCancelTap: () {
                            routerDelegate.pop();
                          },
                          onEmailRequestSuccess: () {
                            routerDelegate.pop();
                          });
                    });
              },
            );
          },
        ),
      );
    },
    _PathConstants.signUpPath: (_) {
      return MaterialPage(
        name: 'sign-up',
        child: SignUpScreen(
          userRepository: userRepository,
          onSignUpSuccess: () {
            routerDelegate.pop();
          },
        ),
      );
    },
    _PathConstants.splashPath: (_) {
      return MaterialPage(
        name: 'Splash-Screen',
        child: SplashScreen(
          userRepository: userRepository,
          navigateToOnBarding: () {
            routerDelegate.replace(_PathConstants.onboardingPath);
          },
          navigateAuthIntro: () {
            routerDelegate.replace(_PathConstants.signInPath);
          },
          navigateToHomeScreen: () {
            routerDelegate.replace(_PathConstants.tabContainerPath);
          },
        ),
      );
    }
  };
}

class _PathConstants {
  const _PathConstants._();
  static String get splashPath => '/';
  static String get tabContainerPath => '${splashPath}root';
  static String get onboardingPath => '/onboardingPath';
  static String get userPreferencesPath =>
      '$tabContainerPath/user-preferencesPath';
  static String get homePath => '$tabContainerPath/home_screen';
  static String get profileMenuPath => '$tabContainerPath/user';
  static String get signInPath => '$tabContainerPath/sign-in';
  static String get signUpPath => '$tabContainerPath/sign-up';
  static String get updateProfilePath => '$profileMenuPath/update-profile';
}
