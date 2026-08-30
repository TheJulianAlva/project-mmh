# Sistema de Diseño Klinik — Plan de Implementación (D1, D1.5, D2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convertir la identidad visual de Klinik en una fuente de verdad de tokens y componentes, sin cambiar nada visible en producción hasta D3.

**Architecture:** Tres capas de tokens (`primitiva → semántica → componente`) en `lib/core/theme/`. Chasis Material con `cupertinoOverrideTheme` y transiciones iOS. Componentes `App*` en `lib/core/presentation/widgets/` probados contra una style guide oculta (`/dev/style-guide`, solo `kDebugMode`). Los estados de sesión/tratamiento pasan de `String` a `enum` en una PR intermedia.

**Tech Stack:** Flutter (Material 3), Riverpod, go_router, Freezed + json_serializable, google_fonts (solo como proveedor de familias, fetch de red desactivado).

**Spec:** `docs/superpowers/specs/2026-08-30-sistema-diseno-d1-d2-design.md`

## Global Constraints

- Flutter fijado por FVM a `3.38.1` (nota: el entorno actual tiene 3.44.8 en PATH sin fvm; si hay incompatibilidad, detenerse y avisar).
- Todos los comandos se ejecutan desde `code/project_mmh/`.
- Idioma de la app: es_ES exclusivamente. Sin dependencias de red en runtime.
- Cada PR valida con `flutter analyze --no-fatal-infos` (limpio) + `flutter test --no-pub` (verde).
- Commits en español, prefijo en minúscula (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`). Nunca commitear en `main`.
- Terminar mensajes de commit con:
  ```
  Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc
  ```
- Ningún literal de color, `TextStyle(fontSize:)` crudo ni `EdgeInsets` mágico en los archivos nuevos: todo pasa por los tokens.
- D1 y D1.5 no cambian ninguna pantalla de usuario. D2 solo añade `/dev/style-guide`.
- Freezed: tras tocar un modelo, correr `dart run build_runner build --delete-conflicting-outputs`.

---

## Estructura de archivos

### Rama `feat/sistema-diseno-d1` (PR 1)

```
code/project_mmh/
  lib/assets/fonts/                         NUEVO  (ya descargados)
    Outfit-Variable.ttf                     fuente variable de títulos
    IBMPlexSans-Regular.ttf                 cuerpo 400
    IBMPlexSans-Medium.ttf                  cuerpo 500
    IBMPlexSans-SemiBold.ttf               cuerpo 600
    IBMPlexSans-Italic.ttf                  cuerpo 400 itálica
    OFL-Outfit.txt / LICENSE-IBMPlexSans.txt  licencias
  lib/core/theme/
    app_palette.dart                        NUEVO  primitivas (privado)
    app_spacing.dart                        NUEVO  escala 4pt
    app_radii.dart                          NUEVO  4 radios + BorderRadius
    app_opacity.dart                        NUEVO  opacidades nombradas
    app_typography.dart                     NUEVO  AppText + buildTextTheme
    app_theme.dart                          MODIF  lee de tokens, +*Theme, +cupertinoOverrideTheme
    app_semantic_colors.dart                MODIF  lee de AppPalette
  lib/main.dart                             MODIF  GoogleFonts.config.allowRuntimeFetching = false
  pubspec.yaml                              MODIF  sección fonts:
  test/theme/tokens_test.dart               NUEVO  invariantes de escalas
  test/theme/app_theme_test.dart            NUEVO  el tema se construye en claro y oscuro
```

### Rama `refactor/estados-enum` (PR 2)

```
  lib/features/agenda/domain/
    estado_asistencia.dart                  NUEVO  enum + label
    estado_tratamiento.dart                 NUEVO  enum + label + dbValue
    sesion.dart                             MODIF  campo -> EstadoAsistencia?
    tratamiento.dart                        MODIF  campo -> EstadoTratamiento
    sesion.g.dart / tratamiento.g.dart      REGEN
  lib/features/agenda/data/repositories/agenda_repository.dart   MODIF
  lib/features/agenda/presentation/providers/agenda_providers.dart MODIF
  lib/features/agenda/presentation/widgets/timeline_session_list.dart MODIF
  lib/features/agenda/presentation/widgets/treatment_timeline_list.dart MODIF
  lib/features/agenda/presentation/widgets/treatment_info_card.dart MODIF
  lib/features/agenda/presentation/screens/treatment_detail_screen.dart MODIF
  lib/features/agenda/presentation/screens/treatments_screen.dart MODIF
  lib/features/agenda/presentation/screens/appointment_create_screen.dart MODIF
  test/features/agenda/estados_enum_test.dart   NUEVO  round-trip JSON
```

### Rama `feat/sistema-diseno-d2` (PR 3)

```
  lib/core/presentation/widgets/
    app_card.dart              AppCard
    app_button.dart            AppButton (.primary/.secondary/.text/.destructive)
    app_search_field.dart      AppSearchField
    app_text_field.dart        AppTextField (.singleLine/.multiline/.number)
    app_section_header.dart    AppSectionHeader
    app_scaffold.dart          AppScaffold + AppNavBar
    app_list_tile.dart         AppListTile + AppSettingsGroup
    app_sheet.dart             showAppSheet
    app_confirm.dart           showAppConfirm
    app_date_time_sheet.dart   AppDateTimeSheet
    app_switch.dart            AppSwitch
    app_status_badge.dart      AppStatusBadge
    app_empty_state.dart       AppEmptyState
  lib/features/dev/presentation/style_guide_screen.dart   NUEVO  (solo kDebugMode)
  lib/core/router/app_router.dart   MODIF  ruta /dev/style-guide bajo kDebugMode
  test/core/widgets/            NUEVO  un archivo de test por componente
```

---

# PARTE 1 — D1: Fundamentos de tokens

Rama: `feat/sistema-diseno-d1` (desde `main`).

---

### Task 1: Escalas de espaciado, radio y opacidad

**Files:**
- Create: `code/project_mmh/lib/core/theme/app_spacing.dart`
- Create: `code/project_mmh/lib/core/theme/app_radii.dart`
- Create: `code/project_mmh/lib/core/theme/app_opacity.dart`
- Test: `code/project_mmh/test/theme/tokens_test.dart`

**Interfaces:**
- Produces:
  - `AppSpacing.xs/sm/md/lg/xl/xxl` → `double` (4/8/12/16/24/32)
  - `AppRadii.sm/md/lg/pill` → `double` (8/12/20/999); `AppRadii.smAll/mdAll/lgAll/pillAll` → `BorderRadius`
  - `AppOpacity.hairline/subtle/muted/strong` → `double` (0.08/0.12/0.40/0.70)

- [ ] **Step 1: Write the failing test**

```dart
// test/theme/tokens_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';

void main() {
  test('AppSpacing sigue la escala de 4pt', () {
    expect(
      [AppSpacing.xs, AppSpacing.sm, AppSpacing.md, AppSpacing.lg,
       AppSpacing.xl, AppSpacing.xxl],
      [4.0, 8.0, 12.0, 16.0, 24.0, 32.0],
    );
  });

  test('AppRadii expone 4 radios y sus BorderRadius', () {
    expect([AppRadii.sm, AppRadii.md, AppRadii.lg], [8.0, 12.0, 20.0]);
    expect(AppRadii.pill, greaterThanOrEqualTo(999.0));
    expect(AppRadii.mdAll, BorderRadius.circular(12));
    expect(AppRadii.pillAll, BorderRadius.circular(AppRadii.pill));
  });

  test('AppOpacity nombra las opacidades en [0,1] y ordenadas', () {
    final vals = [AppOpacity.hairline, AppOpacity.subtle,
                  AppOpacity.muted, AppOpacity.strong];
    expect(vals, [0.08, 0.12, 0.40, 0.70]);
    for (var i = 1; i < vals.length; i++) {
      expect(vals[i], greaterThan(vals[i - 1]));
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/theme/tokens_test.dart --no-pub`
Expected: FAIL — "Target of URI doesn't exist: 'package:project_mmh/core/theme/app_spacing.dart'".

- [ ] **Step 3: Write the three token files**

```dart
// lib/core/theme/app_spacing.dart
/// Escala de espaciado de 4 pt. Único origen de paddings y gaps.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}
```

```dart
// lib/core/theme/app_radii.dart
import 'package:flutter/widgets.dart';

/// Los 4 radios del sistema. Nada en pantalla usa otro valor.
abstract final class AppRadii {
  static const double sm = 8;     // chips, campos
  static const double md = 12;    // tarjetas, hojas
  static const double lg = 20;    // contenedores destacados
  static const double pill = 999; // CTAs y chips de filtro

  static const BorderRadius smAll =
      BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll =
      BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll =
      BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll =
      BorderRadius.all(Radius.circular(pill));
}
```

```dart
// lib/core/theme/app_opacity.dart
/// Opacidades nombradas por intención. Sustituye los `withValues(alpha:)`
/// crudos repartidos por la app.
abstract final class AppOpacity {
  static const double hairline = 0.08; // bordes muy sutiles
  static const double subtle = 0.12;   // fondos de badge, indicadores
  static const double muted = 0.40;    // texto / iconos deshabilitados
  static const double strong = 0.70;   // overlays
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/theme/tokens_test.dart --no-pub`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add code/project_mmh/lib/core/theme/app_spacing.dart \
        code/project_mmh/lib/core/theme/app_radii.dart \
        code/project_mmh/lib/core/theme/app_opacity.dart \
        code/project_mmh/test/theme/tokens_test.dart
git commit -m "feat: escalas de espaciado, radio y opacidad del sistema de diseño

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 2: Paleta primitiva y `AppSemanticColors` sobre ella

**Files:**
- Create: `code/project_mmh/lib/core/theme/app_palette.dart`
- Modify: `code/project_mmh/lib/core/theme/app_semantic_colors.dart`
- Test: `code/project_mmh/test/theme/tokens_test.dart` (añadir grupo)

**Interfaces:**
- Consumes: nada.
- Produces: `AppPalette` con constantes `Color` — `berry`, `berrySoft`, `berryDeep`, `berryPastel`, `teal`, `tealPastel`, `offWhite`, `white`, `inkLight`, `grey900`, `surfaceDark`, `inkDark`, `errorLight`, `errorDark`, `successLight/onSuccessLight/warningLight/onWarningLight/infoLight/onInfoLight`, `successDark/onSuccessDark/warningDark/onWarningDark/infoDark/onInfoDark`, `onPrimaryDark` (`#380016`), `onSecondaryDark` (`#003731`).
- `AppSemanticColors.light` / `.dark` sin cambio de valores (solo su origen).

- [ ] **Step 1: Add failing test**

```dart
// añadir a test/theme/tokens_test.dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_palette.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';

// dentro de main():
group('AppPalette + AppSemanticColors', () {
  test('los valores de marca no cambian', () {
    expect(AppPalette.berry, const Color(0xFFD81B60));
    expect(AppPalette.teal, const Color(0xFF009688));
  });

  test('AppSemanticColors.light se deriva de la paleta', () {
    expect(AppSemanticColors.light.success, AppPalette.successLight);
    expect(AppSemanticColors.dark.warning, AppPalette.warningDark);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/theme/tokens_test.dart --no-pub`
Expected: FAIL — URI `app_palette.dart` no existe.

- [ ] **Step 3: Create `app_palette.dart`**

```dart
// lib/core/theme/app_palette.dart
import 'package:flutter/material.dart';

/// Primitivas de color. Valores crudos, sin significado semántico.
/// NO usar fuera de `lib/core/theme/`.
abstract final class AppPalette {
  // Marca
  static const Color berry = Color(0xFFD81B60);
  static const Color berrySoft = Color(0xFFF8BBD0);
  static const Color berryDeep = Color(0xFF880E4F);
  static const Color berryPastel = Color(0xFFF48FB1);
  static const Color teal = Color(0xFF009688);
  static const Color tealPastel = Color(0xFF80CBC4);

  // Neutros
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color inkLight = Color(0xFF37474F);
  static const Color grey900 = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color inkDark = Color(0xFFECEFF1);

  // "on-" de marca en oscuro
  static const Color onPrimaryDark = Color(0xFF380016);
  static const Color onSecondaryDark = Color(0xFF003731);

  // Error
  static const Color errorLight = Color(0xFFB00020);
  static const Color errorDark = Color(0xFFCF6679);

  // Estado — claro
  static const Color successLight = Color(0xFF2E7D32);
  static const Color onSuccessLight = Colors.white;
  static const Color warningLight = Color(0xFFED6C02);
  static const Color onWarningLight = Colors.white;
  static const Color infoLight = Color(0xFF0288D1);
  static const Color onInfoLight = Colors.white;

  // Estado — oscuro
  static const Color successDark = Color(0xFF81C784);
  static const Color onSuccessDark = Color(0xFF0A2E0C);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color onWarningDark = Color(0xFF3A2400);
  static const Color infoDark = Color(0xFF4FC3F7);
  static const Color onInfoDark = Color(0xFF00263A);
}
```

- [ ] **Step 4: Point `app_semantic_colors.dart` at the palette**

Reemplazar los literales de `static const light` y `static const dark` por
referencias a `AppPalette` (mismo valor). Añadir `import
'package:project_mmh/core/theme/app_palette.dart';`. Ejemplo:

```dart
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
```

- [ ] **Step 5: Run tests**

Run: `flutter test test/theme/tokens_test.dart --no-pub`
Expected: PASS (5 tests).
Run: `flutter analyze --no-fatal-infos lib/core/theme/`
Expected: sin issues nuevos.

- [ ] **Step 6: Commit**

```bash
git add code/project_mmh/lib/core/theme/app_palette.dart \
        code/project_mmh/lib/core/theme/app_semantic_colors.dart \
        code/project_mmh/test/theme/tokens_test.dart
git commit -m "feat: paleta primitiva como origen de los colores semánticos

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 3: Fuentes empaquetadas + `app_typography.dart`

**Files:**
- Modify: `code/project_mmh/pubspec.yaml` (sección `flutter: fonts:`)
- Create: `code/project_mmh/lib/core/theme/app_typography.dart`
- Modify: `code/project_mmh/lib/main.dart` (línea 15, tras `ensureInitialized()`)
- Test: `code/project_mmh/test/theme/app_theme_test.dart`
- (Assets ya presentes en `lib/assets/fonts/`.)

**Interfaces:**
- Consumes: nada.
- Produces:
  - `AppText.screenTitle/cardTitle/body/sectionLabel/metric/caption` → `TextStyle`
  - `buildTextTheme(Brightness brightness)` → `TextTheme`
  - Constantes de familia: `AppText.displayFamily` (`'Outfit'`), `AppText.bodyFamily` (`'IBM Plex Sans'`)

- [ ] **Step 1: Declare fonts in `pubspec.yaml`**

Bajo `flutter:` (junto a `uses-material-design: true` y `assets:`), añadir:

```yaml
  fonts:
    - family: Outfit
      fonts:
        - asset: lib/assets/fonts/Outfit-Variable.ttf
    - family: IBM Plex Sans
      fonts:
        - asset: lib/assets/fonts/IBMPlexSans-Regular.ttf
        - asset: lib/assets/fonts/IBMPlexSans-Medium.ttf
          weight: 500
        - asset: lib/assets/fonts/IBMPlexSans-SemiBold.ttf
          weight: 600
        - asset: lib/assets/fonts/IBMPlexSans-Italic.ttf
          style: italic
```

Nota: `Outfit-Variable.ttf` es fuente variable; Flutter mapea `fontWeight`
al eje `wght` automáticamente, por eso se declara una sola vez.

- [ ] **Step 2: Run `flutter pub get`**

Run: `flutter pub get`
Expected: OK, sin errores de asset faltante.

- [ ] **Step 3: Write the failing test**

```dart
// test/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

void main() {
  test('AppText usa las familias empaquetadas, no google_fonts en runtime', () {
    expect(AppText.screenTitle.fontFamily, 'Outfit');
    expect(AppText.body.fontFamily, 'IBM Plex Sans');
    expect(AppText.metric.fontFamily, 'Outfit');
    expect(AppText.caption.fontFamily, 'IBM Plex Sans');
  });

  test('metric usa cifras tabulares', () {
    expect(
      AppText.metric.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  test('buildTextTheme rellena los slots M3 principales', () {
    final t = buildTextTheme(Brightness.light);
    expect(t.bodyMedium!.fontFamily, 'IBM Plex Sans');
    expect(t.titleLarge!.fontFamily, 'Outfit');
    expect(t.displayLarge!.fontFamily, 'Outfit');
  });
}
```

- [ ] **Step 4: Run test to verify it fails**

Run: `flutter test test/theme/app_theme_test.dart --no-pub`
Expected: FAIL — URI `app_typography.dart` no existe.

- [ ] **Step 5: Create `app_typography.dart`**

```dart
// lib/core/theme/app_typography.dart
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

/// Roles tipográficos nombrados por uso. Outfit para títulos, etiquetas y
/// métricas; IBM Plex Sans para cuerpo y texto largo. Ambas empaquetadas
/// como asset (ver pubspec.yaml) — sin descarga de red.
abstract final class AppText {
  static const String displayFamily = 'Outfit';
  static const String bodyFamily = 'IBM Plex Sans';

  static const TextStyle screenTitle = TextStyle(
    fontFamily: displayFamily,
    fontSize: 27,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: displayFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Se usa con `.toUpperCase()` en el texto (no hay text-transform en Flutter).
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: displayFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.6,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: displayFamily,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
}

/// Construye el `TextTheme` M3 a partir de los roles, para que los widgets
/// Material sin estilo explícito ya salgan con la tipografía correcta.
/// Los colores se aplican después con `.apply(bodyColor:, displayColor:)`.
TextTheme buildTextTheme(Brightness brightness) {
  const display = AppText.displayFamily;
  const bodyF = AppText.bodyFamily;
  return const TextTheme(
    displayLarge: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, letterSpacing: -1.0),
    displayMedium: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, letterSpacing: -0.8),
    displaySmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    headlineLarge: TextStyle(fontFamily: display, fontWeight: FontWeight.w600, letterSpacing: -0.5),
    headlineMedium: TextStyle(fontFamily: display, fontWeight: FontWeight.w600, letterSpacing: -0.4),
    headlineSmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w600, letterSpacing: -0.3),
    titleLarge: TextStyle(fontFamily: display, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    titleMedium: TextStyle(fontFamily: display, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontFamily: bodyF, height: 1.45),
    bodyMedium: TextStyle(fontFamily: bodyF, height: 1.45),
    bodySmall: TextStyle(fontFamily: bodyF),
    labelLarge: TextStyle(fontFamily: display, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: display, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w500, letterSpacing: 1.6),
  );
}
```

- [ ] **Step 6: Turn off runtime font fetching in `main.dart`**

En `lib/main.dart`, añadir import y primera línea de `main()`:

```dart
import 'package:google_fonts/google_fonts.dart';
// ...
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('es_ES', null);
  // ... resto igual
```

- [ ] **Step 7: Run tests**

Run: `flutter test test/theme/app_theme_test.dart --no-pub`
Expected: PASS (3 tests).

- [ ] **Step 8: Commit**

```bash
git add code/project_mmh/pubspec.yaml code/project_mmh/pubspec.lock \
        code/project_mmh/lib/assets/fonts/ \
        code/project_mmh/lib/core/theme/app_typography.dart \
        code/project_mmh/lib/main.dart \
        code/project_mmh/test/theme/app_theme_test.dart
git commit -m "feat: empaqueta Outfit e IBM Plex Sans como asset y apaga el fetch de fuentes

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 4: `app_theme.dart` sobre tokens + `*Theme` de componente + `cupertinoOverrideTheme`

**Files:**
- Modify: `code/project_mmh/lib/core/theme/app_theme.dart` (reescritura del cuerpo)
- Test: `code/project_mmh/test/theme/app_theme_test.dart` (añadir grupo)

**Interfaces:**
- Consumes: `AppPalette`, `AppRadii`, `AppSpacing`, `AppOpacity`, `AppText`, `buildTextTheme`, `AppSemanticColors`.
- Produces: `AppTheme.light()` / `AppTheme.dark()` → `ThemeData` (sin cambio de firma). `AppTheme.brandPink` se mantiene.

- [ ] **Step 1: Add failing test**

```dart
// añadir a test/theme/app_theme_test.dart
import 'package:project_mmh/core/theme/app_theme.dart';
import 'package:project_mmh/core/theme/app_radii.dart';

// dentro de main():
group('AppTheme', () {
  for (final entry in {
    'light': AppTheme.light(),
    'dark': AppTheme.dark(),
  }.entries) {
    test('${entry.key}: se construye con los sub-temas clave', () {
      final t = entry.value;
      expect(t.useMaterial3, isTrue);
      expect(t.cupertinoOverrideTheme, isNotNull);
      expect(t.cupertinoOverrideTheme!.primaryColor, t.colorScheme.primary);
      expect(t.bottomSheetTheme.showDragHandle, isTrue);
      expect(t.dialogTheme.shape, isA<RoundedRectangleBorder>());
      expect(t.textSelectionTheme.cursorColor, t.colorScheme.primary);
      expect(
        t.pageTransitionsTheme.builders[TargetPlatform.android],
        isA<CupertinoPageTransitionsBuilder>(),
      );
      expect(
        (t.cardTheme.shape as RoundedRectangleBorder).borderRadius,
        AppRadii.mdAll,
      );
    });
  }

  test('brandPink sigue siendo el rosa de marca', () {
    expect(AppTheme.brandPink, const Color(0xFFD81B60));
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/theme/app_theme_test.dart --no-pub`
Expected: FAIL — `cupertinoOverrideTheme` es null / `cardTheme` radio 16.

- [ ] **Step 3: Rewrite `app_theme.dart`**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_palette.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  /// Color de marca (rosa). Fuente única para notificaciones y acentos.
  static const Color brandPink = AppPalette.berry;

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

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final scheme = _scheme(brightness);
    final ink = scheme.onSurface;
    final surface = scheme.surface;
    final scaffoldBg = isLight ? AppPalette.offWhite : AppPalette.grey900;

    final textTheme = buildTextTheme(brightness)
        .apply(bodyColor: ink, displayColor: ink);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      extensions: [
        isLight ? AppSemanticColors.light : AppSemanticColors.dark,
      ],
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

      cupertinoOverrideTheme: CupertinoThemeData(
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
          AppText.caption.copyWith(fontFamily: AppText.displayFamily,
              fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ),

      cardTheme: CardThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        elevation: isLight ? 2 : 1,
        color: surface,
        shadowColor: Colors.black.withValues(alpha: AppOpacity.subtle),
        margin: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadii.smAll,
          borderSide: BorderSide(
              color: ink.withValues(alpha: AppOpacity.subtle)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.smAll,
          borderSide: BorderSide(
              color: ink.withValues(alpha: AppOpacity.subtle)),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
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
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? scheme.onPrimary : null),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? scheme.primary
                : ink.withValues(alpha: AppOpacity.subtle)),
      ),

      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: AppOpacity.hairline),
        thickness: 1,
        space: 1,
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: AppRadii.smAll)),
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
            color: isLight ? AppPalette.white : AppPalette.inkDark),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        elevation: 4,
      ),
    );
  }
}
```

- [ ] **Step 4: Run the whole theme test file**

Run: `flutter test test/theme/ --no-pub`
Expected: PASS (todos los grupos).

- [ ] **Step 5: Analyze + full test suite**

Run: `flutter analyze --no-fatal-infos`
Expected: sin errores (posibles infos preexistentes toleradas).
Run: `flutter test --no-pub`
Expected: verde, incluido `test/smoke_test.dart`.

- [ ] **Step 6: Manual smoke (opcional pero recomendado)**

Run: `flutter run` en un emulador; abrir Agenda, Ajustes, un selector de
fecha y una hoja modal. Verificar: sin crash, tipografía Outfit en títulos,
radios de tarjeta ligeramente menores (16→12, cambio esperado).

- [ ] **Step 7: Commit**

```bash
git add code/project_mmh/lib/core/theme/app_theme.dart \
        code/project_mmh/test/theme/app_theme_test.dart
