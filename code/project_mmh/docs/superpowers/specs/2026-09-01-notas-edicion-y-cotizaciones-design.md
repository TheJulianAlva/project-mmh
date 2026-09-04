# Edición/eliminación de Notas y captura ágil de cotizaciones — Design

## Contexto

El módulo de Notas (`lib/features/notas/`) ya implementa creación y listado para sus tres tipos (`general`, `prepaciente`, `lista_materiales` + `cotizacion`), y edición/eliminación solo para notas `general` (`NotaDetailScreen`). Faltan:

- Editar/eliminar un `prepaciente`.
- Editar/eliminar una `lista_materiales` (con eliminación en cascada de sus cotizaciones, ya soportada a nivel de BD vía `FOREIGN KEY (id_nota_relacionada) REFERENCES notas (id_nota) ON DELETE CASCADE`, pero sin UI que la dispare).
- Editar/eliminar una `cotizacion` individual (hoy no existe pantalla de detalle para una cotización; solo se ven como tarjetas de solo lectura dentro de `ListaMaterialesDetailScreen`).
- Un flujo de captura de cotización más ágil: hoy el usuario captura cada ítem desde cero con `NotaItemEditor`; debe en cambio partir de los ítems ya definidos en la lista de materiales y solo ir marcando precios.
- Un botón de contacto por WhatsApp en `PatientDetailScreen` (pacientes ya registrados), replicando el que ya existe en `PrepacienteDetailScreen`.

Referencia visual: dos listas de materiales reales compartidas por el usuario muestran que los ítems son mayormente texto libre numerado, a veces con una aclaración entre paréntesis dentro del propio nombre (p. ej. *"Tipodonto infantil marca Nissin (NO tipo Nissin ni marcas genéricas)"*). Esto confirma que el campo `nombre` de `NotaItem` (sin límite de longitud útil) ya cubre el caso de "aclaración por ítem" sin necesitar un campo nuevo.

## Decisión: sin campo de nota/aclaración por ítem

Se evaluó agregar un campo `nota` de una línea a `NotaItem` para aclaraciones (p. ej. requisitos de marca). Se descarta: el campo `nombre` libre ya cubre este caso en la práctica (los documentos reales lo hacen así), y un campo nuevo implicaría una columna más en `items_json`, un input adicional en el formulario de cada ítem, y una decisión de layout en las 3 pantallas que listan ítems, por un beneficio que ya está cubierto. **No se modifica `NotaItem`.**

## Decisión: la cotización se "siembra" desde la lista, luego es independiente

Al crear una cotización, sus ítems iniciales son una **copia por valor** de `lista.items` (nombre, cantidad, unidad; `precioUnitario` en blanco) — no una referencia viva. A partir de ahí, la cotización tiene su propia lista de ítems, editable independientemente de la lista de materiales (igual que ya ocurre hoy internamente). Esto evita necesitar un identificador estable para "recordar" de qué ítem de la lista vino cada ítem de la cotización: no hace falta, porque tras la siembra inicial son entidades separadas. Al **editar** una cotización existente, el checklist muestra los ítems ya guardados de esa cotización — no se vuelve a mezclar con la lista.

## Componente nuevo: `CotizacionItemChecklist`

Reemplaza a `NotaItemEditor` únicamente en las pantallas de cotización (crear y editar). `NotaItemEditor` no se modifica y sigue usándose tal cual para listas de materiales.

**Archivo:** `lib/features/notas/presentation/widgets/cotizacion_item_checklist.dart`

**Interfaz:**
```dart
class CotizacionItemChecklist extends StatefulWidget {
  const CotizacionItemChecklist({
    super.key,
    this.initialItems = const [],
    required this.onChanged,
  });

  final List<NotaItem> initialItems;
  final ValueChanged<List<NotaItem>> onChanged;
}
```

**Interacción, por renglón:**
- Nombre del ítem + cantidad/unidad como subtítulo (solo lectura en el renglón).
- Campo de precio **en línea**, siempre visible en el renglón (no en una hoja aparte). `TextInputType.numberWithOptions(decimal: true)` con el mismo formateador decimal ya usado por `AppTextField.decimal`.
- Ícono de lápiz: abre una hoja compacta (mismo patrón de `showAppSheet` que `NotaItemEditor`, pero **sin** campo de precio) para corregir nombre/cantidad/unidad — para el caso "Tijeras... Hu-Friedy ó 311 Yamaura" → dejar solo "Tijeras... Hu-Friedy".
- Ícono de basura: quita el renglón (ese proveedor no cotiza ese ítem).
- Botón "Agregar ítem" al final: agrega un renglón vacío (mismo patrón de hoja, ahora sin precio tampoco — el precio se llena en línea después de agregarlo) para ítems que el proveedor ofrece y no estaban en la lista original.

**Encadenado de teclado:** un `FocusNode` por renglón de precio, generado y liberado dinámicamente según el número de ítems. Cada campo de precio usa `textInputAction: TextInputAction.next`; su `onFieldSubmitted` (o `onEditingComplete`) mueve el foco al `FocusNode` del siguiente renglón (`FocusScope.of(context).requestFocus(...)`). El último renglón usa `TextInputAction.done` y cierra el teclado (`FocusScope.of(context).unfocus()`). Los `FocusNode`s se disponen en `dispose()`.

**Estado y notificación:** igual patrón que `NotaItemEditor` — lista mutable en memoria, `onChanged(List.of(_items))` tras cada mutación (agregar/editar/quitar/precio), sin persistencia propia.

## Pantalla: crear cotización (modificada)

`lib/features/notas/presentation/screens/cotizacion_create_screen.dart`

