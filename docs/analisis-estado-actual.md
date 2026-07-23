# Análisis de Estado Actual — Klinik v1.1.2

> **Fecha de análisis:** Mayo 2026  
> **Versión analizada:** 1.1.2 (build 1)  
> **Plataforma:** Flutter 3.38.1 · Android & iOS · Offline-first · Español (es_ES)

---

## 1. Resumen Ejecutivo

Klinik es un asistente académico odontológico offline que cubre seis flujos principales: gestión de pacientes, programación de sesiones, registro de tratamientos, odontograma interactivo, wizard de diagnóstico endodóntico y dashboard de metas por clínica. La arquitectura está bien estructurada (Clean Architecture feature-first + Riverpod + SQLite) y cinco de los seis requisitos esenciales están completamente implementados.

**Calificación global por dimensión:**

| Dimensión | Calificación | Notas |
|---|---|---|
| Completitud de features | ⭐⭐⭐⭐ 4/5 | 5/6 features esenciales; seguimiento preventivo parcial |
| Arquitectura del código | ⭐⭐⭐⭐⭐ 5/5 | Separación limpia, Riverpod bien aplicado |
| Salud de dependencias | ⭐⭐⭐⭐ 4/5 | Todas en versión actual; sin conflictos |
| Cobertura de pruebas | ⭐ 1/5 | Solo smoke test; sin tests reales |
| Documentación interna | ⭐⭐⭐⭐ 4/5 | CLAUDE.md, docs de arquitectura y datos excelentes |
| Soporte móvil | ⭐⭐⭐ 3/5 | Android ✅; iOS tiene un bug crítico en permisos |
| UX / Interfaz | ⭐⭐⭐⭐ 4/5 | Tema profesional, localización, nav intuitiva |

---

## 2. Estado de Implementación por Feature

### 2.1 Features esenciales completamente implementadas

| Feature | Evidencia en código |
|---|---|
| Odontograma interactivo ISO | `lib/features/odontograma/` — `ToothWidget`, `OdontogramaController` |
| Diferenciación de tratamientos | `tratamientos.estado`: `pendiente / en_proceso / concluido` |
| Clasificación por clínica / período | `clinicas` FK a `periodos`; filtros en dashboard y tratamientos |
| Recordatorios automáticos de citas | `NotificationService` — agenda 7 días hacia adelante con `zonedSchedule` |
| Búsqueda rápida de pacientes | `PatientsScreen` con `TextEditingController` y filtro en tiempo real |
| Adjuntar imágenes a paciente | `ImageService` + `imagenes_paths` (pipe-delimited) + `image_picker` |

### 2.2 Features parciales o sin implementar

| Feature | Estado | Gap |
|---|---|---|
| Sugerencia automática de control preventivo | ⚠️ Parcial | El campo `padecimiento_relevante` existe, pero no hay lógica que calcule "próxima cita sugerida en X meses" |
| Horarios de clínica | ❌ Dead feature | `clinicas.horarios` existe en el esquema pero nunca se muestra ni edita en la UI |
| Edición de un tratamiento ya creado | ❌ Sin UI | `updateTratamiento()` existe en el repositorio pero ninguna pantalla lo invoca |
| Eliminación de una sesión individual | ❌ Sin UI | `deleteSesion()` existe pero no es accesible desde la pantalla de detalle |
| Edición de objetivo de clínica | ❌ Sin UI | `updateObjetivo()` y el notifier existen pero sin diálogo de edición |
| Notas estructuradas en sesión | ❌ No implementado | El esquema no tiene campo `notas`; sesiones solo registran estado de asistencia |

---

## 3. Bugs Críticos

