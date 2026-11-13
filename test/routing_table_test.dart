import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:go_router/go_router.dart';
import 'package:monitoring/monitoring.dart';
import 'package:on_boarding/on_boarding.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:rwf_architecture_boiler_plate/app_session.dart';
import 'package:rwf_architecture_boiler_plate/l10n/app_localizations.dart';
import 'package:rwf_architecture_boiler_plate/routing_table.dart';
import 'package:rwf_architecture_boiler_plate/screen_view_observer.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:splash/splash.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_preferences/user_preferences.dart';

import 'helpers/fake_user_repository.dart';

const _minimumSplash = Duration(milliseconds: 100);

class _RecordingAnalyticsService implements AnalyticsService {
  final screenNames = <String>[];

  @override
  Future<void> setCurrentScreen(String screenName) async {
    screenNames.add(screenName);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _RecordingAnalyticsService analyticsService;
  late GoRouter router;

  /// Pumps the real routing table and waits for the splash to be left.
  Future<void> pumpApp(
    WidgetTester tester,
    FakeUserRepository userRepository, {
    String initialLocation = AppRoutes.splash,
  }) async {
    _withholdRiveAssets(tester);
    final appSession = AppSession(
      userRepository: userRepository,
      minimumSplashDuration: _minimumSplash,
    );
    router = buildRouter(
      userRepository: userRepository,
      appSession: appSession,
      initialLocation: initialLocation,
    );
    analyticsService = _RecordingAnalyticsService();
    final screenViewObserver = ScreenViewObserver(
      analyticsService: analyticsService,
      router: router,
    );
    addTearDown(() {
      screenViewObserver.dispose();
      router.dispose();
      appSession.dispose();
    });

    final lightTheme = LightWonderThemeData();
    final darkTheme = DarkWonderThemeData();
    await tester.pumpWidget(
      WonderTheme(
        lightTheme: lightTheme,
        darkTheme: darkTheme,
        child: MaterialApp.router(
          theme: lightTheme.materialThemeData,
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppLocalizations.delegate,
            ComponentLibraryLocalizations.delegate,
            ProfileMenuLocalizations.delegate,
            SignInLocalizations.delegate,
            ForgotMyPasswordLocalizations.delegate,
            SignUpLocalizations.delegate,
            UpdateProfileLocalizations.delegate,
            UserPreferencesLocalizations.delegate,
            OnBoardingLocalizations.delegate,
            SplashLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(_minimumSplash);
    await settle(tester);
    expect(find.byType(SplashScreen), findsNothing);
  }

  String location() => router.routerDelegate.currentConfiguration.uri.path;

  group('cold start', () {
    testWidgets('a first launch shows the onboarding, then home',
        (tester) async {
      final userRepository = FakeUserRepository(passedOnBoarding: false);
      await pumpApp(tester, userRepository);

      expect(find.byType(OnBoardingScreen), findsOneWidget);

      await tester.tap(find.text('Skip').first);
      await settle(tester);

      expect(location(), AppRoutes.homePath);
      expect(find.byType(OnBoardingScreen), findsNothing);
      expect(userRepository.upsertedSettings.single.passedOnBoarding, isTrue);
    });

    testWidgets('an onboarded guest lands on home, not on sign-in',
        (tester) async {
      await pumpApp(tester, FakeUserRepository());

      expect(location(), AppRoutes.homePath);
      expect(find.byType(SignInScreen), findsNothing);
    });

    testWidgets('an unknown location falls back to home', (tester) async {
      await pumpApp(
        tester,
        FakeUserRepository(),
        initialLocation: '/does-not-exist',
      );

      expect(location(), AppRoutes.homePath);
    });
  });

  group('sign-in opened from the profile tab', () {
    Future<void> openSignIn(WidgetTester tester) async {
      await pumpApp(tester, FakeUserRepository());
      await tester.tap(find.text('Profile'));
      await settle(tester);
      await tester.tap(find.widgetWithText(ExpandedElevatedButton, 'Sign In'));
      await settle(tester);
      expect(find.byType(SignInScreen), findsOneWidget);
    }

    testWidgets('can be left with the back button', (tester) async {
      await openSignIn(tester);

      await tester.tap(find.byType(BackButton));
      await settle(tester);

      expect(find.byType(SignInScreen), findsNothing);
      expect(find.byType(ProfileMenuScreen), findsOneWidget);
    });

    testWidgets('returns to the profile after signing in', (tester) async {
      await openSignIn(tester);

      await signIn(tester);

      expect(find.byType(SignInScreen), findsNothing);
      expect(find.byType(ProfileMenuScreen), findsOneWidget);
      expect(location(), AppRoutes.profileMenuPath);
    });

    testWidgets('signing up from it closes both auth screens', (tester) async {
      await openSignIn(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Sign up'));
      await settle(tester);
      expect(find.byType(SignUpScreen), findsOneWidget);

      final fields = find.descendant(
        of: find.byType(SignUpScreen),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'tester');
      await tester.enterText(fields.at(2), 'password');
      await tester.enterText(fields.at(3), 'password');
      final signUpButton = find.descendant(
        of: find.byType(SignUpScreen),
        matching: find.byType(ExpandedElevatedButton),
      );
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await settle(tester);

      expect(find.byType(SignUpScreen), findsNothing);
      expect(find.byType(SignInScreen), findsNothing);
      expect(find.byType(ProfileMenuScreen), findsOneWidget);
    });
  });

  testWidgets(
      'a guest deep-linked to a signed-in screen signs in, then continues',
      (tester) async {
    await pumpApp(
      tester,
      FakeUserRepository(),
      initialLocation: AppRoutes.updateProfile,
    );

    // Sign-in is the only screen on the stack: the case that used to throw
    // "There is nothing to pop".
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(router.canPop(), isFalse);

    await signIn(tester);

    expect(find.byType(SignInScreen), findsNothing);
    expect(find.byType(UpdateProfileScreen), findsOneWidget);
  });

  testWidgets('replaying the onboarding from settings returns to settings',
      (tester) async {
    final userRepository = FakeUserRepository();
    await pumpApp(tester, userRepository);
    await tester.tap(find.text('Settings'));
    await settle(tester);

    final showOnboarding = find.descendant(
      of: find.byType(UserPreferencesScreen),
      matching: find.byType(ExpandedElevatedButton),
    );
    await tester.ensureVisible(showOnboarding.last);
    await tester.tap(showOnboarding.last);
    await settle(tester);
    expect(find.byType(OnBoardingScreen), findsOneWidget);

    await tester.tap(find.text('Skip').first);
    await settle(tester);

    expect(find.byType(OnBoardingScreen), findsNothing);
    expect(location(), AppRoutes.userPreferencesPath);
    expect(
      userRepository.upsertedSettings.map((s) => s.passedOnBoarding),
      everyElement(isTrue),
      reason: 'the onboarding flag must never be reset to false',
    );
  });

  testWidgets('reports screens, including tab switches and returns',
      (tester) async {
    await pumpApp(tester, FakeUserRepository());
    await tester.tap(find.text('Profile'));
    await settle(tester);
    await tester.tap(find.widgetWithText(ExpandedElevatedButton, 'Sign In'));
    await settle(tester);
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    expect(
      analyticsService.screenNames,
      ['splash', 'home', 'profile-menu', 'sign-in', 'profile-menu'],
    );
  });
}

/// Rive needs a native library that isn't loaded under `flutter test`, so the
/// splash animation's file is left loading; every other asset is served as
/// usual.
void _withholdRiveAssets(WidgetTester tester) {
  final assetsDirectory = Platform.environment['UNIT_TEST_ASSETS'];

  tester.binding.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (message) {
      final key = Uri.decodeFull(
        utf8.decode(
          message!.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        ),
      );
      if (key.endsWith('.riv')) {
        return Completer<ByteData?>().future;
      }
      final asset = File('$assetsDirectory/$key');
      return Future.value(
        asset.existsSync()
            ? ByteData.sublistView(asset.readAsBytesSync())
            : null,
      );
    },
  );
}

/// Lets route transitions finish. `pumpAndSettle` can't be used because the
/// screens contain endless progress and Rive animations.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> signIn(WidgetTester tester) async {
  final fields = find.descendant(
    of: find.byType(SignInScreen),
    matching: find.byType(TextField),
  );
  await tester.enterText(fields.at(0), 'user@example.com');
  await tester.enterText(fields.at(1), 'password');
  await tester.tap(
    find.descendant(
      of: find.byType(SignInScreen),
      matching: find.byType(ExpandedElevatedButton),
    ),
  );
  await settle(tester);
}
