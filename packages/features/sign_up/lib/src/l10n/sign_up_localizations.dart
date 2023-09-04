import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'sign_up_localizations_en.dart';
import 'sign_up_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of SignUpLocalizations returned
/// by `SignUpLocalizations.of(context)`.
///
/// Applications need to include `SignUpLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'l10n/sign_up_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SignUpLocalizations.localizationsDelegates,
///   supportedLocales: SignUpLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
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
/// be consistent with the languages listed in the SignUpLocalizations.supportedLocales
/// property.
abstract class SignUpLocalizations {
  SignUpLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SignUpLocalizations of(BuildContext context) {
    return Localizations.of<SignUpLocalizations>(context, SignUpLocalizations)!;
  }

  static const LocalizationsDelegate<SignUpLocalizations> delegate =
      _SignUpLocalizationsDelegate();

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
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @invalidCredentialsErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid email and/or password.'**
  String get invalidCredentialsErrorMessage;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get appBarTitle;

  /// No description provided for @signUpButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButtonLabel;

  /// No description provided for @usernameTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameTextFieldLabel;

  /// No description provided for @usernameTextFieldEmptyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your username can\'t be empty.'**
  String get usernameTextFieldEmptyErrorMessage;

  /// No description provided for @usernameTextFieldInvalidErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your username must be 1-20 characters long and can only contain letters, numbers, and the underscore (_).'**
  String get usernameTextFieldInvalidErrorMessage;

  /// No description provided for @usernameTextFieldAlreadyTakenErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken.'**
  String get usernameTextFieldAlreadyTakenErrorMessage;

  /// No description provided for @emailTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailTextFieldLabel;

  /// No description provided for @emailTextFieldEmptyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your email can\'t be empty.'**
  String get emailTextFieldEmptyErrorMessage;

  /// No description provided for @emailTextFieldInvalidErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'This email is not valid.'**
  String get emailTextFieldInvalidErrorMessage;

  /// No description provided for @emailTextFieldAlreadyRegisteredErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get emailTextFieldAlreadyRegisteredErrorMessage;

  /// No description provided for @passwordTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordTextFieldLabel;

  /// No description provided for @passwordTextFieldEmptyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password can\'t be empty.'**
  String get passwordTextFieldEmptyErrorMessage;

  /// No description provided for @passwordTextFieldInvalidErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least five characters long.'**
  String get passwordTextFieldInvalidErrorMessage;

  /// No description provided for @passwordConfirmationTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Password Confirmation'**
  String get passwordConfirmationTextFieldLabel;

  /// No description provided for @passwordConfirmationTextFieldEmptyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Can\'t be empty.'**
  String get passwordConfirmationTextFieldEmptyErrorMessage;

  /// No description provided for @passwordConfirmationTextFieldInvalidErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your passwords don\'t match.'**
  String get passwordConfirmationTextFieldInvalidErrorMessage;
}

class _SignUpLocalizationsDelegate
    extends LocalizationsDelegate<SignUpLocalizations> {
  const _SignUpLocalizationsDelegate();

  @override
  Future<SignUpLocalizations> load(Locale locale) {
    return SynchronousFuture<SignUpLocalizations>(
        lookupSignUpLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_SignUpLocalizationsDelegate old) => false;
}

SignUpLocalizations lookupSignUpLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SignUpLocalizationsEn();
    case 'pt':
      return SignUpLocalizationsPt();
  }

  throw FlutterError(
      'SignUpLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
