# Sistema de Diseño Klinik — Spec de D1, D1.5 y D2

Fecha: 2026-08-30
Rama base: `main`
Artefacto de origen: "Sistema de Diseño Klinik" (plan v1)

Este spec cubre únicamente las fases **fundacionales** del plan: D1 (tokens +
tema + fuentes), D1.5 (migración de enums de estado) y D2 (componentes
canónicos + style guide). D3 (migración pantalla por pantalla) y D4
(guardarraíl) se especifican por separado cuando D2 esté cerrada.

## Objetivo y propiedad invariante

Convertir la identidad de Klinik en una única fuente de verdad de tokens y
componentes. **D1 y D1.5 no cambian nada visible en producción**; D2 solo
añade una pantalla de desarrollo oculta. La primera pantalla de usuario que
cambia es la primera PR de D3.

Cada PR se valida con:

```bash
flutter analyze --no-fatal-infos
flutter test --no-pub
```

D1 y D2 añaden además una captura de la style guide (D2) o una nota de "sin
cambios visibles" (D1, D1.5).

## Decisiones cerradas

1. **Chasis Material + gestos iOS.** La estructura (MaterialApp, ThemeData
   M3, Scaffold, NavigationBar, rutas go_router) es Material. Se conservan
   gestos iOS donde ya son idiomáticos: swipe-back / push horizontal,
   hoja modal con asa, `CupertinoSwitch`, `CupertinoDatePicker`. Un
   `cupertinoOverrideTheme` hace que los widgets Cupertino hereden marca,
   brillo y fuente.
2. **Segunda fuente de cuerpo: IBM Plex Sans.** Outfit se reserva para
   títulos, `sectionLabel` y `metric`. IBM Plex Sans para `body`,
   `caption`, texto de campos y subtítulos. Ambas empaquetadas como asset.
3. **Migración de enums = PR propia (D1.5)**, entre D1 y D2. El `name` del
   enum coincide con el string actual en BD, así que no hay migración de
   esquema ni bump de versión. `AppStatusBadge` (D2) se construye ya
   contra el enum.

---

# D1 — Fundamentos de tokens

Riesgo: bajo. Sin tocar pantallas. Una sola PR.

## D1.a — Fuentes como asset (arregla el fallo offline-first)

### Problema

`app_theme.dart` usa `GoogleFonts.outfit(...)` en ~20 sitios. `google_fonts`
descarga el `.ttf` por red en el primer arranque. En una app offline-first,
sin conexión en el primer uso la tipografía cae a la fuente del sistema.

### Cambio

1. Añadir los `.ttf` a `lib/assets/fonts/`:
   - `Outfit-Regular.ttf` (400), `Outfit-Medium.ttf` (500),
     `Outfit-SemiBold.ttf` (600), `Outfit-Bold.ttf` (700)
   - `IBMPlexSans-Regular.ttf` (400), `IBMPlexSans-Medium.ttf` (500),
     `IBMPlexSans-SemiBold.ttf` (600), `IBMPlexSans-Italic.ttf` (400 italic)

   Origen (licencia OFL):
   - Outfit: `https://github.com/googlefonts/outfit` (`fonts/ttf/`)
   - IBM Plex Sans: `https://github.com/IBM/plex` (`packages/plex-sans/src/fonts/complete/ttf/`)

   Descarga en el paso de implementación vía `curl`. Si no hay red, se
   entrega la lista y el usuario los coloca.

