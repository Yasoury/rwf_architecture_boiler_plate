// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'splash_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SplashLocalizationsEn extends SplashLocalizations {
  SplashLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get skip => 'Skip';

  @override
  String get onBoardingTitle => 'Welcome to your favorite app';

  @override
  String get onBoardingTitleSubTitle =>
      'some featres out of the Box: Scalable Architecture, Firebase Integration, Navigator 2, Hive DB, and more';

  @override
  String get next => 'Next';

  @override
  String get startNow => 'Start Now';
}
