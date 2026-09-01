import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static const int _databaseVersion = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'odontologia_student.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // Downgrade no destructivo: NUNCA borrar la BD (app offline-first sin
      // respaldo). El esquema v3 es un superconjunto compatible con el código
      // anterior, así que basta con dejar bajar el número de versión.
      onDowngrade: (db, oldVersion, newVersion) async {
        debugPrint(
          'BD: downgrade $oldVersion → $newVersion; se conservan los datos.',
        );
      },
      // Las FKs se habilitan en onOpen (después de onCreate/onUpgrade) para que
      // las migraciones que reconstruyen tablas no disparen ON DELETE CASCADE.
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Handle migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // V2: Soft delete de pacientes.
      await db.execute('ALTER TABLE pacientes ADD COLUMN deleted_at TEXT');
      debugPrint("Migración V2: columna 'deleted_at' agregada a 'pacientes'.");
    }

    if (oldVersion < 3) {
      await _migrateToV3(db);
      debugPrint('Migración V3: unicidad de clínica por periodo, índices y '
          'unicidad de odontograma por paciente.');
    }

    if (oldVersion < 4) {
      await _migrateToV4(db);
      debugPrint("Migración V4: tabla 'notas' agregada.");
    }
  }

  /// V3: `clinicas.nombre_clinica` deja de ser único global y pasa a ser único
  /// por periodo; `odontogramas` pasa a ser único por paciente; se agregan
  /// índices sobre las FKs más consultadas.
  Future<void> _migrateToV3(Database db) async {
    // onUpgrade ya se ejecuta dentro de una transacción y con las FKs
    // deshabilitadas (se habilitan en onOpen), por lo que reconstruir
    // `clinicas` no dispara los ON DELETE CASCADE de tratamientos/objetivos.

    // --- clinicas: UNIQUE(id_periodo, nombre_clinica) ---
    await db.execute('''
      CREATE TABLE clinicas_new (
        id_clinica INTEGER PRIMARY KEY AUTOINCREMENT,
        id_periodo INTEGER NOT NULL,
        nombre_clinica TEXT NOT NULL CHECK(LENGTH(nombre_clinica) > 0),
        color TEXT NOT NULL,
        horarios TEXT,
        FOREIGN KEY (id_periodo) REFERENCES periodos (id_periodo) ON DELETE CASCADE,
        UNIQUE (id_periodo, nombre_clinica)
      )
    ''');
    await db.execute('''
      INSERT INTO clinicas_new (id_clinica, id_periodo, nombre_clinica, color, horarios)
      SELECT id_clinica, id_periodo, nombre_clinica, color, horarios FROM clinicas
    ''');
    await db.execute('DROP TABLE clinicas');
    await db.execute('ALTER TABLE clinicas_new RENAME TO clinicas');

    // --- odontogramas: UNIQUE(id_expediente), de-duplicando filas ---
    // (FKs deshabilitadas durante la migración, así que el DELETE no cascadea:
    // hay que limpiar a mano las piezas huérfanas.)
    await db.execute('''
      DELETE FROM odontogramas
      WHERE id_odontograma NOT IN (
        SELECT MIN(id_odontograma) FROM odontogramas GROUP BY id_expediente
      )
    ''');
    await db.execute('''
      DELETE FROM piezas_dentales
      WHERE id_odontograma NOT IN (SELECT id_odontograma FROM odontogramas)
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_odontogramas_expediente
      ON odontogramas (id_expediente)
    ''');

    // --- índices sobre FKs consultadas por rango/lookup ---
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tratamientos_expediente ON tratamientos (id_expediente)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tratamientos_clinica ON tratamientos (id_clinica)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sesiones_tratamiento ON sesiones (id_tratamiento)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_piezas_odontograma ON piezas_dentales (id_odontograma)');
  }

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

  Future<void> _onCreate(Database db, int version) async {
    // 1. Estructura Académica
    await db.execute('''
      CREATE TABLE periodos (
        id_periodo INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_periodo TEXT NOT NULL CHECK(LENGTH(nombre_periodo) > 0)
      )
    ''');

    await db.execute('''
      CREATE TABLE clinicas (
        id_clinica INTEGER PRIMARY KEY AUTOINCREMENT,
        id_periodo INTEGER NOT NULL,
        nombre_clinica TEXT NOT NULL CHECK(LENGTH(nombre_clinica) > 0),
        color TEXT NOT NULL,
        horarios TEXT,
        FOREIGN KEY (id_periodo) REFERENCES periodos (id_periodo) ON DELETE CASCADE,
        UNIQUE (id_periodo, nombre_clinica)
      )
    ''');

    await db.execute('''
      CREATE TABLE objetivos (
        id_objetivo INTEGER PRIMARY KEY AUTOINCREMENT,
        id_clinica INTEGER NOT NULL,
        nombre_tratamiento TEXT NOT NULL,
        cantidad_meta INTEGER NOT NULL CHECK(cantidad_meta > 0),
        cantidad_actual INTEGER NOT NULL DEFAULT 0 CHECK(cantidad_actual >= 0),
        FOREIGN KEY (id_clinica) REFERENCES clinicas (id_clinica) ON DELETE CASCADE
      )
    ''');

    // 2. Gestión de Pacientes y Odontograma
    await db.execute('''
      CREATE TABLE pacientes (
        id_expediente TEXT PRIMARY KEY,
        nombre TEXT NOT NULL CHECK(LENGTH(nombre) > 0),
        primer_apellido TEXT NOT NULL CHECK(LENGTH(primer_apellido) > 0),
        segundo_apellido TEXT,
        edad INTEGER NOT NULL CHECK(edad >= 0 AND edad <= 120),
        sexo TEXT NOT NULL,
        telefono TEXT,
        padecimiento_relevante TEXT,
        informacion_adicional TEXT,
        imagenes_paths TEXT,
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE odontogramas (
        id_odontograma INTEGER PRIMARY KEY AUTOINCREMENT,
        id_expediente TEXT NOT NULL,
        FOREIGN KEY (id_expediente) REFERENCES pacientes (id_expediente) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX idx_odontogramas_expediente
      ON odontogramas (id_expediente)
    ''');

    await db.execute('''
      CREATE TABLE piezas_dentales (
        id_pieza TEXT PRIMARY KEY,
        id_odontograma INTEGER NOT NULL,
        numero_pieza INTEGER NOT NULL CHECK(numero_pieza > 0),
        tipo_diente TEXT,
        estado_general TEXT,
        id_grupo_puente TEXT,
        superficies TEXT,
        tiene_sellador INTEGER DEFAULT 0 CHECK(tiene_sellador IN (0, 1)),
        FOREIGN KEY (id_odontograma) REFERENCES odontogramas (id_odontograma) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_piezas_odontograma ON piezas_dentales (id_odontograma)');

    // 3. Agenda y Ejecución
    await db.execute('''
      CREATE TABLE tratamientos (
        id_tratamiento INTEGER PRIMARY KEY AUTOINCREMENT,
        id_clinica INTEGER NOT NULL,
        id_expediente TEXT NOT NULL,
        id_objetivo INTEGER,
        nombre_tratamiento TEXT NOT NULL CHECK(LENGTH(nombre_tratamiento) > 0),
        fecha_creacion TEXT NOT NULL,
        estado TEXT NOT NULL,
        FOREIGN KEY (id_clinica) REFERENCES clinicas (id_clinica) ON DELETE CASCADE,
        FOREIGN KEY (id_expediente) REFERENCES pacientes (id_expediente) ON DELETE CASCADE,
        FOREIGN KEY (id_objetivo) REFERENCES objetivos (id_objetivo) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_tratamientos_expediente ON tratamientos (id_expediente)');
    await db.execute(
        'CREATE INDEX idx_tratamientos_clinica ON tratamientos (id_clinica)');

    await db.execute('''
      CREATE TABLE sesiones (
        id_sesion INTEGER PRIMARY KEY AUTOINCREMENT,
        id_tratamiento INTEGER NOT NULL,
        fecha_inicio TEXT NOT NULL,
        fecha_fin TEXT NOT NULL,
        estado_asistencia TEXT,
        FOREIGN KEY (id_tratamiento) REFERENCES tratamientos (id_tratamiento) ON DELETE CASCADE
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_sesiones_tratamiento ON sesiones (id_tratamiento)');

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
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(table, orderBy: orderBy);
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }
}