### 🔴 BUG-01 — iOS se cierra al acceder a la galería de fotos
**Archivo:** `ios/Runner/Info.plist`  
**Impacto:** La app colapsa en cualquier iPhone al intentar seleccionar o tomar una foto de paciente.  
**Causa:** iOS requiere claves de privacidad en `Info.plist` para acceder a la cámara y galería.  
**Archivos faltantes:**
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Para agregar radiografías y evidencia fotográfica de tratamientos.</string>
<key>NSCameraUsageDescription</key>
<string>Para capturar fotos de pacientes y evidencia de procedimientos clínicos.</string>
```

---

### 🔴 BUG-02 — Sobreescritura silenciosa de imágenes de paciente
**Archivo:** `lib/core/services/image_service.dart:26`  
**Impacto:** Si dos pacientes tienen una foto con el mismo nombre de archivo, la segunda sobreescribe a la primera sin advertencia.  
**Causa:**
```dart
final String fileName = path.basename(imageFile.path); // nombre original sin UUID
final String savedPath = path.join(imagesDirPath, fileName);
await imageFile.saveTo(savedPath); // sobreescribe si ya existe
```
**Corrección:** Generar nombre único: `${DateTime.now().millisecondsSinceEpoch}_${fileName}`

---

### 🔴 BUG-03 — Paciente eliminado (soft-delete) aún recuperable por ID
**Archivo:** `lib/features/pacientes/data/repositories/patient_repository.dart`  
**Impacto:** `getPatientById()` no filtra `WHERE deleted_at IS NULL`. Un paciente "eliminado" sigue apareciendo en la vista de detalle si se navega directamente a su ruta `/pacientes/:id`.  
**Causa:** `getAllPatients()` sí filtra; `getPatientById()` no lo hace.

---

### 🟡 BUG-04 — Tratamiento creado sin sesión queda huérfano
**Archivo:** `lib/features/agenda/presentation/screens/appointment_create_screen.dart:912-926`  
**Impacto:** Si la creación del tratamiento tiene éxito pero la inserción de la primera sesión falla, queda un registro de tratamiento sin sesiones en la base de datos.  
**Causa:** Las dos operaciones no están envueltas en una transacción SQLite.

---

### 🟡 BUG-05 — Progreso de objetivo puede superar la meta
**Archivo:** `lib/features/agenda/data/repositories/agenda_repository.dart` — `incrementObjetivoProgress()`  
**Impacto:** `cantidad_actual` puede crecer más allá de `cantidad_meta` si el usuario finaliza más tratamientos de los planeados.  
**Causa:** No hay validación `if (cantidadActual >= cantidadMeta) return;` antes del `UPDATE`.

---

### 🟡 BUG-06 — Recursión potencial en `getOdontograma()`
**Archivo:** `lib/features/odontograma/data/odontograma_repository.dart:13-32`  
**Impacto:** Si `seedOdontograma()` falla silenciosamente, el método se llama a sí mismo de forma recursiva sin límite de profundidad.  
**Causa:**
```dart
if (maps.isEmpty) {
  await seedOdontograma(odontogramaId);
  return getOdontograma(pacienteId); // llamada recursiva sin guarda
}
```

---

## 4. Errores de Datos y Consistencia

### 4.1 Tipo incorrecto al deserializar `deleted_at`
**Archivo:** `lib/features/pacientes/domain/patient.dart:22`  
El modelo Freezed declara `DateTime? deletedAt`, pero SQLite almacena el valor como `TEXT` (ISO8601). No existe un parser custom como el que tiene `imagenes_paths`. La deserialización fallará en tiempo de ejecución cuando `deleted_at` no sea null.

### 4.2 Formato de color de clínica inconsistente
Los colores de clínica se almacenan como strings, pero existen al menos tres formatos en el código:
- `Color(0xFFFC4391)` — representación Dart
- `0xFFFC4391` — hexadecimal sin prefijo
- `#FC4391` — formato web

Hay lógica de parsing con fallbacks en `dashboard_screen.dart:284-309` y duplicada en `timeline_session_list.dart:586`. Se recomienda estandarizar a un único formato y extraer la función de parseo.

### 4.3 Ruta de imágenes usando `|` como separador sin escapado
**Archivo:** `patient_repository.dart`  
Si una ruta de archivo contiene el carácter `|`, la serialización/deserialización corrompe la lista. Aunque improbable en Android/iOS, debería reemplazarse por un arreglo JSON: `json.encode(paths)` / `json.decode(value)`.

---

## 5. Problemas de Rendimiento

### 5.1 Consulta N+1 en `getAllTratamientosRich()` ⚠️ Alta prioridad
**Archivo:** `lib/features/agenda/data/repositories/agenda_repository.dart:89-163`  
Por cada tratamiento se ejecuta una consulta separada para obtener su próxima sesión. Con 50 tratamientos = 51 consultas a la base de datos. En dispositivos de gama baja esto congela la UI.

**Solución:** Reemplazar el bucle con un único JOIN:
```sql
SELECT t.*, MIN(s.fecha_inicio) AS proxima_sesion
FROM tratamientos t
LEFT JOIN sesiones s 
  ON t.id_tratamiento = s.id_tratamiento 
  AND s.estado_asistencia IS NULL
GROUP BY t.id_tratamiento
```

### 5.2 Carga completa de todas las sesiones en memoria
**Archivo:** `lib/features/agenda/presentation/providers/agenda_providers.dart:24`  
`allSesionesProvider` trae toda la tabla `sesiones` y filtra en Dart. Con dos años de historial académico esto puede suponer miles de registros. Debería filtrarse por rango de fechas en la capa de base de datos.

### 5.3 Falta de índices en columnas de consulta frecuente
**Archivo:** `lib/core/database/database_helper.dart`  
No hay índices definidos en:
- `tratamientos(id_expediente, id_clinica)`
- `sesiones(fecha_inicio)`
- `sesiones(id_tratamiento)`

Esto provoca full table scans en cada consulta de la agenda y del dashboard.

### 5.4 Sin paginación en la lista de pacientes
**Archivo:** `lib/features/pacientes/presentation/screens/patients_screen.dart`  
Todos los pacientes se cargan en memoria y se filtran con `.where()`. A partir de ~500 pacientes la pantalla inicial se vuelve perceptiblemente lenta.

---

## 6. Brechas de UX

