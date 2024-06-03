import 'package:formz/formz.dart';

/// Represents an optional password field.
///
/// Useful when the password can or can't be changed, such as in the update
/// profile screen.
class OptionalPassword
    extends FormzInput<String, OptionalPasswordValidationError> {
  const OptionalPassword.unvalidated([
    super.value = '',
  ]) : super.pure();

  const OptionalPassword.validated([
    super.value = '',
  ]) : super.dirty();

  @override
  OptionalPasswordValidationError? validator(String value) {
    return value.isEmpty
        ? null
        : (value.length >= 5 && value.length <= 120
            ? null
            : OptionalPasswordValidationError.invalid);
  }
}

enum OptionalPasswordValidationError {
  invalid,
}
