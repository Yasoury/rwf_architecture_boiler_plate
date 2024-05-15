import 'on_boarding_localizations.dart';

/// The translations for English (`en`).
class OnBoardingLocalizationsEn extends OnBoardingLocalizations {
  OnBoardingLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get skip => 'Skip';

  @override
  String get onBoardingTitle => 'Welcome to your favorite app';

  @override
  String get onBoardingTitleSubTitle => 'some featres out of the Box: Scalable Architecture, Firebase Integration, Navigator 2, Hive DB, and more';

  @override
  String get next => 'Next';

  @override
  String get startNow => 'Start Now';
}
