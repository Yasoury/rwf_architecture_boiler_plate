import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'splash_localizations_ar.dart';
import 'splash_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SplashLocalizations
/// returned by `SplashLocalizations.of(context)`.
///
/// Applications need to include `SplashLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/splash_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SplashLocalizations.localizationsDelegates,
///   supportedLocales: SplashLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SplashLocalizations.supportedLocales
/// property.
abstract class SplashLocalizations {
  SplashLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SplashLocalizations of(BuildContext context) {
    return Localizations.of<SplashLocalizations>(context, SplashLocalizations)!;
  }

  static const LocalizationsDelegate<SplashLocalizations> delegate =
      _SplashLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onBoardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your favorite app'**
  String get onBoardingTitle;

  /// No description provided for @onBoardingTitleSubTitle.
  ///
  /// In en, this message translates to:
  /// **'some featres out of the Box: Scalable Architecture, Firebase Integration, Navigator 2, Hive DB, and more'**
  String get onBoardingTitleSubTitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;
}

class _SplashLocalizationsDelegate
    extends LocalizationsDelegate<SplashLocalizations> {
  const _SplashLocalizationsDelegate();

  @override
  Future<SplashLocalizations> load(Locale locale) {
    return SynchronousFuture<SplashLocalizations>(
        lookupSplashLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SplashLocalizationsDelegate old) => false;
}

SplashLocalizations lookupSplashLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SplashLocalizationsAr();
    case 'en':
      return SplashLocalizationsEn();
  }

  throw FlutterError(
      'SplashLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
