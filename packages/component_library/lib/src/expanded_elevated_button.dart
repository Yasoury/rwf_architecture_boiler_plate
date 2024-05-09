import 'package:flutter/material.dart';

class ExpandedElevatedButton extends StatelessWidget {
  static const double _elevatedButtonHeight = 48;

  const ExpandedElevatedButton({
    required this.label,
    this.onTap,
    this.icon,
    this.color,
    this.onlyBorderColored = false,
    super.key,
  });

  ExpandedElevatedButton.inProgress({
    required String label,
    Key? key,
  }) : this(
          label: label,
          icon: Transform.scale(
            scale: 0.5,
            child: const CircularProgressIndicator(),
          ),
          key: key,
        );

  final VoidCallback? onTap;
  final String label;
  final Widget? icon;
  final Color? color;
  final bool onlyBorderColored;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: onlyBorderColored ? null : color,
            border: onlyBorderColored
                ? Border.all(color: color ?? Colors.black)
                : null,
            borderRadius: const BorderRadius.all(Radius.circular(30))),
        height: _elevatedButtonHeight,
        width: double.infinity,
        child: Center(
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                          color: onlyBorderColored ? color : null,
                          fontWeight: FontWeight.bold),
                    ),
                    icon
                  ],
                )
              : Text(
                  label,
                  style: TextStyle(
                      color: onlyBorderColored ? color : Colors.white,
                      fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
