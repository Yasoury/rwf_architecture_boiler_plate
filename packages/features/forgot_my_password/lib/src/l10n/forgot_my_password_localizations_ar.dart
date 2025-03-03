import 'forgot_my_password_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class ForgotMyPasswordLocalizationsAr extends ForgotMyPasswordLocalizations {
  ForgotMyPasswordLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get dialogTitle => 'نسيت كلمة المرور';

  @override
  String get emailTextFieldLabel => 'البريد الإلكتروني';

  @override
  String get emailTextFieldEmptyErrorMessage => 'لا يمكن أن يكون بريدك الإلكتروني فارغًا.';

  @override
  String get emailTextFieldInvalidErrorMessage => 'هذا البريد الإلكتروني غير صالح.';

  @override
  String get emailRequestSuccessMessage => 'إذا كان هذا البريد الإلكتروني مسجلاً في أنظمتنا، سيتم إرسال رابط لك مع تعليمات حول كيفية إعادة تعيين كلمة المرور.';

  @override
  String get confirmButtonLabel => 'تأكيد';

  @override
  String get cancelButtonLabel => 'إلغاء';

  @override
  String get errorMessage => 'حدث خطأ. يرجى التحقق من اتصالك بالإنترنت.';
}