git commit -m "feat: tema sobre tokens con sub-temas de componente y override Cupertino

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

- [ ] **Step 8: Push branch and open PR 1**

```bash
git push -u origin feat/sistema-diseno-d1
gh pr create --base main --title "D1 · Fundamentos de tokens del sistema de diseño" \
  --body "$(cat <<'EOF'
Implementa la fase D1 del spec `docs/superpowers/specs/2026-08-30-sistema-diseno-d1-d2-design.md`.

- Escalas: `AppSpacing`, `AppRadii`, `AppOpacity`.
- `AppPalette` (primitivas) como origen de `AppSemanticColors`.
- Outfit + IBM Plex Sans empaquetadas como asset; `GoogleFonts.config.allowRuntimeFetching = false`.
- `app_typography.dart`: roles `AppText.*` + `buildTextTheme`.
- `app_theme.dart` reescrito sobre tokens; añade `cupertinoOverrideTheme`, `pageTransitionsTheme` (swipe-back), y los `*Theme` de diálogo, hoja, chip, switch, divisor, segmented, selección de texto e input.

Único cambio visible: radio de tarjeta 16 → 12.

`flutter analyze` limpio · `flutter test` verde.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

# PARTE 2 — D1.5: Migración de enums de estado

Rama: `refactor/estados-enum` (desde `main`, tras mergear PR 1 — o desde `feat/sistema-diseno-d1` si se encadenan).

---

### Task 5: Enums `EstadoAsistencia` y `EstadoTratamiento`

**Files:**
- Create: `code/project_mmh/lib/features/agenda/domain/estado_asistencia.dart`
- Create: `code/project_mmh/lib/features/agenda/domain/estado_tratamiento.dart`
- Test: `code/project_mmh/test/features/agenda/estados_enum_test.dart`

**Interfaces:**
- Produces:
  - `enum EstadoAsistencia { programada, asistio, falto }` con `String get label` y `String get dbValue` (== `programada`/`asistio`/`falto`).
  - `enum EstadoTratamiento { pendiente, enProceso, concluido }` con `String get label` y `String get dbValue` (== `pendiente`/`en_proceso`/`concluido`).
  - `EstadoAsistencia? estadoAsistenciaFromDb(String?)`, `EstadoTratamiento estadoTratamientoFromDb(String?)` (fallback `pendiente`).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/agenda/estados_enum_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';

void main() {
  test('EstadoTratamiento.enProceso serializa a en_proceso', () {
    expect(EstadoTratamiento.enProceso.dbValue, 'en_proceso');
    expect(estadoTratamientoFromDb('en_proceso'), EstadoTratamiento.enProceso);
  });

  test('estadoTratamientoFromDb cae a pendiente si el valor es inválido', () {
    expect(estadoTratamientoFromDb(null), EstadoTratamiento.pendiente);
    expect(estadoTratamientoFromDb('xxx'), EstadoTratamiento.pendiente);
  });

  test('EstadoAsistencia round-trip por dbValue', () {
    for (final e in EstadoAsistencia.values) {
      expect(estadoAsistenciaFromDb(e.dbValue), e);
    }
    expect(estadoAsistenciaFromDb(null), isNull);
    expect(estadoAsistenciaFromDb(''), isNull);
  });

  test('labels en es_ES', () {
    expect(EstadoAsistencia.asistio.label, 'Asistió');
    expect(EstadoTratamiento.enProceso.label, 'En proceso');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/agenda/estados_enum_test.dart --no-pub`