| # | Pantalla afectada | Descripción |
|---|---|---|
| U-01 | Tratamiento detalle | No hay diálogo de confirmación antes de eliminar un tratamiento o sesión |
| U-02 | Lista de pacientes | La búsqueda no normaliza acentos: "José" no encuentra "jose" |
| U-03 | Lista de tratamientos | No hay búsqueda/filtro por nombre de tratamiento |
| U-04 | Recordatorios | No hay botón "Probar notificación" para verificar que el OS las tiene habilitadas |
| U-05 | Settings | El toggle `summaryToday` siempre está en `true` (hardcoded); el control es decorativo |
| U-06 | Pacientes | Los pacientes archivados son invisibles; no hay flujo de recuperación |
| U-07 | General | No existe funcionalidad de exportar o respaldar datos |

---

## 7. Problemas en la Capa de Estado (Riverpod)

| Problema | Impacto | Archivo |
|---|---|---|
| `allTratamientosRichProvider` no se invalida cuando cambia el estado de una sesión | La columna "Próxima sesión" muestra datos desactualizados | `agenda_providers.dart` |
| `dashboardStatsProvider` no se invalida al eliminar un tratamiento | El dashboard muestra conteos de progreso incorrectos | `treatment_detail_screen.dart:378` |
| `allSesionesProvider` no observa `clinicasUpdateSignalProvider` | Las sesiones de una clínica eliminada siguen apareciendo | `agenda_providers.dart:24` |
| `ReminderSettingsNotifier` instancia `AgendaRepository()` directamente | Rompe la inyección de dependencias | `reminder_settings_provider.dart:131` |

---

## 8. Calidad de Código

### 8.1 Manejo de excepciones silencioso
Hay múltiples bloques `catch (_) {}` vacíos o que solo ignoran el error:
- `color_picker_field.dart:84` — fallo al parsear color
- `dashboard_screen.dart:307` — fallo al parsear color de clínica  
- `notification_service.dart:231` — fallo al parsear fecha de sesión
- `pieza_dental.dart:36` — excepción completamente ignorada

### 8.2 Archivo excesivamente largo
`appointment_create_screen.dart` tiene **962 líneas** en un solo widget stateful que maneja formulario, validación, dropdowns de selección de paciente/clínica/objetivo y gestión de sesiones. Debería fragmentarse en widgets separados.

### 8.3 Columna `horarios` sin uso
La tabla `clinicas` incluye `horarios TEXT` que nunca es leída ni escrita por ningún provider o pantalla. Es una deuda de diseño que confunde.

### 8.4 Cobertura de pruebas: prácticamente nula
```dart
// test/smoke_test.dart
testWidgets('Smoke test - App should load', (tester) async {
  expect(true, isTrue);  // ← no prueba nada
});
```
No existen tests unitarios para repositorios, providers ni lógica de negocio.

---

## 9. Árbol de Diagnóstico: Aclaración

El módulo `diagnosis/` se describe como "asistido por IA" pero es un **árbol de decisión estático hardcodeado** en `DiagnosisTree` con lógica endodóntica binaria (Sí/No). No utiliza modelos de ML ni servicios externos. Los 9 diagnósticos posibles (Pulpitis Reversible, Irreversible, Necrosis, Absceso, etc.) están definidos como constantes Dart.

El árbol asume una profundidad máxima de 5 pasos; el indicador de progreso en la UI lo refleja como `(_history.length + 1) / 5.0`, lo que puede superarse si el árbol crece.

---

## 10. Plan de Correcciones Priorizado

### Prioridad 1 — Antes del próximo release (bugs bloqueantes)
1. **BUG-01** — Agregar `NSPhotoLibraryUsageDescription` y `NSCameraUsageDescription` a `ios/Runner/Info.plist`
2. **BUG-02** — Generar nombre único para imágenes guardadas en `ImageService`
3. **BUG-03** — Agregar filtro `WHERE deleted_at IS NULL` a `getPatientById()`
4. **5.1** — Reemplazar bucle N+1 en `getAllTratamientosRich()` con consulta JOIN
5. **4.1** — Agregar parser `DateTime?` para el campo `deleted_at` en el modelo `Patient`

### Prioridad 2 — Calidad antes de escalar usuarios
1. **BUG-04** — Envolver creación de tratamiento + sesión inicial en una transacción
2. **BUG-05** — Validar límite antes de incrementar `cantidad_actual`
3. **4.2** — Estandarizar formato de color y extraer función reutilizable
4. **4.3** — Reemplazar serialización de imágenes con `json.encode/decode`
5. **7** — Corregir gaps de invalidación de providers
6. **6** — Agregar diálogos de confirmación para acciones destructivas

### Prioridad 3 — Mejoras a mediano plazo
1. Agregar índices a columnas frecuentemente consultadas
2. Implementar búsqueda de pacientes con normalización de acentos
3. Implementar edición de tratamiento, objetivo y eliminación de sesión en la UI
4. Fragmentar `appointment_create_screen.dart`
5. Agregar suite de tests unitarios para repositorios y providers

---

*Documento generado mediante análisis estático del código fuente. Todos los archivos y números de línea son referenciales al estado del commit actual.*