2. `pubspec.yaml` → `flutter:`:

   ```yaml
   fonts:
     - family: Outfit
       fonts:
         - asset: lib/assets/fonts/Outfit-Regular.ttf
         - asset: lib/assets/fonts/Outfit-Medium.ttf
           weight: 500
         - asset: lib/assets/fonts/Outfit-SemiBold.ttf
           weight: 600
         - asset: lib/assets/fonts/Outfit-Bold.ttf
           weight: 700
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

3. `lib/main.dart`, al inicio de `main()`:

   ```dart
   GoogleFonts.config.allowRuntimeFetching = false;
   ```

   (Se mantiene `google_fonts` como dependencia por ahora; el objetivo es
   que no haga ninguna llamada de red. En D3/D4 se puede eliminar el
   paquete una vez que ningún archivo lo importe.)

4. Sustituir todas las llamadas `GoogleFonts.outfit(...)` de
   `app_theme.dart` por referencias a `AppTypography` (ver D1.d) o
   `TextStyle(fontFamily: 'Outfit', ...)` / `'IBM Plex Sans'`.

### Verificación

`flutter analyze` limpio; app compila; en un dispositivo/emulador en modo
avión desde una instalación limpia la tipografía Outfit se aplica en los
títulos.

## D1.b — Escalas primitivas y nombradas

Archivos nuevos en `lib/core/theme/`:

### `app_palette.dart` — primitivas (privado al paquete de tema)

Valores crudos, sin significado. Solo lo consume la capa semántica.

```dart
/// Primitivas. No usar fuera de lib/core/theme/.
abstract final class AppPalette {
  // Marca
  static const berry = Color(0xFFD81B60);
  static const berrySoft = Color(0xFFF8BBD0);
  static const berryDeep = Color(0xFF880E4F);
  static const berryPastel = Color(0xFFF48FB1);
  static const teal = Color(0xFF009688);
  static const tealPastel = Color(0xFF80CBC4);
  // Neutros claro / oscuro
  static const offWhite = Color(0xFFFAFAFA);
  static const white = Color(0xFFFFFFFF);
  static const inkLight = Color(0xFF37474F);
  static const grey900 = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const inkDark = Color(0xFFECEFF1);
  // Estado (los actuales de AppSemanticColors, movidos aquí)
  static const successLight = Color(0xFF2E7D32);
  // … resto de AppSemanticColors.light / .dark
  static const errorLight = Color(0xFFB00020);
  static const errorDark = Color(0xFFCF6679);
}
```

### `app_spacing.dart` — escala de 4 pt

```dart
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}
```

### `app_radii.dart` — 4 radios

```dart
abstract final class AppRadii {
  static const double sm = 8;    // chips, campos
  static const double md = 12;   // tarjetas, hojas
  static const double lg = 20;   // contenedores destacados
  static const double pill = 999; // CTAs, chips de filtro

  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
  static const pillAll = BorderRadius.all(Radius.circular(pill));
}
```

### `app_opacity.dart` — opacidades nombradas

```dart
abstract final class AppOpacity {
  static const double hairline = 0.08; // bordes muy sutiles
  static const double subtle = 0.12;   // indicadores, fondos de badge
  static const double muted = 0.40;    // texto/iconos deshabilitados
  static const double strong = 0.70;   // overlays
}
```

Los ~130 sitios con `withValues(alpha: 0.xx)` crudos se migran en D3, no
aquí. En D1 solo se declara la escala.

## D1.c — Tipografía: `app_typography.dart`

`TextTheme` construido desde los assets, más una clase `AppText` con roles
nombrados por uso.

```dart
abstract final class AppText {
  static const _display = 'Outfit';
  static const _body = 'IBM Plex Sans';

