import 'dart:async';
import 'dart:isolate';

import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:firebase_api/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:go_router/go_router.dart';
import 'package:rwf_architecture_boiler_plate/app_session.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:on_boarding/on_boarding.dart';
import 'package:user_preferences/user_preferences.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:rwf_architecture_boiler_plate/routing_table.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'l10n/app_localizations.dart';
import 'screen_view_observer.dart';
import 'package:splash/splash.dart';

void main() async {
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // Keeps the native splash up until the first Flutter frame is worth
    // showing; removed in [_MyAppState].
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    await initializeMonitoringPackage();

    //for A/B testing
    final remoteValueService = RemoteValueService();

    await Future.wait([
      remoteValueService.load(),
      KeyValueStorage().initIsarDB(),
    ]);

    FlutterError.onError = errorReportingService.recordFlutterError;

    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        await errorReportingService.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
        );
      }).sendPort,
    );

    runApp(
      MyApp(
        remoteValueService: remoteValueService,
      ),
    );
  },
      (error, stack) => errorReportingService.recordError(
            error,
            stack,
            fatal: true,
          ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.remoteValueService,
  });
  final RemoteValueService remoteValueService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _keyValueStorage = KeyValueStorage();

  final _analyticsService = AnalyticsService();
  final _dynamicLinkService = DynamicLinkService();

  late final FirebaseApi _firebaseApi = FirebaseApi(
    userTokenSupplier: () => _userRepository.getUserToken(),
  );

  late final UserRepository _userRepository = UserRepository(
    remoteApi: _firebaseApi,
    noSqlStorage: _keyValueStorage,
  );

  late final AppSession _appSession = AppSession(
    userRepository: _userRepository,
  );

  late final GoRouter _router = buildRouter(
    userRepository: _userRepository,
    appSession: _appSession,
  );

  late final ScreenViewObserver _screenViewObserver;

  late final Stream<UserSettings> _userSettingsStream =
      _userRepository.getUserSettings();

  late StreamSubscription _incomingDynamicLinksSubscription;
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  void initState() {
    super.initState();

    _screenViewObserver = ScreenViewObserver(
      analyticsService: _analyticsService,
      router: _router,
    );

    _removeNativeSplashOnceSettingsLoad();

    _openInitialDynamicLinkIfAny();

    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
              _openDynamicLink,
            );
  }

  /// Holds the native splash until the stored locale and theme are known, so
  /// the first Flutter frame doesn't flash the defaults.
  Future<void> _removeNativeSplashOnceSettingsLoad() async {
    try {
      await _userRepository.getUserSettings().first;
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null && mounted) {
      _openDynamicLink(path);
    }
  }

  void _openDynamicLink(String path) {
    if (_appSession.isReady) {
      _router.push(path);
    } else {
      // Still on the splash: `go` lets the redirect park the link and resume
      // it once startup finishes, instead of stacking it on the splash.
      _router.go(path);
    }
  }

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    _screenViewObserver.dispose();
    _router.dispose();
    _appSession.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserSettings>(
        stream: _userSettingsStream,
        builder: (context, userSettingsStream) {
          final darkModePreference =
              userSettingsStream.data?.darkModePreference;

          return WonderTheme(
            lightTheme: _lightTheme,
            darkTheme: _darkTheme,
            child: MaterialApp.router(
              title: 'RWF Architecture',
              theme: _lightTheme.materialThemeData,
              darkTheme: _darkTheme.materialThemeData,
              themeMode: darkModePreference?.toThemeMode(),
              locale: Locale(userSettingsStream.data?.language ?? "en"),
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('ar', 'SA'),
              ],
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
              routerConfig: _router,
            ),
          );
        });
  }
}

extension on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings:
        return ThemeMode.system;
      case DarkModePreference.alwaysLight:
        return ThemeMode.light;
      case DarkModePreference.alwaysDark:
        return ThemeMode.dark;
    }
  }
}
