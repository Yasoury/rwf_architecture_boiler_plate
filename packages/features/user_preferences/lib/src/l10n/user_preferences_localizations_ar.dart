import 'user_preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class UserPreferencesLocalizationsAr extends UserPreferencesLocalizations {
  UserPreferencesLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get signInButtonLabel => 'تسجيل الدخول';

  @override
  String signedInUserGreeting(String username) {
    return 'مرحبًا، $username!';
  }

  @override
  String get updateProfileTileLabel => 'تحديث الملف الشخصي';

  @override
  String get darkModePreferencesHeaderTileLabel => 'تفضيلات الوضع الداكن';

  @override
  String get languageHeaderTileLabel => 'اللغة';

  @override
  String get darkModePreferencesAlwaysDarkTileLabel => 'دائمًا داكن';

  @override
  String get darkModePreferencesAlwaysLightTileLabel => 'دائمًا فاتح';

  @override
  String get darkModePreferencesUseSystemSettingsTileLabel => 'استخدام إعدادات النظام';

  @override
  String get signOutButtonLabel => 'تسجيل الخروج';

  @override
  String get signUpOpeningText => 'لا تملك حسابًا؟';

  @override
  String get signUpButtonLabel => 'إنشاء حساب';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get portuguese => 'البرتغالية';

  @override
  String get showOnbOarding => 'أظهر شاشة التقديم الاولي';
}
