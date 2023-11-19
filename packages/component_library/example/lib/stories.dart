import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

List<Story> getStories(WonderThemeData theme) {
  return [
    Story.simple(
      name: 'CircularProgressIndicator',
      section: 'Indecators',
      child: const CircularProgressIndicator(),
    ),
    Story.simple(
      name: 'InProgressTextButton',
      section: 'Indecators',
      child: const InProgressTextButton(label: "upload"),
    ),
    Story.simple(
      name: 'Simple Expanded Elevated Button',
      section: 'Buttons',
      child: ExpandedElevatedButton(
        label: 'Press me',
        onTap: () {},
      ),
    ),
    Story(
      name: 'Expanded Elevated Button',
      section: 'Buttons',
      builder: (_, k) => ExpandedElevatedButton(
        label: k.text(
          label: 'label',
          initial: 'Press me',
        ),
        onTap: k.boolean(
          label: 'onTap',
          initial: true,
        )
            ? () {}
            : null,
        icon: Icon(
          k.options(
            label: 'icon',
            initial: Icons.home,
            options: const [
              Option(
                'Login',
                Icons.login,
              ),
              Option(
                'Refresh',
                Icons.refresh,
              ),
              Option(
                'Logout',
                Icons.logout,
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}
