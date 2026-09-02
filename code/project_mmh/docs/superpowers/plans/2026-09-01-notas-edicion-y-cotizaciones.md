# Edición/eliminación de Notas y checklist de cotizaciones Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Agregar edición/eliminación a prepacientes, listas de materiales (con sus cotizaciones) y cotizaciones individuales, y reemplazar la captura manual de ítems de una cotización por un checklist que se siembra desde la lista de materiales padre, con precio en línea y encadenado de teclado; además, agregar el botón de WhatsApp a la ficha de paciente registrado.

**Architecture:** Se extiende el módulo `lib/features/notas/` ya existente (modelo `Nota`/`NotaItem`, `NotasRepository`, `notas_providers.dart` — ninguno cambia). Tres pantallas de detalle pasan de solo lectura/creación a editables siguiendo el patrón ya establecido por `NotaDetailScreen` (formulario pre-llenado + "Guardar" + eliminar con confirmación). Se agrega un widget `CotizacionItemChecklist` (paralelo a `NotaItemEditor`, sin reemplazarlo) para la captura de precios de cotización, y una pantalla nueva `CotizacionDetailScreen`. `PatientDetailScreen` gana un botón de WhatsApp reusando el helper existente.

**Tech Stack:** Flutter, `flutter_riverpod`, `go_router`, `flutter_form_builder` — mismas dependencias ya usadas en el módulo, sin dependencias nuevas.

**Spec:** `docs/superpowers/specs/2026-09-01-notas-edicion-y-cotizaciones-design.md`

## Global Constraints

- Commits en español, minúscula al inicio, en una rama que no sea `main`.
- No usar `Co-Authored-By` ni referencias a Claude en mensajes de commit.
- Ningún archivo de este plan cambia el esquema de BD, `NotaItem`, `Nota`, `NotasRepository` ni `notas_providers.dart` — `updateNota`/`deleteNota` ya son genéricos para cualquier `tipo` de nota, y el borrado en cascada de cotizaciones al borrar su lista ya está en el esquema (FK `id_nota_relacionada` con `ON DELETE CASCADE`).
- Las pantallas/widgets de este módulo no tienen tests dedicados (mismo criterio ya establecido: `NotaItemEditor`, `NotaDetailScreen`, etc. tampoco los tienen) — la verificación de cada tarea es `flutter analyze` sobre el archivo tocado, más una revisión manual cuidadosa del código contra los criterios de la tarea.
- **Bug a evitar en toda tarea que "siembra" una lista de ítems desde otra nota (lista de materiales → cotización) o desde la nota propia (edición):** `NotaItemEditor`/`CotizacionItemChecklist` solo notifican cambios (`onChanged`) cuando el usuario muta algo — nunca al construirse. Si la pantalla guarda usando una variable de estado `_items` que arranca vacía o nula y el usuario no toca ningún ítem antes de guardar, se persistiría una lista vacía por error. La corrección en todas las tareas de este plan es inicializar `_items` con `??=` la primera vez que llegan los datos de la nota/lista (dentro del branch `data:` del `AsyncValue`), nunca en el estado inicial del `State`.

---

## File Structure

```
lib/features/notas/presentation/widgets/
  cotizacion_item_checklist.dart          # NUEVO — checklist de precios en línea
lib/features/notas/presentation/screens/
  cotizacion_create_screen.dart           # MODIFICADO — siembra desde la lista
  cotizacion_detail_screen.dart           # NUEVO — editar/eliminar cotización
  prepaciente_detail_screen.dart          # MODIFICADO — editable + eliminar
  lista_materiales_detail_screen.dart     # MODIFICADO — editable + eliminar + onTap en tarjetas
lib/core/router/app_router.dart           # MODIFICADO — ruta de detalle de cotización
lib/features/pacientes/presentation/screens/
  patient_detail_screen.dart              # MODIFICADO — botón de WhatsApp
```

---

### Task 1: Widget `CotizacionItemChecklist`

**Files:**
- Create: `lib/features/notas/presentation/widgets/cotizacion_item_checklist.dart`

