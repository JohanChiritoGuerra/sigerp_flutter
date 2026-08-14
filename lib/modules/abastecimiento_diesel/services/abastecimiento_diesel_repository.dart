import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/connectivity_service.dart';
import '../models/abastecimiento_diesel_lista_item.dart';
import '../models/borrador_diesel.dart';
import '../models/centro_costo.dart';
import '../models/chofer.dart';
import '../models/jefatura.dart';
import 'abastecimiento_diesel_local_store.dart';
import 'abastecimiento_diesel_service.dart';
import 'foto_evidencia_storage.dart';

enum RegistrarDieselEstado { exitoso, guardadoComoBorrador, rechazado }

class RegistrarDieselResultado {
  final RegistrarDieselEstado estado;
  final String mensaje;
  // Solo poblados cuando estado == rechazado: permiten que la pantalla
  // ofrezca "guardar como borrador" puntualmente para el único rechazo que
  // amerita esa opción (sin stock), reusando la MISMA clave de idempotencia
  // del intento que acaba de fallar.
  final String? codigoError;
  final String? idempotencyKey;

  RegistrarDieselResultado._(this.estado, this.mensaje, {this.codigoError, this.idempotencyKey});

  factory RegistrarDieselResultado.exitoso(String mensaje) =>
      RegistrarDieselResultado._(RegistrarDieselEstado.exitoso, mensaje);

  // esReintento: true cuando esto pasa al tocar "Reintentar" DESDE la propia
  // pestaña Borradores — ahí no tiene sentido decirle al usuario "revisa la
  // pestaña Borradores", ya está parado justo ahí mirando esa tarjeta. Ese
  // mensaje ("revisa la pestaña...") solo aplica cuando el borrador se
  // acaba de crear desde OTRA pantalla (el formulario).
  factory RegistrarDieselResultado.guardadoComoBorrador({bool esReintento = false}) => RegistrarDieselResultado._(
        RegistrarDieselEstado.guardadoComoBorrador,
        esReintento
            ? 'Sigue sin conexión. El borrador continúa pendiente.'
            : 'Sin conexión. Se guardó como borrador — revisa la pestaña "Borradores" para enviarlo cuando haya señal.',
      );

  factory RegistrarDieselResultado.rechazado(String mensaje, {String? codigoError, String? idempotencyKey}) =>
      RegistrarDieselResultado._(
        RegistrarDieselEstado.rechazado,
        mensaje,
        codigoError: codigoError,
        idempotencyKey: idempotencyKey,
      );

  bool get puedeGuardarComoBorradorPorStock =>
      estado == RegistrarDieselEstado.rechazado && codigoError == kCodigoErrorStockInsuficiente;
}

class ListaDieselResultado {
  final List<AbastecimientoDieselListaItem> items;
  final bool esDatoCacheado;
  final DateTime? sincronizadoEn;

  ListaDieselResultado({required this.items, required this.esDatoCacheado, this.sincronizadoEn});
}

// Une el API remoto con el espejo local para el historial de Abastecimiento
// de Diesel. La pantalla habla con esta clase, no directamente con
// AbastecimientoDieselService — así no necesita saber si el dato vino de la
// red o de la copia local.
class AbastecimientoDieselRepository {
  final AbastecimientoDieselService _api = AbastecimientoDieselService();
  final AbastecimientoDieselLocalStore _local = AbastecimientoDieselLocalStore();
  final ConnectivityService _connectivity = ConnectivityService();
  final FotoEvidenciaStorage _fotoStorage = FotoEvidenciaStorage();

  // Mensajes que ApiService genera cuando la petición ni siquiera llegó al
  // servidor (timeout, DNS, sin red) — a diferencia de un rechazo real del
  // backend, que trae su propio mensaje de negocio (stock, cierre, permiso).
  bool _esFalloDeConexion(String mensaje) {
    return mensaje.startsWith('Error de red') || mensaje.startsWith('Error de conexión');
  }