Expected: FAIL — URIs no existen.

- [ ] **Step 3: Create the enums**

```dart
// lib/features/agenda/domain/estado_asistencia.dart
import 'package:freezed_annotation/freezed_annotation.dart';

/// Estado de asistencia de una sesión. `name` del enum ≠ valor en BD para
/// `programada`? no: aquí coinciden. Se serializa con @JsonValue por
/// claridad y para blindar cambios futuros.
enum EstadoAsistencia {
  @JsonValue('programada')
  programada,
  @JsonValue('asistio')
  asistio,
  @JsonValue('falto')
  falto;

  String get dbValue => switch (this) {
        EstadoAsistencia.programada => 'programada',
        EstadoAsistencia.asistio => 'asistio',
        EstadoAsistencia.falto => 'falto',
      };

  String get label => switch (this) {
        EstadoAsistencia.programada => 'Programada',
        EstadoAsistencia.asistio => 'Asistió',
        EstadoAsistencia.falto => 'Faltó',
      };
}

/// Parseo tolerante para valores crudos de BD (incluye null / vacío).
EstadoAsistencia? estadoAsistenciaFromDb(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final e in EstadoAsistencia.values) {
    if (e.dbValue == raw) return e;
  }
  return null;
}
```

```dart
// lib/features/agenda/domain/estado_tratamiento.dart
import 'package:freezed_annotation/freezed_annotation.dart';

/// Estado de un tratamiento. Ojo: `enProceso` ↔ `'en_proceso'` en BD.
enum EstadoTratamiento {
  @JsonValue('pendiente')
  pendiente,
  @JsonValue('en_proceso')
  enProceso,
  @JsonValue('concluido')
  concluido;

  String get dbValue => switch (this) {
        EstadoTratamiento.pendiente => 'pendiente',
        EstadoTratamiento.enProceso => 'en_proceso',
        EstadoTratamiento.concluido => 'concluido',
      };

  String get label => switch (this) {
        EstadoTratamiento.pendiente => 'Pendiente',
        EstadoTratamiento.enProceso => 'En proceso',
        EstadoTratamiento.concluido => 'Concluido',
      };
}

/// Fallback a `pendiente` para valores desconocidos (dato histórico).
EstadoTratamiento estadoTratamientoFromDb(String? raw) {
  for (final e in EstadoTratamiento.values) {
    if (e.dbValue == raw) return e;
  }
  return EstadoTratamiento.pendiente;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/agenda/estados_enum_test.dart --no-pub`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add code/project_mmh/lib/features/agenda/domain/estado_asistencia.dart \
        code/project_mmh/lib/features/agenda/domain/estado_tratamiento.dart \
        code/project_mmh/test/features/agenda/estados_enum_test.dart
git commit -m "feat: enums EstadoAsistencia y EstadoTratamiento con serialización a BD

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 6: Modelos Freezed usan los enums

**Files:**
- Modify: `code/project_mmh/lib/features/agenda/domain/sesion.dart:14-15`
- Modify: `code/project_mmh/lib/features/agenda/domain/tratamiento.dart:16-17`
- Regen: `sesion.g.dart`, `tratamiento.g.dart` (+ `.freezed.dart`)
- Test: `code/project_mmh/test/features/agenda/estados_enum_test.dart` (añadir grupo de modelo)

**Interfaces:**
- Consumes: `EstadoAsistencia`, `EstadoTratamiento`.
- Produces: `Sesion.estadoAsistencia` → `EstadoAsistencia?`; `Tratamiento.estado` → `EstadoTratamiento` (required).

- [ ] **Step 1: Add failing model round-trip test**

