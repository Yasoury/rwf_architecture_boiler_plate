import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class DialCode extends FormzInput<String, DialCodeValidationError>
    with EquatableMixin {
  const DialCode.unvalidated([
    super.value = '',
  ]) : super.pure();

  const DialCode.validated(super.value) : super.dirty();

  static final _dialCodeRegex = RegExp(r'^\+[0-9]{1,4}$');

  @override
  DialCodeValidationError? validator(String value) {
    return value.isEmpty
        ? DialCodeValidationError.empty
        : (_dialCodeRegex.hasMatch(value)
            ? null
            : DialCodeValidationError.invalid);
  }

  @override
  List<Object?> get props => [
        value,
        isPure,
      ];
}

enum DialCodeValidationError {
  empty,
  invalid,
}
