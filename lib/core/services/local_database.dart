import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Base de datos local del modo offline: espejo de datos leídos del API para
// poder mostrarlos sin conexión.
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static const _dbName = 'sigerp_local.db';
  static const _dbVersion = 6;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    // sqflite solo tiene implementación nativa en Android/iOS/macOS — en
    // Windows/Linux (usado en este proyecto para pruebas de escritorio) hace
    // falta el motor FFI en su lugar.
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(_sqlCacheCentroCosto);
      await db.execute(_sqlCacheJefatura);
    }
    if (oldVersion < 3) {
      await db.execute(_sqlCacheChofer);
    }
    if (oldVersion < 4) {
      await db.execute(_sqlBorradorDiesel);
    }
    if (oldVersion < 5) {
      // Distingue partes normales ('Mis salidas') de partes ANULADOS (pestaña
      // nueva) dentro de la misma tabla — un SalMatCabId nunca puede estar en
      // los dos estados a la vez, así que no hace falta una tabla aparte.
      await db.execute('ALTER TABLE cache_salida_diesel ADD COLUMN anulado INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 6) {
      // Clave de idempotencia por borrador (ver AbastecimientoDieselRepository)
      // — borradores ya existentes quedan con '' (se tratan como sin clave).
      await db.execute("ALTER TABLE borrador_diesel ADD COLUMN idempotencyKey TEXT NOT NULL DEFAULT ''");
    }
  }

  // Catálogo de Centro de Costo (Unidad): se reemplaza por completo en cada
  // sincronización exitosa — es chico (unos cientos de filas) y cambia poco,
  // no vale la pena un diffing incremental.
  static const _sqlCacheCentroCosto = '''
    CREATE TABLE cache_centro_costo (
      empresaId TEXT NOT NULL,
      centroCosto TEXT NOT NULL,
      cenCostDescripcion TEXT,
      gerenciaId TEXT,
      dptoId TEXT,
      seccId TEXT,
      displayText TEXT,
      PRIMARY KEY (empresaId, centroCosto)
    )
  ''';

  // Catálogo de Jefatura por unidad organizativa (Gerencia/Depto/Sección):
  // mismo criterio de reemplazo completo.
  static const _sqlCacheJefatura = '''
    CREATE TABLE cache_jefatura (
      empresaId TEXT NOT NULL,
      gerenciaId TEXT NOT NULL,
      dptoId TEXT NOT NULL,
      seccId TEXT NOT NULL,
      usuaId TEXT,
      nombreCompleto TEXT,
      correoElectronico TEXT,
      seccDescripcion TEXT,
      PRIMARY KEY (empresaId, gerenciaId, dptoId, seccId)
    )
  ''';

  // Catálogo de Chofer: espejo completo (+9,000 trabajadores), igual que
  // Centro de Costo — el peso total es chico (~150 bytes por fila), así que
  // no vale la pena la complejidad de un caché parcial.
  static const _sqlCacheChofer = '''
    CREATE TABLE cache_chofer (
      empresaId TEXT NOT NULL,
      trabId TEXT NOT NULL,
      trabApePat TEXT,
      trabApeMat TEXT,
      trabNombres TEXT,
      displayText TEXT,
      PRIMARY KEY (empresaId, trabId)
    )
  ''';

  // Outbox de borradores: registros que no se pudieron enviar por falta de
  // conexión, esperando reintento manual (o el aviso de reconexión).
  // fotoPath apunta a la copia PERMANENTE de la foto (ver
  // FotoEvidenciaStorage) — no a la ruta temporal que entrega la cámara.
  static const _sqlBorradorDiesel = '''
    CREATE TABLE borrador_diesel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      empresaId TEXT NOT NULL,
      usuaId TEXT NOT NULL,
      centroCosto TEXT NOT NULL,
      centroCostoDescripcion TEXT,
      choferId TEXT NOT NULL,
      choferNombre TEXT,
      cantidad REAL NOT NULL,
      kilometraje INTEGER NOT NULL,
      fotoPath TEXT NOT NULL,
      creadoEn TEXT NOT NULL,
      estado TEXT NOT NULL,
      motivoError TEXT,
      idempotencyKey TEXT NOT NULL DEFAULT ''
    )
  ''';

  Future<void> _onCreate(Database db, int version) async {
    // Espejo del historial de Abastecimiento de Diesel ("Mis salidas"): se
    // reemplaza por completo en cada sincronización exitosa (DELETE +
    // INSERT), no hay diffing incremental — es la lista propia del usuario,
    // no tan grande como para que valga la pena la complejidad.
    await db.execute('''
      CREATE TABLE cache_salida_diesel (
        empresaId TEXT NOT NULL,
        usuaId TEXT NOT NULL,
        salMatCabId INTEGER NOT NULL,
        numeroDocumento TEXT,
        fecha TEXT,
        itemDescripcion TEXT,
        centroCosto TEXT,
        centroCostoDescripcion TEXT,
        chofer TEXT,
        jefatura TEXT,
        cantidad REAL,
        unidadMedida TEXT,
        precioUnitario REAL,
        total REAL,
        kilometraje INTEGER,
        tieneFoto INTEGER,
        anulado INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (empresaId, usuaId, salMatCabId)
      )
    ''');

    await db.execute(_sqlCacheCentroCosto);
    await db.execute(_sqlCacheJefatura);
    await db.execute(_sqlCacheChofer);
    await db.execute(_sqlBorradorDiesel);
  }
}
