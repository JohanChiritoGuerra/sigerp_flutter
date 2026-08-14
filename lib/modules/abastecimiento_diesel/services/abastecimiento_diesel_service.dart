import 'dart:io';
import 'dart:typed_data';
import '../../../core/models/base_response.dart';
import '../../../core/services/api_service.dart';
import '../models/abastecimiento_diesel_lista_item.dart';
import '../models/centro_costo.dart';
import '../models/chofer.dart';
import '../models/item_almacen.dart';
import '../models/jefatura.dart';

class AbastecimientoDieselResultado {
  final bool exito;
  final String mensaje;
  // Código fijo del backend (ej. "STOCK_INSUFICIENTE") para distinguir el
  // motivo de un rechazo sin depender del texto de "mensaje" — ese es para
  // mostrárselo al usuario, y puede cambiar de redacción sin previo aviso.
  final String? codigoError;

  AbastecimientoDieselResultado({required this.exito, required this.mensaje, this.codigoError});
}

// Código fijo que el backend manda cuando el rechazo es específicamente por
// falta de stock — el único caso donde la app ofrece guardar como borrador
// pese a ser un rechazo real del servidor (el stock es lo único de la lista
// de validaciones que genuinamente puede cambiar solo con el tiempo).
const String kCodigoErrorStockInsuficiente = 'STOCK_INSUFICIENTE';

// Timeout corto para Listar/ListarAnulados — se disparan solas al abrir la
// pantalla, con fallback a la copia local si fallan. Con el timeout normal
// (30s), un falso "conectado" (interfaz activa pero sin Internet real) hace
// que la pantalla se sienta colgada antes de caer a lo local.
const int _kTimeoutListado = 8;

class AbastecimientoDieselService {
  final ApiService _apiService = ApiService();