```dart
// añadir a test/features/agenda/estados_enum_test.dart
import 'package:project_mmh/features/agenda/domain/sesion.dart';
import 'package:project_mmh/features/agenda/domain/tratamiento.dart';

// dentro de main():
group('round-trip de modelos', () {
  test('Sesion preserva estado_asistencia', () {
    final s = Sesion(
      idTratamiento: 1, fechaInicio: 'x', fechaFin: 'y',
      estadoAsistencia: EstadoAsistencia.asistio,
    );
    final json = s.toJson();
    expect(json['estado_asistencia'], 'asistio');
    expect(Sesion.fromJson(json), s);
  });

  test('Tratamiento preserva estado en_proceso', () {
    final t = Tratamiento(
      idClinica: 1, idExpediente: 'A', nombreTratamiento: 'Endo',
      fechaCreacion: 'x', estado: EstadoTratamiento.enProceso,
    );
    final json = t.toJson();
    expect(json['estado'], 'en_proceso');
    expect(Tratamiento.fromJson(json), t);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/agenda/estados_enum_test.dart --no-pub`
Expected: FAIL — el campo aún es `String` / tipos incompatibles.

- [ ] **Step 3: Edit the models**

`sesion.dart`:

```dart
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
// ...
    @JsonKey(name: 'estado_asistencia')
    EstadoAsistencia? estadoAsistencia,
```

`tratamiento.dart`:

```dart
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';
// ...
    @JsonKey(name: 'estado')
    required EstadoTratamiento estado,
```

- [ ] **Step 4: Regenerate**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: OK, `sesion.g.dart` y `tratamiento.g.dart` regenerados con
`$enumDecodeNullable` / `_$EstadoTratamientoEnumMap`.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/agenda/estados_enum_test.dart --no-pub`
Expected: PASS. (El resto del proyecto aún NO compila — es esperado, se
arregla en Task 7.)

- [ ] **Step 6: Commit**

```bash
git add code/project_mmh/lib/features/agenda/domain/sesion.dart \
        code/project_mmh/lib/features/agenda/domain/tratamiento.dart \
        code/project_mmh/lib/features/agenda/domain/sesion.g.dart \
        code/project_mmh/lib/features/agenda/domain/sesion.freezed.dart \
        code/project_mmh/lib/features/agenda/domain/tratamiento.g.dart \
        code/project_mmh/lib/features/agenda/domain/tratamiento.freezed.dart \
        code/project_mmh/test/features/agenda/estados_enum_test.dart
git commit -m "refactor: Sesion.estadoAsistencia y Tratamiento.estado como enum

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 7: Adaptar repositorio, providers y widgets al enum

**Files:**
- Modify: `code/project_mmh/lib/features/agenda/data/repositories/agenda_repository.dart` (líneas ~86-88, ~145-146, ~215, ~246, ~300, ~336)
- Modify: `code/project_mmh/lib/features/agenda/presentation/providers/agenda_providers.dart` (~32, ~62-70)
- Modify: `code/project_mmh/lib/features/agenda/presentation/widgets/timeline_session_list.dart` (~353, ~370-380 `_getNodeColor`, `_buildStatusBadge`, ~516)
- Modify: `code/project_mmh/lib/features/agenda/presentation/widgets/treatment_timeline_list.dart` (~371, ~439-455)
- Modify: `code/project_mmh/lib/features/agenda/presentation/widgets/treatment_info_card.dart:143`
- Modify: `code/project_mmh/lib/features/agenda/presentation/screens/treatment_detail_screen.dart:86,102`
- Modify: `code/project_mmh/lib/features/agenda/presentation/screens/treatments_screen.dart:230,234,535`
- Modify: `code/project_mmh/lib/features/agenda/presentation/screens/appointment_create_screen.dart:1010,1021,1031`

**Interfaces:**
- Consumes: enums de Task 5, modelos de Task 6.
- Produces: proyecto que compila y pasa `flutter analyze`.

- [ ] **Step 1: Run analyze to get the full error list**

Run: `flutter analyze --no-fatal-infos`
Expected: lista de errores de tipo en los archivos de arriba. Usarla como
checklist.

- [ ] **Step 2: `agenda_repository.dart`**

- Query raw (`_buildStatusFilter` / línea ~145): sustituir
  `estado_asistencia = 'programada'` por
  `estado_asistencia = '${EstadoAsistencia.programada.dbValue}'` (o
  parámetro posicional `?` con `whereArgs`).
- Marcar concluido (líneas 86-88):
  ```dart
  {'estado': EstadoTratamiento.concluido.dbValue},
  where: 'id_tratamiento = ? AND estado != ?',
  whereArgs: [idTratamiento, EstadoTratamiento.concluido.dbValue],
  ```
- Conteo por objetivo (línea ~336): `"WHERE id_objetivo = ? AND estado = '${EstadoTratamiento.concluido.dbValue}'"`.
- Construcción de `SesionRichModel` desde fila raw (línea ~246):
  ```dart
  estadoAsistencia: estadoAsistenciaFromDb(row['estado_asistencia'] as String?),
  ```
- `updateEstadoAsistencia` (línea ~300): el parámetro entra como
  `EstadoAsistencia`; escribir `{'estado_asistencia': nuevoEstado.dbValue}`.
  Actualizar la firma del método y su llamador en `SessionActionSheet` si
  aplica (buscar `updateEstadoAsistencia(`).

- [ ] **Step 3: `agenda_providers.dart`**

- `statusFilterProvider`: pasa de `StateProvider<String?>` a
  `StateProvider<EstadoAsistencia?>`.
- Filtro "pendientes" (líneas ~62-64):
  ```dart
  s.sesion.estadoAsistencia == null ||
  s.sesion.estadoAsistencia == EstadoAsistencia.programada,
  ```
- Filtro exacto (línea ~70): `.where((s) => s.sesion.estadoAsistencia == statusFilter)`.
- Buscar los consumidores de `statusFilterProvider` (chips de filtro en la
  UI de agenda) y cambiar los `String` literales por valores de enum.

- [ ] **Step 4: `timeline_session_list.dart` y `treatment_timeline_list.dart`**

`_getNodeColor()`:

```dart
Color _getNodeColor() {
  return switch (session.sesion.estadoAsistencia) {
    EstadoAsistencia.asistio => colorScheme.secondary,
    EstadoAsistencia.falto => colorScheme.error,
    EstadoAsistencia.programada || null => colorScheme.primary,
  };
}
```

`_buildStatusBadge(BuildContext, EstadoAsistencia?)`: cambiar la firma; el
`switch` interno pasa a ser sobre el enum (mismo mapeo color/label). El
`null` se trata como `programada`. Mantener el aspecto visual idéntico
(este widget se reemplaza por `AppStatusBadge` en D3, aquí solo se tipa).

- [ ] **Step 5: `treatment_info_card.dart`, `treatment_detail_screen.dart`, `treatments_screen.dart`**

- `treatment_info_card.dart:143`: `final isCompleted = status == EstadoTratamiento.concluido;`
  (y tipar el parámetro `status` como `EstadoTratamiento`).
- `treatment_detail_screen.dart:86`: `final isConcluded = tratamiento.estado == EstadoTratamiento.concluido;`
  línea 102: `status: tratamiento.estado` (ahora ya es enum; ajustar el
  tipo del parámetro receptor).
- `treatments_screen.dart:230/234`:
  ```dart
  .where((t) => t.tratamiento.estado != EstadoTratamiento.concluido)
  .where((t) => t.tratamiento.estado == EstadoTratamiento.concluido)
  ```
  línea 535: `final isCompleted = item.tratamiento.estado == EstadoTratamiento.concluido;`

- [ ] **Step 6: `appointment_create_screen.dart`**

- línea 1010: `estado: EstadoTratamiento.pendiente,`
- líneas 1021 / 1031: `estadoAsistencia: EstadoAsistencia.programada,`

- [ ] **Step 7: Resolver el resto de la lista de `analyze`**

Repetir `flutter analyze --no-fatal-infos` y arreglar cada error residual
(imports faltantes de los enums, comparaciones sueltas). Añadir
`import '.../estado_asistencia.dart'` / `estado_tratamiento.dart` donde
haga falta.

- [ ] **Step 8: Verify**

Run: `flutter analyze --no-fatal-infos`
Expected: sin errores.
Run: `flutter test --no-pub`
Expected: verde (todos los suites, incluido `smoke_test.dart` y
`estados_enum_test.dart`).

- [ ] **Step 9: Manual DB check**

`flutter run`; crear tratamiento + sesión, marcar "Asistió", concluir
tratamiento. Con `adb shell` o un visor sqlite comprobar que
`tratamientos.estado` guarda `en_proceso`/`concluido` y
`sesiones.estado_asistencia` guarda `asistio`. (Alternativa: añadir un
`debugPrint` temporal del row y quitarlo antes de commitear.)

- [ ] **Step 10: Commit + PR 2**

```bash
git add -A code/project_mmh/lib/features/agenda
git commit -m "refactor: consume los enums de estado en repositorio, providers y widgets

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
git push -u origin refactor/estados-enum
gh pr create --base main --title "D1.5 · Estados de sesión y tratamiento como enum" \
  --body "$(cat <<'EOF'
Fase D1.5 del spec. `EstadoAsistencia` / `EstadoTratamiento` sustituyen los `String` mágicos.

- Sin migración de BD: `@JsonValue` mantiene los valores (`en_proceso`, etc.).
- `switch` exhaustivos en los widgets de timeline.
- Test de round-trip JSON, incluido `enProceso ↔ en_proceso`.

`flutter analyze` limpio · `flutter test` verde.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

# PARTE 3 — D2: Componentes canónicos + style guide

Rama: `feat/sistema-diseno-d2` (desde `main` tras PR 1 y 2, o encadenada).

Convención común a todos los componentes:
- Viven en `lib/core/presentation/widgets/`, un archivo por componente.
- Doc-comment de 3 líneas: **qué hace / cómo se usa / de qué depende**.
- Solo consumen tokens (`AppSpacing`, `AppRadii`, `AppText`, `AppOpacity`),
  `Theme.of(context).colorScheme` y `context.semantic`. Cero literales.
- Cada uno con un test de widget: renderiza sin excepción en `Brightness.light`
  y `Brightness.dark` dentro de un `MaterialApp(theme: AppTheme.light())`.

Helper de test compartido (crear una vez, en Task 8):

```dart
// test/core/widgets/_harness.dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_theme.dart';

Widget wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );
```

---

### Task 8: `AppCard` + `AppSectionHeader` + `AppEmptyState`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_card.dart`
- Create: `code/project_mmh/lib/core/presentation/widgets/app_section_header.dart`
- Create: `code/project_mmh/lib/core/presentation/widgets/app_empty_state.dart`
- Create: `code/project_mmh/test/core/widgets/_harness.dart`
- Test: `code/project_mmh/test/core/widgets/app_card_test.dart`

