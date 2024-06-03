import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

class GenericErrorSnackBar extends SnackBar {
  const GenericErrorSnackBar({super.key})
      : super(
          content: const _GenericErrorSnackBarMessage(),
        );
}

class _GenericErrorSnackBarMessage extends StatelessWidget {
  const _GenericErrorSnackBarMessage();

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return Text(
      l10n.genericErrorSnackbarMessage,
    );
  }
}
