# Theme System

## InheritedWidget-Based Theming

The theme system uses a custom `WonderTheme` InheritedWidget wrapping both light and dark theme data.

## WonderThemeData Abstract Class

```dart
abstract class WonderThemeData {
  ThemeData get materialThemeData;

  // Colors
  Color get primaryColor;
  Color get secondaryColor;
  Color get accentColor;
  Color get lightAccentColor;
  Color get lightTextColor;
  Color get quoteSvgColor;
  Color get roundedChoiceChipBackgroundColor;
  Color get roundedChoiceChipSelectedBackgroundColor;
  Color get roundedChoiceChipLabelColor;
  Color get roundedChoiceChipSelectedLabelColor;

  // Typography
  TextStyle quoteTextStyle = const TextStyle(
    fontFamily: 'Fondamento',
    package: 'component_library',
  );

  // Layout
  double get screenMargin;
  double get gridSpacing;
}
```

## Light and Dark Implementations

```dart
class LightWonderThemeData extends WonderThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.black.toMaterialColor(),
    useMaterial3: false,
  );

  @override
  Color get accentColor => const Color(0xff6c63ff);
  // ... light colors
}

class DarkWonderThemeData extends WonderThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.white.toMaterialColor(),
    useMaterial3: false,
  );

  @override
  Color get accentColor => const Color(0xffBB86FC);  // Lighter for dark backgrounds
  // ... dark colors
}
```

## WonderTheme InheritedWidget

```dart
class WonderTheme extends InheritedWidget {
  const WonderTheme({
    required super.child,
    required this.lightTheme,
    required this.darkTheme,
    super.key,
  });

  final WonderThemeData lightTheme;
  final WonderThemeData darkTheme;

  static WonderThemeData of(BuildContext context) {
    final inheritedTheme = context.dependOnInheritedWidgetOfExactType<WonderTheme>();
    assert(inheritedTheme != null, 'No WonderTheme found in context');

    final currentBrightness = Theme.of(context).brightness;
    return currentBrightness == Brightness.dark
        ? inheritedTheme!.darkTheme
        : inheritedTheme!.lightTheme;
  }

  @override
  bool updateShouldNotify(WonderTheme oldWidget) =>
      oldWidget.lightTheme != lightTheme || oldWidget.darkTheme != darkTheme;
}
```

## Theme Setup in Main App

```dart
WonderTheme(
  lightTheme: _lightTheme,
  darkTheme: _darkTheme,
  child: MaterialApp.router(
    theme: _lightTheme.materialThemeData,
    darkTheme: _darkTheme.materialThemeData,
    themeMode: darkModePreference?.toThemeMode(),
  ),
)
```

## Dark Mode Preference Persistence

```dart
enum DarkModePreference { useSystemSettings, alwaysLight, alwaysDark }

extension DarkModePreferenceToThemeMode on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings: return ThemeMode.system;
      case DarkModePreference.alwaysLight: return ThemeMode.light;
      case DarkModePreference.alwaysDark: return ThemeMode.dark;
    }
  }
}
```

User preference is persisted via `UserRepository.upsertDarkModePreference()` → Isar, and the main app listens via `StreamBuilder<DarkModePreference>`.

## Using Theme in Widgets

```dart
final theme = WonderTheme.of(context);
Container(
  color: theme.primaryColor,
  padding: EdgeInsets.all(theme.screenMargin),
  child: Text('Hello', style: theme.quoteTextStyle),
)
```

## Spacing & Typography Constants

```dart
class Spacing {
  static const double extraSmall = 4;
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double mediumLarge = 24;
  static const double extraLarge = 32;
  static const double xxLarge = 48;
}

class FontSize {
  static const double extraSmall = 10;
  static const double small = 12;
  static const double medium = 14;
  static const double large = 16;
  static const double extraLarge = 18;
  static const double xxLarge = 24;
}
```