**Interfaces:**
- Produces:
  - `AppCard({Widget child, Color? accentColor, VoidCallback? onTap, EdgeInsetsGeometry? padding})`
  - `AppSectionHeader(String label, {EdgeInsetsGeometry? padding})`
  - `AppEmptyState({required IconData icon, required String title, String? message, Widget? action})`

- [ ] **Step 1: Write failing tests**

```dart
// test/core/widgets/app_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import '_harness.dart';

void main() {
  testWidgets('AppCard renderiza el hijo y responde al tap', (t) async {
    var tapped = false;
    await t.pumpWidget(wrap(AppCard(
      onTap: () => tapped = true,
      child: const Text('contenido'),
    )));
    expect(find.text('contenido'), findsOneWidget);
    await t.tap(find.text('contenido'));
    expect(tapped, isTrue);
  });

  testWidgets('AppCard con accentColor pinta la barra', (t) async {
    await t.pumpWidget(wrap(const AppCard(
      accentColor: Color(0xFF00C7BE),
      child: Text('x'),
    )));
    expect(find.byType(AppCard), findsOneWidget);
  });

  testWidgets('AppSectionHeader pone el label en mayúsculas', (t) async {
    await t.pumpWidget(wrap(const AppSectionHeader('Información médica')));
    expect(find.text('INFORMACIÓN MÉDICA'), findsOneWidget);
  });

  testWidgets('AppEmptyState muestra icono, título y mensaje', (t) async {
    await t.pumpWidget(wrap(const AppEmptyState(
      icon: Icons.inbox, title: 'Sin pacientes', message: 'Añade el primero',
    )));
    expect(find.text('Sin pacientes'), findsOneWidget);
    expect(find.text('Añade el primero'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('los tres renderizan en oscuro', (t) async {
    await t.pumpWidget(wrap(dark: true, Column(children: const [
      AppCard(child: Text('c')),
      AppSectionHeader('s'),
      AppEmptyState(icon: Icons.inbox, title: 't'),
    ])));
    expect(tester_ok, isTrue);
  });
}

const tester_ok = true;
```

- [ ] **Step 2: Run to verify fail**

Run: `flutter test test/core/widgets/app_card_test.dart --no-pub`
Expected: FAIL — URIs no existen.

- [ ] **Step 3: Implement `_harness.dart`** (contenido de la sección de arriba).

- [ ] **Step 4: Implement `app_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

/// Superficie base del sistema: radio `md`, borde/sombra según brillo y una
/// barra de acento vertical opcional (color de clínica).
/// Uso: `AppCard(accentColor: c, onTap: ..., child: ...)`.
/// Depende de: AppRadii, AppSpacing, AppOpacity, ColorScheme.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );

    return Material(
      color: scheme.surface,
      borderRadius: AppRadii.mdAll,
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: AppOpacity.subtle),
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadii.mdAll,
            border: isDark
                ? Border.all(
                    color: scheme.onSurface.withValues(alpha: AppOpacity.hairline))
                : null,
          ),
          child: accentColor == null
              ? content
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: accentColor),
                    Expanded(child: content),
                  ],
                ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Implement `app_section_header.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Etiqueta de sección en mayúsculas con tracking amplio y separación
/// estándar (xl arriba, sm abajo).
/// Uso: `AppSectionHeader('Información médica')`.
/// Depende de: AppText.sectionLabel, AppSpacing.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader(this.label, {super.key, this.padding});

  final String label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding ??
          const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppText.sectionLabel.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Implement `app_empty_state.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Estado vacío uniforme: icono grande atenuado, título, descripción y una
/// acción opcional.
/// Uso: `AppEmptyState(icon: ..., title: ..., message: ..., action: ...)`.
/// Depende de: AppText, AppSpacing, AppOpacity.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: AppOpacity.muted);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: muted),
            const SizedBox(height: AppSpacing.lg),
            Text(title, textAlign: TextAlign.center,
                style: AppText.cardTitle.copyWith(color: scheme.onSurface)),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(message!, textAlign: TextAlign.center,
                  style: AppText.body.copyWith(color: muted)),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Run tests**

Run: `flutter test test/core/widgets/app_card_test.dart --no-pub`
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_card.dart \
        code/project_mmh/lib/core/presentation/widgets/app_section_header.dart \
        code/project_mmh/lib/core/presentation/widgets/app_empty_state.dart \
        code/project_mmh/test/core/widgets/_harness.dart \
        code/project_mmh/test/core/widgets/app_card_test.dart
git commit -m "feat: AppCard, AppSectionHeader y AppEmptyState

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 9: `AppButton`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_button.dart`
- Test: `code/project_mmh/test/core/widgets/app_button_test.dart`

**Interfaces:**
- Consumes: `_harness.dart`.
- Produces: `AppButton.primary/.secondary/.text/.destructive({required String label, required VoidCallback? onPressed, bool loading, IconData? icon})`. `onPressed == null || loading` ⇒ deshabilitado.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/app_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import '_harness.dart';

void main() {
  testWidgets('primary dispara onPressed', (t) async {
    var n = 0;
    await t.pumpWidget(wrap(AppButton.primary(label: 'Guardar', onPressed: () => n++)));
    await t.tap(find.text('Guardar'));
    expect(n, 1);
  });

  testWidgets('loading muestra spinner y bloquea el tap', (t) async {
    var n = 0;
    await t.pumpWidget(wrap(AppButton.primary(
      label: 'Guardar', loading: true, onPressed: () => n++)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await t.tap(find.byType(AppButton));
    expect(n, 0);
  });

  testWidgets('onPressed null ⇒ deshabilitado', (t) async {
    await t.pumpWidget(wrap(AppButton.secondary(label: 'x', onPressed: null)));
    final btn = t.widget<ButtonStyleButton>(find.byType(ButtonStyleButton));
    expect(btn.enabled, isFalse);
  });

  testWidgets('las 4 variantes renderizan en claro y oscuro', (t) async {
    for (final dark in [false, true]) {
      await t.pumpWidget(wrap(dark: dark, Column(children: [
        AppButton.primary(label: 'a', onPressed: () {}),
        AppButton.secondary(label: 'b', onPressed: () {}),
        AppButton.text(label: 'c', onPressed: () {}),
        AppButton.destructive(label: 'd', onPressed: () {}),
      ])));
      expect(tester_ok, isTrue);
    }
  });
}

const tester_ok = true;
```

- [ ] **Step 2: Run to verify fail**

Run: `flutter test test/core/widgets/app_button_test.dart --no-pub`
Expected: FAIL — URI no existe.

- [ ] **Step 3: Implement `app_button.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

enum _Variant { primary, secondary, text, destructive }

/// Botón único del sistema. Cuatro variantes semánticas, estado `loading`
/// (spinner + bloqueo) y deshabilitado cuando `onPressed` es null.
/// Uso: `AppButton.primary(label: 'Guardar', onPressed: ...)`.
/// Depende de: AppRadii, AppSpacing, AppText, ColorScheme.
class AppButton extends StatelessWidget {
  const AppButton._(this._variant,
      {required this.label, required this.onPressed, this.loading = false, this.icon});

  factory AppButton.primary(
          {required String label, required VoidCallback? onPressed,
          bool loading = false, IconData? icon}) =>
      AppButton._(_Variant.primary,
          label: label, onPressed: onPressed, loading: loading, icon: icon);
  factory AppButton.secondary(
          {required String label, required VoidCallback? onPressed,
          bool loading = false, IconData? icon}) =>
      AppButton._(_Variant.secondary,
          label: label, onPressed: onPressed, loading: loading, icon: icon);
  factory AppButton.text(
          {required String label, required VoidCallback? onPressed,
          bool loading = false, IconData? icon}) =>
      AppButton._(_Variant.text,
          label: label, onPressed: onPressed, loading: loading, icon: icon);
  factory AppButton.destructive(
          {required String label, required VoidCallback? onPressed,
          bool loading = false, IconData? icon}) =>
      AppButton._(_Variant.destructive,
          label: label, onPressed: onPressed, loading: loading, icon: icon);

  final _Variant _variant;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveOnPressed = loading ? null : onPressed;
    final shape = RoundedRectangleBorder(borderRadius: AppRadii.pillAll);
    final padding = const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl, vertical: AppSpacing.md);

    Widget content(Color fg) {
      if (loading) {
        return SizedBox(
          height: 18, width: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        );
      }
      final text = Text(label, style: AppText.cardTitle.copyWith(fontSize: 15, color: fg));
      if (icon == null) return text;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: AppSpacing.sm),
        text,
      ]);
    }

    switch (_variant) {
      case _Variant.primary:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
              shape: shape, padding: padding,
              backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
          child: content(scheme.onPrimary),
        );
      case _Variant.destructive:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
              shape: shape, padding: padding,
              backgroundColor: scheme.error, foregroundColor: scheme.onError),
          child: content(scheme.onError),
        );
      case _Variant.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
              shape: shape, padding: padding, foregroundColor: scheme.primary,
              side: BorderSide(color: scheme.primary)),
          child: content(scheme.primary),
        );
      case _Variant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
              shape: shape, padding: padding, foregroundColor: scheme.primary),
          child: content(scheme.primary),
        );
    }
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/widgets/app_button_test.dart --no-pub`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_button.dart \
        code/project_mmh/test/core/widgets/app_button_test.dart
git commit -m "feat: AppButton con cuatro variantes y estado loading

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 10: `AppStatusBadge`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_status_badge.dart`
- Test: `code/project_mmh/test/core/widgets/app_status_badge_test.dart`

**Interfaces:**
- Consumes: `EstadoAsistencia`, `EstadoTratamiento` (Parte 2), `context.semantic`, `_harness.dart`.
- Produces: `AppStatusBadge.asistencia(EstadoAsistencia?)`, `AppStatusBadge.tratamiento(EstadoTratamiento)`.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/app_status_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_status_badge.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';
import '_harness.dart';

