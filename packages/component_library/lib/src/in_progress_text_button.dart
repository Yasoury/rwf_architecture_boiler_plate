import 'package:flutter/material.dart';

class InProgressTextButton extends StatelessWidget {
  const InProgressTextButton({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Transform.scale(
        scale: 0.5,
        child: const CircularProgressIndicator(),
      ),
      label: Text(
        label,
      ),
      onPressed: null,
    );
  }
}
