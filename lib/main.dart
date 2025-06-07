import 'dart:async';
import 'dart:isolate';

import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';

import 'package:flutter/material.dart';

import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:news_api/news_api.dart';
import 'package:news_repository/news_repository.dart';

import 'package:routemaster/routemaster.dart';
import 'package:rwf_architecture_boiler_plate/routing_table.dart';

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

  late final NewsApi _newsApi = NewsApi();

  late final NewsRepository _newsRepository = NewsRepository(
    keyValueStorage: _keyValueStorage,
    remoteApi: _newsApi,
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
            remoteValueService: widget.remoteValueService,
            dynamicLinkService: _dynamicLinkService,
            newsRepository: _newsRepository,
          ),
        );
      });

  late StreamSubscription _incomingDynamicLinksSubscription;
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();

    _openInitialDynamicLinkIfAny();

    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
              _routerDelegate.push,
            );
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
    return WonderTheme(
      lightTheme: _lightTheme,
      darkTheme: _darkTheme,
      child: MaterialApp.router(
        title: 'RWF Architecture',
        theme: _lightTheme.materialThemeData,
        darkTheme: _darkTheme.materialThemeData,
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
        ],
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: _routerDelegate,
      ),
    );
  }
}
