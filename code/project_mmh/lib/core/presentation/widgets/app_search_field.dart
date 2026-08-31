import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_radii.dart';

/// Campo de búsqueda: icono de lupa, botón limpiar cuando hay texto,
/// `onChanged` con debounce.
/// Uso: `AppSearchField(onChanged: (q) => ref.read(...).search(q))`.
/// Depende de: inputDecorationTheme, AppRadii.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Buscar',
    this.onChanged,
    this.debounce = const Duration(milliseconds: 250),
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Duration debounce;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // refresca el sufijo
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged?.call(value));
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _controller.text.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
        border: const OutlineInputBorder(borderRadius: AppRadii.pillAll),
        enabledBorder: const OutlineInputBorder(borderRadius: AppRadii.pillAll),
        focusedBorder: const OutlineInputBorder(borderRadius: AppRadii.pillAll),
      ),
    );
  }
}
