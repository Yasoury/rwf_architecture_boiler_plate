// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'on_boarding_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class OnBoardingLocalizationsAr extends OnBoardingLocalizations {
  OnBoardingLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get skip => 'تخطي';

  @override
  String get onBoardingTitle => 'مرحبا بك معنا ';

  @override
  String get onBoardingTitleSubTitle =>
      'أتمنى لك الاستمتاع في بناء نطبيق بجودة عالية ';

  @override
  String get next => 'التالي';

  @override
  String get startNow => 'بدء الان';
}