  // Se genera UNA sola vez por intento de registro (el primero, no cada
  // reintento) y viaja con la petición al backend, que la usa para detectar
  // un reintento de algo que en realidad ya se había procesado antes (ej. el
  // servidor sí guardó el registro pero la confirmación nunca llegó al
  // celular porque se cortó la señal justo después) — así evita duplicarlo.
  String _generarIdempotencyKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // anio/mes: la copia local ya NO es un mirror del historial completo —
  // solo acumula los meses que el usuario fue mirando con conexión (ver
  // AbastecimientoDieselLocalStore.reemplazarSalidasDelMes). Sin conexión,
  // un mes que nunca se sincronizó antes simplemente no tiene nada que
  // mostrar (sincronizadoEn queda null, y la pantalla lo distingue de
  // "este mes está vacío de verdad").
  Future<ListaDieselResultado> listar({
    required String usuaId,
    required String empresaId,
    required int anio,
    required int mes,
  }) async {
    if (await _connectivity.isOnline()) {
      try {
        final remoto = await _api.listar(empresaId: empresaId, anio: anio, mes: mes);
        await _local.reemplazarSalidasDelMes(empresaId: empresaId, usuaId: usuaId, anio: anio, mes: mes, lista: remoto);
        final ahora = DateTime.now();
        await _guardarSincronizadoEn(empresaId, usuaId, anio, mes, ahora);
        return ListaDieselResultado(items: remoto, esDatoCacheado: false, sincronizadoEn: ahora);
      } catch (_) {
        // Sigue abajo: si el pedido en vivo falla a último momento
        // (ej. se cortó la señal a media petición), se cae al espejo local.
      }
    }

    final local = await _local.obtenerSalidasDelMesLocal(empresaId: empresaId, usuaId: usuaId, anio: anio, mes: mes);
    final sincronizadoEn = await _obtenerSincronizadoEn(empresaId, usuaId, anio, mes);
    return ListaDieselResultado(items: local, esDatoCacheado: true, sincronizadoEn: sincronizadoEn);
  }

  // Igual que listar(), pero de los partes ANULADOS — usa su propia copia
  // local (anulado = true) y su propia fecha de sincronización por mes,
  // separada de "Mis salidas".
  Future<ListaDieselResultado> listarAnulados({
    required String usuaId,
    required String empresaId,
    required int anio,
    required int mes,
  }) async {
    if (await _connectivity.isOnline()) {
      try {
        final remoto = await _api.listarAnulados(empresaId: empresaId, anio: anio, mes: mes);
        await _local.reemplazarSalidasDelMes(
          empresaId: empresaId,
          usuaId: usuaId,
          anio: anio,
          mes: mes,
          lista: remoto,
          anulado: true,
        );
        final ahora = DateTime.now();
        await _guardarSincronizadoEnAnulados(empresaId, usuaId, anio, mes, ahora);
        return ListaDieselResultado(items: remoto, esDatoCacheado: false, sincronizadoEn: ahora);
      } catch (_) {
        // Sigue abajo: si el pedido en vivo falla a último momento se cae al espejo local.
      }
    }

    final local = await _local.obtenerSalidasDelMesLocal(empresaId: empresaId, usuaId: usuaId, anio: anio, mes: mes, anulado: true);
    final sincronizadoEn = await _obtenerSincronizadoEnAnulados(empresaId, usuaId, anio, mes);
    return ListaDieselResultado(items: local, esDatoCacheado: true, sincronizadoEn: sincronizadoEn);
  }

  // ---------- Foto de un parte ya registrado ("Mis salidas" / "Anulados") ----------

  // Una foto de evidencia ya registrada nunca cambia, así que si ya está en
  // disco no hace falta ni preguntarle al servidor — eso además la deja
  // disponible sin conexión (antes solo vivía en memoria mientras la app
  // seguía abierta, así que se perdía apenas se cerraba la app).
  Future<Uint8List?> obtenerFoto({required int salMatCabId, required String empresaId}) async {
    final enDisco = await _fotoStorage.leerFotoHistorial(empresaId: empresaId, salMatCabId: salMatCabId);
    if (enDisco != null) return enDisco;

    if (!await _connectivity.isOnline()) return null;

    final bytes = await _api.obtenerFoto(salMatCabId: salMatCabId, empresaId: empresaId);
    if (bytes != null) {
      await _fotoStorage.guardarFotoHistorial(empresaId: empresaId, salMatCabId: salMatCabId, bytes: bytes);
    }
    return bytes;
  }

