import 'sign_in_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SignInLocalizationsAr extends SignInLocalizations {
  SignInLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get invalidCredentialsErrorMessage => 'البريد الإلكتروني و/أو كلمة المرور غير صحيحة.';

  @override
  String get appBarTitle => 'تسجيل الدخول';

  @override
  String get emailTextFieldLabel => 'البريد الإلكتروني';

  @override
  String get emailTextFieldEmptyErrorMessage => 'لا يمكن أن يكون بريدك الإلكتروني فارغًا.';

  @override
  String get emailTextFieldInvalidErrorMessage => 'هذا البريد الإلكتروني غير صالح.';

  @override
  String get passwordTextFieldLabel => 'كلمة المرور';

  @override
  String get passwordTextFieldEmptyErrorMessage => 'لا يمكن أن تكون كلمة المرور فارغة.';

  @override
  String get passwordTextFieldInvalidErrorMessage => 'يجب أن تكون كلمة المرور مكونة من خمسة أحرف على الأقل.';

  @override
  String get forgotMyPasswordButtonLabel => 'نسيت كلمة المرور';

  @override
  String get signInButtonLabel => 'تسجيل الدخول';

  @override
  String get signUpOpeningText => 'لا تملك حسابًا؟';

  @override
  String get signUpButtonLabel => 'إنشاء حساب';
}
