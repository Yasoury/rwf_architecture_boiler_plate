import 'package:domain_models/domain_models.dart';
import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final String? language;
  final bool? passedOnBoarding;
  final DarkModePreference? darkModePreference;

  UserSettings({
    this.language,
    this.passedOnBoarding,
    this.darkModePreference,
  });

  UserSettings copyWith({
    String? language,
    bool? passedOnBoarding,
    DarkModePreference? darkModePreference,
  }) {
    return UserSettings(
      language: language ?? this.language,
      passedOnBoarding: passedOnBoarding ?? this.passedOnBoarding,
      darkModePreference: darkModePreference ?? this.darkModePreference,
    );
  }

  @override
  List<Object?> get props => [
        language,
        passedOnBoarding,
        darkModePreference,
      ];
  bool anyUserSettingsIsNull() {
    return props.toString().contains('null');
  }
}
