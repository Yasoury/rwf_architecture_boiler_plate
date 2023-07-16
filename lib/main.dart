import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:monitoring/monitoring.dart';
import 'package:routemaster/routemaster.dart';
import 'package:rwf_architecture_boiler_plate/routing_table.dart';

import 'screen_view_observer.dart';

void main() async {
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

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
  final _analyticsService = AnalyticsService();
  final _dynamicLinkService = DynamicLinkService();

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
          ),
        );
      });

  late StreamSubscription _incomingDynamicLinksSubscription;

  @override
  void initState() {
    super.initState();

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
    return MaterialApp.router(
      title: 'RWF Architecture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: _routerDelegate,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Welcome to the RWF arch"),
    );
  }
}
