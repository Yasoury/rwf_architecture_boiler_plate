import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class MobileNumber extends FormzInput<String, MobileNumberValidationError>
    with EquatableMixin {
  const MobileNumber.unvalidated([
    super.value = '',
  ])  : isAlreadyRegistered = false,
        super.pure();

  const MobileNumber.validated(
    super.value, {
    this.isAlreadyRegistered = false,
  }) : super.dirty();

  final bool isAlreadyRegistered;

  // Regex for phone number validation - this should be adjusted based on your specific requirements
  static final _mobileNumberRegex = RegExp(r'^[0-9]{9,10}$');

  @override
  MobileNumberValidationError? validator(String value) {
    return value.isEmpty
        ? MobileNumberValidationError.empty
        : (isAlreadyRegistered
            ? MobileNumberValidationError.alreadyRegistered
            : (_mobileNumberRegex.hasMatch(value)
                ? null
                : MobileNumberValidationError.invalid));
  }

  @override
  List<Object?> get props => [
        value,
        isPure,
        isAlreadyRegistered,
      ];
}

enum MobileNumberValidationError {
  empty,
  invalid,
  alreadyRegistered,
}
