# Localization (i18n)

## Per-Feature Localization

Each feature package manages its own translations independently.

**Required files per feature:**

```
packages/features/sign_in/
├── l10n.yaml                          # Generation config
└── lib/src/l10n/
    ├── messages_en.arb                # English translations
    ├── messages_ar.arb                # Arabic translations
    └── sign_in_localizations.dart     # Generated (DO NOT EDIT)
```

## l10n.yaml Configuration

```yaml
arb-dir: lib/src/l10n
template-arb-file: messages_en.arb
output-localization-file: sign_in_localizations.dart
output-class: SignInLocalizations
nullable-getter: false
synthetic-package: false    # REQUIRED for multi-package projects
```

## ARB File Format

```json
{
  "appBarTitle": "Sign In",
  "emailTextFieldLabel": "Email",
  "emailTextFieldEmptyErrorMessage": "Your email can't be empty.",
  "emailTextFieldInvalidErrorMessage": "This email is not valid.",
  "signInButtonLabel": "Sign In",
  "signedInUserGreeting": "Hi, {username}!",
  "@signedInUserGreeting": {
    "placeholders": {
      "username": {"type": "String"}
    }
  }
}
```

## Key Naming Rules

- Use camelCase starting with lowercase
- Name keys after WHERE they appear, not what they contain: `signInButtonLabel` (not `signIn`)
- Error messages follow pattern: `fieldNameErrorTypeMessage` (e.g., `emailTextFieldEmptyErrorMessage`)
- Same logical text used in different contexts SHOULD have separate keys (allows different translations)

## Usage in Views

```dart
@override
Widget build(BuildContext context) {
  final l10n = SignInLocalizations.of(context);

  return Scaffold(
    appBar: AppBar(title: Text(l10n.appBarTitle)),
    body: TextField(
      decoration: InputDecoration(labelText: l10n.emailTextFieldLabel),
    ),
  );
}
```

## Registering Delegates in Main App

Every feature's localization delegate must be registered in `MaterialApp`:

```dart
MaterialApp.router(
  supportedLocales: const [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ],
  localizationsDelegates: const [
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    AppLocalizations.delegate,
    ComponentLibraryLocalizations.delegate,
    SignInLocalizations.delegate,
    SignUpLocalizations.delegate,
    ProfileMenuLocalizations.delegate,
    QuoteListLocalizations.delegate,
    // ... all feature delegates
  ],
)
```

## Generation

Run `make gen-l10n` after modifying any ARB file. This generates Dart localization classes for all packages.
