# Firebase Monitoring (Analytics & Crashlytics)

## Package Structure

```
packages/monitoring/lib/
├── monitoring.dart                  # Public API + initialization
└── src/
    ├── analytics_service.dart       # Firebase Analytics wrapper
    ├── error_reporting_service.dart  # Firebase Crashlytics wrapper
    └── remote_value_service.dart    # Firebase Remote Config wrapper
```

## Initialization

```dart
// monitoring.dart
Future<void> initializeMonitoringPackage() =>
    Firebase.initializeApp().then((val) async {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    });
```

## Analytics Service

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> setCurrentScreen(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}
```

## Screen View Tracking via NavigatorObserver

The `ScreenViewObserver` extends `NavigatorObserver` (not a router-specific observer) and is passed to `GoRouter(observers: [...])`. Screen names come from `GoRoute(name: 'screen-name')` in the routing table. See the Routing & Navigation doc for the full implementation.

## Error Reporting (Crashlytics)

```dart
class ErrorReportingService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> recordFlutterError(FlutterErrorDetails details) {
    return _crashlytics.recordFlutterError(details);
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
  }) {
    return _crashlytics.recordError(exception, stack, fatal: fatal);
  }
}
```

## Three Error Capture Points in main.dart

```dart
void main() async {
  late final errorReportingService = ErrorReportingService();

  // 1. Zoned errors (catches async errors not caught elsewhere)
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeMonitoringPackage();

    // 2. Flutter framework errors (widget build errors, layout errors)
    FlutterError.onError = errorReportingService.recordFlutterError;

    // 3. Isolate errors (errors from other isolates)
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await errorReportingService.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    runApp(MyApp());
  }, (error, stack) => errorReportingService.recordError(error, stack, fatal: true));
}
```
