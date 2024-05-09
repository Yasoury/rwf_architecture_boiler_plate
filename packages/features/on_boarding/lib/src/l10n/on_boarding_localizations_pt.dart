import 'on_boarding_localizations.dart';

/// The translations for Portuguese (`pt`).
class OnBoardingLocalizationsPt extends OnBoardingLocalizations {
  OnBoardingLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get skip => 'Skip';

  @override
  String get onBoardingTitle => 'Welcome to your favorite app';

  @override
  String get onBoardingTitleSubTitle => 'some day you will look at the soruce code and wonder, WHY the fuck I didn\'t use MVWhatever design pattren';

  @override
  String get next => 'Next';

  @override
  String get startNow => 'Start Now';
}