  // Imprimir requiere conexión siempre (el PDF se genera en el servidor al
  // momento) — no tiene sentido cachearlo como la foto, es una acción
  // puntual, no algo para consultar offline más tarde.
  Future<Uint8List?> obtenerPdfParte({required int salMatCabId, required String empresaId}) async {
    if (!await _connectivity.isOnline()) return null;
    return _api.obtenerPdfParte(salMatCabId: salMatCabId, empresaId: empresaId);
  }

  // ---------- Centro de Costo ----------

  // No cachea acá directamente — el catálogo completo solo se guarda desde
  // sincronizarCatalogosSiCorresponde() (con su límite de una vez al día).
  // Esto evita tener dos puntos distintos escribiendo la misma tabla con
  // criterios de "cuándo" diferentes.
  Future<List<CentroCosto>> buscarCentroCosto({required String filtro, required String empresaId}) async {
    if (await _connectivity.isOnline()) {
      try {
        return await _api.buscarCentroCosto(filtro: filtro, empresaId: empresaId);
      } catch (_) {
        // Sigue abajo si falla a último momento.
      }
    }
    return _local.buscarCentroCostoLocal(empresaId: empresaId, filtro: filtro);
  }

  // ---------- Jefatura ----------

  // A diferencia de Centro de Costo, acá SÍ se lee siempre de la copia local
  // (nunca se llama al endpoint puntual PorCentroCosto desde el celular) —
  // el catálogo completo de jefaturas se sincroniza aparte (ver
  // sincronizarCatalogosSiCorresponde) y esta función solo consulta esa
  // copia, haya o no conexión en este momento.
  Future<Jefatura?> obtenerJefatura({
    required String gerenciaId,
    required String dptoId,
    required String seccId,
    required String empresaId,
  }) {
    return _local.obtenerJefaturaLocal(empresaId: empresaId, gerenciaId: gerenciaId, dptoId: dptoId, seccId: seccId);
  }

  // ---------- Chofer ----------

  // Mismo patrón que Centro de Costo: no cachea acá directamente, el
  // catálogo completo (+9,000, espejo total) solo se guarda desde
  // sincronizarCatalogosSiCorresponde().
  Future<List<Chofer>> buscarChofer({required String filtro, required String empresaId}) async {
    if (await _connectivity.isOnline()) {
      try {
        return await _api.buscarChofer(filtro: filtro, empresaId: empresaId);
      } catch (_) {
        // Sigue abajo si falla a último momento.
      }
    }
    return _local.buscarChoferLocal(empresaId: empresaId, filtro: filtro);
  }

  // ---------- Registrar / Borradores (Outbox) ----------

  Future<RegistrarDieselResultado> registrar({
    required String usuaId,
    required String empresaId,
    required CentroCosto centroCosto,
    required Chofer chofer,
    required double cantidad,
    required int kilometraje,
    required File foto,
  }) async {
    // Se genera una sola vez acá, en el primer intento — si termina cayendo
    // a un borrador, todos sus reintentos reusan esta misma clave.
    final idempotencyKey = _generarIdempotencyKey();

    if (!await _connectivity.isOnline()) {
      await _guardarComoBorrador(
        usuaId: usuaId,
        empresaId: empresaId,
        centroCosto: centroCosto,
        chofer: chofer,
        cantidad: cantidad,
        kilometraje: kilometraje,
        foto: foto,
        idempotencyKey: idempotencyKey,
      );
      return RegistrarDieselResultado.guardadoComoBorrador();
    }

    final resultado = await _api.registrar(
      codigoCentroCosto: centroCosto.centroCosto,
      trabIdChofer: chofer.trabId,
      cantidad: cantidad,
      kilometraje: kilometraje,
      empresaId: empresaId,
      foto: foto,
      idempotencyKey: idempotencyKey,
    );

    if (resultado.exito) return RegistrarDieselResultado.exitoso(resultado.mensaje);

    if (_esFalloDeConexion(resultado.mensaje)) {
      await _guardarComoBorrador(
        usuaId: usuaId,
        empresaId: empresaId,
        centroCosto: centroCosto,
        chofer: chofer,
        cantidad: cantidad,
        kilometraje: kilometraje,
        foto: foto,
        idempotencyKey: idempotencyKey,
      );
      return RegistrarDieselResultado.guardadoComoBorrador();
    }

    return RegistrarDieselResultado.rechazado(
      resultado.mensaje,
      codigoError: resultado.codigoError,
      idempotencyKey: idempotencyKey,
    );
  }

