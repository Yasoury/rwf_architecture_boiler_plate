import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

List<Story> getStories(WonderThemeData theme) {
  return [
    Story(
      name: 'CircularProgressIndicator',
      description: 'Indecators',
      builder: (context) => const CircularProgressIndicator(),
    ),
    Story(
      name: 'InProgressTextButton',
      description: 'Indecators',
      builder: (context) => const InProgressTextButton(label: "upload"),
    ),
    Story(
      name: 'Simple Expanded Elevated Button',
      description: 'Buttons',
      builder: (context) => ExpandedElevatedButton(
        label: 'Press me',
        onTap: () {},
      ),
    ),
    Story(
      name: 'Expanded Elevated Button',
      description: 'Buttons',
      builder: (context) => ExpandedElevatedButton(
        label: context.knobs.text(
          label: 'label',
          initial: 'Press me',
        ),
        onTap: context.knobs.boolean(
          label: 'onTap',
          initial: true,
        )
            ? () {}
            : null,
        icon: Icon(
          context.knobs.options(
            label: 'icon',
            initial: Icons.home,
            options: const [
              Option(
                label: 'Login',
                value: Icons.login,
              ),
              Option(
                label: 'Refresh',
                value: Icons.refresh,
              ),
              Option(
                label: 'Logout',
                value: Icons.logout,
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}
