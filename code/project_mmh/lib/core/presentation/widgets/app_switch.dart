import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Switch único de la app: look Cupertino, color de marca, idéntico en
/// Android e iOS.
/// Uso: `AppSwitch(value: x, onChanged: (v) => ...)`.
/// Depende de: ColorScheme.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: Theme.of(context).colorScheme.primary,
    );
  }
}