**Interfaces:**
- Consumes: `NotaItem` (`lib/features/notas/domain/nota_item.dart`, campos `nombre`, `cantidad` (num), `unidad` (String?), `precioUnitario` (double?)); widgets existentes `AppButton`, `AppEmptyState`, `AppTextField.singleLine`/`.decimal`, `showAppSheet` (todos en `lib/core/presentation/widgets/`); `AppSpacing`, `AppOpacity` (`lib/core/theme/`).
- Produces: `CotizacionItemChecklist({List<NotaItem> initialItems = const [], required ValueChanged<List<NotaItem>> onChanged})`. Usado por `CotizacionCreateScreen` (Task 2) y `CotizacionDetailScreen` (Task 3).

- [ ] **Step 1: Implementa el widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';

/// Checklist de captura de precios de cotización: cada renglón trae el
/// nombre/cantidad del ítem (heredado de la lista de materiales al sembrar
/// la cotización, o de la propia cotización al editarla) y un campo de
/// precio en línea. El teclado encadena "siguiente" al precio del renglón
/// que sigue, para capturar precios sin volver a tocar la pantalla entre
/// uno y otro. Nombre/cantidad/unidad se corrigen aparte (ícono de lápiz),
/// sin abrir el precio.
class CotizacionItemChecklist extends StatefulWidget {
  const CotizacionItemChecklist({
    super.key,
    this.initialItems = const [],
    required this.onChanged,
  });

  final List<NotaItem> initialItems;
  final ValueChanged<List<NotaItem>> onChanged;

  @override
  State<CotizacionItemChecklist> createState() =>
      _CotizacionItemChecklistState();
}

class _CotizacionItemChecklistState extends State<CotizacionItemChecklist> {
  late final List<NotaItem> _items = List.of(widget.initialItems);
  late final List<TextEditingController> _priceControllers = _items
      .map(
        (i) =>
            TextEditingController(text: i.precioUnitario?.toString() ?? ''),
      )
      .toList();
  late final List<FocusNode> _priceFocusNodes = List.generate(
    _items.length,
    (_) => FocusNode(),
  );

  void _notify() => widget.onChanged(List.of(_items));

