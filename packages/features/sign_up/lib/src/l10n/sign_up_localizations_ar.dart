import 'sign_up_localizations.dart';

/// The translations for Arabic (`ar`).
class SignUpLocalizationsAr extends SignUpLocalizations {
  SignUpLocalizationsAr([super.locale = 'ar']);

  @override
  String get invalidCredentialsErrorMessage =>
      'البريد الإلكتروني و/أو كلمة المرور غير صحيحة.';

  @override
  String get appBarTitle => 'إنشاء حساب';

  @override
  String get signUpButtonLabel => 'إنشاء حساب';

  @override
  String get usernameTextFieldLabel => 'اسم المستخدم';

  @override
  String get usernameTextFieldEmptyErrorMessage =>
      'لا يمكن أن يكون اسم المستخدم فارغًا.';

  @override
  String get usernameTextFieldInvalidErrorMessage =>
      'يجب أن يكون اسم المستخدم بين 1-20 حرفًا ويمكن أن يحتوي فقط على أحرف وأرقام وشرطة سفلية (_).';

  @override
  String get usernameTextFieldAlreadyTakenErrorMessage =>
      'اسم المستخدم هذا مأخوذ بالفعل.';

  @override
  String get emailTextFieldLabel => 'البريد الإلكتروني';

  @override
  String get emailTextFieldEmptyErrorMessage =>
      'لا يمكن أن يكون بريدك الإلكتروني فارغًا.';

  @override
  String get emailTextFieldInvalidErrorMessage =>
      'هذا البريد الإلكتروني غير صالح.';

  @override
  String get emailTextFieldAlreadyRegisteredErrorMessage =>
      'هذا البريد الإلكتروني مسجل بالفعل.';

  @override
  String get passwordTextFieldLabel => 'كلمة المرور';

  @override
  String get passwordTextFieldEmptyErrorMessage =>
      'لا يمكن أن تكون كلمة المرور فارغة.';

  @override
  String get passwordTextFieldInvalidErrorMessage =>
      'يجب أن تكون كلمة المرور مكونة من خمسة أحرف على الأقل.';

  @override
  String get passwordConfirmationTextFieldLabel => 'تأكيد كلمة المرور';

  @override
  String get passwordConfirmationTextFieldEmptyErrorMessage =>
      'لا يمكن أن يكون فارغًا.';

  @override
  String get passwordConfirmationTextFieldInvalidErrorMessage =>
      'كلمات المرور غير متطابقة.';
}
