import 'dart:async';
import 'dart:isolate';

import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:firebase_api/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:on_boarding/on_boarding.dart';
import 'package:user_preferences/user_preferences.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:routemaster/routemaster.dart';
import 'package:rwf_architecture_boiler_plate/routing_table.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'l10n/app_localizations.dart';
import 'screen_view_observer.dart';

void main() async {
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    await initializeMonitoringPackage();

    //for A/B testing
    final remoteValueService = RemoteValueService();
    await remoteValueService.load();

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

    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

  late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(
      observers: [
        ScreenViewObserver(
          analyticsService: _analyticsService,
        )
      ],
      routesBuilder: (context) {
        return RouteMap(
          routes: buildRoutingTable(
            routerDelegate: _routerDelegate,
            userRepository: _userRepository,
            remoteValueService: widget.remoteValueService,
            dynamicLinkService: _dynamicLinkService,
          ),
        );
      });

  late StreamSubscription _incomingDynamicLinksSubscription;
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  void initState() {
    super.initState();

    _openInitialDynamicLinkIfAny();
    _initializeApp(); // Start initialization

    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
              _routerDelegate.push,
            );
  }

  Future<void> _initializeApp() async {
    // Wait for user settings to load
    await _userRepository.getUserSettings().first;
    FlutterNativeSplash.remove();
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      _routerDelegate.push(path);
    }
  }

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserSettings>(
        stream: _userRepository.getUserSettings(),
        builder: (context, userSettingsStream) {
          final darkModePreference =
              userSettingsStream.data?.darkModePreference;
          final userPassedOnBoarding =
              userSettingsStream.data?.passedOnBoarding ?? false;

          return WonderTheme(
            lightTheme: _lightTheme,
            darkTheme: _darkTheme,
            child: !userPassedOnBoarding
                ? MaterialApp(
                    theme: _lightTheme.materialThemeData,
                    darkTheme: _darkTheme.materialThemeData,
                    themeMode: darkModePreference?.toThemeMode(),
                    locale: Locale(userSettingsStream.data?.langugae ?? "en"),
                    supportedLocales: const [
                      Locale('en', 'US'),
                      Locale('ar', 'SA'),
                    ],
                    localizationsDelegates: const [
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      ComponentLibraryLocalizations.delegate,
                      OnBoardingLocalizations.delegate,
                    ],
                    home: Scaffold(
                      body: OnBoardingScreen(
                        navigateToHome: () {
                          _userRepository.upsertUserSettings(
                            UserSettings(
                              passedOnBoarding: true,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : MaterialApp.router(
                    title: 'RWF Architecture',
                    theme: _lightTheme.materialThemeData,
                    darkTheme: _darkTheme.materialThemeData,
                    themeMode: darkModePreference?.toThemeMode(),
                    locale: Locale(userSettingsStream.data?.langugae ?? "en"),
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
                    ],
                    routeInformationParser: const RoutemasterParser(),
                    routerDelegate: _routerDelegate,
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
