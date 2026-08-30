import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_theme.dart';

/// Envuelve un widget en un MaterialApp con el tema real de la app para los
/// tests de widget de los componentes `App*`.
Widget wrap(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);