  Future<AbastecimientoDieselResultado> registrar({
    required String codigoCentroCosto,
    required String trabIdChofer,
    required double cantidad,
    required int kilometraje,
    required String empresaId,
    required File foto,
    required String idempotencyKey,
  }) async {
    final response = await _apiService.postMultipart(
      'api/AbastecimientoDiesel/Registrar',
      {
        'codigoCentroCosto': codigoCentroCosto,
        'trabIdChofer': trabIdChofer,
        'cantidad': cantidad.toString(),
        'kilometraje': kilometraje.toString(),
        'empresaId': empresaId,
        'idempotencyKey': idempotencyKey,
      },
      foto,
      'foto',
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    return AbastecimientoDieselResultado(
      exito: baseResponse.esExitoso,
      mensaje: baseResponse.message ?? (baseResponse.esExitoso
          ? 'Registrado correctamente'
          : 'No se pudo registrar el abastecimiento'),
      codigoError: response['codigoError'] as String?,
    );
  }

  // anio/mes: acota la consulta a un mes puntual — evita traer el historial
  // completo del usuario en cada sincronización (ver AbastecimientoDieselRepository).
  //
  // timeoutSeconds corto (ver constante abajo): esta llamada se dispara sola
  // al abrir la pantalla, con un fallback a la copia local si falla — pero
  // ConnectivityService.isOnline() solo detecta que hay una interfaz de red
  // activa, no que haya Internet real de punta a punta (ej. wifi conectado a
  // un router sin salida, o datos móviles con falso "conectado"). Si eso
  // pasa, este pedido igual se intenta, y con el timeout normal (30s) la
  // pantalla se siente colgada un buen rato antes de caer a lo local, aunque
  // en los hechos esté "sin conexión". Con un timeout corto, ese peor caso
  // se nota mucho menos.
  Future<List<AbastecimientoDieselListaItem>> listar({
    required String empresaId,
    required int anio,
    required int mes,
  }) async {
    final response = await _apiService.get(
      'api/AbastecimientoDiesel/Listar',
      queryParams: {'empresaId': empresaId, 'anio': anio, 'mes': mes},
      timeoutSeconds: _kTimeoutListado,
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => AbastecimientoDieselListaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Igual que listar(), pero de los partes ANULADOS del usuario logueado.
  Future<List<AbastecimientoDieselListaItem>> listarAnulados({
    required String empresaId,
    required int anio,
    required int mes,
  }) async {
    final response = await _apiService.get(
      'api/AbastecimientoDiesel/ListarAnulados',
      queryParams: {'empresaId': empresaId, 'anio': anio, 'mes': mes},
      timeoutSeconds: _kTimeoutListado,
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => AbastecimientoDieselListaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Sin caché acá: guardar la foto ya descargada en disco (para que también
  // se pueda ver sin conexión más adelante) es responsabilidad del
  // Repository, no de este wrapper puro del API.
  Future<Uint8List?> obtenerFoto({required int salMatCabId, required String empresaId}) async {
    final bytes = await _apiService.getBytes(
      'api/AbastecimientoDiesel/Foto/$salMatCabId',
      queryParams: {'empresaId': empresaId},
    );
    return bytes;
  }

  // PDF imprimible del Parte de Salida. No se cachea (a diferencia de la
  // foto): imprimir es una acción puntual, no algo que se necesite ver
  // offline más tarde.
  Future<Uint8List?> obtenerPdfParte({required int salMatCabId, required String empresaId}) async {
    final bytes = await _apiService.getBytes(
      'api/AbastecimientoDiesel/ImprimirParte/$salMatCabId',
      queryParams: {'empresaId': empresaId},
    );
    return bytes;
  }

  Future<double?> obtenerStock({required String empresaId}) async {
    final response = await _apiService.get(
      'api/AbastecimientoDiesel/Stock',
      queryParams: {'empresaId': empresaId},
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return null;

    final stock = response['stock'];
    if (stock == null) return null;
    return (stock as num).toDouble();
  }

  Future<ItemAlmacen?> obtenerItemAlmacen({
    required String codigoItem,
    required String empresaId,
  }) async {
    final response = await _apiService.get(
      'api/ItemAlmacen/ObtenerPorCodigo',
      queryParams: {
        'codigoItem': codigoItem,
        'empresaId': empresaId,
      },
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return null;

    final itemJson = response['item'] as Map<String, dynamic>?;
    if (itemJson == null) return null;

    return ItemAlmacen.fromJson(itemJson);
  }

  // timeoutSeconds: por defecto corto (búsqueda interactiva, con fallback a
  // la copia local). La sincronización masiva (filtro vacío, ver
  // AbastecimientoDieselRepository) pasa un valor más generoso explícito —
  // son ~379 filas, no hace falta tanto como choferes, pero sí más que una
  // búsqueda puntual mientras el usuario escribe.
  Future<List<CentroCosto>> buscarCentroCosto({
    required String filtro,
    required String empresaId,
    String cenCostCost = '81',
    int timeoutSeconds = _kTimeoutListado,
  }) async {
    final response = await _apiService.get(
      'api/CentroCosto/Buscar',
      queryParams: {
        'filtro': filtro,
        'empresaId': empresaId,
        'cenCostCost': cenCostCost,
      },
      timeoutSeconds: timeoutSeconds,
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CentroCosto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Todas las jefaturas activas de una sola vez — usado para sincronizar el
  // catálogo local completo (ver AbastecimientoDieselRepository), en vez de
  // pedir la jefatura de cada Centro de Costo una por una.
  Future<List<Jefatura>> obtenerTodasLasJefaturas({required String empresaId}) async {
    final response = await _apiService.get(
      'api/Jefatura/Todas',
      queryParams: {'empresaId': empresaId},
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Jefatura.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Chofer>> buscarChofer({
    required String filtro,
    required String empresaId,
  }) async {
    final response = await _apiService.get(
      'api/Trabajador/Buscar',
      queryParams: {
        'filtro': filtro,
        'empresaId': empresaId,
      },
      timeoutSeconds: _kTimeoutListado,
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Chofer.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Todos los trabajadores activos de una sola vez — usado para sincronizar
  // el catálogo local completo (ver AbastecimientoDieselRepository), en vez
  // de depender del tope de la búsqueda en vivo. Timeout más largo que el
  // normal (90s vs. 30s): es una llamada de fondo (no bloquea ninguna
  // pantalla) que trae +9,000 filas — con una conexión mobile lenta, 30s
  // puede no alcanzar y cortar la sincronización a medias.
  Future<List<Chofer>> obtenerTodosLosChoferes({required String empresaId}) async {
    final response = await _apiService.get(
      'api/Trabajador/Todos',
      queryParams: {'empresaId': empresaId},
      timeoutSeconds: 90,
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Chofer.fromJson(e as Map<String, dynamic>)).toList();
  }
}