- Al construir la pantalla, lee la lista de materiales padre vía `notaByIdProvider(widget.listaId)` y usa `lista.items` para sembrar el `CotizacionItemChecklist.initialItems` (copiando cada `NotaItem` con `precioUnitario: null`). Mientras la lista está en `loading`/`error`, mostrar el estado correspondiente antes de renderizar el formulario (igual patrón `AsyncValue.when` que el resto del módulo).
- Reemplaza `NotaItemEditor(showPrecio: true, ...)` por `CotizacionItemChecklist(initialItems: ..., onChanged: ...)`.
- El resto (campo `proveedor`, guardado, manejo de error) no cambia.

## Pantalla nueva: detalle/edición de cotización

`lib/features/notas/presentation/screens/cotizacion_detail_screen.dart`

- `CotizacionDetailScreen({required int cotizacionId})`, mismo patrón que `NotaDetailScreen`/`PrepacienteDetailScreen`: `ConsumerStatefulWidget`, carga vía `notaByIdProvider(cotizacionId)`, maneja `data`(encontrada)/`data`(null)/`loading`/`error`.
- Formulario: `proveedor` (editable, mismo validador que crear) + `CotizacionItemChecklist` pre-llenado con `nota.items` (sin siembra desde la lista — son sus propios ítems).
- Acciones: "Guardar" (→ `updateNota`) e ícono de eliminar (→ `showAppConfirm(destructive: true)` → `deleteNota` → `context.pop()`), mismo patrón de manejo de error (SnackBar) que `NotaDetailScreen`.
- Se navega aquí desde `ListaMaterialesDetailScreen`: cada tarjeta de cotización en el `ListView` horizontal gana `onTap` → `context.push('/notas/materiales/${listaId}/cotizacion/${c.idNota}')`.

**Ruta nueva** (registrada en `app_router.dart`, anidada bajo `/notas/materiales/:id`):
```
/notas/materiales/:id/cotizacion/:cotizacionId
```
con guardas `int.tryParse` para ambos parámetros, igual patrón que las rutas existentes del módulo.

## Pantalla modificada: `PrepacienteDetailScreen`

Pasa de `ConsumerWidget` de solo lectura a `ConsumerStatefulWidget` editable, mismo patrón que `NotaDetailScreen`:

- Formulario con los mismos campos que `PrepacienteCreateScreen` (`nombre_contacto` requerido, `telefono`, `tratamiento_probable`, `contenido`), pre-llenado con los valores actuales.
- Acciones: "Guardar" (→ `updateNota` con los valores del formulario, normalizando strings vacíos a `null` igual que en creación) + ícono de eliminar (→ confirmación destructiva → `deleteNota` → `context.pop()`).
- El botón "Contactar por WhatsApp" se conserva tal cual (visible solo si `telefono != null`).

## Pantalla modificada: `ListaMaterialesDetailScreen`

Pasa a `ConsumerStatefulWidget` editable:

- Formulario con los mismos campos que `ListaMaterialesCreateScreen` (`contenido` requerido, clínica opcional vía `showAppSelectionSheet`, ítems vía `NotaItemEditor` sin cambios), pre-llenado.
- Acciones: "Guardar" (→ `updateNota`) + ícono de eliminar. El diálogo de confirmación es dinámico: si `cotizacionesDeListaProvider(listaId)` no está vacío, el mensaje indica explícitamente que también se eliminarán esas N cotizaciones (para que el borrado en cascada no sea una sorpresa); si está vacío, mensaje genérico igual al resto del módulo.
- La sección de cotizaciones (tarjetas horizontales) se mantiene, solo se le agrega `onTap` por tarjeta (ver sección anterior) y el botón "Agregar cotización" existente no cambia.

## Adición: WhatsApp en `PatientDetailScreen`

`lib/features/pacientes/presentation/screens/patient_detail_screen.dart`

- Se agrega un botón "Contactar por WhatsApp" (mismo patrón visual y de manejo de error que en `PrepacienteDetailScreen`: `AppButton.primary`, ícono `Icons.chat`, `try { await launchWhatsApp(patient.telefono!); } catch (e) { ...SnackBar... }`), ubicado junto al botón "Ver Odontograma" existente en `_buildPatientContent`.
- Visible solo si `patient.telefono != null`. Reutiliza `launchWhatsApp` de `lib/core/services/whatsapp_launcher.dart` sin modificarlo.
- No requiere cambios de modelo ni de provider — `Patient.telefono` ya existe.

## Sin cambios de esquema de BD

Ninguna de las decisiones anteriores requiere una nueva migración: `NotaItem` no cambia, `Nota`/`NotasRepository`/`notas_providers.dart` ya soportan `updateNota`/`deleteNota` genéricos para cualquier `tipo`, y el `ON DELETE CASCADE` de `id_nota_relacionada` ya está en el esquema desde la migración v4.

## Testing

Siguiendo la profundidad de tests ya establecida en el módulo (modelos con tests unitarios; pantallas/widgets sin tests dedicados, verificados por `flutter analyze` + revisión manual): no se agregan tests de widget nuevos salvo que un componente sea puramente lógico y aislado. `CotizacionItemChecklist` no tiene test dedicado (mismo criterio que `NotaItemEditor`, que tampoco lo tiene).

## Fuera de alcance

- Traer automáticamente a una cotización ya creada los ítems que se agreguen después a la lista de materiales (edge case; se puede agregar manualmente con el botón "Agregar ítem" si hace falta).
- Cualquier cambio a la captura por imagen/PDF (HU-10, fuera de alcance desde el plan original).
- Cambios al modelo `NotaItem` o al esquema de `notas`.