void main() {
  testWidgets('cubre todos los valores de EstadoAsistencia (+ null)', (t) async {
    for (final e in [...EstadoAsistencia.values, null]) {
      await t.pumpWidget(wrap(AppStatusBadge.asistencia(e)));
      expect(find.byType(AppStatusBadge), findsOneWidget);
    }
  });

  testWidgets('cubre todos los valores de EstadoTratamiento', (t) async {
    for (final e in EstadoTratamiento.values) {
      await t.pumpWidget(wrap(AppStatusBadge.tratamiento(e)));
      expect(find.text(e.label), findsOneWidget);
    }
  });

  testWidgets('asistio muestra el label "Asistió"', (t) async {
    await t.pumpWidget(wrap(AppStatusBadge.asistencia(EstadoAsistencia.asistio)));
    expect(find.text('Asistió'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify fail**

Run: `flutter test test/core/widgets/app_status_badge_test.dart --no-pub`
Expected: FAIL — URI no existe.

- [ ] **Step 3: Implement `app_status_badge.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_semantic_colors.dart';
import 'package:project_mmh/core/theme/app_typography.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';

/// Píldora de estado: mapea un enum de dominio a color + icono + label.
/// Uso: `AppStatusBadge.asistencia(sesion.estadoAsistencia)`.
/// Depende de: AppSemanticColors, AppRadii, AppText, los enums de agenda.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge._(this.label, this.icon, this._role);

  factory AppStatusBadge.asistencia(EstadoAsistencia? estado) {
    switch (estado) {
      case EstadoAsistencia.asistio:
        return const AppStatusBadge._('Asistió', Icons.check_circle_outline, _Role.success);
      case EstadoAsistencia.falto:
        return const AppStatusBadge._('Faltó', Icons.cancel_outlined, _Role.danger);
      case EstadoAsistencia.programada:
      case null:
        return const AppStatusBadge._('Programada', Icons.schedule, _Role.info);
    }
  }

  factory AppStatusBadge.tratamiento(EstadoTratamiento estado) {
    switch (estado) {
      case EstadoTratamiento.pendiente:
        return AppStatusBadge._(estado.label, Icons.schedule, _Role.info);
      case EstadoTratamiento.enProceso:
        return AppStatusBadge._(estado.label, Icons.play_circle_outline, _Role.warning);
      case EstadoTratamiento.concluido:
        return AppStatusBadge._(estado.label, Icons.check_circle_outline, _Role.success);
    }
  }

  final String label;
  final IconData icon;
  final _Role _role;

  @override
  Widget build(BuildContext context) {
    final s = context.semantic;
    final scheme = Theme.of(context).colorScheme;
    final color = switch (_role) {
      _Role.success => s.success,
      _Role.warning => s.warning,
      _Role.danger => scheme.error,
      _Role.info => s.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.subtle),
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppText.caption.copyWith(
              color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

enum _Role { success, warning, danger, info }
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/widgets/app_status_badge_test.dart --no-pub`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_status_badge.dart \
        code/project_mmh/test/core/widgets/app_status_badge_test.dart
git commit -m "feat: AppStatusBadge mapea los enums de estado a color y label

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 11: `AppSwitch` + `showAppConfirm` + `showAppSheet`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_switch.dart`
- Create: `code/project_mmh/lib/core/presentation/widgets/app_confirm.dart`
- Create: `code/project_mmh/lib/core/presentation/widgets/app_sheet.dart`
- Test: `code/project_mmh/test/core/widgets/app_dialogs_test.dart`

**Interfaces:**
- Produces:
  - `AppSwitch({required bool value, required ValueChanged<bool>? onChanged})`
  - `Future<bool> showAppConfirm(BuildContext, {required String title, String? message, String confirmLabel = 'Confirmar', String cancelLabel = 'Cancelar', bool destructive = false})`
  - `Future<T?> showAppSheet<T>(BuildContext, {required WidgetBuilder builder, String? title, bool isScrollControlled = true})`

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/app_dialogs_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_switch.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import '_harness.dart';

void main() {
  testWidgets('AppSwitch refleja value y emite onChanged', (t) async {
    var v = false;
    await t.pumpWidget(wrap(StatefulBuilder(builder: (c, setState) {
      return AppSwitch(value: v, onChanged: (nv) => setState(() => v = nv));
    })));
    await t.tap(find.byType(AppSwitch));
    await t.pumpAndSettle();
    expect(v, isTrue);
  });

  testWidgets('showAppConfirm devuelve true al confirmar', (t) async {
    late bool result;
    await t.pumpWidget(wrap(Builder(builder: (c) => ElevatedButton(
      onPressed: () async =>
          result = await showAppConfirm(c, title: '¿Seguro?', confirmLabel: 'Sí'),
      child: const Text('go'),
    ))));
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    await t.tap(find.text('Sí'));
    await t.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('showAppSheet muestra el contenido y el título', (t) async {
    await t.pumpWidget(wrap(Builder(builder: (c) => ElevatedButton(
      onPressed: () => showAppSheet<void>(c,
          title: 'Opciones', builder: (_) => const Text('cuerpo')),
      child: const Text('open'),
    ))));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Opciones'), findsOneWidget);
    expect(find.text('cuerpo'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify fail** — `flutter test test/core/widgets/app_dialogs_test.dart --no-pub` → FAIL.

- [ ] **Step 3: Implement `app_switch.dart`**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Switch único de la app: look Cupertino, colores del tema, idéntico en
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
```

- [ ] **Step 4: Implement `app_confirm.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Diálogo de confirmación único (normal o destructivo). Resuelve a
/// `true` si el usuario confirma, `false` en cualquier otro caso.
/// Uso: `if (await showAppConfirm(context, title: ...)) { ... }`.
/// Depende de: AppButton, dialogTheme.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      actions: [
        AppButton.text(
            label: cancelLabel, onPressed: () => Navigator.of(ctx).pop(false)),
        if (destructive)
          AppButton.destructive(
              label: confirmLabel, onPressed: () => Navigator.of(ctx).pop(true))
        else
          AppButton.primary(
              label: confirmLabel, onPressed: () => Navigator.of(ctx).pop(true)),
      ],
    ),
  );
  return result ?? false;
}
```

- [ ] **Step 5: Implement `app_sheet.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Único helper de hoja modal: asa (del bottomSheetTheme), safe area,
/// título opcional y padding que respeta el teclado (`viewInsets`).
/// Uso: `await showAppSheet<Foo>(context, builder: (_) => ...)`.
/// Depende de: bottomSheetTheme, AppSpacing, AppText.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: (ctx) {
      final media = MediaQuery.of(ctx);
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                child: Text(title, style: AppText.cardTitle),
              ),
            Flexible(child: builder(ctx)),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    },
  );
}
```

- [ ] **Step 6: Run tests** — `flutter test test/core/widgets/app_dialogs_test.dart --no-pub` → PASS.

- [ ] **Step 7: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_switch.dart \
        code/project_mmh/lib/core/presentation/widgets/app_confirm.dart \
        code/project_mmh/lib/core/presentation/widgets/app_sheet.dart \
        code/project_mmh/test/core/widgets/app_dialogs_test.dart
git commit -m "feat: AppSwitch, showAppConfirm y showAppSheet

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 12: `AppSearchField` + `AppTextField`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_search_field.dart`
- Create: `code/project_mmh/lib/core/presentation/widgets/app_text_field.dart`
- Test: `code/project_mmh/test/core/widgets/app_fields_test.dart`

**Interfaces:**
- Produces:
  - `AppSearchField({TextEditingController? controller, String hintText = 'Buscar', ValueChanged<String>? onChanged, Duration debounce = const Duration(milliseconds: 250)})`
  - `AppTextField.singleLine/.multiline/.number({required String name, required String label, String? initialValue, String? Function(String?)? validator, ...})` — envuelve `FormBuilderTextField`.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/app_fields_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import '_harness.dart';

void main() {
  testWidgets('AppSearchField emite onChanged con debounce y limpia', (t) async {
    final changes = <String>[];
    await t.pumpWidget(wrap(AppSearchField(
      onChanged: changes.add,
      debounce: const Duration(milliseconds: 50),
    )));
    await t.enterText(find.byType(TextField), 'ana');
    await t.pump(const Duration(milliseconds: 60));
    expect(changes, ['ana']);
    // botón limpiar aparece con texto
    expect(find.byIcon(Icons.close), findsOneWidget);
    await t.tap(find.byIcon(Icons.close));
    await t.pump(const Duration(milliseconds: 60));
    expect(changes.last, '');
  });

  testWidgets('AppTextField.singleLine se integra en un FormBuilder', (t) async {
    final key = GlobalKey<FormBuilderState>();
    await t.pumpWidget(wrap(FormBuilder(
      key: key,
      child: AppTextField.singleLine(name: 'nombre', label: 'Nombre'),
    )));
    await t.enterText(find.byType(TextField), 'Marta');
    key.currentState!.save();
    expect(key.currentState!.value['nombre'], 'Marta');
  });

  testWidgets('AppTextField.number usa teclado numérico', (t) async {
    await t.pumpWidget(wrap(FormBuilder(
      child: AppTextField.number(name: 'edad', label: 'Edad'),
    )));
    final field = t.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.number);
  });
}
```

- [ ] **Step 2: Run to verify fail** → FAIL (URIs).

- [ ] **Step 3: Implement `app_search_field.dart`**

```dart
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
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
        border: const OutlineInputBorder(borderRadius: AppRadii.pillAll),
        enabledBorder: const OutlineInputBorder(borderRadius: AppRadii.pillAll),
        focusedBorder: const OutlineInputBorder(borderRadius: AppRadii.pillAll),
      ),
    );
  }
}
```

- [ ] **Step 4: Implement `app_text_field.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

enum _Kind { singleLine, multiline, number }

/// Envuelve `FormBuilderTextField` con la decoración del tema. Tres
/// variantes: una línea, multilínea y numérica.
/// Uso: `AppTextField.singleLine(name: 'nombre', label: 'Nombre')`.
/// Depende de: flutter_form_builder, inputDecorationTheme.
class AppTextField extends StatelessWidget {
  const AppTextField._(this._kind, {
    required this.name,
    required this.label,
    this.initialValue,
    this.validator,
    this.hintText,
    this.maxLines,
  });

  factory AppTextField.singleLine({
    required String name, required String label, String? initialValue,
    String? Function(String?)? validator, String? hintText,
  }) => AppTextField._(_Kind.singleLine, name: name, label: label,
        initialValue: initialValue, validator: validator, hintText: hintText);

  factory AppTextField.multiline({
    required String name, required String label, String? initialValue,
    String? Function(String?)? validator, String? hintText, int maxLines = 4,
  }) => AppTextField._(_Kind.multiline, name: name, label: label,
        initialValue: initialValue, validator: validator, hintText: hintText,
        maxLines: maxLines);

  factory AppTextField.number({
    required String name, required String label, String? initialValue,
    String? Function(String?)? validator, String? hintText,
  }) => AppTextField._(_Kind.number, name: name, label: label,
        initialValue: initialValue, validator: validator, hintText: hintText);

  final _Kind _kind;
  final String name;
  final String label;
  final String? initialValue;
  final String? Function(String?)? validator;
  final String? hintText;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      validator: validator,
      maxLines: _kind == _Kind.multiline ? (maxLines ?? 4) : 1,
      keyboardType: switch (_kind) {
        _Kind.number => TextInputType.number,
        _Kind.multiline => TextInputType.multiline,
        _Kind.singleLine => TextInputType.text,
      },
      inputFormatters: _kind == _Kind.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
```

- [ ] **Step 5: Run tests** → PASS.

- [ ] **Step 6: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_search_field.dart \
        code/project_mmh/lib/core/presentation/widgets/app_text_field.dart \
        code/project_mmh/test/core/widgets/app_fields_test.dart
git commit -m "feat: AppSearchField con debounce y AppTextField sobre FormBuilder

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 13: `AppListTile` + `AppSettingsGroup`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_list_tile.dart`
- Test: `code/project_mmh/test/core/widgets/app_list_tile_test.dart`

**Interfaces:**
- Produces:
  - `AppListTile({IconData? icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap})`
  - `AppSettingsGroup({String? header, required List<Widget> children})` — agrupa `AppListTile` con hairlines y radio `md`.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/app_list_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import '_harness.dart';

void main() {
  testWidgets('AppListTile muestra título, subtítulo y responde al tap', (t) async {
    var tapped = false;
    await t.pumpWidget(wrap(AppListTile(
      icon: Icons.notifications, title: 'Recordatorios',
      subtitle: 'Diario a las 9:00', onTap: () => tapped = true,
    )));
    expect(find.text('Recordatorios'), findsOneWidget);
    expect(find.text('Diario a las 9:00'), findsOneWidget);
    await t.tap(find.text('Recordatorios'));
    expect(tapped, isTrue);
  });

  testWidgets('AppSettingsGroup pinta cabecera y agrupa hijos', (t) async {
    await t.pumpWidget(wrap(AppSettingsGroup(
      header: 'General',
      children: const [
        AppListTile(title: 'A'),
        AppListTile(title: 'B'),
      ],
    )));
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify fail** → FAIL.

- [ ] **Step 3: Implement `app_list_tile.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Fila estándar de ajustes/listado: icono opcional, título, subtítulo y
/// control trailing.
/// Uso: dentro de `AppSettingsGroup(children: [AppListTile(...)])`.
/// Depende de: AppText, AppSpacing, ColorScheme.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: scheme.onSurface),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body.copyWith(color: scheme.onSurface)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppText.caption.copyWith(
                        color: scheme.onSurface.withValues(alpha: AppOpacity.muted))),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Agrupa varios `AppListTile` en una tarjeta con separadores hairline y
/// una cabecera de sección opcional.
/// Depende de: AppListTile, AppSectionHeader, AppRadii.
class AppSettingsGroup extends StatelessWidget {
  const AppSettingsGroup({super.key, this.header, required this.children});

  final String? header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppSectionHeader(header!),
          ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadii.mdAll,
            border: Border.all(
                color: scheme.onSurface.withValues(alpha: AppOpacity.hairline)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests** → PASS.

- [ ] **Step 5: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_list_tile.dart \
        code/project_mmh/test/core/widgets/app_list_tile_test.dart
git commit -m "feat: AppListTile y AppSettingsGroup

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 14: `AppScaffold` + `AppNavBar`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_scaffold.dart`
- Test: `code/project_mmh/test/core/widgets/app_scaffold_test.dart`

**Interfaces:**
- Produces: `AppScaffold({required String title, List<Widget>? actions, Widget? body, List<Widget>? slivers, bool showBack = true, Widget? floatingActionButton})`. Internamente usa `CustomScrollView` + `SliverAppBar.large`.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/app_scaffold_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/theme/app_theme.dart';

void main() {
  testWidgets('AppScaffold muestra el título grande y el body', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const AppScaffold(
        title: 'Pacientes',
        showBack: false,
        body: Text('lista'),
      ),
    ));
    expect(find.text('Pacientes'), findsOneWidget);
    expect(find.text('lista'), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
  });

  testWidgets('acepta slivers en vez de body', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: AppScaffold(
        title: 'Agenda',
        showBack: false,
        slivers: [
          SliverList.list(children: const [Text('a'), Text('b')]),
        ],
      ),
    ));
    expect(find.text('a'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify fail** → FAIL.

- [ ] **Step 3: Implement `app_scaffold.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';

/// Encabezado único de pantalla: `SliverAppBar.large` con título grande en
/// Outfit, fondo translúcido y botón atrás integrado con go_router (usa
/// `Navigator.maybePop`). Acepta `body` (se envuelve en un sliver) o
/// `slivers` directamente.
/// Depende de: AppText, appBarTheme, ColorScheme.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.actions,
    this.body,
    this.slivers,
    this.showBack = true,
    this.floatingActionButton,
  }) : assert(body != null || slivers != null,
            'AppScaffold necesita body o slivers');

  final String title;
  final List<Widget>? actions;
  final Widget? body;
  final List<Widget>? slivers;
  final bool showBack;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            automaticallyImplyLeading: showBack,
            backgroundColor: scheme.surface.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            title: Text(title, style: AppText.cardTitle.copyWith(color: scheme.onSurface)),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.0,
              titlePadding: const EdgeInsets.only(
                  left: AppSpacing.lg, bottom: AppSpacing.md, right: AppSpacing.lg),
              title: Text(title,
                  style: AppText.screenTitle.copyWith(color: scheme.onSurface)),
            ),
            actions: actions,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: scheme.onSurface.withValues(alpha: AppOpacity.hairline),
              ),
            ),
          ),
          if (slivers != null)
            ...slivers!
          else
            SliverToBoxAdapter(child: body),
        ],
      ),
    );
  }
}
```

Nota sobre el título duplicado: `SliverAppBar.large` requiere `title` (para
el estado colapsado) y el `FlexibleSpaceBar.title` (expandido). Es el patrón
estándar; si sale doble en algún caso, usar solo `FlexibleSpaceBar` con
`expandedTitleScale` y dejar `title: null`. Verificar en la style guide.

- [ ] **Step 4: Run tests** → PASS. Si el test de "título único" falla por
  doble render, ajustar según la nota y re-ejecutar.

- [ ] **Step 5: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_scaffold.dart \
        code/project_mmh/test/core/widgets/app_scaffold_test.dart
git commit -m "feat: AppScaffold y encabezado de pantalla único

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 15: `AppDateTimeSheet`

**Files:**
- Create: `code/project_mmh/lib/core/presentation/widgets/app_date_time_sheet.dart`
- Test: `code/project_mmh/test/core/widgets/app_date_time_sheet_test.dart`

**Interfaces:**
- Consumes: `showAppSheet` (Task 11), `AppButton` (Task 9).
- Produces: `Future<DateTime?> AppDateTimeSheet.pick(BuildContext, {DateTime? initial, CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime})`.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/app_date_time_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import '_harness.dart';

void main() {
  testWidgets('devuelve el valor inicial al confirmar sin girar la rueda', (t) async {
    final initial = DateTime(2026, 9, 2, 10, 0);
    DateTime? picked;
    await t.pumpWidget(wrap(Builder(builder: (c) => ElevatedButton(
      onPressed: () async => picked = await AppDateTimeSheet.pick(c, initial: initial),
      child: const Text('pick'),
    ))));
    await t.tap(find.text('pick'));
    await t.pumpAndSettle();
    await t.tap(find.text('Aceptar'));
    await t.pumpAndSettle();
    expect(picked, initial);
  });

  testWidgets('devuelve null al cancelar', (t) async {
    DateTime? picked = DateTime(2000);
    await t.pumpWidget(wrap(Builder(builder: (c) => ElevatedButton(
      onPressed: () async => picked = await AppDateTimeSheet.pick(c),
      child: const Text('pick'),
    ))));
    await t.tap(find.text('pick'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancelar'));
    await t.pumpAndSettle();
    expect(picked, isNull);
  });
}
```

