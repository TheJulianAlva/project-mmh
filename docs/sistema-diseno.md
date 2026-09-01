# Sistema de diseño de Klinik

Toda la UI de la app consume **tokens** y **componentes `App*`**. Nada de
estilo suelto en las pantallas.

## Las tres capas

1. **Primitiva** — `lib/core/theme/app_palette.dart`. Hex y escalas crudas.
   Privada al paquete de tema; no se importa desde `lib/features/`.
2. **Semántica** — `ColorScheme` (derivado del berry de marca),
   `AppSemanticColors` (`success`/`warning`/`info` vía `context.semantic`),
   `AppSpacing` (4/8/12/16/24/32), `AppRadii` (`sm 8`/`md 12`/`lg 20`/`pill`),
   `AppOpacity` (`hairline .08`/`subtle .12`/`muted .40`/`strong .70`),
   `AppText` (`screenTitle`/`cardTitle`/`body`/`sectionLabel`/`metric`/`caption`).
   El color de clínica pasa siempre por `ClinicPalette`.
3. **Componente** — `lib/core/presentation/widgets/App*`. Lo único que
   tocan las pantallas.

## Reglas

| Prohibido en `lib/features/` | Usa |
|---|---|
| `TextStyle(fontSize: …)` | un rol de `AppText` o `Theme.of(context).textTheme.*` |
| `Card`, `Container` con `BoxDecoration` de tarjeta | `AppCard` |
| `Color(0x…)`, `Colors.*` (salvo `Colors.transparent`) | `ColorScheme` / `context.semantic` / `ClinicPalette` |
| `showModalBottomSheet`, `showCupertinoModalPopup` | `showAppSheet` |
| `AlertDialog`, `CupertinoAlertDialog` de confirmación | `showAppConfirm` |
| `CupertinoSliverNavigationBar`, `AppBar(` a mano | `AppScaffold` |
| `_getInputDecoration`, `InputDecoration` inline | `AppTextField` |
| `EdgeInsets` con número mágico | `AppSpacing.*` |
| `withValues(alpha: 0.xx)` con número suelto | `AppOpacity.*` |
| `BorderRadius.circular(N)` | `AppRadii.*` |

Excepción puntual: `// design-system-ignore: <motivo>` en la línea de
encima exime esa ocurrencia (p. ej. un gradiente decorativo legítimo). El
test de guardarraíl las cuenta e imprime.

## Añadir un token

1. Valor crudo → `app_palette.dart` (o la escala correspondiente).
2. Exponerlo con nombre semántico en la capa 2.
3. Nunca se consume la capa 1 desde una pantalla.

## Añadir un componente

1. `lib/core/presentation/widgets/app_<nombre>.dart`, un archivo por
   componente, con doc-comment de 3 líneas (qué hace / cómo se usa / de
   qué depende).
2. Solo consume tokens y otros `App*`.
3. Test de widget en `test/core/widgets/`: renderiza sin excepción en
   claro y oscuro.
4. Entrada en `/dev/style-guide`
   (`lib/features/dev/presentation/style_guide_screen.dart`).

## Checklist de PR de UI

- [ ] La pantalla solo importa `App*` y tokens.
- [ ] `flutter test` incluye el guardarraíl y pasa.
- [ ] Captura de `/dev/style-guide` si se tocó un componente.
