import 'package:component_library/component_library.dart';
import 'package:component_library_storybook/stories.dart';
import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

class ComponentStorybook extends StatelessWidget {
  final ThemeData lightThemeData, darkThemeData;

  const ComponentStorybook({
    super.key,
    required this.lightThemeData,
    required this.darkThemeData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    return Storybook(
      initialLayout: Layout.compact,
      stories: [
        ...getStories(theme),
      ],
      initialStory: 'rounded-choice-chip',
    );
  }
}
