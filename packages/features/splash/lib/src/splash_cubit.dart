import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:user_repository/user_repository.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final Size screenSize;

  final UserRepository userRepository;

  SplashCubit({
    required this.screenSize,
    required this.userRepository,
  }) : super(SplashInProgress()) {
    initSplash();
  }

  void initSplash() {
    Future.delayed(const Duration(milliseconds: 300), () {
      emit(SplashLoaded(
          size: screenSize.width / 1.5,
          navigationStatus: NavigationStatus.idle));
    });
    _getCurrentVersionNo();
    navigateToHome();
  }

  Future<void> navigateToHome() async {
    var userModel = await userRepository.getUser().first;
    var userSettings = await userRepository.getUserSettings().first;

    Future.delayed(const Duration(seconds: kDebugMode ? 0 : 5), () {
      final bool isUserLoggedIn =
          userModel != null && userModel.accessToken.isNotEmpty;
      final bool hasPassedOnBoarding = userSettings.passedOnBoarding ?? false;

      NavigationStatus navigationStatus;

      if (!hasPassedOnBoarding) {
        // If user hasn't completed onboarding, always show onboarding first
        navigationStatus = NavigationStatus.navigateToOnBarding;
      } else if (!isUserLoggedIn) {
        // If user completed onboarding but not logged in, show auth
        navigationStatus = NavigationStatus.navigateAuthIntro;
      } else {
        // User is logged in and completed onboarding, go to home
        navigationStatus = NavigationStatus.navigateToHomeScreen;
      }

      emit(SplashLoaded(
        size: state is SplashLoaded
            ? (state as SplashLoaded).size
            : screenSize.width / 1.5,
        version: state is SplashLoaded ? (state as SplashLoaded).version : null,
        navigationStatus: navigationStatus,
      ));
    });
  }

  void _getCurrentVersionNo() {
    PackageInfo.fromPlatform().then((packageInfo) {
      emit(SplashLoaded(
        size: state is SplashLoaded ? (state as SplashLoaded).size : null,
        version: packageInfo.version,
        navigationStatus: NavigationStatus.idle,
      ));
    });
  }
}
