import 'package:domain_models/domain_models.dart';

class UserSettings extends Equatable {
  final String? langugae;
  final bool? passedOnBoarding;
  final DarkModePreference? darkModePreference;
  UserSettings({
    this.langugae,
    this.passedOnBoarding,
    this.darkModePreference,
  });

  @override
  List<Object?> get props => [
        langugae,
        passedOnBoarding,
        darkModePreference,
      ];
}
