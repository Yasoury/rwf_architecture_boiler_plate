// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'update_profile_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class UpdateProfileLocalizationsAr extends UpdateProfileLocalizations {
  UpdateProfileLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appBarTitle => 'تحديث الملف الشخصي';

  @override
  String get updateProfileButtonLabel => 'تحديث';

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
  String get passwordTextFieldLabel => 'كلمة مرور جديدة';

  @override
  String get passwordTextFieldInvalidErrorMessage =>
      'يجب أن تكون كلمة المرور مكونة من خمسة أحرف على الأقل.';

  @override
  String get passwordConfirmationTextFieldLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordConfirmationTextFieldInvalidErrorMessage =>
      'كلمات المرور غير متطابقة.';
}
