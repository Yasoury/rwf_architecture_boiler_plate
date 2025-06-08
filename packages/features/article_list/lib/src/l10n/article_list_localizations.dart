import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'article_list_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ArticleListLocalizations
/// returned by `ArticleListLocalizations.of(context)`.
///
/// Applications need to include `ArticleListLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/article_list_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ArticleListLocalizations.localizationsDelegates,
///   supportedLocales: ArticleListLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ArticleListLocalizations.supportedLocales
/// property.
abstract class ArticleListLocalizations {
  ArticleListLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ArticleListLocalizations of(BuildContext context) {
    return Localizations.of<ArticleListLocalizations>(context, ArticleListLocalizations)!;
  }

  static const LocalizationsDelegate<ArticleListLocalizations> delegate = _ArticleListLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @newsRefreshErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t refresh your items.\nPlease, check your internet connection and try again later.'**
  String get newsRefreshErrorMessage;

  /// No description provided for @technologyTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technologyTagLabel;

  /// No description provided for @businessTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessTagLabel;

  /// No description provided for @startupsTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Startups'**
  String get startupsTagLabel;

  /// No description provided for @scienceTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get scienceTagLabel;

  /// No description provided for @healthTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthTagLabel;

  /// No description provided for @politicsTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get politicsTagLabel;

  /// No description provided for @sportsTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sportsTagLabel;

  /// No description provided for @entertainmentTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainmentTagLabel;

  /// No description provided for @worldTagLabel.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get worldTagLabel;

  /// No description provided for @financeTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get financeTagLabel;

  /// No description provided for @cybersecurityTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Cybersecurity'**
  String get cybersecurityTagLabel;

  /// No description provided for @aiTagLabel.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiTagLabel;

  /// No description provided for @climateTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get climateTagLabel;

  /// No description provided for @automotiveTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get automotiveTagLabel;

  /// No description provided for @gamingTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gamingTagLabel;

  /// No description provided for @viewModeLabel.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewModeLabel;

  /// No description provided for @switchToListViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to list view'**
  String get switchToListViewTooltip;

  /// No description provided for @switchToGridViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to grid view'**
  String get switchToGridViewTooltip;
}

class _ArticleListLocalizationsDelegate extends LocalizationsDelegate<ArticleListLocalizations> {
  const _ArticleListLocalizationsDelegate();

  @override
  Future<ArticleListLocalizations> load(Locale locale) {
    return SynchronousFuture<ArticleListLocalizations>(lookupArticleListLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ArticleListLocalizationsDelegate old) => false;
}

ArticleListLocalizations lookupArticleListLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return ArticleListLocalizationsEn();
  }

  throw FlutterError(
    'ArticleListLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
