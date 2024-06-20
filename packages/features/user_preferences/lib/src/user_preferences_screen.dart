import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_preferences/user_preferences.dart';
import 'package:user_preferences/src/user_preferences_bloc.dart';
import 'package:user_repository/user_repository.dart';

part './dark_mode_preference_picker.dart';
part './locale_picker.dart';

class UserPreferencesScreen extends StatelessWidget {
  const UserPreferencesScreen({
    required this.userRepository,
    this.onUpdateProfileTap,
    super.key,
  });

  final VoidCallback? onUpdateProfileTap;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserPreferencesBloc>(
      create: (_) => UserPreferencesBloc(
        userRepository: userRepository,
      ),
      child: UserPreferencesView(
        onUpdateProfileTap: onUpdateProfileTap,
      ),
    );
  }
}

@visibleForTesting
class UserPreferencesView extends StatelessWidget {
  const UserPreferencesView({
    this.onUpdateProfileTap,
    super.key,
  });

  final VoidCallback? onUpdateProfileTap;

  @override
  Widget build(BuildContext context) {
    final l10n = UserPreferencesLocalizations.of(context);
    return StyledStatusBar.dark(
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<UserPreferencesBloc, UserPreferencesState>(
            builder: (context, state) {
              if (state is UserPreferencesLoaded) {
                final username = state.username;
                return Column(
                  children: [
                    if (username != null) ...[
                      //TODO show load/save settings buttons
                      const SizedBox(
                        height: Spacing.mediumLarge,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Spacing.small,
                          ),
                          child: ShrinkableText(
                            l10n.signedInUserGreeting(username),
                            style: const TextStyle(
                              fontSize: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: Spacing.mediumLarge,
                      ),
                    ],
                    DarkModePreferencePicker(
                      currentValue: state.darkModePreference!,
                    ),
                    LocalePicker(
                      currentLocale: state.appLocale ?? const Locale('en'),
                    ),
                    RoundedChoiceChip(
                        label: l10n.showOnbOarding,
                        isSelected: !state.passedOnBoarding,
                        onSelected: (val) {
                          final bloc = context.read<UserPreferencesBloc>();
                          bloc.userRepository.upsertUserSettings(
                            UserSettings(
                              passedOnBoarding: !val,
                            ),
                          );
                        }),
                  ],
                );
              } else {
                return const CenteredCircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton(this.onSignInTap);

  final VoidCallback? onSignInTap;

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    final l10n = UserPreferencesLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: theme.screenMargin,
        right: theme.screenMargin,
        top: Spacing.xxLarge,
      ),
      child: ExpandedElevatedButton(
        onTap: onSignInTap,
        label: l10n.signInButtonLabel,
        icon: const Icon(
          Icons.login,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({
    required this.isSignOutInProgress,
  });

  final bool isSignOutInProgress;

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    final l10n = UserPreferencesLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: theme.screenMargin,
        right: theme.screenMargin,
        bottom: Spacing.xLarge,
      ),
      child: isSignOutInProgress
          ? ExpandedElevatedButton.inProgress(
              label: l10n.signOutButtonLabel,
            )
          : ExpandedElevatedButton(
              onTap: () {
                final bloc = context.read<UserPreferencesBloc>();
                bloc.add(
                  const UserPreferencesSignedOut(),
                );
              },
              label: l10n.signOutButtonLabel,
              icon: const Icon(
                Icons.logout,
              ),
            ),
    );
  }
}