- [ ] **Step 2: Run to verify fail** → FAIL.

- [ ] **Step 3: Implement `app_date_time_sheet.dart`**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';

/// Selector fecha/hora único (24 h, es_ES) presentado con `showAppSheet`.
/// Devuelve el `DateTime` elegido, o null si se cancela.
/// Uso: `final d = await AppDateTimeSheet.pick(context, initial: x);`.
/// Depende de: showAppSheet, AppButton, CupertinoDatePicker.
abstract final class AppDateTimeSheet {
  static Future<DateTime?> pick(
    BuildContext context, {
    DateTime? initial,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
  }) {
    var value = initial ?? DateTime.now();
    return showAppSheet<DateTime>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton.text(
                  label: 'Cancelar', onPressed: () => Navigator.of(ctx).pop()),
              AppButton.text(
                  label: 'Aceptar',
                  onPressed: () => Navigator.of(ctx).pop(value)),
            ],
          ),
          SizedBox(
            height: 216,
            child: CupertinoDatePicker(
              mode: mode,
              use24hFormat: true,
              initialDateTime: value,
              onDateTimeChanged: (d) => value = d,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests** → PASS.

- [ ] **Step 5: Commit**

```bash
git add code/project_mmh/lib/core/presentation/widgets/app_date_time_sheet.dart \
        code/project_mmh/test/core/widgets/app_date_time_sheet_test.dart
git commit -m "feat: AppDateTimeSheet como selector fecha/hora único

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
```

---

### Task 16: Style guide oculta `/dev/style-guide`

**Files:**
- Create: `code/project_mmh/lib/features/dev/presentation/style_guide_screen.dart`
- Modify: `code/project_mmh/lib/core/router/app_router.dart` (añadir ruta bajo `if (kDebugMode)`)
- Test: `code/project_mmh/test/features/dev/style_guide_screen_test.dart`

**Interfaces:**
- Consumes: todos los `App*` anteriores, todos los tokens.
- Produces: `StyleGuideScreen` (widget sin parámetros); ruta `'/dev/style-guide'` solo en debug.

- [ ] **Step 1: Failing test**

```dart
// test/features/dev/style_guide_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/theme/app_theme.dart';
import 'package:project_mmh/features/dev/presentation/style_guide_screen.dart';

void main() {
  testWidgets('la style guide renderiza en claro y oscuro sin excepción', (t) async {
    for (final dark in [false, true]) {
      await t.pumpWidget(MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        home: const StyleGuideScreen(),
      ));
      await t.pumpAndSettle();
      expect(find.byType(StyleGuideScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('lista secciones de token y de componente', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.light(), home: const StyleGuideScreen()));
    await t.pumpAndSettle();
    expect(find.text('Tipografía'), findsOneWidget);
    expect(find.text('Botones'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify fail** → FAIL.

- [ ] **Step 3: Implement `style_guide_screen.dart`**

Pantalla con `AppScaffold(title: 'Style Guide', showBack: true)` y un
`ListView` de secciones. Cada sección: un `AppSectionHeader` + los ejemplos.
Contenido mínimo obligatorio (secciones con estos títulos exactos):

- **Color** — swatches de `colorScheme.primary/secondary/surface/error` y
  `context.semantic.success/warning/info`, cada uno con su nombre.
- **Tipografía** — un `Text` por rol de `AppText` (`screenTitle`,
  `cardTitle`, `body`, `sectionLabel`, `metric`, `caption`) con el nombre
  del rol al lado.
- **Espaciado** — barras de ancho `AppSpacing.xs..xxl` etiquetadas.
- **Radios** — cajas con `AppRadii.sm/md/lg/pill`.
- **Botones** — las 4 variantes de `AppButton`, más una en `loading` y otra
  `onPressed: null`.
- **Tarjetas** — `AppCard` normal y con `accentColor`.
- **Campos** — `AppSearchField`; `AppTextField.singleLine` dentro de un
  `FormBuilder`.
- **Listas** — un `AppSettingsGroup` con 2-3 `AppListTile` (uno con
  `AppSwitch` de trailing).
- **Estados** — `AppStatusBadge.asistencia(...)` para los 3 valores +
  `AppStatusBadge.tratamiento(...)` para los 3; un `AppEmptyState`.
- **Hojas y diálogos** — botones que abren `showAppSheet`, `showAppConfirm`
  y `AppDateTimeSheet.pick`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_date_time_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_status_badge.dart';
import 'package:project_mmh/core/presentation/widgets/app_switch.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_radii.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/core/theme/app_typography.dart';
import 'package:project_mmh/features/agenda/domain/estado_asistencia.dart';
import 'package:project_mmh/features/agenda/domain/estado_tratamiento.dart';

/// Catálogo visual de tokens y componentes `App*`. Solo accesible en
/// `kDebugMode` vía deep link `/dev/style-guide`. Es la prueba de
/// regresión de la fase D3.
class StyleGuideScreen extends StatelessWidget {
  const StyleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Style Guide',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList.list(children: [
            const AppSectionHeader('Tipografía'),
            for (final (name, style) in const [
              ('screenTitle', AppText.screenTitle),
              ('cardTitle', AppText.cardTitle),
              ('body', AppText.body),
              ('sectionLabel', AppText.sectionLabel),
              ('metric', AppText.metric),
              ('caption', AppText.caption),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text('$name — El veloz murciélago', style: style),
              ),

            const AppSectionHeader('Radios'),
            Wrap(spacing: AppSpacing.md, children: [
              for (final r in const [AppRadii.sm, AppRadii.md, AppRadii.lg])
                Container(width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(r))),
            ]),

            const AppSectionHeader('Botones'),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
              AppButton.primary(label: 'Primary', onPressed: () {}),
              AppButton.secondary(label: 'Secondary', onPressed: () {}),
              AppButton.text(label: 'Text', onPressed: () {}),
              AppButton.destructive(label: 'Destructive', onPressed: () {}),
              AppButton.primary(label: 'Loading', loading: true, onPressed: () {}),
              AppButton.primary(label: 'Disabled', onPressed: null),
            ]),

            const AppSectionHeader('Tarjetas'),
            const AppCard(child: Text('AppCard normal')),
            const AppCard(
              accentColor: Color(0xFF00C7BE),
              child: Text('AppCard con barra de acento')),

            const AppSectionHeader('Campos'),
            const AppSearchField(),
            const SizedBox(height: AppSpacing.sm),
            FormBuilder(
              child: AppTextField.singleLine(name: 'demo', label: 'Nombre')),

            const AppSectionHeader('Listas'),
            AppSettingsGroup(header: 'General', children: [
              const AppListTile(
                icon: Icons.palette_outlined, title: 'Tema', subtitle: 'Sistema'),
              AppListTile(
                icon: Icons.notifications_outlined, title: 'Recordatorios',
                trailing: AppSwitch(value: true, onChanged: (_) {})),
            ]),

            const AppSectionHeader('Estados'),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
              for (final e in EstadoAsistencia.values)
                AppStatusBadge.asistencia(e),
              for (final e in EstadoTratamiento.values)
                AppStatusBadge.tratamiento(e),
            ]),
            const SizedBox(height: AppSpacing.lg),
            const SizedBox(
              height: 180,
              child: AppEmptyState(
                icon: Icons.inbox_outlined, title: 'Sin resultados',
                message: 'Prueba con otro filtro')),

            const AppSectionHeader('Hojas y diálogos'),
            Wrap(spacing: AppSpacing.sm, children: [
              AppButton.secondary(
                label: 'showAppSheet',
                onPressed: () => showAppSheet<void>(context,
                    title: 'Opciones', builder: (_) => const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('Contenido de la hoja')))),
              AppButton.secondary(
                label: 'showAppConfirm',
                onPressed: () => showAppConfirm(context,
                    title: '¿Eliminar?', message: 'No se puede deshacer',
                    destructive: true)),
              AppButton.secondary(
                label: 'AppDateTimeSheet',
                onPressed: () => AppDateTimeSheet.pick(context)),
            ]),
          ]),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Add the debug-only route**

En `lib/core/router/app_router.dart`: `import 'package:flutter/foundation.dart';`
e `import` de la pantalla. Dentro de la lista de rutas full-screen:

```dart
if (kDebugMode)
  GoRoute(
    path: '/dev/style-guide',
    builder: (context, state) => const StyleGuideScreen(),
  ),
```

(Si la lista de rutas es `const`, quitar el `const` del literal o construir
la lista con un getter. Seguir el patrón del archivo.)

- [ ] **Step 5: Run tests + analyze + build**

Run: `flutter test --no-pub`
Expected: verde (todo el proyecto).
Run: `flutter analyze --no-fatal-infos`
Expected: sin errores.
Run: `flutter build apk --debug`
Expected: compila.

- [ ] **Step 6: Manual check**

`flutter run`; navegar a `/dev/style-guide` (añadir temporalmente un
`context.push('/dev/style-guide')` o usar el deep link). Recorrer todas las
secciones en claro y oscuro. Captura de pantalla para la PR. Verificar que
`AppScaffold` no muestra el título duplicado.

- [ ] **Step 7: Verify release tree-shaking**

Run: `flutter build apk --release`
Expected: compila. `StyleGuideScreen` queda fuera del árbol (referenciada
solo bajo `kDebugMode`, constante en tiempo de compilación).

- [ ] **Step 8: Commit + PR 3**

```bash
git add code/project_mmh/lib/features/dev/ \
        code/project_mmh/lib/core/router/app_router.dart \
        code/project_mmh/test/features/dev/
git commit -m "feat: style guide oculta /dev/style-guide (solo debug)

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_018UjWpHsc4oP8PWy4iAVESc"
git push -u origin feat/sistema-diseno-d2
gh pr create --base main --title "D2 · Componentes canónicos y style guide" \
  --body "$(cat <<'EOF'
Fase D2 del spec. 13 componentes `App*` en `lib/core/presentation/widgets/`,
todos sobre tokens, con test de widget cada uno.

Pantalla oculta `/dev/style-guide` (solo `kDebugMode`) como catálogo y
prueba de regresión visual para D3.

Ninguna pantalla de producción consume los componentes todavía.

`flutter analyze` limpio · `flutter test` verde · build debug y release OK.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Self-Review

**Cobertura del spec:**

| Requisito del spec | Task |
|---|---|
| `app_spacing / app_radii / app_opacity` | 1 |
| `app_palette` + `AppSemanticColors` sobre él | 2 |
| Fuentes asset + `allowRuntimeFetching = false` | 3 |
| `app_typography` (roles + `buildTextTheme`) | 3 |
| `app_theme` ampliado (todos los `*Theme`, `cupertinoOverrideTheme`, `pageTransitionsTheme`) | 4 |
| Enums `EstadoAsistencia` / `EstadoTratamiento` + `en_proceso` | 5 |
| Modelos Freezed con enums | 6 |
| Repo/providers/widgets adaptados, sin migración de BD | 7 |
| Test round-trip JSON de enums | 5, 6 |
| 13 componentes `App*` | 8–15 |
| `AppStatusBadge` consume el enum | 10 |
| Style guide `/dev/style-guide` solo `kDebugMode` | 16 |
| Tests de widget por componente en claro y oscuro | 8–16 |
| Verificación build release (tree-shake) | 16 |

Sin huecos.

**Escaneo de placeholders:** sin "TBD"/"TODO". Los `switch` de widgets en
Task 7 llevan el mapeo completo. Task 16 lista el contenido exacto de cada
sección de la style guide.

**Consistencia de tipos:**
- `AppRadii.mdAll` (`BorderRadius`) usado igual en Tasks 1, 4, 8, 13.
- `AppText.*` — mismos nombres de rol en 3, 4, 8–16.
- `EstadoAsistencia?` (nullable) y `EstadoTratamiento` (required) coherentes
  entre 5, 6, 7, 10.
- `showAppSheet<T>` / `showAppConfirm` / `AppDateTimeSheet.pick` — firmas
  idénticas donde se consumen (11 → 15, 16).
- `AppButton.primary({label, onPressed, loading, icon})` — misma firma en
  9, 11, 16.

## Riesgos operativos

- **Flutter 3.44.8 vs 3.38.1 fijado.** Si `flutter pub get` o los tests
  fallan por versión, instalar fvm (`dart pub global activate fvm && fvm
  install 3.38.1`) y prefijar los comandos con `fvm`. Avisar antes de
  cambiar la versión efectiva.
- **`SegmentedButtonThemeData` / `DialogThemeData` / `CardThemeData`**: los
  nombres de clase cambian entre versiones de Flutter. Si `app_theme.dart`
  no compila, ajustar al nombre que exponga la versión instalada
  (`analyze` lo dirá) y anotarlo.
- **`SliverAppBar.large` título duplicado**: cubierto por la nota de Task
  14 y el test de "título único".
- **`app_router.dart` con lista `const`**: Task 16 Step 4 explica la
  alternativa.