  static const screenTitle = TextStyle(
    fontFamily: _display, fontSize: 27, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, height: 1.15);
  static const cardTitle = TextStyle(
    fontFamily: _display, fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.2);
  static const body = TextStyle(
    fontFamily: _body, fontSize: 15, fontWeight: FontWeight.w400, height: 1.45);
  static const sectionLabel = TextStyle(
    fontFamily: _display, fontSize: 12, fontWeight: FontWeight.w600,
    letterSpacing: 1.6); // se usa con text-transform manual (toUpperCase)
  static const metric = TextStyle(
    fontFamily: _display, fontSize: 21, fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()]);
  static const caption = TextStyle(
    fontFamily: _body, fontSize: 13, fontWeight: FontWeight.w400);
}
```

Función `buildTextTheme(Brightness)` que mapea estos roles a los slots de
`TextTheme` M3 (para que widgets Material sin estilo explícito ya salgan
bien):

- `displayLarge/Medium/Small`, `headlineLarge` ← Outfit, pesos 700/600
- `titleLarge` ← `cardTitle`; `titleMedium/Small` ← Outfit 600/500
- `bodyLarge/Medium/Small` ← IBM Plex Sans 400
- `labelLarge/Medium` ← Outfit 600; `labelSmall` ← `sectionLabel`

Reemplaza `AppTheme._buildTextTheme`. Colores (`bodyColor`, `displayColor`)
se siguen aplicando con `.apply(...)` en `light()` / `dark()`.

## D1.d — `app_theme.dart` ampliado

Refactor de `AppTheme`:

- Los literales `_lightPrimary` etc. pasan a leer de `AppPalette`.
- `_scheme()` sin cambios de comportamiento (sigue `fromSeed(berry)` +
  `copyWith` de roles de marca).
- Añadir a `light()` y `dark()` (vía un helper `_common(ColorScheme,
  Brightness)` para no duplicar):

  | Propiedad | Contenido |
  |---|---|
  | `textTheme` | `buildTextTheme(brightness).apply(bodyColor, displayColor)` |
  | `pageTransitionsTheme` | `CupertinoPageTransitionsBuilder` para todas las plataformas (swipe-back) |
  | `cupertinoOverrideTheme` | `CupertinoThemeData(primaryColor: scheme.primary, brightness: brightness, applyThemeToAll: true, textTheme: CupertinoTextThemeData(...))` con fuente IBM Plex Sans / Outfit |
  | `inputDecorationTheme` | versión definitiva: `filled`, `fillColor: surfaceContainer`, radios `AppRadii.smAll`, borde `hairline` en enabled, `primary` 2px en focused, `error` en errorBorder, `contentPadding` `lg`/`md` |
  | `dialogTheme` | `DialogThemeData(shape: mdAll, backgroundColor: surface, titleTextStyle: AppText.cardTitle, contentTextStyle: AppText.body)` |
  | `bottomSheetTheme` | `BottomSheetThemeData(shape: top mdAll, backgroundColor: surface, showDragHandle: true, dragHandleColor: onSurface@muted, clipBehavior: antiAlias)` |
  | `chipTheme` | radio `pill`, `sectionLabel` sin uppercase-transform, colores de `AppSemanticColors` / `primary@subtle` |
  | `switchTheme` | pista/pulgar en `primary` / `onPrimary`, track off en `onSurface@subtle` |
  | `dividerTheme` | `DividerThemeData(color: onSurface@hairline, thickness: 1, space: 1)` |
  | `segmentedButtonTheme` | radio `sm`, selected `primary@subtle` / `primary`, texto `caption` |
  | `textSelectionTheme` | `cursorColor: primary`, `selectionColor: primary@subtle`, `selectionHandleColor: primary` |
  | `navigationBarTheme` | ya existe; migrar textos a `AppText` y opacidad a `AppOpacity.subtle` |
  | `appBarTheme` | conservar; `titleTextStyle` ← Outfit 600 (para Odontograma / pantallas de error hasta que D3 las migre) |
  | `snackBarTheme` | conservar; textos ← `AppText` |
  | `cardTheme` | radio `AppRadii.mdAll` (hoy 16 → 12), resto igual |

- `AppTheme.brandPink` se mantiene (lo consume `NotificationService`).

### Verificación D1

- `flutter analyze --no-fatal-infos` limpio.
- `flutter test --no-pub` verde (incluido `smoke_test.dart`).
- Recorrido manual de las pantallas principales: sin regresión visual
  perceptible (radios de tarjeta 16→12 es el único delta admitido y
  esperado).
- Modo avión desde instalación limpia: tipografía correcta.

---

# D1.5 — Migración de enums de estado

Riesgo: bajo. PR propia. Sin migración de BD.

## Alcance

| Hoy | Enum nuevo | Valores (`name` == string en BD) |
|---|---|---|
| `Sesion.estadoAsistencia` (`String?`) | `EstadoAsistencia?` | `programada`, `asistio`, `falto` |
| `Tratamiento.estado` (`String`) | `EstadoTratamiento` | `pendiente`, `enProceso`\*, `concluido` |

\* **Ojo:** el string en BD es `en_proceso` (con guion bajo). Opciones:
(a) nombrar el enum `en_proceso`… no válido en Dart. (b) usar
`@JsonValue('en_proceso')` sobre `EstadoTratamiento.enProceso`. Se elige
(b): el converter Freezed/json_serializable mapea `enProceso ↔
'en_proceso'`. Igual para `estadoAsistencia` si algún valor tuviera guion
(no es el caso hoy).

## Archivos nuevos

`lib/features/agenda/domain/estado_asistencia.dart`
`lib/features/agenda/domain/estado_tratamiento.dart`

```dart
enum EstadoTratamiento {
  @JsonValue('pendiente') pendiente,
  @JsonValue('en_proceso') enProceso,
  @JsonValue('concluido') concluido;
}
```

Cada enum incluye helpers que hoy están dispersos como `switch` en los
widgets de timeline: `label` (es_ES), y se dejan **fuera** color/icono
(eso vive en `AppStatusBadge` en D2, que mapea enum → estilo).

## Cambios

1. `sesion.dart` / `tratamiento.dart`: cambiar el tipo del campo; el
   `@JsonKey(name:)` se mantiene. Regenerar con
   `dart run build_runner build --delete-conflicting-outputs`.
2. `agenda_repository.dart`:
   - lecturas: `EstadoAsistencia.values.byName(...)` ya no hace falta —
     lo hace el `fromJson` generado; los `row['estado_asistencia'] as
     String?` se sustituyen por el parseo del modelo o un converter
     explícito para las queries raw (líneas 246, 300, 336).
   - SQL con literales (`'concluido'`, `'programada'`): se mantienen los
     literales string en el SQL, pero se generan desde
     `EstadoTratamiento.concluido.name` / vía `@JsonValue` para no tener
     el string suelto. Helper `EstadoTratamiento.dbValue`.
3. `agenda_providers.dart`: comparaciones `== 'programada'` →
   `== EstadoAsistencia.programada` (y el caso null/empty se colapsa a
   solo null).
4. `timeline_session_list.dart`, `treatment_timeline_list.dart`,
   `treatment_info_card.dart`, `treatment_detail_screen.dart`,
   `treatments_screen.dart`: `switch` sobre el enum (exhaustivo, sin
   `default`), comparaciones tipadas.
5. `appointment_create_screen.dart`: `estadoAsistencia:
   EstadoAsistencia.programada`, `estado: EstadoTratamiento.pendiente`.
6. `database_helper.dart`: columnas siguen `TEXT`. Sin cambios de esquema.

## Verificación D1.5

- `build_runner` sin conflictos.
- `flutter analyze` limpio; los `switch` exhaustivos no dan warning.
- `flutter test --no-pub` verde.
- Prueba manual: crear tratamiento y sesión, marcar asistencia, concluir
  tratamiento; verificar que los valores en BD siguen siendo
  `programada` / `asistio` / `en_proceso` / `concluido` (inspección con
  sqlite o log).
- Test nuevo: round-trip `Model.fromJson(model.toJson())` para ambos
  enums, incluido `en_proceso ↔ enProceso`.

---

# D2 — Componentes canónicos

Riesgo: bajo (no se monta en producción). Puede ser 1 PR grande o 2
(chasis + formularios / resto). Recomendación: **1 PR** con la style guide
como prueba visible.

## Ubicación

`lib/core/presentation/widgets/` — un archivo por componente o grupo
lógico. `app_error_view.dart` ya existe y se conserva.

## Componentes

| Componente | Rol | Construido sobre | Notas de API |
|---|---|---|---|
| `AppScaffold` + `AppNavBar` | Encabezado único: `SliverAppBar.large`, título grande Outfit, fondo translúcido (`surface` @ 0.9 + blur), acción trailing, back go_router | Material `CustomScrollView` + `SliverAppBar` | `AppScaffold({title, actions, slivers / body, leadingBack})` |
| `AppSearchField` | Icono, botón limpiar, `onChanged` con debounce 250 ms | `TextField` + `inputDecorationTheme` | `AppSearchField({controller, hintText, onChanged, debounce})` |
| `AppTextField` | Envuelve `FormBuilderTextField` con decoración del tema | `flutter_form_builder` | factories `.singleLine` / `.multiline` / `.number` |
| `AppButton` | `.primary` `.secondary` `.text` `.destructive`, con `loading` y `onPressed == null` = disabled | `FilledButton` / `OutlinedButton` / `TextButton` themed | `AppButton.primary(label, onPressed, {loading, icon})` |
| `AppSectionHeader` | Label mayúsculas + tracking (`AppText.sectionLabel`), separación estándar | `Padding` + `Text` | `AppSectionHeader(label)` |
| `AppCard` | Superficie + `AppRadii.md` + sombra/borde según brillo; slot opcional de barra de acento 4 px | `Material` / `DecoratedBox` | `AppCard({child, accentColor, onTap, padding})` |
| `AppListTile` / `AppSettingsGroup` | Fila icono/título/subtítulo/trailing; grupo con hairlines y `AppRadii.md` | `ListTile` themed | `AppSettingsGroup({header, children})` |
| `showAppSheet<T>()` | Único helper de hoja modal: asa, safe area, título opcional, `viewInsets`, `isScrollControlled` | `showModalBottomSheet` (o `showBarModalBottomSheet` de `modal_bottom_sheet`) | `showAppSheet(context, builder, {title, isScrollControlled})` |
| `showAppConfirm()` | Confirmación normal / destructiva | `showDialog` + `AlertDialog` themed | `showAppConfirm(context, {title, message, confirmLabel, destructive})` → `Future<bool>` |
| `AppDateTimeSheet` | Selector fecha/hora único (24 h, es_ES) dentro de `showAppSheet` | `CupertinoDatePicker` | `AppDateTimeSheet.pick(context, {initial, mode})` → `Future<DateTime?>` |
| `AppSwitch` | Wrapper sobre `CupertinoSwitch` con colores del tema, igual en ambas plataformas | `CupertinoSwitch` | `AppSwitch({value, onChanged})` |
| `AppStatusBadge` | Mapea `EstadoAsistencia` / `EstadoTratamiento` → color + label + icono desde `AppSemanticColors` | `Container` + `AppRadii.pill` | `AppStatusBadge.asistencia(EstadoAsistencia)` / `.tratamiento(EstadoTratamiento)` |
| `AppEmptyState` | Icono + título + descripción + acción opcional | `Column` centrada | `AppEmptyState({icon, title, message, action})` |
| `AppErrorView` | Ya existe | — | conservar; alinear estilos a tokens |

### Principios de API

- Todos consumen **solo** tokens (`AppSpacing`, `AppRadii`, `AppText`,
  `AppOpacity`, `ColorScheme`, `AppSemanticColors`). Cero literales.
- Sin dependencia de features: viven en `core/`. `AppStatusBadge` es la
  excepción controlada — importa los enums de `features/agenda/domain/`
  (igual que el plan lo previó). Si molesta, los enums se mueven a
  `core/` en D1.5; **decisión: se dejan en `features/agenda/domain/`** y
  `AppStatusBadge` los importa.
- Cada componente entendible sin leer sus internos: doc-comment con
  "qué hace / cómo se usa / de qué depende".

## Style guide oculta

Ruta nueva en `app_router.dart`, **solo `kDebugMode`**:

```dart
if (kDebugMode)
  GoRoute(path: '/dev/style-guide', builder: (_, __) => const StyleGuideScreen()),
