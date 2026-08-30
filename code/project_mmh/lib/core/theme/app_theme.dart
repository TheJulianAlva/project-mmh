import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_palette.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Fuente única del tema de Klinik. Construido sobre los tokens de
/// `lib/core/theme/` (paleta, escalas, tipografía). Chasis Material con
/// `cupertinoOverrideTheme` y transición de push iOS.
class AppTheme {
  AppTheme._();

  /// Color de marca (rosa). Fuente única para notificaciones y acentos.
  static const Color brandPink = AppPalette.berry;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  /// `ColorScheme` completo derivado del color de marca, con los roles de
  /// identidad forzados a la paleta de la app.
  static ColorScheme _scheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final seeded = ColorScheme.fromSeed(
      seedColor: AppPalette.berry,
      brightness: brightness,
    );
    return seeded.copyWith(
      primary: isLight ? AppPalette.berry : AppPalette.berryPastel,
      onPrimary: isLight ? AppPalette.white : AppPalette.onPrimaryDark,
      primaryContainer: isLight ? AppPalette.berrySoft : AppPalette.berryDeep,
      secondary: isLight ? AppPalette.teal : AppPalette.tealPastel,
      onSecondary: isLight ? AppPalette.white : AppPalette.onSecondaryDark,
      error: isLight ? AppPalette.errorLight : AppPalette.errorDark,
      onError: isLight ? AppPalette.white : AppPalette.grey900,
      surface: isLight ? AppPalette.white : AppPalette.surfaceDark,
      onSurface: isLight ? AppPalette.inkLight : AppPalette.inkDark,
    );
  }

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final scheme = _scheme(brightness);
    final ink = scheme.onSurface;
    final surface = scheme.surface;
    final scaffoldBg = isLight ? AppPalette.offWhite : AppPalette.grey900;

    final textTheme = buildTextTheme(
      brightness,
    ).apply(bodyColor: ink, displayColor: ink);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: [isLight ? AppSemanticColors.light : AppSemanticColors.dark],
      textTheme: textTheme,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),

      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        applyThemeToAll: true,
        brightness: brightness,
        primaryColor: scheme.primary,
        scaffoldBackgroundColor: scaffoldBg,
        barBackgroundColor: surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: scheme.primary,
          textStyle: AppText.body.copyWith(color: ink),
          navTitleTextStyle: AppText.cardTitle.copyWith(color: ink),
          navLargeTitleTextStyle: AppText.screenTitle.copyWith(color: ink),
          pickerTextStyle: AppText.body.copyWith(color: ink),
          dateTimePickerTextStyle: AppText.body.copyWith(color: ink),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primary.withValues(alpha: AppOpacity.subtle),
        labelTextStyle: WidgetStateProperty.all(
          AppText.caption.copyWith(
            fontFamily: AppText.displayFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        elevation: isLight ? 2 : 1,
        color: surface,
        shadowColor: Colors.black.withValues(alpha: AppOpacity.subtle),
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.lg,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.smAll,
          borderSide: BorderSide(
            color: ink.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.smAll,
          borderSide: BorderSide(
            color: ink.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.smAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.smAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.smAll,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        titleTextStyle: AppText.cardTitle.copyWith(color: ink),
        contentTextStyle: AppText.body.copyWith(color: ink),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        dragHandleColor: ink.withValues(alpha: AppOpacity.muted),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.md),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: ink.withValues(alpha: AppOpacity.hairline)),
        backgroundColor: scheme.primary.withValues(alpha: AppOpacity.subtle),
        selectedColor: scheme.primary,
        labelStyle: AppText.caption.copyWith(color: ink),
        secondaryLabelStyle: AppText.caption.copyWith(color: scheme.onPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : ink.withValues(alpha: AppOpacity.subtle),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: AppOpacity.hairline),
        thickness: 1,
        space: 1,
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: AppRadii.smAll),
          ),
          textStyle: WidgetStateProperty.all(AppText.caption),
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: AppOpacity.subtle),
        selectionHandleColor: scheme.primary,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.cardTitle.copyWith(color: ink),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AppPalette.inkLight : AppPalette.surfaceDark,
        contentTextStyle: AppText.body.copyWith(
          color: isLight ? AppPalette.white : AppPalette.inkDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        elevation: 4,
      ),
    );
  }
}
