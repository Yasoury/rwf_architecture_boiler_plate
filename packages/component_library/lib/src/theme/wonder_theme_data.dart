import 'package:component_library/component_library.dart';
import 'package:component_library/src/theme/spacing.dart';
import 'package:flutter/material.dart';

const _dividerThemeData = DividerThemeData(
  space: 0,
);

// If the number of properties get too big, we can start grouping them in
// classes like Flutter does with TextTheme, ButtonTheme, etc, inside ThemeData.
abstract class WonderThemeData {
  ThemeData get materialThemeData;

  double screenMargin = Spacing.mediumLarge;

  double gridSpacing = Spacing.mediumLarge;

  Color get roundedChoiceChipBackgroundColor;

  Color get roundedChoiceChipSelectedBackgroundColor;

  Color get roundedChoiceChipLabelColor;

  Color get roundedChoiceChipSelectedLabelColor;

  Color get roundedChoiceChipAvatarColor;

  Color get roundedChoiceChipSelectedAvatarColor;

  Color get articleSvgColor;

  Color get unvotedButtonColor;

  Color get votedButtonColor;

  Color get primaryColor;

  Color get secondaryColor;

  Color get accentColor;

  Color get lightAccentColor;

  Color get lightTextColor;

  Color get surfaceColor;

  MaterialColor get accentColorAsMaterialColor;

  TextStyle get articleTextStyle => TextStyle(
        fontFamily: 'Fondamento',
        package: 'component_library',
        color: articleTextColor,
      );

  TextStyle get headlineTextStyle => TextStyle(
        fontWeight: FontWeight.bold,
        color: headlineTextColor,
      );

  TextStyle get bodyTextStyle => TextStyle(
        color: bodyTextColor,
      );

  TextStyle get captionTextStyle => TextStyle(
        color: captionTextColor,
      );

  Color get articleTextColor;
  Color get headlineTextColor;
  Color get bodyTextColor;
  Color get captionTextColor;
}

class LightWonderThemeData extends WonderThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.black.toMaterialColor(),
        dividerTheme: _dividerThemeData,
        useMaterial3: false,
      );

  @override
  Color get roundedChoiceChipBackgroundColor => Colors.white;

  @override
  Color get roundedChoiceChipLabelColor => Colors.black;

  @override
  Color get roundedChoiceChipSelectedBackgroundColor => Colors.black;

  @override
  Color get roundedChoiceChipSelectedLabelColor => Colors.white;

  @override
  Color get articleSvgColor => Colors.black;

  @override
  Color get roundedChoiceChipAvatarColor => Colors.black;

  @override
  Color get roundedChoiceChipSelectedAvatarColor => Colors.white;

  @override
  Color get unvotedButtonColor => Colors.black54;

  @override
  Color get votedButtonColor => Colors.black;

  @override
  Color get primaryColor => Colors.white;

  @override
  Color get secondaryColor => const Color(0xff535353);

  @override
  Color get accentColor => const Color(0xff6c63ff);

  @override
  Color get lightAccentColor => const Color(0xffF3F9ED);

  @override
  Color get lightTextColor => const Color(0xffBEBEBE);

  @override
  Color get surfaceColor => Colors.grey.shade100;

  @override
  MaterialColor get accentColorAsMaterialColor =>
      const Color(0xff6c63ff).toMaterialColor();

  @override
  Color get articleTextColor => Colors.black87;

  @override
  Color get headlineTextColor => Colors.black;

  @override
  Color get bodyTextColor => Colors.black87;

  @override
  Color get captionTextColor => Colors.grey.shade600;
}

class DarkWonderThemeData extends WonderThemeData {
  @override
  ThemeData get materialThemeData => ThemeData(
        brightness: Brightness.dark,
        toggleButtonsTheme: const ToggleButtonsThemeData(color: Colors.white),
        primarySwatch: Colors.white.toMaterialColor(),
        dividerTheme: _dividerThemeData,
        useMaterial3: false,
      );

  @override
  Color get roundedChoiceChipBackgroundColor => Colors.black;

  @override
  Color get roundedChoiceChipLabelColor => Colors.white;

  @override
  Color get roundedChoiceChipSelectedBackgroundColor => Colors.white;

  @override
  Color get roundedChoiceChipSelectedLabelColor => Colors.black;

  @override
  Color get articleSvgColor => Colors.white;

  @override
  Color get roundedChoiceChipAvatarColor => Colors.white;

  @override
  Color get roundedChoiceChipSelectedAvatarColor => Colors.black;

  @override
  Color get unvotedButtonColor => Colors.white54;

  @override
  Color get votedButtonColor => Colors.white;

  @override
  Color get primaryColor => Colors.white;

  @override
  Color get secondaryColor => const Color(0xff535353);

  @override
  Color get accentColor => const Color(0xff6c63ff);

  @override
  Color get lightAccentColor => const Color(0xffF3F9ED);

  @override
  Color get lightTextColor => const Color(0xffBEBEBE);

  @override
  Color get surfaceColor => Colors.grey.shade800;

  @override
  MaterialColor get accentColorAsMaterialColor =>
      const Color(0xff6c63ff).toMaterialColor();

  @override
  Color get articleTextColor => Colors.white38;

  @override
  Color get headlineTextColor => Colors.white;

  @override
  Color get bodyTextColor => Colors.white70;

  @override
  Color get captionTextColor => Colors.grey.shade400;
}

extension on Color {
  Map<int, Color> _toSwatch() => {
        50: withValues(alpha: 0.1),
        100: withValues(alpha: 0.2),
        200: withValues(alpha: 0.3),
        300: withValues(alpha: 0.4),
        400: withValues(alpha: 0.5),
        500: withValues(alpha: 0.6),
        600: withValues(alpha: 0.7),
        700: withValues(alpha: 0.8),
        800: withValues(alpha: 0.9),
        900: this,
      };

  MaterialColor toMaterialColor() => MaterialColor(
        toARGB32(),
        _toSwatch(),
      );
}
