import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_menu/src/profile_menu_bloc.dart';

import '../profile_menu.dart';

class LocalePicker extends StatelessWidget {
  final Locale currentLocale;
  const LocalePicker({
    required this.currentLocale,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ProfileMenuLocalizations.of(context);
    final bloc = context.read<ProfileMenuBloc>();
    return Column(children: [
      ListTile(
        title: Text(
          l10n.languageHeaderTileLabel,
          style: const TextStyle(
            fontSize: FontSize.mediumLarge,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      ...ListTile.divideTiles(
        context: context,
        tiles: [
          RadioListTile<Locale>(
            title: Text(
              l10n.english,
            ),
            value: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (newOption) {
              bloc.add(
                const ProfileMenuLocaleChanged(
                  Locale('en'),
                ),
              );
            },
          ),
          RadioListTile<Locale>(
            title: Text(
              l10n.arabic,
            ),
            value: const Locale('ar'),
            groupValue: currentLocale,
            onChanged: (newOption) {
              bloc.add(
                const ProfileMenuLocaleChanged(
                  Locale('ar'),
                ),
              );
            },
          ),
        ],
      )
    ]);
  }
}