  // Guarda como borrador un intento que el servidor YA rechazó explícitamente
  // por falta de stock — a diferencia de _guardarComoBorrador (que se usa
  // cuando ni siquiera se pudo intentar), acá se conoce el motivo exacto de
  // entrada, así que nace directo en estado esperandoStock (no pendiente):
  // no es un problema de conexión, es un recurso que hay que esperar a que
  // se reponga. Reusa la MISMA idempotencyKey del intento rechazado — el
  // servidor no llegó a crear nada (fue un rechazo limpio, con rollback), así
  // que no hay riesgo de duplicado al reintentar con esa misma clave.
  Future<void> guardarBorradorPorStock({
    required String usuaId,
    required String empresaId,
    required CentroCosto centroCosto,
    required Chofer chofer,
    required double cantidad,
    required int kilometraje,
    required File foto,
    required String idempotencyKey,
    required String motivo,
  }) {
    return _guardarComoBorrador(
      usuaId: usuaId,
      empresaId: empresaId,
      centroCosto: centroCosto,
      chofer: chofer,
      cantidad: cantidad,
      kilometraje: kilometraje,
      foto: foto,
      idempotencyKey: idempotencyKey,
      estado: EstadoBorrador.esperandoStock,
      motivoError: motivo,
    );
  }

  Future<void> _guardarComoBorrador({
    required String usuaId,
    required String empresaId,
    required CentroCosto centroCosto,
    required Chofer chofer,
    required double cantidad,
    required int kilometraje,
    required File foto,
    required String idempotencyKey,
    EstadoBorrador estado = EstadoBorrador.pendiente,
    String? motivoError,
  }) async {
    // Copia la foto a una carpeta permanente ANTES de guardar el borrador —
    // la ruta que entrega la cámara vive en caché y el sistema la puede
    // borrar sola mientras el borrador espera señal.
    final fotoPermanente = await _fotoStorage.guardarCopiaPermanente(foto);

    await _local.insertarBorrador(BorradorDiesel(
      empresaId: empresaId,
      usuaId: usuaId,
      centroCosto: centroCosto.centroCosto,
      // OJO: cenCostDescripcion (descripción pura), NO displayText — ese ya
      // viene formateado como "código - descripción" (se usa en el buscador),
      // y el detalle del borrador vuelve a anteponer el código por su cuenta;
      // guardar displayText acá lo duplicaba ("código - código - descripción").
      centroCostoDescripcion: centroCosto.cenCostDescripcion,
      choferId: chofer.trabId,
      choferNombre: chofer.displayText,
      cantidad: cantidad,
      kilometraje: kilometraje,
      fotoPath: fotoPermanente,
      creadoEn: DateTime.now(),
      idempotencyKey: idempotencyKey,
      estado: estado,
      motivoError: motivoError,
    ));
  }

