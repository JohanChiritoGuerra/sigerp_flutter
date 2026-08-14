import 'package:sqflite/sqflite.dart';
import '../../../core/services/local_database.dart';
import '../models/abastecimiento_diesel_lista_item.dart';
import '../models/borrador_diesel.dart';
import '../models/centro_costo.dart';
import '../models/chofer.dart';
import '../models/jefatura.dart';

// Acceso a la copia local (espejo) de Abastecimiento de Diesel. No conoce el
// API ni la conectividad — solo lee/escribe SQLite. La decisión de cuándo
// usar esta copia en vez del API en vivo vive en el repositorio.
class AbastecimientoDieselLocalStore {
  final LocalDatabase _db = LocalDatabase();

  // ---------- Centro de Costo ----------

  Future<void> reemplazarCentroCostos(String empresaId, List<CentroCosto> lista) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('cache_centro_costo', where: 'empresaId = ?', whereArgs: [empresaId]);
      for (final c in lista) {
        await txn.insert('cache_centro_costo', {
          'empresaId': empresaId,
          'centroCosto': c.centroCosto,
          'cenCostDescripcion': c.cenCostDescripcion,
          'gerenciaId': c.gerenciaId,
          'dptoId': c.dptoId,
          'seccId': c.seccId,
          'displayText': c.displayText,
        });
      }
    });
  }

  Future<List<CentroCosto>> buscarCentroCostoLocal({required String empresaId, required String filtro}) async {
    final db = await _db.database;
    final filtroLimpio = filtro.trim();
    final rows = filtroLimpio.isEmpty
        ? await db.query('cache_centro_costo', where: 'empresaId = ?', whereArgs: [empresaId], orderBy: 'centroCosto')
        : await db.query(
            'cache_centro_costo',
            where: 'empresaId = ? AND (centroCosto LIKE ? OR cenCostDescripcion LIKE ?)',
            whereArgs: [empresaId, '%$filtroLimpio%', '%$filtroLimpio%'],
            orderBy: 'centroCosto',
          );

    return rows
        .map((r) => CentroCosto(
              centroCosto: r['centroCosto'] as String? ?? '',
              cenCostDescripcion: r['cenCostDescripcion'] as String? ?? '',
              gerenciaId: r['gerenciaId'] as String? ?? '',
              dptoId: r['dptoId'] as String? ?? '',
              seccId: r['seccId'] as String? ?? '',
              displayText: r['displayText'] as String? ?? '',
            ))
        .toList();
  }

  // ---------- Chofer ----------
  // Espejo completo, igual que Centro de Costo — son +9,000 filas, pero el
  // peso total es chico (~150 bytes por fila), así que no vale la pena la
  // complejidad de un caché parcial.

  Future<void> reemplazarChoferes(String empresaId, List<Chofer> lista) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('cache_chofer', where: 'empresaId = ?', whereArgs: [empresaId]);
      for (final c in lista) {
        // El SP de sincronización masiva ya no manda displayText (se quitó
        // por ser redundante y pesar en las +9,000 filas) — se arma acá con
        // los mismos 4 campos, igual que lo hacía el servidor.
        final displayText = c.displayText.isNotEmpty
            ? c.displayText
            : '${c.trabId} - ${c.trabApePat} ${c.trabApeMat} ${c.trabNombres}'.trim();
        await txn.insert('cache_chofer', {
          'empresaId': empresaId,
          'trabId': c.trabId,
          'trabApePat': c.trabApePat,
          'trabApeMat': c.trabApeMat,
          'trabNombres': c.trabNombres,
          'displayText': displayText,
        });
      }
    });
  }

  Future<List<Chofer>> buscarChoferLocal({required String empresaId, required String filtro}) async {
    final db = await _db.database;
    final filtroLimpio = filtro.trim();
    final rows = filtroLimpio.isEmpty
        ? await db.query('cache_chofer', where: 'empresaId = ?', whereArgs: [empresaId], orderBy: 'trabApePat, trabApeMat, trabNombres')
        : await db.query(
            'cache_chofer',
            where: 'empresaId = ? AND (trabId LIKE ? OR displayText LIKE ?)',
            whereArgs: [empresaId, '%$filtroLimpio%', '%$filtroLimpio%'],
            orderBy: 'trabApePat, trabApeMat, trabNombres',
          );

    return rows
        .map((r) => Chofer(
              trabId: r['trabId'] as String? ?? '',
              trabApePat: r['trabApePat'] as String? ?? '',
              trabApeMat: r['trabApeMat'] as String? ?? '',
              trabNombres: r['trabNombres'] as String? ?? '',
              displayText: r['displayText'] as String? ?? '',
            ))
        .toList();
  }

  // ---------- Jefatura ----------

  Future<void> reemplazarJefaturas(String empresaId, List<Jefatura> lista) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('cache_jefatura', where: 'empresaId = ?', whereArgs: [empresaId]);
      for (final j in lista) {
        await txn.insert(
          'cache_jefatura',
          {
            'empresaId': empresaId,
            'gerenciaId': j.gerenciaId,
            'dptoId': j.dptoId,
            'seccId': j.seccId,
            'usuaId': j.usuaId,
            'nombreCompleto': j.nombreCompleto,
            'correoElectronico': j.correoElectronico,
            'seccDescripcion': j.seccDescripcion,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<Jefatura?> obtenerJefaturaLocal({
    required String empresaId,
    required String gerenciaId,
    required String dptoId,
    required String seccId,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'cache_jefatura',
      where: 'empresaId = ? AND gerenciaId = ? AND dptoId = ? AND seccId = ?',
      whereArgs: [empresaId, gerenciaId, dptoId, seccId],
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Jefatura(
      usuaId: r['usuaId'] as String? ?? '',
      nombreCompleto: r['nombreCompleto'] as String? ?? '',
      correoElectronico: r['correoElectronico'] as String?,
      gerenciaId: gerenciaId,
      dptoId: dptoId,
      seccId: seccId,
      seccDescripcion: r['seccDescripcion'] as String?,
    );
  }

  // [anulado] separa "Mis salidas" (false) de "Anulados" (true) dentro de la
  // misma tabla — un SalMatCabId nunca puede estar en los dos estados a la
  // vez. [anio]/[mes] acotan el reemplazo a UN mes puntual: a diferencia de
  // los catálogos (espejo total), acá no conviene borrar y volver a bajar
  // TODO el historial en cada sincronización — así que solo se reemplaza la
  // porción de ese mes, dejando intactos los demás meses que ya se hayan
  // sincronizado antes. La copia local termina siendo "los meses que el
  // usuario fue mirando", no un mirror completo.
  Future<void> reemplazarSalidasDelMes({
    required String empresaId,
    required String usuaId,
    required int anio,
    required int mes,
    required List<AbastecimientoDieselListaItem> lista,
    bool anulado = false,
  }) async {
    final db = await _db.database;
    final desde = DateTime(anio, mes, 1);
    final hasta = DateTime(anio, mes + 1, 1);
    await db.transaction((txn) async {
      await txn.delete(
        'cache_salida_diesel',
        where: 'empresaId = ? AND usuaId = ? AND anulado = ? AND fecha >= ? AND fecha < ?',
        whereArgs: [empresaId, usuaId, anulado ? 1 : 0, desde.toIso8601String(), hasta.toIso8601String()],
      );
      for (final item in lista) {
        await txn.insert('cache_salida_diesel', {
          'empresaId': empresaId,
          'usuaId': usuaId,
          'salMatCabId': item.salMatCabId,
          'numeroDocumento': item.numeroDocumento,
          'fecha': item.fecha.toIso8601String(),
          'itemDescripcion': item.itemDescripcion,
          'centroCosto': item.centroCosto,
          'centroCostoDescripcion': item.centroCostoDescripcion,
          'chofer': item.chofer,
          'jefatura': item.jefatura,
          'cantidad': item.cantidad,
          'unidadMedida': item.unidadMedida,
          'precioUnitario': item.precioUnitario,
          'total': item.total,
          'kilometraje': item.kilometraje,
          'tieneFoto': item.tieneFoto ? 1 : 0,
          'anulado': anulado ? 1 : 0,
        });
      }
    });
  }

  Future<List<AbastecimientoDieselListaItem>> obtenerSalidasDelMesLocal({
    required String empresaId,
    required String usuaId,
    required int anio,
    required int mes,
    bool anulado = false,
  }) async {
    final db = await _db.database;
    final desde = DateTime(anio, mes, 1);
    final hasta = DateTime(anio, mes + 1, 1);
    final rows = await db.query(
      'cache_salida_diesel',
      where: 'empresaId = ? AND usuaId = ? AND anulado = ? AND fecha >= ? AND fecha < ?',
      whereArgs: [empresaId, usuaId, anulado ? 1 : 0, desde.toIso8601String(), hasta.toIso8601String()],
      orderBy: 'fecha DESC, salMatCabId DESC',
    );

    return rows
        .map((r) => AbastecimientoDieselListaItem(
              salMatCabId: r['salMatCabId'] as int,
              numeroDocumento: r['numeroDocumento'] as String? ?? '',
              fecha: DateTime.parse(r['fecha'] as String),
              itemDescripcion: r['itemDescripcion'] as String? ?? '',
              centroCosto: r['centroCosto'] as String? ?? '',
              centroCostoDescripcion: r['centroCostoDescripcion'] as String? ?? '',
              chofer: r['chofer'] as String? ?? '',
              jefatura: r['jefatura'] as String? ?? '',
              cantidad: (r['cantidad'] as num?)?.toDouble() ?? 0,
              unidadMedida: r['unidadMedida'] as String? ?? '',
              precioUnitario: (r['precioUnitario'] as num?)?.toDouble() ?? 0,
              total: (r['total'] as num?)?.toDouble() ?? 0,
              kilometraje: r['kilometraje'] as int? ?? 0,
              tieneFoto: (r['tieneFoto'] as int? ?? 0) == 1,
            ))
        .toList();
  }

  // ---------- Borradores (Outbox) ----------

  Future<int> insertarBorrador(BorradorDiesel borrador) async {
    final db = await _db.database;
    return db.insert('borrador_diesel', borrador.toMap());
  }

  Future<List<BorradorDiesel>> listarBorradores({required String empresaId, required String usuaId}) async {
    final db = await _db.database;
    final rows = await db.query(
      'borrador_diesel',
      where: 'empresaId = ? AND usuaId = ?',
      whereArgs: [empresaId, usuaId],
      orderBy: 'creadoEn DESC',
    );
    return rows.map((r) => BorradorDiesel.fromMap(r)).toList();
  }

  Future<int> contarBorradoresPendientes({required String empresaId, required String usuaId}) async {
    final db = await _db.database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) as total FROM borrador_diesel WHERE empresaId = ? AND usuaId = ?',
      [empresaId, usuaId],
    );
    return (resultado.first['total'] as int?) ?? 0;
  }

  Future<void> marcarError(int id, String motivo) async {
    final db = await _db.database;
    await db.update(
      'borrador_diesel',
      {'estado': EstadoBorrador.error.name, 'motivoError': motivo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarPendiente(int id) async {
    final db = await _db.database;
    await db.update(
      'borrador_diesel',
      {'estado': EstadoBorrador.pendiente.name, 'motivoError': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarEsperandoStock(int id, String motivo) async {
    final db = await _db.database;
    await db.update(
      'borrador_diesel',
      {'estado': EstadoBorrador.esperandoStock.name, 'motivoError': motivo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> eliminarBorrador(int id) async {
    final db = await _db.database;
    await db.delete('borrador_diesel', where: 'id = ?', whereArgs: [id]);
  }
}
