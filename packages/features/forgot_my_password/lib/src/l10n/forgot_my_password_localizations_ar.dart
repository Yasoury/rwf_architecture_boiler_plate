import 'forgot_my_password_localizations.dart';

/// The translations for Arabic (`ar`).
class ForgotMyPasswordLocalizationsAr extends ForgotMyPasswordLocalizations {
  ForgotMyPasswordLocalizationsAr([super.locale = 'ar']);

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
