# Notas Rápidas (Generales, Prepacientes, Listas de Materiales) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Agregar el módulo de Notas (generales, prepacientes y listas de materiales con cotizaciones) definido en las historias de usuario HU-01 a HU-13, con captura y edición manual.

**Architecture:** Nueva feature `lib/features/notas/` que sigue el patrón ya establecido en `pacientes`/`clinicas_metas`: modelo `freezed` → repositorio sobre `DatabaseHelper` (una sola tabla `notas` con columna `tipo` discriminante) → provider Riverpod (`AsyncNotifier` + providers derivados filtrados en memoria) → pantallas con los widgets del sistema de diseño (`AppScaffold`, `AppCard`, `AppEntityCard`, etc.). Un único hub `NotasScreen` con `TabBar` (Generales / Prepacientes / Materiales) centraliza los tres listados; las pantallas de creación/detalle son rutas raíz sin navbar, igual que `/patient-create` o `/diagnosis`.

**Tech Stack:** Flutter 3.7+ (Dart ^3.7.2), `flutter_riverpod`, `sqflite`, `go_router`, `freezed`/`json_serializable`, `flutter_form_builder`, `url_launcher` (nueva dependencia, para HU-06).

**Spec:** `docs/documentacion-notas-rapidas/historias-usuario-notas.md`

## Global Constraints

- Commits en español, minúscula al inicio, en una rama que no sea `main` (ya estamos en `feat/implementa-notas-rapidas`).
- No usar `Co-Authored-By` ni referencias a Claude en mensajes de commit.
- No correr `dart format` sobre todo `lib/` (fvm no instalado; formatear solo los archivos tocados con el Dart SDK del sistema si hace falta).
- Seguir el patrón de soft/hard delete y transacciones ya usado en `PatientRepository` cuando aplique.
- **Fuera de alcance de este plan** (requieren un plan aparte por ser un subsistema independiente con dependencias nuevas de OCR/PDF/share-intent): HU-10 (crear lista de materiales desde imagen/PDF) y la variante "por imagen/PDF" de HU-11. Este plan implementa el modelo de datos completo (incluida la columna `origen`) para que ese trabajo futuro no requiera migración adicional, pero solo construye el flujo `origen = 'manual'`.

---

## Mapa de historias de usuario → entregable

| HU | Entregable |
|----|-----------|
| HU-01 Crear nota rápida | Tarea 10 |
| HU-02 Listar y buscar notas | Tarea 9 |
| HU-03 Editar/eliminar nota | Tarea 11 |
| HU-04 Registrar prepaciente | Tarea 12 |
| HU-05 Listar prepacientes | Tarea 13 |
| HU-06 Contactar por WhatsApp | Tarea 14 |
| HU-07 Crear lista de materiales manual | Tarea 15 |
| HU-11 Registrar cotización (manual) | Tarea 18 |
| HU-12 Comparar cotizaciones | Tarea 17 |
| HU-13 Listar/filtrar listas de materiales | Tarea 16 |

---

## File Structure

```
lib/features/notas/
  domain/
    nota_tipo.dart          # enums NotaTipo, NotaOrigen
    nota_item.dart           # NotaItem (freezed) — ítems de items_json
    nota.dart                 # Nota (freezed) — modelo único de la tabla
  data/
    repositories/
      notas_repository.dart
  presentation/
    providers/
      notas_providers.dart
    screens/
      notas_screen.dart                    # hub con TabBar
      nota_create_screen.dart              # HU-01
      nota_detail_screen.dart              # HU-03
      prepaciente_create_screen.dart       # HU-04
      prepaciente_detail_screen.dart       # HU-06
      lista_materiales_create_screen.dart  # HU-07
      lista_materiales_detail_screen.dart  # HU-11 (lectura) + HU-12
      cotizacion_create_screen.dart        # HU-11 (escritura)
    widgets/
      nota_general_list_view.dart          # HU-02
      prepaciente_list_view.dart           # HU-05
      lista_materiales_list_view.dart      # HU-13
      nota_item_editor.dart                # editor de ítems compartido (materiales/cotización)
lib/core/services/
  whatsapp_launcher.dart                    # helper HU-06
```

Modificados: `lib/core/database/database_helper.dart`, `lib/core/router/app_router.dart`, `lib/features/dashboard/presentation/screens/dashboard_screen.dart`, `pubspec.yaml`.

Tests nuevos en `test/features/notas/` espejando `test/features/agenda/estados_enum_test.dart` (round-trip de modelos) y `test/core/widgets/` para el editor de ítems si aplica.

---

### Task 1: Enums `NotaTipo` y `NotaOrigen`

**Files:**
- Create: `lib/features/notas/domain/nota_tipo.dart`
- Test: `test/features/notas/nota_tipo_test.dart`

**Interfaces:**
- Produces: `enum NotaTipo { general, prepaciente, listaMateriales, cotizacion }` con `.dbValue` (`'general'`, `'prepaciente'`, `'lista_materiales'`, `'cotizacion'`) y `.label`; `enum NotaOrigen { manual, imagen, pdf }` con `.dbValue` y `.label`.

- [ ] **Step 1: Escribe el test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

void main() {
  test('NotaTipo.listaMateriales serializa a lista_materiales', () {
    expect(NotaTipo.listaMateriales.dbValue, 'lista_materiales');
  });

  test('NotaOrigen.imagen serializa a imagen', () {
    expect(NotaOrigen.imagen.dbValue, 'imagen');
  });

  test('labels en español', () {
    expect(NotaTipo.prepaciente.label, 'Prepaciente');
    expect(NotaTipo.cotizacion.label, 'Cotización');
  });
}
```

- [ ] **Step 2: Corre el test y confirma que falla**

Run: `flutter test test/features/notas/nota_tipo_test.dart`
Expected: FAIL (no existe `nota_tipo.dart`)

- [ ] **Step 3: Implementa los enums**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

enum NotaTipo {
  @JsonValue('general')
  general,
  @JsonValue('prepaciente')
  prepaciente,
  @JsonValue('lista_materiales')
  listaMateriales,
  @JsonValue('cotizacion')
  cotizacion;

  String get dbValue => switch (this) {
    NotaTipo.general => 'general',
    NotaTipo.prepaciente => 'prepaciente',
    NotaTipo.listaMateriales => 'lista_materiales',
    NotaTipo.cotizacion => 'cotizacion',
  };

  String get label => switch (this) {
    NotaTipo.general => 'General',
    NotaTipo.prepaciente => 'Prepaciente',
    NotaTipo.listaMateriales => 'Lista de materiales',
    NotaTipo.cotizacion => 'Cotización',
  };
}

enum NotaOrigen {
  @JsonValue('manual')
  manual,
  @JsonValue('imagen')
  imagen,
  @JsonValue('pdf')
  pdf;

  String get dbValue => switch (this) {
    NotaOrigen.manual => 'manual',
    NotaOrigen.imagen => 'imagen',
    NotaOrigen.pdf => 'pdf',
  };

  String get label => switch (this) {
    NotaOrigen.manual => 'Manual',
    NotaOrigen.imagen => 'Imagen',
    NotaOrigen.pdf => 'PDF',
  };
}
```

- [ ] **Step 4: Corre el test y confirma que pasa**

Run: `flutter test test/features/notas/nota_tipo_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/notas/domain/nota_tipo.dart test/features/notas/nota_tipo_test.dart
git commit -m "feat: agrega enums NotaTipo y NotaOrigen"
```

---

### Task 2: Modelo `NotaItem`