  @override
  void dispose() {
    for (final c in _priceControllers) {
      c.dispose();
    }
    for (final f in _priceFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onPriceChanged(int index, String value) {
    setState(() {
      _items[index] = _items[index].copyWith(
        precioUnitario: value.isEmpty ? null : double.tryParse(value),
      );
    });
    _notify();
  }

  void _focusNext(int index) {
    if (index < _items.length - 1) {
      FocusScope.of(context).requestFocus(_priceFocusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _editDetails({NotaItem? existing, int? index}) async {
    final formKey = GlobalKey<FormBuilderState>();
    final result = await showAppSheet<NotaItem>(
      context,
      title: existing == null ? 'Nuevo ítem' : 'Editar ítem',
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField.singleLine(
                  name: 'nombre',
                  label: 'Nombre *',
                  initialValue: existing?.nombre,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField.decimal(
                        name: 'cantidad',
                        label: 'Cantidad *',
                        initialValue: existing?.cantidad.toString(),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField.singleLine(
                        name: 'unidad',
                        label: 'Unidad',
                        initialValue: existing?.unidad,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton.primary(
                  label: 'Guardar',
                  onPressed: () {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      final v = formKey.currentState!.value;
                      Navigator.of(ctx).pop(
                        NotaItem(
                          nombre: v['nombre'] as String,
                          cantidad: num.parse(v['cantidad'] as String),
                          unidad: (v['unidad'] as String?)?.isEmpty ?? true
                              ? null
                              : v['unidad'] as String,
                          precioUnitario: existing?.precioUnitario,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null || !mounted) return;
    setState(() {
      if (index != null) {
        _items[index] = result;
      } else {
        _items.add(result);
        _priceControllers.add(TextEditingController());
        _priceFocusNodes.add(FocusNode());
      }
    });
    _notify();
  }

  void _removeAt(int index) {
    setState(() {
      _items.removeAt(index);
      _priceControllers.removeAt(index).dispose();
      _priceFocusNodes.removeAt(index).dispose();
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_items.isEmpty)
          const AppEmptyState(
            icon: Icons.checklist_rtl,
            title: 'Sin ítems todavía',
          )
        else
          ..._items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombre,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${item.cantidad}'
                          '${item.unidad != null ? ' ${item.unidad}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.onSurface.withValues(
                                  alpha: AppOpacity.muted,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _priceControllers[i],
                      focusNode: _priceFocusNodes[i],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      textInputAction: i == _items.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixText: '\$',
                        isDense: true,
                        hintText: '0.00',
                      ),
                      onChanged: (value) => _onPriceChanged(i, value),
                      onSubmitted: (_) => _focusNext(i),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editDetails(existing: item, index: i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _removeAt(i),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: AppSpacing.sm),
        AppButton.secondary(
          label: 'Agregar ítem',
          icon: Icons.add,
          onPressed: () => _editDetails(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/widgets/cotizacion_item_checklist.dart`
Expected: sin errores.

- [ ] **Step 3: Revisión manual del encadenado de teclado**

Confirma leyendo el código (no hay test automatizado para este widget, igual que `NotaItemEditor`):
- Cada `TextField` de precio tiene su propio `FocusNode` (`_priceFocusNodes[i]`) y controlador (`_priceControllers[i]`), en el mismo índice que `_items`.
- `textInputAction` es `.next` en todos menos el último renglón (`.done`).
- `onSubmitted` llama a `_focusNext(i)`, que mueve el foco a `_priceFocusNodes[i + 1]` o cierra el teclado si es el último.
- `_editDetails` (agregar) y `_removeAt` mantienen `_items`, `_priceControllers` y `_priceFocusNodes` sincronizados en longitud e índice — un ítem nuevo agrega un controlador y un `FocusNode` al final; uno eliminado los quita (y los dispone) en el mismo índice.

- [ ] **Step 4: Commit**

```bash
git add lib/features/notas/presentation/widgets/cotizacion_item_checklist.dart
git commit -m "feat: agrega checklist de precios en linea para cotizaciones"
```

---

### Task 2: `CotizacionCreateScreen` — sembrar ítems desde la lista

**Files:**
- Modify: `lib/features/notas/presentation/screens/cotizacion_create_screen.dart`

**Interfaces:**
- Consumes: `CotizacionItemChecklist` (Task 1); `notaByIdProvider`, `notasProvider.notifier.addNota` (`lib/features/notas/presentation/providers/notas_providers.dart`, sin cambios); `Nota`, `NotaTipo`.
- Produces: mismo constructor público `CotizacionCreateScreen({required int listaId})` (sin cambios de firma — la ruta que ya existe en `app_router.dart` sigue funcionando igual).

- [ ] **Step 1: Reemplaza el contenido del archivo**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/cotizacion_item_checklist.dart';

class CotizacionCreateScreen extends ConsumerStatefulWidget {
  const CotizacionCreateScreen({super.key, required this.listaId});

  final int listaId;

  @override
  ConsumerState<CotizacionCreateScreen> createState() =>
      _CotizacionCreateScreenState();
}

class _CotizacionCreateScreenState
    extends ConsumerState<CotizacionCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem>? _items;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.cotizacion,
          fecha: DateTime.now().toIso8601String(),
          idNotaRelacionada: widget.listaId,
          proveedor: v['proveedor'] as String,
          items: _items ?? [],
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaAsync = ref.watch(notaByIdProvider(widget.listaId));

    return listaAsync.when(
      data: (lista) {
        if (lista == null) {
          return const AppScaffold(
            title: 'Nueva Cotización',
            body: Center(child: Text('Lista no encontrada.')),
          );
        }
        // Siembra los ítems desde la lista de materiales una sola vez (ver
        // Global Constraints: evita guardar una lista vacía si el usuario no
        // toca ningún precio).
        _items ??= lista.items
            .map((i) => i.copyWith(precioUnitario: null))
            .toList();

        return AppScaffold(
          title: 'Nueva Cotización',
          actions: [
            AppButton.text(
              label: 'Guardar',
              loading: _isSaving,
              onPressed: _save,
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField.singleLine(
                    name: 'proveedor',
                    label: 'Proveedor *',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const AppSectionHeader('Ítems'),
                  CotizacionItemChecklist(
                    initialItems: _items!,
                    onChanged: (items) => _items = items,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Nueva Cotización',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Nueva Cotización',
        body: AppErrorView(
          message: 'No se pudo cargar la lista de materiales.',
          onRetry: () => ref.invalidate(notaByIdProvider(widget.listaId)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/cotizacion_create_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/cotizacion_create_screen.dart
git commit -m "feat: siembra los items de la cotizacion desde la lista de materiales"
```

---

### Task 3: Pantalla nueva — `CotizacionDetailScreen`

**Files:**
- Create: `lib/features/notas/presentation/screens/cotizacion_detail_screen.dart`

**Interfaces:**
- Consumes: `CotizacionItemChecklist` (Task 1); `notaByIdProvider`, `notasProvider.notifier.updateNota/deleteNota`; `showAppConfirm` (`lib/core/presentation/widgets/app_confirm.dart`).
- Produces: `CotizacionDetailScreen({required int cotizacionId})`. Usado por la ruta nueva (Task 4) y por el `onTap` de las tarjetas de cotización (Task 6).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/cotizacion_item_checklist.dart';

class CotizacionDetailScreen extends ConsumerStatefulWidget {
  const CotizacionDetailScreen({super.key, required this.cotizacionId});

  final int cotizacionId;

  @override
  ConsumerState<CotizacionDetailScreen> createState() =>
      _CotizacionDetailScreenState();
}

class _CotizacionDetailScreenState
    extends ConsumerState<CotizacionDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem>? _items;
  bool _isSaving = false;

  Future<void> _save() async {
    final nota = ref
        .read(notaByIdProvider(widget.cotizacionId))
        .asData
        ?.value;
    if (nota == null) return;
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final v = _formKey.currentState!.value;
      await ref.read(notasProvider.notifier).updateNota(
        nota.copyWith(
          proveedor: v['proveedor'] as String,
          items: _items ?? nota.items,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar cotización',
      message: 'Esta acción no se puede deshacer.',
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    try {
      await ref.read(notasProvider.notifier).deleteNota(widget.cotizacionId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notaAsync = ref.watch(notaByIdProvider(widget.cotizacionId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Cotización',
            body: Center(child: Text('Cotización no encontrada.')),
          );
        }
        // Ver Global Constraints: siembra una sola vez desde los datos ya
        // guardados, para no perder ítems si el usuario no toca ninguno.
        _items ??= List.of(nota.items);

        return AppScaffold(
          title: nota.proveedor ?? 'Cotización',
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
            AppButton.text(
              label: 'Guardar',
              loading: _isSaving,
              onPressed: _save,
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField.singleLine(
                    name: 'proveedor',
                    label: 'Proveedor *',
                    initialValue: nota.proveedor,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const AppSectionHeader('Ítems'),
                  CotizacionItemChecklist(
                    initialItems: nota.items,
                    onChanged: (items) => _items = items,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Cotización',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Cotización',
        body: AppErrorView(
          message: 'No se pudo cargar la cotización.',
          onRetry: () =>
              ref.invalidate(notaByIdProvider(widget.cotizacionId)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/cotizacion_detail_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/cotizacion_detail_screen.dart
git commit -m "feat: agrega pantalla de edicion y eliminacion de cotizacion"
```

---

### Task 4: Ruta de detalle de cotización

**Files:**
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `CotizacionDetailScreen` (Task 3).
- Produces: ruta `/notas/materiales/:id/cotizacion/:cotizacionId`, anidada bajo la ruta existente `/notas/materiales/:id`, hermana de `cotizacion-nueva`. Usada por el `onTap` de las tarjetas de cotización (Task 6).

- [ ] **Step 1: Agrega el import**, junto a los demás imports de pantallas de `notas`:

```dart
import 'package:project_mmh/features/notas/presentation/screens/cotizacion_detail_screen.dart';
```

- [ ] **Step 2: Agrega la ruta anidada**

Dentro del `GoRoute` de `/notas/materiales/:id`, en su lista `routes:`, junto al `GoRoute(path: 'cotizacion-nueva', ...)` ya existente:

```dart
        GoRoute(
          path: 'cotizacion/:cotizacionId',
          builder: (context, state) {
            final cotizacionId = int.tryParse(
              state.pathParameters['cotizacionId'] ?? '',
            );
            if (cotizacionId == null) {
              return const _RouteErrorScreen(message: 'Cotización no válida');
            }
            return CotizacionDetailScreen(cotizacionId: cotizacionId);
          },
        ),
```

- [ ] **Step 3: Verifica que compila**

Run: `flutter analyze lib/core/router/app_router.dart`
Expected: sin errores.

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat: registra ruta de detalle de cotizacion"
```

---

### Task 5: `PrepacienteDetailScreen` — editar y eliminar

**Files:**
- Modify: `lib/features/notas/presentation/screens/prepaciente_detail_screen.dart`

**Interfaces:**
- Consumes: `notaByIdProvider`, `notasProvider.notifier.updateNota/deleteNota`; `showAppConfirm`; `launchWhatsApp` (`lib/core/services/whatsapp_launcher.dart`, sin cambios).
- Produces: mismo constructor público `PrepacienteDetailScreen({required int notaId})` (la ruta existente en `app_router.dart` sigue funcionando igual).

- [ ] **Step 1: Reemplaza el contenido del archivo**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/services/whatsapp_launcher.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteDetailScreen extends ConsumerStatefulWidget {
  const PrepacienteDetailScreen({super.key, required this.notaId});

  final int notaId;

  @override
  ConsumerState<PrepacienteDetailScreen> createState() =>
      _PrepacienteDetailScreenState();
}

class _PrepacienteDetailScreenState
    extends ConsumerState<PrepacienteDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    final nota = ref.read(notaByIdProvider(widget.notaId)).asData?.value;
    if (nota == null) return;
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final v = _formKey.currentState!.value;
      await ref.read(notasProvider.notifier).updateNota(
        nota.copyWith(
          nombreContacto: v['nombre_contacto'] as String,
          telefono: (v['telefono'] as String?)?.isEmpty ?? true
              ? null
              : v['telefono'] as String,
          tratamientoProbable:
              (v['tratamiento_probable'] as String?)?.isEmpty ?? true
              ? null
              : v['tratamiento_probable'] as String,
          contenido: (v['contenido'] as String?)?.isEmpty ?? true
              ? null
              : v['contenido'] as String,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar prepaciente',
      message: 'Esta acción no se puede deshacer.',
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    try {
      await ref.read(notasProvider.notifier).deleteNota(widget.notaId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notaAsync = ref.watch(notaByIdProvider(widget.notaId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Prepaciente',
            body: Center(child: Text('Prepaciente no encontrado.')),
          );
        }
        return AppScaffold(
          title: 'Prepaciente',
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
            AppButton.text(
              label: 'Guardar',
              loading: _isSaving,
              onPressed: _save,
            ),
          ],
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField.singleLine(
                    name: 'nombre_contacto',
                    label: 'Nombre *',
                    initialValue: nota.nombreContacto,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.phone(
                    name: 'telefono',
                    label: 'Teléfono',
                    initialValue: nota.telefono,
                    maxLength: 10,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.singleLine(
                    name: 'tratamiento_probable',
                    label: 'Tratamiento probable',
                    initialValue: nota.tratamientoProbable,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.multiline(
                    name: 'contenido',
                    label: 'Observaciones',
                    initialValue: nota.contenido,
                    maxLines: 5,
                    minLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (nota.telefono != null)
                    AppButton.primary(
                      label: 'Contactar por WhatsApp',
                      icon: Icons.chat,
                      onPressed: () async {
                        try {
                          await launchWhatsApp(nota.telefono!);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo abrir WhatsApp.'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Prepaciente',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Prepaciente',
        body: AppErrorView(
          message: 'No se pudo cargar el prepaciente.',
          onRetry: () => ref.invalidate(notaByIdProvider(widget.notaId)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/prepaciente_detail_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/prepaciente_detail_screen.dart
git commit -m "feat: agrega edicion y eliminacion de prepaciente"
```

---

### Task 6: `ListaMaterialesDetailScreen` — editar, eliminar (en cascada) y navegar a cotización

**Files:**
- Modify: `lib/features/notas/presentation/screens/lista_materiales_detail_screen.dart`

**Interfaces:**
- Consumes: `NotaItemEditor` (sin cambios, `lib/features/notas/presentation/widgets/nota_item_editor.dart`); `notaByIdProvider`, `cotizacionesDeListaProvider`, `notasProvider.notifier.updateNota/deleteNota`; `showAppConfirm`; `showAppSelectionSheet`; `Clinica`/`clinicasByPeriodoProvider`/`lastViewedPeriodIdProvider` (mismos que usa `ListaMaterialesCreateScreen`).
- Produces: mismo constructor público `ListaMaterialesDetailScreen({required int listaId})`; navega a `/notas/materiales/$listaId/cotizacion/${c.idNota}` (ruta de Task 4) al tocar una tarjeta de cotización.

- [ ] **Step 1: Reemplaza el contenido del archivo**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_confirm.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/nota_item_editor.dart';

class ListaMaterialesDetailScreen extends ConsumerStatefulWidget {
  const ListaMaterialesDetailScreen({super.key, required this.listaId});

  final int listaId;

  @override
  ConsumerState<ListaMaterialesDetailScreen> createState() =>
      _ListaMaterialesDetailScreenState();
}

class _ListaMaterialesDetailScreenState
    extends ConsumerState<ListaMaterialesDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem>? _items;
  Clinica? _clinica;
  bool _isSaving = false;

  Clinica? _findClinica(List<Clinica> clinicas, int? id) {
    if (id == null) return null;
    for (final c in clinicas) {
      if (c.idClinica == id) return c;
    }
    return null;
  }

  Future<void> _pickClinica(List<Clinica> clinicas, Clinica? current) async {
    final selected = await showAppSelectionSheet<Clinica>(
      context,
      title: 'Clínica',
      options: clinicas,
      labelOf: (c) => c.nombreClinica,
      selected: current,
    );
    if (selected != null) setState(() => _clinica = selected);
  }

  Future<void> _save() async {
    final nota = ref.read(notaByIdProvider(widget.listaId)).asData?.value;
    if (nota == null) return;
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final v = _formKey.currentState!.value;
      await ref.read(notasProvider.notifier).updateNota(
        nota.copyWith(
          contenido: v['contenido'] as String,
          idClinica: _clinica?.idClinica ?? nota.idClinica,
          items: _items ?? nota.items,
        ),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $message')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final cotizaciones = ref.read(
      cotizacionesDeListaProvider(widget.listaId),
    );
    final message = cotizaciones.isEmpty
        ? 'Esta acción no se puede deshacer.'
        : 'Esta acción no se puede deshacer y también eliminará sus '
              '${cotizaciones.length} cotización(es).';

    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar lista de materiales',
      message: message,
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    try {
      await ref.read(notasProvider.notifier).deleteNota(widget.listaId);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final errMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $errMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaAsync = ref.watch(notaByIdProvider(widget.listaId));

    return listaAsync.when(
      data: (lista) {
        if (lista == null) {
          return const AppScaffold(
            title: 'Lista de materiales',
            body: Center(child: Text('Lista no encontrada.')),
          );
        }
        // Ver Global Constraints: siembra una sola vez, para no perder
        // items si el usuario guarda sin tocar el editor.
        _items ??= List.of(lista.items);
        final cotizaciones = ref.watch(
          cotizacionesDeListaProvider(widget.listaId),
        );
        final periodId = ref.watch(lastViewedPeriodIdProvider);
        final clinicasAsync = periodId == null
            ? const AsyncValue<List<Clinica>>.data([])
            : ref.watch(clinicasByPeriodoProvider(periodId));

        return AppScaffold(
          title: lista.contenido ?? 'Lista de materiales',
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
            AppButton.text(
              label: 'Guardar',
              loading: _isSaving,
              onPressed: _save,
            ),
          ],
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField.singleLine(
                        name: 'contenido',
                        label: 'Nombre de la lista *',
                        initialValue: lista.contenido,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      clinicasAsync.when(
                        data: (clinicas) {
                          final current =
                              _clinica ??
                              _findClinica(clinicas, lista.idClinica);
                          return AppButton.secondary(
                            label:
                                current?.nombreClinica ??
                                'Asociar clínica (opcional)',
                            onPressed: clinicas.isEmpty
                                ? null
                                : () => _pickClinica(clinicas, current),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                      const AppSectionHeader('Ítems'),
                      NotaItemEditor(
                        initialItems: lista.items,
                        onChanged: (items) => _items = items,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AppSectionHeader('Cotizaciones'),
                          AppButton.text(
                            label: 'Agregar cotización',
                            icon: Icons.add,
                            onPressed: () => context.push(
                              '/notas/materiales/${widget.listaId}/cotizacion-nueva',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (cotizaciones.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: AppEmptyState(
                    icon: Icons.request_quote_outlined,
                    title: 'Aún no hay cotizaciones.',
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: cotizaciones.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final c = cotizaciones[index];
                      return SizedBox(
                        width: 220,
                        child: AppCard(
                          onTap: () => context.push(
                            '/notas/materiales/${widget.listaId}/cotizacion/${c.idNota}',
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.proveedor ?? '(Sin proveedor)',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Expanded(
                                child: ListView(
                                  children: c.items
                                      .map(
                                        (i) => Text(
                                          '${i.nombre} x${i.cantidad}'
                                          '${i.precioUnitario != null ? ' — \$${i.precioUnitario}' : ''}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const Divider(),
                              Text(
                                'Total: \$${c.totalCotizacion.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        );
      },
      loading: () => const AppScaffold(
        title: 'Lista de materiales',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Lista de materiales',
        body: AppErrorView(
          message: 'No se pudo cargar la lista.',
          onRetry: () => ref.invalidate(notaByIdProvider(widget.listaId)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/lista_materiales_detail_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/lista_materiales_detail_screen.dart
git commit -m "feat: agrega edicion y eliminacion en cascada de lista de materiales"
```

---

### Task 7: `PatientDetailScreen` — botón de WhatsApp

**Files:**
- Modify: `lib/features/pacientes/presentation/screens/patient_detail_screen.dart`

**Interfaces:**
- Consumes: `launchWhatsApp` (`lib/core/services/whatsapp_launcher.dart`, sin cambios); `Patient.telefono` (ya existe).
- Produces: nada nuevo hacia otras tareas — cambio autocontenido.

- [ ] **Step 1: Agrega el import**, junto a los demás imports del archivo:

```dart
import 'package:project_mmh/core/services/whatsapp_launcher.dart';
```

- [ ] **Step 2: Agrega el botón**

En `_buildPatientContent`, inmediatamente después del bloque `AppButton.secondary(label: 'Ver Odontograma', ...)` y su `SizedBox(height: AppSpacing.lg)` que le sigue (antes de `_buildImagesSection(context, ref, patient)`):

```dart
          if (patient.telefono != null) ...[
            AppButton.primary(
              label: 'Contactar por WhatsApp',
              icon: Icons.chat,
              onPressed: () async {
                try {
                  await launchWhatsApp(patient.telefono!);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se pudo abrir WhatsApp.'),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
```

- [ ] **Step 3: Verifica que compila**

Run: `flutter analyze lib/features/pacientes/presentation/screens/patient_detail_screen.dart`
Expected: sin errores.

- [ ] **Step 4: Commit**

```bash
git add lib/features/pacientes/presentation/screens/patient_detail_screen.dart
git commit -m "feat: agrega boton de whatsapp a la ficha de paciente"
```

---

## Self-Review

- **Cobertura del spec:** sin campo de nota por ítem → no se agrega ningún campo (Task 1 confirma `NotaItem` intacto). `CotizacionItemChecklist` con precio en línea y encadenado de teclado → Task 1. Cotización sembrada desde la lista, luego independiente → Task 2 (`_items ??= lista.items.map(...)`). Editar/eliminar prepaciente → Task 5. Editar/eliminar lista con cascada de cotizaciones → Task 6. Detalle/edición/eliminación de cotización individual → Task 3 + ruta en Task 4 + `onTap` en Task 6. WhatsApp en `PatientDetailScreen` → Task 7. Sin cambios de esquema → confirmado en Global Constraints, ninguna tarea toca `database_helper.dart`.
- **Placeholders:** ninguno; cada paso trae el código completo del archivo a crear/reemplazar.
- **Consistencia de tipos:** `CotizacionItemChecklist({initialItems, onChanged})` se usa igual en Tasks 2 y 3. `notaByIdProvider`, `notasProvider.notifier.updateNota/deleteNota`, `cotizacionesDeListaProvider` se consumen con la misma firma ya establecida en `notas_providers.dart` (sin cambios) en todas las tareas. La ruta `/notas/materiales/:id/cotizacion/:cotizacionId` registrada en Task 4 coincide exactamente con la cadena usada en el `onTap` de Task 6 y con el constructor `CotizacionDetailScreen({required int cotizacionId})` de Task 3.
