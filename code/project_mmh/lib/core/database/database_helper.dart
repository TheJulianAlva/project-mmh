import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'odontologia_student.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Estructura Académica
    await db.execute('''
      CREATE TABLE periodos (
        id_periodo INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_periodo TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE clinicas (
        id_clinica INTEGER PRIMARY KEY AUTOINCREMENT,
        id_periodo INTEGER NOT NULL,
        nombre_clinica TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        horarios TEXT,
        FOREIGN KEY (id_periodo) REFERENCES periodos (id_periodo) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE objetivos (
        id_objetivo INTEGER PRIMARY KEY AUTOINCREMENT,
        id_clinica INTEGER NOT NULL,
        nombre_tratamiento TEXT NOT NULL,
        cantidad_meta INTEGER NOT NULL,
        cantidad_actual INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (id_clinica) REFERENCES clinicas (id_clinica) ON DELETE CASCADE
      )
    ''');

    // 2. Gestión de Pacientes y Odontograma
    await db.execute('''
      CREATE TABLE pacientes (
        id_expediente TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        primer_apellido TEXT NOT NULL,
        segundo_apellido TEXT,
        edad INTEGER NOT NULL,
        sexo TEXT NOT NULL,
        telefono TEXT,
        padecimiento_relevante TEXT,
        informacion_adicional TEXT,
        imagenes_paths TEXT
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
      CREATE TABLE piezas_dentales (
        id_pieza TEXT PRIMARY KEY,
        id_odontograma INTEGER NOT NULL,
        numero_pieza INTEGER NOT NULL,
        tipo_diente TEXT,
        estado_general TEXT,
        id_grupo_puente TEXT,
        superficies TEXT,
        tiene_sellador INTEGER DEFAULT 0,
        FOREIGN KEY (id_odontograma) REFERENCES odontogramas (id_odontograma) ON DELETE CASCADE
      )
    ''');

    // 3. Agenda y Ejecución
    await db.execute('''
      CREATE TABLE tratamientos (
        id_tratamiento INTEGER PRIMARY KEY AUTOINCREMENT,
        id_clinica INTEGER NOT NULL,
        id_expediente TEXT NOT NULL,
        id_objetivo INTEGER,
        nombre_tratamiento TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        estado TEXT NOT NULL,
        FOREIGN KEY (id_clinica) REFERENCES clinicas (id_clinica) ON DELETE CASCADE,
        FOREIGN KEY (id_expediente) REFERENCES pacientes (id_expediente) ON DELETE CASCADE,
        FOREIGN KEY (id_objetivo) REFERENCES objetivos (id_objetivo) ON DELETE SET NULL
      )
    ''');

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
  }

  // Helper methods for direct queries during development/debug
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }
}