**Files:**
- Create: `lib/features/notas/domain/nota_item.dart`
- Test: `test/features/notas/nota_item_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces: `NotaItem({required String nombre, required num cantidad, String? unidad, double? precioUnitario})` con `NotaItem.fromJson`/`.toJson` (JSON key `precio_unitario`). Usado por `Nota.items` (Task 3) y por `NotaItemEditor` (Task 8).

- [ ] **Step 1: Escribe el test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';

void main() {
  test('NotaItem round-trip preserva precio_unitario', () {
    const item = NotaItem(
      nombre: 'Guantes',
      cantidad: 2,
      unidad: 'caja',
      precioUnitario: 45.5,
    );
    final json = item.toJson();
    expect(json['precio_unitario'], 45.5);
    expect(NotaItem.fromJson(json), item);
  });

  test('NotaItem sin precio ni unidad', () {
    const item = NotaItem(nombre: 'Resina', cantidad: 1);
    expect(NotaItem.fromJson(item.toJson()), item);
  });
}
```

- [ ] **Step 2: Corre el test y confirma que falla**

Run: `flutter test test/features/notas/nota_item_test.dart`
Expected: FAIL (no existe `nota_item.dart` / falta build_runner)

- [ ] **Step 3: Implementa el modelo**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nota_item.freezed.dart';
part 'nota_item.g.dart';

@freezed
abstract class NotaItem with _$NotaItem {
  const factory NotaItem({
    required String nombre,
    required num cantidad,
    String? unidad,
    @JsonKey(name: 'precio_unitario') double? precioUnitario,
  }) = _NotaItem;

  factory NotaItem.fromJson(Map<String, dynamic> json) =>
      _$NotaItemFromJson(json);
}
```

- [ ] **Step 4: Genera el código y corre el test**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/features/notas/nota_item_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/notas/domain/nota_item.dart lib/features/notas/domain/nota_item.freezed.dart lib/features/notas/domain/nota_item.g.dart test/features/notas/nota_item_test.dart
git commit -m "feat: agrega modelo NotaItem"
```

---

### Task 3: Modelo `Nota`

**Files:**
- Create: `lib/features/notas/domain/nota.dart`
- Test: `test/features/notas/nota_test.dart`

**Interfaces:**
- Consumes: `NotaTipo`, `NotaOrigen` (Task 1), `NotaItem` (Task 2).
- Produces: `Nota` (freezed) con campos `idNota (int?)`, `tipo (NotaTipo)`, `contenido (String?)`, `fecha (String)`, `idPaciente (String?)`, `idClinica (int?)`, `idNotaRelacionada (int?)`, `items (List<NotaItem>, default [])`, `proveedor (String?)`, `origen (NotaOrigen, default manual)`, `nombreContacto (String?)`, `telefono (String?)`, `tratamientoProbable (String?)`, `convertido (bool, default false)`, `idPacienteConvertido (String?)`. Getter `totalCotizacion`. Usado por `NotasRepository` (Task 5) y todas las pantallas.

- [ ] **Step 1: Escribe el test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

void main() {
  test('Nota general round-trip', () {
    const nota = Nota(
      tipo: NotaTipo.general,
      contenido: 'Revisar radiografía',
      fecha: '2026-09-01T10:00:00.000',
    );
    final json = nota.toJson();
    expect(json['tipo'], 'general');
    expect(Nota.fromJson(json), nota);
  });

  test('Nota lista_materiales serializa items_json como lista de mapas', () {
    const nota = Nota(
      tipo: NotaTipo.listaMateriales,
      fecha: '2026-09-01T10:00:00.000',
      items: [NotaItem(nombre: 'Resina', cantidad: 3, unidad: 'pza')],
    );
    final json = nota.toJson();
    expect(json['items_json'], isA<List>());
    expect(Nota.fromJson(json).items, nota.items);
  });

  test('Nota.fromJson parsea items_json cuando viene como String (BD)', () {
    final json = {
      'id_nota': 1,
      'tipo': 'lista_materiales',
      'fecha': '2026-09-01T10:00:00.000',
      'items_json': '[{"nombre":"Guantes","cantidad":2,"unidad":"caja"}]',
      'origen': 'manual',
      'convertido': 0,
    };
    final nota = Nota.fromJson(json);
    expect(nota.items, [const NotaItem(nombre: 'Guantes', cantidad: 2, unidad: 'caja')]);
  });

  test('Nota.fromJson trata items_json vacío/null como lista vacía', () {
    final json = {
      'id_nota': 2,
      'tipo': 'general',
      'fecha': '2026-09-01T10:00:00.000',
      'items_json': null,
      'origen': 'manual',
      'convertido': 0,
    };
    expect(Nota.fromJson(json).items, isEmpty);
  });

  test('totalCotizacion suma cantidad * precioUnitario', () {
    const nota = Nota(
      tipo: NotaTipo.cotizacion,
      fecha: '2026-09-01T10:00:00.000',
      items: [
        NotaItem(nombre: 'A', cantidad: 2, precioUnitario: 10),
        NotaItem(nombre: 'B', cantidad: 1, precioUnitario: 5),
      ],
    );
    expect(nota.totalCotizacion, 25);
  });
}
```

- [ ] **Step 2: Corre el test y confirma que falla**

Run: `flutter test test/features/notas/nota_test.dart`
Expected: FAIL (no existe `nota.dart`)

- [ ] **Step 3: Implementa el modelo**

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

part 'nota.freezed.dart';
part 'nota.g.dart';

@freezed
abstract class Nota with _$Nota {
  const Nota._();

  const factory Nota({
    @JsonKey(name: 'id_nota') int? idNota,
    @JsonKey(name: 'tipo') required NotaTipo tipo,
    @JsonKey(name: 'contenido') String? contenido,
    @JsonKey(name: 'fecha') required String fecha,
    @JsonKey(name: 'id_paciente') String? idPaciente,
    @JsonKey(name: 'id_clinica') int? idClinica,
    @JsonKey(name: 'id_nota_relacionada') int? idNotaRelacionada,
    @JsonKey(name: 'items_json', fromJson: _parseItems)
    @Default([])
    List<NotaItem> items,
    @JsonKey(name: 'proveedor') String? proveedor,
    @JsonKey(name: 'origen')
    @Default(NotaOrigen.manual)
    NotaOrigen origen,
    @JsonKey(name: 'nombre_contacto') String? nombreContacto,
    @JsonKey(name: 'telefono') String? telefono,
    @JsonKey(name: 'tratamiento_probable') String? tratamientoProbable,
    @JsonKey(name: 'convertido', fromJson: _boolFromDb)
    @Default(false)
    bool convertido,
    @JsonKey(name: 'id_paciente_convertido') String? idPacienteConvertido,
  }) = _Nota;

  factory Nota.fromJson(Map<String, dynamic> json) => _$NotaFromJson(json);

  /// Suma `cantidad * precioUnitario` de los ítems (usado en notas `cotizacion`).
  double get totalCotizacion => items.fold(
    0.0,
    (sum, i) => sum + (i.cantidad * (i.precioUnitario ?? 0)),
  );
}

List<NotaItem> _parseItems(Object? value) {
  if (value == null) return [];
  if (value is String) {
    if (value.trim().isEmpty) return [];
    final decoded = jsonDecode(value) as List;
    return decoded
        .map((e) => NotaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  if (value is List) {
    return value
        .map((e) => NotaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

bool _boolFromDb(Object? value) => value == true || value == 1;
```

Nota: falta el import de `dart:convert` para `jsonDecode`; agrégalo al inicio del archivo (`import 'dart:convert';`).

