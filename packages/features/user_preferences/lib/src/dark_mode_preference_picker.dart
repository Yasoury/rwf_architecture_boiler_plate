part of 'user_preferences_screen.dart';

class DarkModePreferencePicker extends StatelessWidget {
  const DarkModePreferencePicker({
    required this.currentValue,
    super.key,
  });

  final DarkModePreference currentValue;

  @override
  Widget build(BuildContext context) {
    final l10n = UserPreferencesLocalizations.of(context);
    final bloc = context.read<UserPreferencesBloc>();
    return Column(
      children: [
        ListTile(
          title: Text(
            l10n.darkModePreferencesHeaderTileLabel,
            style: const TextStyle(
              fontSize: FontSize.mediumLarge,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        RadioGroup<DarkModePreference>(
          groupValue: currentValue,
          onChanged: (newOption) {
            if (newOption != null) {
              bloc.add(
                UserPreferencesDarkModePreferenceChanged(
                  newOption,
                ),
              );
            }
          },
          child: Column(
            children: ListTile.divideTiles(
              tiles: [
                RadioListTile<DarkModePreference>(
                  title: Text(
                    l10n.darkModePreferencesAlwaysDarkTileLabel,
                  ),
                  value: DarkModePreference.alwaysDark,
                ),
                RadioListTile<DarkModePreference>(
                  title: Text(
                    l10n.darkModePreferencesAlwaysLightTileLabel,
                  ),
                  value: DarkModePreference.alwaysLight,
                ),
                RadioListTile<DarkModePreference>(
                  title: Text(
                    l10n.darkModePreferencesUseSystemSettingsTileLabel,
                  ),
                  value: DarkModePreference.useSystemSettings,
                ),
              ],
              context: context,
            ).toList(),
          ),
        ),
      ],
    );
  }
}