  // Reintenta un borrador ya guardado: vuelve a correr todas las
  // validaciones reales en el servidor (nunca se asume que sigue siendo
  // válido solo porque lo era cuando se creó el borrador).
  Future<RegistrarDieselResultado> reintentarBorrador(BorradorDiesel borrador) async {
    final fotoArchivo = File(borrador.fotoPath);
    if (!await fotoArchivo.exists()) {
      const motivo = 'La foto ya no está disponible en el dispositivo. Elimina este borrador y regístralo de nuevo.';
      if (borrador.id != null) await _local.marcarError(borrador.id!, motivo);
      return RegistrarDieselResultado.rechazado(motivo);
    }

    if (!await _connectivity.isOnline()) {
      return RegistrarDieselResultado.guardadoComoBorrador(esReintento: true);
    }

    final resultado = await _api.registrar(
      codigoCentroCosto: borrador.centroCosto,
      trabIdChofer: borrador.choferId,
      cantidad: borrador.cantidad,
      kilometraje: borrador.kilometraje,
      empresaId: borrador.empresaId,
      foto: fotoArchivo,
      // Se reutiliza la MISMA clave del intento original — así el backend
      // detecta si este reintento en realidad ya se había procesado antes.
      idempotencyKey: borrador.idempotencyKey,
    );

    if (resultado.exito) {
      if (borrador.id != null) {
        await _local.eliminarBorrador(borrador.id!);
        await _fotoStorage.eliminarCopia(borrador.fotoPath);
      }
      return RegistrarDieselResultado.exitoso(resultado.mensaje);
    }

    if (_esFalloDeConexion(resultado.mensaje)) {
      if (borrador.id != null) await _local.marcarPendiente(borrador.id!);
      return RegistrarDieselResultado.guardadoComoBorrador(esReintento: true);
    }

    // Si sigue sin stock, se queda en "esperandoStock" (no salta a "error")
    // — sigue siendo el mismo motivo transitorio, no algo nuevo que revisar.
    if (resultado.codigoError == kCodigoErrorStockInsuficiente) {
      if (borrador.id != null) await _local.marcarEsperandoStock(borrador.id!, resultado.mensaje);
      return RegistrarDieselResultado.rechazado(resultado.mensaje, codigoError: resultado.codigoError);
    }

    if (borrador.id != null) await _local.marcarError(borrador.id!, resultado.mensaje);
    return RegistrarDieselResultado.rechazado(resultado.mensaje);
  }

  Future<List<BorradorDiesel>> listarBorradores({required String usuaId, required String empresaId}) {
    return _local.listarBorradores(usuaId: usuaId, empresaId: empresaId);
  }

  Future<int> contarBorradoresPendientes({required String usuaId, required String empresaId}) {
    return _local.contarBorradoresPendientes(usuaId: usuaId, empresaId: empresaId);
  }

  Future<void> eliminarBorrador(BorradorDiesel borrador) async {
    if (borrador.id == null) return;
    await _local.eliminarBorrador(borrador.id!);
    await _fotoStorage.eliminarCopia(borrador.fotoPath);
  }

  // ---------- Sincronización de catálogos (Centro de Costo + Jefatura + Chofer) ----------

  // Se llama sola (sin await, sin bloquear la pantalla) al entrar al módulo,
  // al formulario, o al iniciar sesión. No sincroniza cada vez que hay señal
  // — estos catálogos casi no cambian, así que alcanza con una vez al día;
  // hacerlo en cada apertura sería gastar señal/batería para traer una y
  // otra vez lo mismo.
  //
  // Las 3 llamadas corren en PARALELO (antes iban una detrás de otra, el
  // tiempo total era la suma de las 3) y cada una se guarda y throttlea de
  // forma INDEPENDIENTE — con un solo timestamp compartido, si la más pesada
  // (choferes) fallaba, ni siquiera se guardaba lo que sí había llegado bien
  // (centro de costo/jefatura), y encima cada reintento volvía a pedir las
  // 3 de nuevo. Así, un catálogo que ya sincronizó con éxito no se vuelve a
  // pedir aunque otro siga fallando (ej. choferes con una conexión lenta).
  // Estático (no de instancia): esta clase se instancia una vez por pantalla
  // (screen, modal, app.dart...), así que una bandera de instancia no evitaría
  // que DOS instancias distintas arrancaran cada una su propia ronda casi al
  // mismo tiempo (ej. una al iniciar sesión, otra al entrar al módulo unos
  // segundos después) — eso duplicaba la descarga de los mismos catálogos en
  // paralelo, compitiendo por el mismo ancho de banda justo cuando más
  // importa que la app se sienta rápida (recién abierta).
  static Future<void>? _syncEnCurso;