- [ ] **Step 4: Genera el código y corre el test**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/features/notas/nota_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/notas/domain/nota.dart lib/features/notas/domain/nota.freezed.dart lib/features/notas/domain/nota.g.dart test/features/notas/nota_test.dart
git commit -m "feat: agrega modelo Nota"
```

---

### Task 4: Esquema de BD — tabla `notas` (migración v4)

**Files:**
- Modify: `lib/core/database/database_helper.dart`

**Interfaces:**
- Produces: tabla `notas` con columnas exactas del modelo de referencia del spec; usada por `NotasRepository` (Task 5).

- [ ] **Step 1: Sube `_databaseVersion` a 4**

```dart
static const int _databaseVersion = 4;
```

- [ ] **Step 2: Agrega el CREATE TABLE en `_onCreate`** (después del bloque de `sesiones`, antes del cierre del método)

```dart
    // 4. Notas (generales, prepacientes, listas de materiales, cotizaciones)
    await db.execute('''
      CREATE TABLE notas (
        id_nota INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL CHECK(tipo IN ('general', 'prepaciente', 'lista_materiales', 'cotizacion')),
        contenido TEXT,
        fecha TEXT NOT NULL,
        id_paciente TEXT,
        id_clinica INTEGER,
        id_nota_relacionada INTEGER,
        items_json TEXT,
        proveedor TEXT,
        origen TEXT NOT NULL DEFAULT 'manual' CHECK(origen IN ('manual', 'imagen', 'pdf')),
        nombre_contacto TEXT,
        telefono TEXT,
        tratamiento_probable TEXT,
        convertido INTEGER NOT NULL DEFAULT 0 CHECK(convertido IN (0, 1)),
        id_paciente_convertido TEXT,
        FOREIGN KEY (id_paciente) REFERENCES pacientes (id_expediente) ON DELETE SET NULL,
        FOREIGN KEY (id_clinica) REFERENCES clinicas (id_clinica) ON DELETE SET NULL,
        FOREIGN KEY (id_nota_relacionada) REFERENCES notas (id_nota) ON DELETE CASCADE,
        FOREIGN KEY (id_paciente_convertido) REFERENCES pacientes (id_expediente) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_notas_tipo ON notas (tipo)');
    await db.execute(
        'CREATE INDEX idx_notas_relacionada ON notas (id_nota_relacionada)');
    await db.execute('CREATE INDEX idx_notas_paciente ON notas (id_paciente)');
```

- [ ] **Step 3: Agrega la migración v4 en `_onUpgrade`**

```dart
    if (oldVersion < 4) {
      await _migrateToV4(db);
      debugPrint("Migración V4: tabla 'notas' agregada.");
    }
```

Y el método (junto a `_migrateToV3`), reutilizando exactamente el mismo SQL del Step 2:

```dart
  /// V4: agrega la tabla `notas` (notas generales, prepacientes, listas de
  /// materiales y sus cotizaciones).
  Future<void> _migrateToV4(Database db) async {
    await db.execute('''
      CREATE TABLE notas (
        id_nota INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL CHECK(tipo IN ('general', 'prepaciente', 'lista_materiales', 'cotizacion')),
        contenido TEXT,
        fecha TEXT NOT NULL,
        id_paciente TEXT,
        id_clinica INTEGER,
        id_nota_relacionada INTEGER,
        items_json TEXT,
        proveedor TEXT,
        origen TEXT NOT NULL DEFAULT 'manual' CHECK(origen IN ('manual', 'imagen', 'pdf')),
        nombre_contacto TEXT,
        telefono TEXT,
        tratamiento_probable TEXT,
        convertido INTEGER NOT NULL DEFAULT 0 CHECK(convertido IN (0, 1)),
        id_paciente_convertido TEXT,
        FOREIGN KEY (id_paciente) REFERENCES pacientes (id_expediente) ON DELETE SET NULL,
        FOREIGN KEY (id_clinica) REFERENCES clinicas (id_clinica) ON DELETE SET NULL,
        FOREIGN KEY (id_nota_relacionada) REFERENCES notas (id_nota) ON DELETE CASCADE,
        FOREIGN KEY (id_paciente_convertido) REFERENCES pacientes (id_expediente) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_notas_tipo ON notas (tipo)');
    await db.execute(
        'CREATE INDEX idx_notas_relacionada ON notas (id_nota_relacionada)');
    await db.execute('CREATE INDEX idx_notas_paciente ON notas (id_paciente)');
  }
```

- [ ] **Step 4: Verifica que la app abre sin errores**

Run: `flutter analyze lib/core/database/database_helper.dart`
Expected: sin errores. (No hay infraestructura de tests de BD en este proyecto — se valida manualmente en la Tarea 21 corriendo la app.)

- [ ] **Step 5: Commit**

```bash
git add lib/core/database/database_helper.dart
git commit -m "feat: agrega tabla notas (migración BD v4)"
```

---

### Task 5: `NotasRepository`

**Files:**
- Create: `lib/features/notas/data/repositories/notas_repository.dart`

**Interfaces:**
- Consumes: `DatabaseHelper` (`lib/core/database/database_helper.dart`), `Nota`/`NotaItem` (Tasks 2-3).
- Produces: `NotasRepository` con `getAllNotas()`, `getNotaById(int id)`, `insertNota(Nota nota) -> Future<int>`, `updateNota(Nota nota) -> Future<int>`, `deleteNota(int id) -> Future<void>`. Usado por `notas_providers.dart` (Task 6).

- [ ] **Step 1: Implementa el repositorio** (sin test dedicado: el proyecto no tiene infraestructura de tests de `sqflite`; se ejercita a través de los providers y de QA manual en la Tarea 21, igual que `ClinicasRepository`/`PatientRepository`)

```dart
import 'dart:convert';

import 'package:project_mmh/core/database/database_helper.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';

class NotasRepository {
  final DatabaseHelper _dbHelper;

  NotasRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  static const String _tableName = 'notas';

  Map<String, dynamic> _toDbMap(Nota nota) {
    final map = nota.toJson();
    map['items_json'] = jsonEncode(
      nota.items.map((i) => i.toJson()).toList(),
    );
    map['convertido'] = nota.convertido ? 1 : 0;
    return map;
  }

  Future<List<Nota>> getAllNotas() async {
    final db = await _dbHelper.database;
    final result = await db.query(_tableName, orderBy: 'fecha DESC');
    return result.map((e) => Nota.fromJson(e)).toList();
  }

  Future<Nota?> getNotaById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      _tableName,
      where: 'id_nota = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Nota.fromJson(result.first);
  }

  Future<int> insertNota(Nota nota) async {
    return await _dbHelper.insert(_tableName, _toDbMap(nota));
  }

  Future<int> updateNota(Nota nota) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      _toDbMap(nota),
      where: 'id_nota = ?',
      whereArgs: [nota.idNota],
    );
  }

  Future<void> deleteNota(int id) async {
    final db = await _dbHelper.database;
    await db.delete(_tableName, where: 'id_nota = ?', whereArgs: [id]);
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/data/repositories/notas_repository.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/data/repositories/notas_repository.dart
git commit -m "feat: agrega NotasRepository"
```

---

### Task 6: Providers de Notas

**Files:**
- Create: `lib/features/notas/presentation/providers/notas_providers.dart`

**Interfaces:**
- Consumes: `NotasRepository` (Task 5), `Nota`/`NotaTipo` (Tasks 1-3).
- Produces:
  - `notasRepositoryProvider: Provider<NotasRepository>`
  - `notasProvider: AsyncNotifierProvider<NotasNotifier, List<Nota>>` con métodos `addNota(Nota)`, `updateNota(Nota)`, `deleteNota(int id)`, `getById(int id) -> Future<Nota?>` (lectura directa para pantallas de detalle, sin pasar por el estado en memoria).
  - `notaByIdProvider: FutureProvider.family<Nota?, int>`
  - `notasPorTipoProvider: Provider.family<List<Nota>, NotaTipo>` — deriva de `notasProvider`, filtra por `tipo`.
  - `cotizacionesDeListaProvider: Provider.family<List<Nota>, int>` — deriva de `notasProvider`, filtra `tipo == cotizacion && idNotaRelacionada == arg`.
- Usado por todas las pantallas (Tasks 9-20).

- [ ] **Step 1: Implementa el archivo**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/features/notas/data/repositories/notas_repository.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';

final notasRepositoryProvider = Provider<NotasRepository>((ref) {
  return NotasRepository();
});

final notasProvider = AsyncNotifierProvider<NotasNotifier, List<Nota>>(
  NotasNotifier.new,
);

class NotasNotifier extends AsyncNotifier<List<Nota>> {
  @override
  Future<List<Nota>> build() async {
    return ref.watch(notasRepositoryProvider).getAllNotas();
  }

  Future<void> _reloadInPlace() async {
    final notas = await ref.read(notasRepositoryProvider).getAllNotas();
    state = AsyncData(notas);
  }

  Future<int> addNota(Nota nota) async {
    final id = await ref.read(notasRepositoryProvider).insertNota(nota);
    await _reloadInPlace();
    return id;
  }

  Future<void> updateNota(Nota nota) async {
    await ref.read(notasRepositoryProvider).updateNota(nota);
    ref.invalidate(notaByIdProvider(nota.idNota!));
    await _reloadInPlace();
  }

  Future<void> deleteNota(int id) async {
    await ref.read(notasRepositoryProvider).deleteNota(id);
    ref.invalidate(notaByIdProvider(id));
    await _reloadInPlace();
  }
}

final notaByIdProvider = FutureProvider.family<Nota?, int>((ref, id) {
  return ref.watch(notasRepositoryProvider).getNotaById(id);
});

final notasPorTipoProvider = Provider.family<List<Nota>, NotaTipo>((
  ref,
  tipo,
) {
  final notas = ref.watch(notasProvider).asData?.value ?? [];
  return notas.where((n) => n.tipo == tipo).toList();
});

final cotizacionesDeListaProvider = Provider.family<List<Nota>, int>((
  ref,
  idLista,
) {
  final notas = ref.watch(notasProvider).asData?.value ?? [];
  return notas
      .where((n) => n.tipo == NotaTipo.cotizacion && n.idNotaRelacionada == idLista)
      .toList();
});
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/providers/notas_providers.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/providers/notas_providers.dart
git commit -m "feat: agrega providers de notas"
```

---

### Task 7: Dependencia `url_launcher` + helper de WhatsApp

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/services/whatsapp_launcher.dart`
- Test: `test/core/services/whatsapp_launcher_test.dart`

**Interfaces:**
- Produces: `String buildWhatsAppUri(String telefono)` — normaliza el teléfono (quita espacios/guiones) y arma `https://wa.me/<telefono>`; `Future<void> launchWhatsApp(String telefono)` que usa `url_launcher`. Usado por `prepaciente_detail_screen.dart` (Task 14).

- [ ] **Step 1: Agrega la dependencia**

En `pubspec.yaml`, dentro de `dependencies:` (orden alfabético con las demás):

```yaml
  url_launcher: ^6.3.1
```

Run: `flutter pub get`

- [ ] **Step 2: Escribe el test de la función pura de construcción de URI**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:project_mmh/core/services/whatsapp_launcher.dart';

void main() {
  test('buildWhatsAppUri limpia espacios y guiones', () {
    expect(buildWhatsAppUri('55 1234-5678'), 'https://wa.me/5512345678');
  });

  test('buildWhatsAppUri conserva el signo + inicial', () {
    expect(buildWhatsAppUri('+52 55 1234 5678'), 'https://wa.me/+525512345678');
  });
}
```

- [ ] **Step 3: Corre el test y confirma que falla**

Run: `flutter test test/core/services/whatsapp_launcher_test.dart`
Expected: FAIL (no existe el archivo)

- [ ] **Step 4: Implementa el helper**

```dart
import 'package:url_launcher/url_launcher.dart';

/// Construye el enlace `wa.me` a partir de un teléfono capturado libremente
/// (puede traer espacios o guiones); conserva el `+` inicial si existe.
String buildWhatsAppUri(String telefono) {
  final digits = telefono.replaceAll(RegExp(r'[^0-9+]'), '');
  return 'https://wa.me/$digits';
}

Future<void> launchWhatsApp(String telefono) async {
  final uri = Uri.parse(buildWhatsAppUri(telefono));
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```

- [ ] **Step 5: Corre el test y confirma que pasa**

Run: `flutter test test/core/services/whatsapp_launcher_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/services/whatsapp_launcher.dart test/core/services/whatsapp_launcher_test.dart
git commit -m "feat: agrega url_launcher y helper de WhatsApp"
```

---

### Task 8: Widget compartido `NotaItemEditor`

**Files:**
- Create: `lib/features/notas/presentation/widgets/nota_item_editor.dart`

**Interfaces:**
- Consumes: `NotaItem` (Task 2).
- Produces: `NotaItemEditor` — `StatefulWidget` que administra una `List<NotaItem>` mutable en memoria (agregar/editar/eliminar renglón vía `showAppSheet`), con `initialItems`, `showPrecio` (bool, para diferenciar lista de materiales de cotización) y `onChanged(List<NotaItem>)`. Usado por `lista_materiales_create_screen.dart` (Task 15) y `cotizacion_create_screen.dart` (Task 18).

- [ ] **Step 1: Implementa el widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_list_tile.dart';
import 'package:project_mmh/core/presentation/widgets/app_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';

/// Editor de la lista de ítems de una nota `lista_materiales` o `cotizacion`.
/// Mantiene el estado en memoria; el llamador decide cuándo persistir.
class NotaItemEditor extends StatefulWidget {
  const NotaItemEditor({
    super.key,
    this.initialItems = const [],
    this.showPrecio = false,
    required this.onChanged,
  });

  final List<NotaItem> initialItems;
  final bool showPrecio;
  final ValueChanged<List<NotaItem>> onChanged;

  @override
  State<NotaItemEditor> createState() => _NotaItemEditorState();
}

class _NotaItemEditorState extends State<NotaItemEditor> {
  late List<NotaItem> _items = List.of(widget.initialItems);

  void _notify() => widget.onChanged(_items);

  Future<void> _openEditor({NotaItem? existing, int? index}) async {
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
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField.number(
                        name: 'cantidad',
                        label: 'Cantidad *',
                        initialValue: existing?.cantidad.toString(),
                        validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
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
                if (widget.showPrecio) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField.number(
                    name: 'precio_unitario',
                    label: 'Precio unitario',
                    initialValue: existing?.precioUnitario?.toString(),
                  ),
                ],
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
                          precioUnitario: (v['precio_unitario'] as String?)
                                  ?.isNotEmpty ==
                              true
                              ? double.tryParse(v['precio_unitario'] as String)
                              : null,
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

    if (result == null) return;
    setState(() {
      if (index != null) {
        _items[index] = result;
      } else {
        _items.add(result);
      }
    });
    _notify();
  }

  void _removeAt(int index) {
    setState(() => _items.removeAt(index));
    _notify();
  }

  @override
  Widget build(BuildContext context) {
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
            final subtitleParts = [
              '${item.cantidad}${item.unidad != null ? ' ${item.unidad}' : ''}',
              if (widget.showPrecio && item.precioUnitario != null)
                '\$${item.precioUnitario}',
            ];
            return AppListTile(
              title: item.nombre,
              subtitle: subtitleParts.join(' · '),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeAt(i),
              ),
              onTap: () => _openEditor(existing: item, index: i),
            );
          }),
        const SizedBox(height: AppSpacing.sm),
        AppButton.secondary(
          label: 'Agregar ítem',
          icon: Icons.add,
          onPressed: () => _openEditor(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/widgets/nota_item_editor.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/widgets/nota_item_editor.dart
git commit -m "feat: agrega editor de items compartido para notas"
```

---

### Task 9: Listado de notas generales (HU-02)

**Files:**
- Create: `lib/features/notas/presentation/widgets/nota_general_list_view.dart`

**Interfaces:**
- Consumes: `notasPorTipoProvider(NotaTipo.general)` (Task 6).
- Produces: `NotaGeneralListView` — widget con `AppSearchField` (busca en `contenido`), `AppFilterChip` ("Con paciente" / "Todas"), lista de `AppEntityCard` (extracto + fecha), `onTap` navega a `/notas/:id`. Usado por `NotasScreen` (Task 19).

- [ ] **Step 1: Implementa el widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_search_field.dart';
import 'package:project_mmh/core/theme/app_opacity.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/core/presentation/widgets/app_filter_chip.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class NotaGeneralListView extends ConsumerStatefulWidget {
  const NotaGeneralListView({super.key});

  @override
  ConsumerState<NotaGeneralListView> createState() =>
      _NotaGeneralListViewState();
}

class _NotaGeneralListViewState extends ConsumerState<NotaGeneralListView> {
  String _query = '';
  bool _soloConPaciente = false;

  @override
  Widget build(BuildContext context) {
    final notas = ref.watch(notasPorTipoProvider(NotaTipo.general));
    final filtradas = notas.where((n) {
      final matchesQuery =
          _query.isEmpty ||
          (n.contenido ?? '').toLowerCase().contains(_query.toLowerCase());
      final matchesFiltro = !_soloConPaciente || n.idPaciente != null;
      return matchesQuery && matchesFiltro;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: AppSearchField(
            hintText: 'Buscar en notas',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppFilterChip(
              label: 'Con paciente',
              icon: Icons.person,
              isActive: _soloConPaciente,
              onTap: () => setState(() => _soloConPaciente = !_soloConPaciente),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: filtradas.isEmpty
              ? const AppEmptyState(
                  icon: Icons.note_alt_outlined,
                  title: 'No hay notas que coincidan.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final nota = filtradas[index];
                    final extracto = (nota.contenido ?? '').trim();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppEntityCard(
                        title: extracto.isEmpty ? '(Sin contenido)' : extracto,
                        onTap: () => context.push('/notas/${nota.idNota}'),
                        child: Text(
                          DateFormat('d MMM y, HH:mm', 'es_MX')
                              .format(DateTime.parse(nota.fecha)),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: AppOpacity.muted),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/widgets/nota_general_list_view.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/widgets/nota_general_list_view.dart
git commit -m "feat: agrega listado de notas generales con busqueda y filtro"
```

---

### Task 10: Crear nota general (HU-01)

**Files:**
- Create: `lib/features/notas/presentation/screens/nota_create_screen.dart`

**Interfaces:**
- Consumes: `notasProvider.notifier.addNota` (Task 6), `Nota`/`NotaTipo` (Tasks 1, 3).
- Produces: `NotaCreateScreen` — `AppScaffold` con un único `AppTextField.multiline` para `contenido` y botón "Guardar" en `actions`; guarda con `fecha = DateTime.now().toIso8601String()` y hace `context.pop()`. No exige ningún campo (criterio HU-01: "no se exige ningún campo adicional"); si `contenido` viene vacío, igual permite guardar una nota vacía (el usuario decide). Ruta `/notas/nueva` (Task 20).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class NotaCreateScreen extends ConsumerStatefulWidget {
  const NotaCreateScreen({super.key});

  @override
  ConsumerState<NotaCreateScreen> createState() => _NotaCreateScreenState();
}

class _NotaCreateScreenState extends ConsumerState<NotaCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    _formKey.currentState?.save();
    final contenido = _formKey.currentState?.value['contenido'] as String?;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.general,
          contenido: contenido,
          fecha: DateTime.now().toIso8601String(),
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Nueva Nota',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FormBuilder(
          key: _formKey,
          child: AppTextField.multiline(
            name: 'contenido',
            label: 'Escribe tu nota',
            maxLines: 12,
            minLines: 6,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/nota_create_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/nota_create_screen.dart
git commit -m "feat: agrega pantalla de creacion de nota rapida"
```

---

### Task 11: Editar y eliminar nota general (HU-03)

**Files:**
- Create: `lib/features/notas/presentation/screens/nota_detail_screen.dart`

**Interfaces:**
- Consumes: `notaByIdProvider` (Task 6), `notasProvider.notifier.updateNota/deleteNota`, `showAppConfirm` (`lib/core/presentation/widgets/app_confirm.dart`).
- Produces: `NotaDetailScreen({required int notaId})` — carga la nota, permite editar `contenido` in-place y guardar, y un botón de eliminar (icono en `actions`) que pide confirmación (`showAppConfirm(destructive: true)`) antes de borrar y regresar. Ruta `/notas/:id` (Task 20).

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
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class NotaDetailScreen extends ConsumerStatefulWidget {
  const NotaDetailScreen({super.key, required this.notaId});

  final int notaId;

  @override
  ConsumerState<NotaDetailScreen> createState() => _NotaDetailScreenState();
}

class _NotaDetailScreenState extends ConsumerState<NotaDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    final nota = ref.read(notaByIdProvider(widget.notaId)).asData?.value;
    if (nota == null) return;

    setState(() => _isSaving = true);
    try {
      final contenido = _formKey.currentState?.value['contenido'] as String?;
      await ref
          .read(notasProvider.notifier)
          .updateNota(nota.copyWith(contenido: contenido));
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showAppConfirm(
      context,
      title: 'Eliminar nota',
      message: 'Esta acción no se puede deshacer.',
      destructive: true,
      confirmLabel: 'Eliminar',
    );
    if (!confirmed) return;
    await ref.read(notasProvider.notifier).deleteNota(widget.notaId);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final notaAsync = ref.watch(notaByIdProvider(widget.notaId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Nota',
            body: Center(child: Text('Nota no encontrada.')),
          );
        }
        return AppScaffold(
          title: 'Nota',
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
              child: AppTextField.multiline(
                name: 'contenido',
                label: 'Contenido',
                initialValue: nota.contenido,
                maxLines: 12,
                minLines: 6,
              ),
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Nota',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => AppScaffold(
        title: 'Nota',
        body: AppErrorView(
          message: 'No se pudo cargar la nota.',
          onRetry: () => ref.invalidate(notaByIdProvider(widget.notaId)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/nota_detail_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/nota_detail_screen.dart
git commit -m "feat: agrega edicion y eliminacion de nota general"
```

---

### Task 12: Registrar prepaciente (HU-04)

**Files:**
- Create: `lib/features/notas/presentation/screens/prepaciente_create_screen.dart`

**Interfaces:**
- Consumes: `notasProvider.notifier.addNota` (Task 6).
- Produces: `PrepacienteCreateScreen` — formulario con `nombre_contacto` (requerido), `telefono` (opcional), `tratamiento_probable` (opcional), `contenido` (multiline, opcional). Guarda `Nota(tipo: NotaTipo.prepaciente, ...)`. No toca la tabla `pacientes` ni `odontogramas` (criterio de aceptación explícito). Ruta `/notas/prepacientes/nuevo` (Task 20).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteCreateScreen extends ConsumerStatefulWidget {
  const PrepacienteCreateScreen({super.key});

  @override
  ConsumerState<PrepacienteCreateScreen> createState() =>
      _PrepacienteCreateScreenState();
}

class _PrepacienteCreateScreenState
    extends ConsumerState<PrepacienteCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.prepaciente,
          fecha: DateTime.now().toIso8601String(),
          nombreContacto: v['nombre_contacto'] as String,
          telefono: (v['telefono'] as String?)?.isEmpty ?? true
              ? null
              : v['telefono'] as String,
          tratamientoProbable: (v['tratamiento_probable'] as String?)?.isEmpty ?? true
              ? null
              : v['tratamiento_probable'] as String,
          contenido: (v['contenido'] as String?)?.isEmpty ?? true
              ? null
              : v['contenido'] as String,
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Nuevo Prepaciente',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
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
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.phone(name: 'telefono', label: 'Teléfono', maxLength: 10),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.singleLine(
                name: 'tratamiento_probable',
                label: 'Tratamiento probable',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField.multiline(
                name: 'contenido',
                label: 'Observaciones',
                maxLines: 5,
                minLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/prepaciente_create_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/prepaciente_create_screen.dart
git commit -m "feat: agrega registro de prepacientes"
```

---

### Task 13: Listar prepacientes (HU-05)

**Files:**
- Create: `lib/features/notas/presentation/widgets/prepaciente_list_view.dart`

**Interfaces:**
- Consumes: `notasPorTipoProvider(NotaTipo.prepaciente)` (Task 6).
- Produces: `PrepacienteListView` — lista de `AppEntityCard` con nombre, teléfono y tratamiento probable (si existe); `onTap` navega a `/notas/prepacientes/:id`. Usado por `NotasScreen` (Task 19).

- [ ] **Step 1: Implementa el widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteListView extends ConsumerWidget {
  const PrepacienteListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prepacientes = ref.watch(notasPorTipoProvider(NotaTipo.prepaciente));

    if (prepacientes.isEmpty) {
      return const AppEmptyState(
        icon: Icons.person_search_outlined,
        title: 'No hay prepacientes registrados.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: prepacientes.length,
      itemBuilder: (context, index) {
        final p = prepacientes[index];
        final partes = [
          if (p.telefono != null) p.telefono!,
          if (p.tratamientoProbable != null) p.tratamientoProbable!,
        ];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppEntityCard(
            title: p.nombreContacto ?? '(Sin nombre)',
            onTap: () => context.push('/notas/prepacientes/${p.idNota}'),
            child: Text(partes.isEmpty ? 'Sin datos adicionales' : partes.join(' · ')),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/widgets/prepaciente_list_view.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/widgets/prepaciente_list_view.dart
git commit -m "feat: agrega listado de prepacientes"
```

---

### Task 14: Detalle de prepaciente con WhatsApp (HU-06)

**Files:**
- Create: `lib/features/notas/presentation/screens/prepaciente_detail_screen.dart`

**Interfaces:**
- Consumes: `notaByIdProvider` (Task 6), `launchWhatsApp` (Task 7).
- Produces: `PrepacienteDetailScreen({required int notaId})` — muestra datos del prepaciente; si `telefono != null` muestra `AppButton.primary` con ícono de WhatsApp que llama `launchWhatsApp(nota.telefono!)`; si es `null`, el botón no se renderiza. Ruta `/notas/prepacientes/:id` (Task 20).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/services/whatsapp_launcher.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class PrepacienteDetailScreen extends ConsumerWidget {
  const PrepacienteDetailScreen({super.key, required this.notaId});

  final int notaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notaAsync = ref.watch(notaByIdProvider(notaId));

    return notaAsync.when(
      data: (nota) {
        if (nota == null) {
          return const AppScaffold(
            title: 'Prepaciente',
            body: Center(child: Text('Prepaciente no encontrado.')),
          );
        }
        return AppScaffold(
          title: nota.nombreContacto ?? 'Prepaciente',
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (nota.telefono != null)
                        Text('Teléfono: ${nota.telefono}'),
                      if (nota.tratamientoProbable != null)
                        Text('Tratamiento probable: ${nota.tratamientoProbable}'),
                      if (nota.contenido != null && nota.contenido!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(nota.contenido!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (nota.telefono != null)
                  AppButton.primary(
                    label: 'Contactar por WhatsApp',
                    icon: Icons.chat,
                    onPressed: () => launchWhatsApp(nota.telefono!),
                  ),
              ],
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
          onRetry: () => ref.invalidate(notaByIdProvider(notaId)),
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
git commit -m "feat: agrega detalle de prepaciente con contacto por whatsapp"
```

---

### Task 15: Crear lista de materiales manual (HU-07)

**Files:**
- Create: `lib/features/notas/presentation/screens/lista_materiales_create_screen.dart`

**Interfaces:**
- Consumes: `notasProvider.notifier.addNota` (Task 6), `NotaItemEditor` (Task 8), `clinicasProvider`/`showAppSelectionSheet` (para elegir clínica opcional, mismo patrón que otras pantallas de la app).
- Produces: `ListaMaterialesCreateScreen` — campo `contenido` (nombre/descripción de la lista, requerido para poder mostrarla en el listado), selector opcional de clínica, `NotaItemEditor(showPrecio: false)`. Guarda `Nota(tipo: NotaTipo.listaMateriales, origen: NotaOrigen.manual, ...)`. Ruta `/notas/materiales/nueva` (Task 20).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_selection_sheet.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/clinicas_metas/domain/clinica.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/nota_item_editor.dart';

class ListaMaterialesCreateScreen extends ConsumerStatefulWidget {
  const ListaMaterialesCreateScreen({super.key});

  @override
  ConsumerState<ListaMaterialesCreateScreen> createState() =>
      _ListaMaterialesCreateScreenState();
}

class _ListaMaterialesCreateScreenState
    extends ConsumerState<ListaMaterialesCreateScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<NotaItem> _items = [];
  Clinica? _clinica;
  bool _isSaving = false;

  Future<void> _pickClinica(List<Clinica> clinicas) async {
    final selected = await showAppSelectionSheet<Clinica>(
      context,
      title: 'Clínica',
      options: clinicas,
      labelOf: (c) => c.nombreClinica,
      selected: _clinica,
    );
    if (selected != null) setState(() => _clinica = selected);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;

    setState(() => _isSaving = true);
    try {
      await ref.read(notasProvider.notifier).addNota(
        Nota(
          tipo: NotaTipo.listaMateriales,
          fecha: DateTime.now().toIso8601String(),
          contenido: v['contenido'] as String,
          idClinica: _clinica?.idClinica,
          items: _items,
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clinicasAsync = ref.watch(periodosProvider.notifier).ref.watch(
      clinicasByPeriodoProvider,
    ); // placeholder overridden below

    return AppScaffold(
      title: 'Nueva Lista de Materiales',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField.singleLine(
                name: 'contenido',
                label: 'Nombre de la lista *',
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: _clinica?.nombreClinica ?? 'Asociar clínica (opcional)',
                onPressed: () {}, // se completa en el paso 2
              ),
              const AppSectionHeader('Ítems'),
              NotaItemEditor(onChanged: (items) => _items = items),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Corrige el selector de clínica**

El `Provider` correcto para listar todas las clínicas (sin filtrar por período) no existe todavía en `clinicas_providers.dart`; reutiliza el período activo en su lugar, que sí está disponible. Reemplaza el `build` completo por esta versión (elimina el placeholder del Step 1):

```dart
  @override
  Widget build(BuildContext context) {
    final periodId = ref.watch(lastViewedPeriodIdProvider);
    final clinicasAsync = periodId == null
        ? const AsyncValue<List<Clinica>>.data([])
        : ref.watch(clinicasByPeriodoProvider(periodId));

    return AppScaffold(
      title: 'Nueva Lista de Materiales',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField.singleLine(
                name: 'contenido',
                label: 'Nombre de la lista *',
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              clinicasAsync.when(
                data: (clinicas) => AppButton.secondary(
                  label: _clinica?.nombreClinica ?? 'Asociar clínica (opcional)',
                  onPressed: clinicas.isEmpty ? null : () => _pickClinica(clinicas),
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const AppSectionHeader('Ítems'),
              NotaItemEditor(onChanged: (items) => _items = items),
            ],
          ),
        ),
      ),
    );
  }
```

Y agrega el import que falta: `import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';` (donde vive `lastViewedPeriodIdProvider`; verifícalo con `grep -rn "lastViewedPeriodIdProvider" lib/` si el import difiere).

- [ ] **Step 3: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/lista_materiales_create_screen.dart`
Expected: sin errores.

- [ ] **Step 4: Commit**

```bash
git add lib/features/notas/presentation/screens/lista_materiales_create_screen.dart
git commit -m "feat: agrega creacion manual de listas de materiales"
```

---

### Task 16: Listar y filtrar listas de materiales (HU-13)

**Files:**
- Create: `lib/features/notas/presentation/widgets/lista_materiales_list_view.dart`

**Interfaces:**
- Consumes: `notasPorTipoProvider(NotaTipo.listaMateriales)`, `cotizacionesDeListaProvider` (Task 6).
- Produces: `ListaMaterialesListView` — filtro por clínica (`AppFilterChip` por cada clínica del período activo, más "Todas"), cada fila (`AppEntityCard`) muestra nombre/fecha y cuántas cotizaciones tiene (`cotizacionesDeListaProvider(nota.idNota!).length`). `onTap` navega a `/notas/materiales/:id`. Usado por `NotasScreen` (Task 19).

- [ ] **Step 1: Implementa el widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_entity_card.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/clinicas_metas/presentation/providers/clinicas_providers.dart';
import 'package:project_mmh/features/core/presentation/providers/preferences_provider.dart';
import 'package:project_mmh/features/core/presentation/widgets/app_filter_chip.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class ListaMaterialesListView extends ConsumerStatefulWidget {
  const ListaMaterialesListView({super.key});

  @override
  ConsumerState<ListaMaterialesListView> createState() =>
      _ListaMaterialesListViewState();
}

class _ListaMaterialesListViewState
    extends ConsumerState<ListaMaterialesListView> {
  int? _clinicaFiltro;

  @override
  Widget build(BuildContext context) {
    final listas = ref.watch(notasPorTipoProvider(NotaTipo.listaMateriales));
    final periodId = ref.watch(lastViewedPeriodIdProvider);
    final clinicasAsync = periodId == null
        ? null
        : ref.watch(clinicasByPeriodoProvider(periodId));

    final filtradas = _clinicaFiltro == null
        ? listas
        : listas.where((n) => n.idClinica == _clinicaFiltro).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (clinicasAsync != null)
          clinicasAsync.when(
            data: (clinicas) => clinicas.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(
                            label: 'Todas',
                            icon: Icons.apps,
                            isActive: _clinicaFiltro == null,
                            onTap: () => setState(() => _clinicaFiltro = null),
                          ),
                        ),
                        ...clinicas.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: AppFilterChip(
                              label: c.nombreClinica,
                              icon: Icons.local_hospital,
                              isActive: _clinicaFiltro == c.idClinica,
                              onTap: () =>
                                  setState(() => _clinicaFiltro = c.idClinica),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: filtradas.isEmpty
              ? const AppEmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'No hay listas de materiales.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: filtradas.length,
                  itemBuilder: (context, index) {
                    final lista = filtradas[index];
                    final cotizaciones =
                        ref.watch(cotizacionesDeListaProvider(lista.idNota!));
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppEntityCard(
                        title: lista.contenido ?? '(Sin nombre)',
                        onTap: () =>
                            context.push('/notas/materiales/${lista.idNota}'),
                        child: Text(
                          '${cotizaciones.length} cotización(es)',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/widgets/lista_materiales_list_view.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/widgets/lista_materiales_list_view.dart
git commit -m "feat: agrega listado y filtro por clinica de listas de materiales"
```

---

### Task 17: Detalle de lista de materiales + comparación de cotizaciones (HU-12)

**Files:**
- Create: `lib/features/notas/presentation/screens/lista_materiales_detail_screen.dart`

**Interfaces:**
- Consumes: `notaByIdProvider`, `cotizacionesDeListaProvider` (Task 6).
- Produces: `ListaMaterialesDetailScreen({required int listaId})` — muestra los ítems de la lista, botón "Agregar cotización" (navega a `/notas/materiales/:id/cotizacion-nueva`, Task 18), y debajo una fila horizontal de tarjetas (una por cotización) con proveedor, sus ítems y el total (`nota.totalCotizacion`); sin cruce automático de ítems entre cotizaciones (criterio HU-12). Ruta `/notas/materiales/:id` (Task 20).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_card.dart';
import 'package:project_mmh/core/presentation/widgets/app_empty_state.dart';
import 'package:project_mmh/core/presentation/widgets/app_error_view.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';

class ListaMaterialesDetailScreen extends ConsumerWidget {
  const ListaMaterialesDetailScreen({super.key, required this.listaId});

  final int listaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaAsync = ref.watch(notaByIdProvider(listaId));

    return listaAsync.when(
      data: (lista) {
        if (lista == null) {
          return const AppScaffold(
            title: 'Lista de materiales',
            body: Center(child: Text('Lista no encontrada.')),
          );
        }
        final cotizaciones = ref.watch(cotizacionesDeListaProvider(listaId));

        return AppScaffold(
          title: lista.contenido ?? 'Lista de materiales',
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader('Ítems'),
                    if (lista.items.isEmpty)
                      const AppEmptyState(
                        icon: Icons.checklist_rtl,
                        title: 'Sin ítems.',
                      )
                    else
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: lista.items
                              .map((i) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xs,
                                    ),
                                    child: Text(
                                      '${i.nombre} — ${i.cantidad}${i.unidad != null ? ' ${i.unidad}' : ''}',
                                    ),
                                  ))
                              .toList(),
                        ),
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
                            '/notas/materiales/$listaId/cotizacion-nueva',
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: cotizaciones.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final c = cotizaciones[index];
                      return SizedBox(
                        width: 220,
                        child: AppCard(
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
                                      .map((i) => Text(
                                            '${i.nombre} x${i.cantidad}${i.precioUnitario != null ? ' — \$${i.precioUnitario}' : ''}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ))
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
          onRetry: () => ref.invalidate(notaByIdProvider(listaId)),
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
git commit -m "feat: agrega detalle de lista de materiales con comparacion de cotizaciones"
```

---

### Task 18: Registrar cotización manual (HU-11)

**Files:**
- Create: `lib/features/notas/presentation/screens/cotizacion_create_screen.dart`

**Interfaces:**
- Consumes: `notasProvider.notifier.addNota` (Task 6), `NotaItemEditor(showPrecio: true)` (Task 8).
- Produces: `CotizacionCreateScreen({required int listaId})` — campo `proveedor` (requerido) + editor de ítems con precio. Guarda `Nota(tipo: NotaTipo.cotizacion, idNotaRelacionada: listaId, origen: NotaOrigen.manual, ...)`. Ruta `/notas/materiales/:id/cotizacion-nueva` (Task 20).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_button.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/core/presentation/widgets/app_section_header.dart';
import 'package:project_mmh/core/presentation/widgets/app_text_field.dart';
import 'package:project_mmh/core/theme/app_spacing.dart';
import 'package:project_mmh/features/notas/domain/nota.dart';
import 'package:project_mmh/features/notas/domain/nota_item.dart';
import 'package:project_mmh/features/notas/domain/nota_tipo.dart';
import 'package:project_mmh/features/notas/presentation/providers/notas_providers.dart';
import 'package:project_mmh/features/notas/presentation/widgets/nota_item_editor.dart';

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
  List<NotaItem> _items = [];
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
          items: _items,
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Nueva Cotización',
      actions: [
        AppButton.text(label: 'Guardar', loading: _isSaving, onPressed: _save),
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
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const AppSectionHeader('Ítems'),
              NotaItemEditor(
                showPrecio: true,
                onChanged: (items) => _items = items,
              ),
            ],
          ),
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
git commit -m "feat: agrega registro manual de cotizaciones"
```

---

### Task 19: Hub `NotasScreen` (TabBar)

**Files:**
- Create: `lib/features/notas/presentation/screens/notas_screen.dart`

**Interfaces:**
- Consumes: `NotaGeneralListView` (Task 9), `PrepacienteListView` (Task 13), `ListaMaterialesListView` (Task 16).
- Produces: `NotasScreen` — `AppScaffold` con `TabBar` (Generales / Prepacientes / Materiales) y un `FloatingActionButton` cuyo destino cambia según la pestaña activa (`/notas/nueva`, `/notas/prepacientes/nuevo`, `/notas/materiales/nueva`). Ruta `/notas` (Task 20).

- [ ] **Step 1: Implementa la pantalla**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/features/notas/presentation/widgets/lista_materiales_list_view.dart';
import 'package:project_mmh/features/notas/presentation/widgets/nota_general_list_view.dart';
import 'package:project_mmh/features/notas/presentation/widgets/prepaciente_list_view.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  static const _createRoutes = [
    '/notas/nueva',
    '/notas/prepacientes/nuevo',
    '/notas/materiales/nueva',
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Notas',
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(_createRoutes[_tabController.index]),
        child: const Icon(Icons.add),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            tabs: const [
              Tab(text: 'Generales'),
              Tab(text: 'Prepacientes'),
              Tab(text: 'Materiales'),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: true,
          child: TabBarView(
            controller: _tabController,
            children: const [
              NotaGeneralListView(),
              PrepacienteListView(),
              ListaMaterialesListView(),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/notas/presentation/screens/notas_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/notas/presentation/screens/notas_screen.dart
git commit -m "feat: agrega hub de notas con pestañas"
```

---

### Task 20: Registrar rutas de Notas

**Files:**
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: todas las pantallas de las Tasks 10, 11, 12, 14, 15, 17, 18, 19.
- Produces: rutas raíz (sin navbar, mismo bloque que `/patient-create` y `/diagnosis`): `/notas`, `/notas/nueva`, `/notas/:id`, `/notas/prepacientes/nuevo`, `/notas/prepacientes/:id`, `/notas/materiales/nueva`, `/notas/materiales/:id`, `/notas/materiales/:id/cotizacion-nueva`.

- [ ] **Step 1: Agrega los imports** (junto a los demás imports de pantallas)

```dart
import 'package:project_mmh/features/notas/presentation/screens/notas_screen.dart';
import 'package:project_mmh/features/notas/presentation/screens/nota_create_screen.dart';
import 'package:project_mmh/features/notas/presentation/screens/nota_detail_screen.dart';
import 'package:project_mmh/features/notas/presentation/screens/prepaciente_create_screen.dart';
import 'package:project_mmh/features/notas/presentation/screens/prepaciente_detail_screen.dart';
import 'package:project_mmh/features/notas/presentation/screens/lista_materiales_create_screen.dart';
import 'package:project_mmh/features/notas/presentation/screens/lista_materiales_detail_screen.dart';
import 'package:project_mmh/features/notas/presentation/screens/cotizacion_create_screen.dart';
```

- [ ] **Step 2: Agrega las rutas** (dentro de la lista `routes:` del `GoRouter`, junto a `/patient-create` y `/diagnosis`, antes del bloque `if (kDebugMode)`)

```dart
    GoRoute(
      path: '/notas',
      builder: (context, state) => const NotasScreen(),
    ),
    GoRoute(
      path: '/notas/nueva',
      builder: (context, state) => const NotaCreateScreen(),
    ),
    GoRoute(
      path: '/notas/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const _RouteErrorScreen(message: 'Nota no válida');
        }
        return NotaDetailScreen(notaId: id);
      },
    ),
    GoRoute(
      path: '/notas/prepacientes/nuevo',
      builder: (context, state) => const PrepacienteCreateScreen(),
    ),
    GoRoute(
      path: '/notas/prepacientes/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const _RouteErrorScreen(message: 'Prepaciente no válido');
        }
        return PrepacienteDetailScreen(notaId: id);
      },
    ),
    GoRoute(
      path: '/notas/materiales/nueva',
      builder: (context, state) => const ListaMaterialesCreateScreen(),
    ),
    GoRoute(
      path: '/notas/materiales/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const _RouteErrorScreen(message: 'Lista no válida');
        }
        return ListaMaterialesDetailScreen(listaId: id);
      },
      routes: [
        GoRoute(
          path: 'cotizacion-nueva',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const _RouteErrorScreen(message: 'Lista no válida');
            }
            return CotizacionCreateScreen(listaId: id);
          },
        ),
      ],
    ),
```

Nota: la ruta `/notas/:id` con un solo parámetro colisionaría por prefijo con `/notas/prepacientes/...` y `/notas/materiales/...` si `go_router` no diera prioridad a los segmentos literales sobre los parámetros — `go_router` sí la da (coincidencia por segmentos, no por regex greedy), así que el orden dentro de la lista no importa, pero esta plantilla las declara ambas para que quede explícito.

- [ ] **Step 3: Verifica que compila y que las rutas no colisionan**

Run: `flutter analyze lib/core/router/app_router.dart`
Expected: sin errores.

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat: registra rutas del modulo de notas"
```

---

### Task 21: Accesos directos desde el Dashboard (HU-01)

**Files:**
- Modify: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Interfaces:**
- Consumes: nada nuevo (usa `context.push`, ya importado).
- Produces: dos `_ActionTile` adicionales en la sección "Accesos Directos": "Nota Rápida" (`push('/notas/nueva')`) y "Notas y Listas" (`push('/notas')`).

- [ ] **Step 1: Agrega las tiles** (después del `_ActionTile` de "Diagnóstico Pulpar", antes del `SizedBox` final de padding)

```dart
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: CupertinoIcons.pencil_outline,
                      label: 'Nota Rápida',
                      subtitle: 'Capturar una nota en segundos',
                      onPressed: () {
                        context.push('/notas/nueva');
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: CupertinoIcons.folder,
                      label: 'Notas y Listas',
                      subtitle: 'Prepacientes, materiales y cotizaciones',
                      onPressed: () {
                        context.push('/notas');
                      },
                    ),
```

- [ ] **Step 2: Verifica que compila**

Run: `flutter analyze lib/features/dashboard/presentation/screens/dashboard_screen.dart`
Expected: sin errores.

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboard/presentation/screens/dashboard_screen.dart
git commit -m "feat: agrega accesos directos de notas al dashboard"
```

---

### Task 22: Verificación integral

**Files:** ninguno (solo comandos).

- [ ] **Step 1: Corre el análisis estático completo**

Run: `flutter analyze`
Expected: sin errores (warnings preexistentes fuera de `lib/features/notas` no son responsabilidad de este plan).

- [ ] **Step 2: Corre toda la suite de tests**

Run: `flutter test`
Expected: todos los tests pasan, incluidos los nuevos de `test/features/notas/` y `test/core/services/`.

- [ ] **Step 3: Formatea solo los archivos nuevos/modificados**

Run: `dart format lib/features/notas lib/core/database/database_helper.dart lib/core/router/app_router.dart lib/core/services/whatsapp_launcher.dart lib/features/dashboard/presentation/screens/dashboard_screen.dart pubspec.yaml`
Expected: sin cambios inesperados fuera de estilo (revisa el diff antes de commitear si `dart format` toca algo).

- [ ] **Step 4: QA manual en el emulador/dispositivo**

Arranca la app (`flutter run`) y verifica manualmente cada criterio de aceptación de HU-01 a HU-07 y HU-11 a HU-13: crear/editar/eliminar nota general, registrar prepaciente y abrir WhatsApp (o confirmar que el botón no aparece sin teléfono), crear lista de materiales con ítems, registrar dos cotizaciones para la misma lista y verificar que se muestran lado a lado con sus totales, y que el filtro por clínica y el buscador de notas generales funcionan. Presta atención especial a que instalar sobre una BD existente (v3) dispare la migración a v4 sin perder datos.

- [ ] **Step 5: Commit final si el formateo tocó algo**

```bash
git add -A
git commit -m "chore: formatea archivos del modulo de notas"
```

(Omite este paso si `dart format` no modificó nada.)

---

## Self-Review

- **Cobertura del spec:** HU-01→Task 10, HU-02→Task 9, HU-03→Task 11, HU-04→Task 12, HU-05→Task 13, HU-06→Task 14, HU-07→Task 15, HU-11 (manual)→Tasks 17-18, HU-12→Task 17, HU-13→Task 16. HU-10 y la variante imagen/PDF de HU-11 quedan fuera de alcance (ver Global Constraints) — requieren un plan aparte.
- **Placeholders:** ninguno; cada paso trae código completo. La única nota de "reemplaza el placeholder" (Task 15, Step 2) es intencional: TDD-style, se corrige un provider inexistente detectado durante el diseño del plan, dejando explícito el motivo y el código final completo.
- **Consistencia de tipos:** `Nota`, `NotaItem`, `NotaTipo`, `NotaOrigen` se usan con los mismos nombres de campo (`idNota`, `idNotaRelacionada`, `totalCotizacion`, etc.) en todas las tareas 5-21. `notasProvider.notifier.addNota/updateNota/deleteNota` y `notaByIdProvider`/`notasPorTipoProvider`/`cotizacionesDeListaProvider` se consumen igual en todas las pantallas.