```

`lib/features/dev/presentation/style_guide_screen.dart` (feature nueva
`dev/`, solo debug). Renderiza cada componente en sus variantes con los
tokens visibles (nombre + valor). Secciones: Color, Tipografía (los 6
roles), Espaciado, Radios, y cada `App*`. Es la fuente de verdad visual y
la prueba de regresión de D3.

No se enlaza desde ninguna pantalla de usuario. Acceso manual por deep
link en debug.

### Verificación D2

- `flutter analyze --no-fatal-infos` limpio.
- `flutter test --no-pub` verde + **tests de widget** por componente
  (render sin excepción en claro y oscuro; `AppButton` loading/disabled;
  `AppStatusBadge` cubre todos los valores de enum; `showAppConfirm`
  devuelve true/false).
- `flutter build apk --debug` compila; `/dev/style-guide` navegable en
  emulador, captura adjunta a la PR.
- Build release: verificar que `StyleGuideScreen` y la ruta quedan fuera
  (`kDebugMode` const → tree-shaken).
- Ninguna pantalla de producción importa componentes nuevos todavía.

---

## Orden de entrega

1. **PR D1** — fuentes asset + escalas + tipografía + tema ampliado.
2. **PR D1.5** — enums de estado.
3. **PR D2** — componentes `App*` + style guide.

Luego se especifica D3 (migración por feature) sobre esta base.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| No hay red para descargar los `.ttf` | Entregar lista exacta de URLs/archivos; el usuario los coloca en `lib/assets/fonts/` |
| `cupertinoOverrideTheme` cambia sutilmente pickers existentes | D1 incluye recorrido manual de los 3 selectores de fecha actuales |
| Radio de tarjeta 16→12 visible | Delta aceptado y documentado; es el único cambio visual de D1 |
| `google_fonts` sigue como dep y podría hacer red | `allowRuntimeFetching = false` global; eliminación del paquete se pospone a D4 |
| `en_proceso` vs `enProceso` | `@JsonValue('en_proceso')` + test de round-trip explícito |
