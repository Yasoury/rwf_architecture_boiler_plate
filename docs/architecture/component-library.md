# Component Library & Storybook

## Component Library Structure

```
packages/component_library/
├── lib/
│   ├── component_library.dart    # Barrel file
│   └── src/
│       ├── theme/                # WonderTheme, WonderThemeData, Spacing, FontSize
│       ├── expanded_elevated_button.dart
│       ├── favorite_icon_button.dart
│       ├── upvote_icon_button.dart
│       ├── quote_card.dart
│       ├── exception_indicator.dart
│       ├── generic_error_snack_bar.dart
│       ├── rounded_choice_chip.dart
│       ├── custom_search_bar.dart
│       └── l10n/                 # Component-level localizations
│
└── example/                      # Storybook standalone app
    └── lib/
        ├── main.dart
        ├── story_app.dart
        └── stories.dart
```

## Storybook Setup

```dart
// example/lib/story_app.dart
class StoryApp extends StatelessWidget {
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  Widget build(BuildContext context) {
    return WonderTheme(
      lightTheme: _lightTheme,
      darkTheme: _darkTheme,
      child: ComponentStorybook(
        lightThemeData: _lightTheme.materialThemeData,
        darkThemeData: _darkTheme.materialThemeData,
      ),
    );
  }
}
```

## Story Definition Pattern

```dart
List<Story> getStories(WonderThemeData theme) {
  return [
    // Simple story (no configuration)
    Story.simple(
      name: 'CenteredCircularProgressIndicator',
      section: 'Indicators',
      child: const CenteredCircularProgressIndicator(),
    ),

    // Configurable story with knobs
    Story(
      name: 'ExpandedElevatedButton',
      section: 'Buttons',
      builder: (context) => ExpandedElevatedButton(
        label: context.knobs.text(label: 'label', initial: 'Press me'),
        onTap: context.knobs.boolean(label: 'enabled', initial: true) ? () {} : null,
        icon: Icon(context.knobs.options(
          label: 'icon',
          initial: Icons.search,
          options: [
            Option('Search', Icons.search),
            Option('Add', Icons.add),
          ],
        )),
      ),
    ),
  ];
}
```

## Component Rules

- Components are reusable UI building blocks shared across features
- Components live in `component_library`, NOT in feature packages
- Components should be theme-aware (use `WonderTheme.of(context)`)
- Components should support localization via `ComponentLibraryLocalizations`
- Every new component should have a corresponding story in the storybook
- Update the storybook whenever modifying a component
