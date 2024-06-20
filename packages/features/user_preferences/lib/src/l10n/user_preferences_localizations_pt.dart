import 'user_preferences_localizations.dart';

/// The translations for Portuguese (`pt`).
class UserPreferencesLocalizationsPt extends UserPreferencesLocalizations {
  UserPreferencesLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get signInButtonLabel => 'Entrar';

  @override
  String signedInUserGreeting(String username) {
    return 'Olá, $username!';
  }

  @override
  String get updateProfileTileLabel => 'Atualizar Perfil';

  @override
  String get darkModePreferencesHeaderTileLabel => 'Configurações de Modo Noturno';

  @override
  String get languageHeaderTileLabel => 'Linguagem';

  @override
  String get darkModePreferencesAlwaysDarkTileLabel => 'Sempre Escuro';

  @override
  String get darkModePreferencesAlwaysLightTileLabel => 'Sempre Claro';

  @override
  String get darkModePreferencesUseSystemSettingsTileLabel => 'De Acordo com o Sistema';

  @override
  String get signOutButtonLabel => 'Sair';

  @override
  String get signUpOpeningText => 'Não tem uma conta?';

  @override
  String get signUpButtonLabel => 'Cadastrar';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get showOnbOarding => 'Show On Boarding Screen';
}
