part of 'user_preferences_screen.dart';

class LocalePicker extends StatelessWidget {
  final Locale currentLocale;
  const LocalePicker({
    required this.currentLocale,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = UserPreferencesLocalizations.of(context);
    final bloc = context.read<UserPreferencesBloc>();
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
      RadioGroup<Locale>(
        groupValue: currentLocale,
        onChanged: (newOption) {
          if (newOption != null) {
            bloc.add(
              UserPreferencesLocaleChanged(
                newOption,
              ),
            );
          }
        },
        child: Column(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              RadioListTile<Locale>(
                title: Text(
                  l10n.english,
                ),
                value: const Locale('en'),
              ),
              RadioListTile<Locale>(
                title: Text(
                  l10n.arabic,
                ),
                value: const Locale('ar'),
              ),
            ],
          ).toList(),
        ),
      ),
    ]);
  }
}
