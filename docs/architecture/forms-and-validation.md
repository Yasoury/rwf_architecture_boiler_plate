# Form Validation with Formz

## FormzInput Field Pattern

Every form field extends `FormzInput` and has TWO constructors:

```dart
class Email extends FormzInput<String, EmailValidationError> {
  const Email.unvalidated([super.value = '']) : super.pure();   // No errors shown yet
  const Email.validated(super.value) : super.dirty();           // Errors are shown

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!_emailRegex.hasMatch(value)) return EmailValidationError.invalid;
    return null;  // Valid
  }
}

enum EmailValidationError { empty, invalid, alreadyRegistered }
```

## Form Cubit Methods

**Field change handler** — Only validate if the field was previously invalid:
```dart
void onEmailChanged(String newValue) {
  final previousEmail = state.email;
  final shouldValidate = previousEmail.isNotValid && !previousEmail.isPure;

  final newEmail = shouldValidate
      ? Email.validated(newValue)
      : Email.unvalidated(newValue);

  emit(state.copyWith(email: newEmail));
}
```

**Field unfocus handler** — Force validation when user leaves the field:
```dart
void onEmailUnfocused() {
  emit(state.copyWith(email: Email.validated(state.email.value)));
}
```

**Form submission** — Validate ALL fields, submit only if valid:
```dart
void onSubmit() async {
  final email = Email.validated(state.email.value);
  final password = Password.validated(state.password.value);
  final isFormValid = Formz.validate([email, password]);

  emit(state.copyWith(
    email: email,
    password: password,
    submissionStatus: isFormValid ? SubmissionStatus.inProgress : SubmissionStatus.idle,
  ));

  if (!isFormValid) return;

  try {
    await userRepository.signIn(email.value, password.value);
    emit(state.copyWith(submissionStatus: SubmissionStatus.success));
  } catch (error) {
    emit(state.copyWith(
      submissionStatus: error is InvalidCredentialsException
          ? SubmissionStatus.invalidCredentialsError
          : SubmissionStatus.genericError,
    ));
  }
}
```

## Form UI Integration

**FocusNode setup** — Wire unfocus events to Cubit:
```dart
final _emailFocusNode = FocusNode();

@override
void initState() {
  super.initState();
  final cubit = context.read<SignInCubit>();
  _emailFocusNode.addListener(() {
    if (!_emailFocusNode.hasFocus) {
      cubit.onEmailUnfocused();
    }
  });
}

@override
void dispose() {
  _emailFocusNode.dispose();
  super.dispose();
}
```

**TextField with error display:**
```dart
TextField(
  focusNode: _emailFocusNode,
  onChanged: cubit.onEmailChanged,
  decoration: InputDecoration(
    enabled: state.submissionStatus != SubmissionStatus.inProgress,
    labelText: l10n.emailLabel,
    errorText: state.email.isNotValid && !state.email.isPure
        ? _getEmailError(state.email.error, l10n)
        : null,
  ),
)
```

**Error text resolution:**
```dart
String? _getEmailError(EmailValidationError? error, SignInLocalizations l10n) {
  switch (error) {
    case EmailValidationError.empty:
      return l10n.emailEmptyErrorMessage;
    case EmailValidationError.invalid:
      return l10n.emailInvalidErrorMessage;
    default:
      return null;
  }
}
```
