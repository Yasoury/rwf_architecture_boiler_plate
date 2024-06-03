import 'package:equatable/equatable.dart';
import 'package:form_fields/form_fields.dart';

class PasswordConfirmation
    extends FormzInput<String, PasswordConfirmationValidationError>
    with EquatableMixin {
  const PasswordConfirmation.unvalidated([
    super.value = '',
  ])  : password = const Password.unvalidated(),
        super.pure();

  const PasswordConfirmation.validated(
    super.value, {
    required this.password,
  }) : super.dirty();

  final Password password;

  @override
  PasswordConfirmationValidationError? validator(String value) {
    return value.isEmpty
        ? PasswordConfirmationValidationError.empty
        : (value == password.value
            ? null
            : PasswordConfirmationValidationError.invalid);
  }

  @override
  List<Object?> get props => [
        value,
        isPure,
        password,
      ];
}

enum PasswordConfirmationValidationError {
  empty,
  invalid,
}
