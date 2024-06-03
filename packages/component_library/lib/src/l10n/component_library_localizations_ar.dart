import 'component_library_localizations.dart';

/// The translations for Arabic (`ar`).
class ComponentLibraryLocalizationsAr extends ComponentLibraryLocalizations {
  ComponentLibraryLocalizationsAr([super.locale = 'ar']);

  @override
  String get downvoteIconButtonTooltip => 'عدم الإعجاب';

  @override
  String get upvoteIconButtonTooltip => 'الإعجاب';

  @override
  String get searchBarHintText => 'رحلة';

  @override
  String get searchBarLabelText => 'بحث';

  @override
  String get shareIconButtonTooltip => 'مشاركة';

  @override
  String get favoriteIconButtonTooltip => 'المفضلة';

  @override
  String get exceptionIndicatorGenericTitle => 'حدث خطأ ما';

  @override
  String get exceptionIndicatorTryAgainButton => 'حاول مرة أخرى';

  @override
  String get exceptionIndicatorGenericMessage =>
      'حدث خطأ.\nيرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى لاحقًا.';

  @override
  String get genericErrorSnackbarMessage =>
      'حدث خطأ. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get authenticationRequiredErrorSnackbarMessage =>
      'تحتاج إلى تسجيل الدخول قبل القيام بهذا الإجراء.';
}