  Future<void> sincronizarCatalogosSiCorresponde({required String empresaId}) async {
    if (!await _connectivity.isOnline()) return;

    if (_syncEnCurso != null) {
      await _syncEnCurso;
      return;
    }

    final ronda = Future.wait([
      _sincronizarUnCatalogoSiCorresponde(
        clave: 'diesel_sync_centrocosto_$empresaId',
        sincronizar: () async {
          final centrosCosto = await _api.buscarCentroCosto(filtro: '', empresaId: empresaId, timeoutSeconds: 30);
          await _local.reemplazarCentroCostos(empresaId, centrosCosto);
        },
      ),
      _sincronizarUnCatalogoSiCorresponde(
        clave: 'diesel_sync_jefatura_$empresaId',
        sincronizar: () async {
          final jefaturas = await _api.obtenerTodasLasJefaturas(empresaId: empresaId);
          await _local.reemplazarJefaturas(empresaId, jefaturas);
        },
      ),
      _sincronizarUnCatalogoSiCorresponde(
        clave: 'diesel_sync_chofer_$empresaId',
        sincronizar: () async {
          final choferes = await _api.obtenerTodosLosChoferes(empresaId: empresaId);
          await _local.reemplazarChoferes(empresaId, choferes);
        },
      ),
    ]);

    _syncEnCurso = ronda;
    try {
      await ronda;
    } finally {
      _syncEnCurso = null;
    }
  }

  Future<void> _sincronizarUnCatalogoSiCorresponde({
    required String clave,
    required Future<void> Function() sincronizar,
  }) async {
    final ultimaSync = await _obtenerUltimaSincronizacionGenerica(clave);
    final yaToca = ultimaSync == null || DateTime.now().difference(ultimaSync) > const Duration(hours: 24);
    if (!yaToca) return;

    try {
      await sincronizar();
      await _guardarUltimaSincronizacionGenerica(clave, DateTime.now());
    } catch (_) {
      // No se actualiza la fecha — este catálogo puntual se reintenta la
      // próxima vez que corresponda, sin afectar a los otros dos.
    }
  }

  Future<void> _guardarUltimaSincronizacionGenerica(String clave, DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(clave, fecha.toIso8601String());
  }

  Future<DateTime?> _obtenerUltimaSincronizacionGenerica(String clave) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(clave);
    if (data == null) return null;
    return DateTime.tryParse(data);
  }

  // La marca de sincronización ahora es POR MES (antes era una sola por
  // usuario/empresa, porque se sincronizaba todo el historial de una vez).
  String _claveSincronizado(String empresaId, String usuaId, int anio, int mes) =>
      'diesel_historial_sync_${empresaId}_${usuaId}_${anio}_$mes';

  Future<void> _guardarSincronizadoEn(String empresaId, String usuaId, int anio, int mes, DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveSincronizado(empresaId, usuaId, anio, mes), fecha.toIso8601String());
  }

  Future<DateTime?> _obtenerSincronizadoEn(String empresaId, String usuaId, int anio, int mes) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_claveSincronizado(empresaId, usuaId, anio, mes));
    if (data == null) return null;
    return DateTime.tryParse(data);
  }

  String _claveSincronizadoAnulados(String empresaId, String usuaId, int anio, int mes) =>
      'diesel_historial_anulados_sync_${empresaId}_${usuaId}_${anio}_$mes';

  Future<void> _guardarSincronizadoEnAnulados(String empresaId, String usuaId, int anio, int mes, DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveSincronizadoAnulados(empresaId, usuaId, anio, mes), fecha.toIso8601String());
  }

  Future<DateTime?> _obtenerSincronizadoEnAnulados(String empresaId, String usuaId, int anio, int mes) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_claveSincronizadoAnulados(empresaId, usuaId, anio, mes));
    if (data == null) return null;
    return DateTime.tryParse(data);
  }
}
