import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_palette.dart';

/// Tokens de color semánticos (éxito / advertencia / información) que no
/// existen en `ColorScheme`. Se acceden con `Theme.of(context).extension<
/// AppSemanticColors>()!` o el atajo `context.semantic`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  static const light = AppSemanticColors(
    success: AppPalette.successLight,
    onSuccess: AppPalette.onSuccessLight,
    warning: AppPalette.warningLight,
    onWarning: AppPalette.onWarningLight,
    info: AppPalette.infoLight,
    onInfo: AppPalette.onInfoLight,
  );

  static const dark = AppSemanticColors(
    success: AppPalette.successDark,
    onSuccess: AppPalette.onSuccessDark,
    warning: AppPalette.warningDark,
    onWarning: AppPalette.onWarningDark,
    info: AppPalette.infoDark,
    onInfo: AppPalette.onInfoDark,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}

extension SemanticColorsX on BuildContext {
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
