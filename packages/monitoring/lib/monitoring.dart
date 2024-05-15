import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

export 'src/dynamic_link_service.dart';
export 'src/analytics_service.dart';
export 'src/error_reporting_service.dart';
export 'src/explicit_crash.dart';
export 'src/remote_value_service.dart';

Future<void> initializeMonitoringPackage() =>
    Firebase.initializeApp().then((val) async {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    });
