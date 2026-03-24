import '../models/presupuesto_emergencia.dart';
import '../../../core/services/api_service.dart';

class PresupuestoEmergenciaService {
  final ApiService _apiService = ApiService();

  /// Tab 1 → PorAutorizar / Tab 2 → Autorizados
  Future<PresupuestoEmergenciaAutorizacionResponse> obtenerListasAutorizacion({
    required String usuario,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.get(
        'api/presupuesto-emergencia/grillas/autorizacion',
        queryParams: {
          'usuario': usuario,
          'empresaId': empresaId,
        },
      );

      // Normaliza por si tu API devuelve data/envuelto
      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final normalized = <String, dynamic>{
        'baseResponse': response['baseResponse'] ?? response,
        'porAutorizar': data['porAutorizar'] ?? response['porAutorizar'] ?? [],
        'autorizados': data['autorizados'] ?? response['autorizados'] ?? [],
      };

      return PresupuestoEmergenciaAutorizacionResponse.fromJson(normalized);
    } catch (e) {
      return PresupuestoEmergenciaAutorizacionResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error: $e',
        ),
        porAutorizar: const [],
        autorizados: const [],
      );
    }
  }

  /// Detalle para el diálogo
  Future<PresupuestoEmergenciaDetalleResponse> obtenerDetalle({
    required int id,
    required int idSubtipo,
    required String usuario,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.get(
        'api/presupuesto-emergencia/$id/detalle',
        queryParams: {
          'idSubtipo': idSubtipo.toString(),
          'usuario': usuario,
          'empresaId': empresaId,
        },
      );

      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final normalized = <String, dynamic>{
        'baseResponse': response['baseResponse'] ?? response,
        'encabezado': data['encabezado'] ?? response['encabezado'],
        'detalle': data['detalle'] ?? response['detalle'] ?? [],
      };

      return PresupuestoEmergenciaDetalleResponse.fromJson(normalized);
    } catch (e) {
      return PresupuestoEmergenciaDetalleResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error: $e',
        ),
        detalle: const [],
      );
    }
  }

  /// Obtiene lista de presupuestos pendientes de autorización
  Future<PresupuestoListResponse> obtenerPresupuestosPendientes({
    required String trabId,
    required String empresaId,
    String? prioridad,
  }) async {
    try {
      final response = await _apiService.post(
        'api/PresupuestoEmergencia/ObtenerListaAutorizar',
        {
          'trabId': trabId,
          'empresaId': empresaId,
          'estado': 'PENDIENTE',
          if (prioridad != null && prioridad != 'TODOS') 'prioridad': prioridad,
        },
      );

      return PresupuestoListResponse.fromJson(response);
    } catch (e) {
      return PresupuestoListResponse(
        success: false,
        message: 'Error al obtener presupuestos: $e',
        presupuestos: const [],
        totalRegistros: 0,
      );
    }
  }

  /// Obtiene lista de presupuestos autorizados por el usuario
  Future<PresupuestoListResponse> obtenerPresupuestosAutorizados({
    required String trabId,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.post(
        'api/PresupuestoEmergencia/ObtenerListaAutorizar',
        {
          'trabId': trabId,
          'empresaId': empresaId,
          'estado': 'AUTORIZADO',
        },
      );

      return PresupuestoListResponse.fromJson(response);
    } catch (e) {
      return PresupuestoListResponse(
        success: false,
        message: 'Error al obtener presupuestos: $e',
        presupuestos: const [],
        totalRegistros: 0,
      );
    }
  }

  /// Obtiene el detalle completo de un presupuesto
  Future<PresupuestoDetalleResponse> obtenerDetalle1({
    required String presupId,
    required String trabId,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.post(
        'api/PresupuestoEmergencia/ObtenerDetalle',
        {
          'presupId': presupId,
          'trabId': trabId,
          'empresaId': empresaId,
        },
      );

      return PresupuestoDetalleResponse.fromJson(response);
    } catch (e) {
      return PresupuestoDetalleResponse(
        success: false,
        message: 'Error al obtener detalle: $e',
      );
    }
  }

  /// Autoriza un presupuesto de emergencia
  Future<PresupuestoActionResponse> autorizarPresupuesto({
    required String presupId,
    required String trabId,
    required String empresaId,
    required int nivelAutorizacion,
    String? observacion,
  }) async {
    try {
      final response = await _apiService.post(
        'api/PresupuestoEmergencia/Autorizar',
        {
          'presupId': presupId,
          'trabId': trabId,
          'empresaId': empresaId,
          'nivelAutorizacion': nivelAutorizacion,
          'observacion': observacion ?? 'Autorizado conforme',
        },
      );

      return PresupuestoActionResponse.fromJson(response);
    } catch (e) {
      return PresupuestoActionResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error al autorizar: $e',
        ),
      );
    }
  }

  /// Observa un presupuesto de emergencia
  Future<PresupuestoActionResponse> observarPresupuesto({
    required String presupId,
    required String trabId,
    required String empresaId,
    required int nivelAutorizacion,
    required String motivo,
  }) async {
    try {
      final response = await _apiService.post(
        'api/PresupuestoEmergencia/Observar',
        {
          'presupId': presupId,
          'trabId': trabId,
          'empresaId': empresaId,
          'nivelAutorizacion': nivelAutorizacion,
          'motivo': motivo,
        },
      );

      return PresupuestoActionResponse.fromJson(response);
    } catch (e) {
      return PresupuestoActionResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error al observar: $e',
        ),
      );
    }
  }
}

/// Respuesta genérica para listas de presupuestos
class PresupuestoEmergenciaListaResponse {
  final BaseResponse baseResponse;
  final List<PresupuestoEmergenciaListaItem> presupuestos;
  final int totalRegistros;
  final int paginaActual;
  final int totalPaginas;

  PresupuestoEmergenciaListaResponse({
    required this.baseResponse,
    required this.presupuestos,
    this.totalRegistros = 0,
    this.paginaActual = 1,
    this.totalPaginas = 1,
  });

  factory PresupuestoEmergenciaListaResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawItems = data['presupuestos'] ?? data['items'] ?? data['lista'] ?? [];

    final items = (rawItems as List<dynamic>? ?? [])
        .map((e) => PresupuestoEmergenciaListaItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();

    return PresupuestoEmergenciaListaResponse(
      baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? json),
      presupuestos: items,
      totalRegistros: (data['totalRegistros'] ?? items.length) as int,
      paginaActual: (data['paginaActual'] ?? 1) as int,
      totalPaginas: (data['totalPaginas'] ?? 1) as int,
    );
  }

  bool get esExitoso => baseResponse.success;
}

/// Respuesta de acciones (autorizar / observar)
class PresupuestoActionResponse {
  final BaseResponse baseResponse;
  final String? presupId;
  final String? estado;
  final int? siguienteNivel;
  final bool? requiereMasAutorizaciones;
  final DateTime? fechaAccion;

  PresupuestoActionResponse({
    required this.baseResponse,
    this.presupId,
    this.estado,
    this.siguienteNivel,
    this.requiereMasAutorizaciones,
    this.fechaAccion,
  });

  factory PresupuestoActionResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final fecha = data['fechaAutorizacion'] ?? data['fechaObservacion'];

    return PresupuestoActionResponse(
      baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? json),
      presupId: data['presupId']?.toString(),
      estado: data['estado']?.toString(),
      siguienteNivel: (data['siguienteNivel'] as num?)?.toInt(),
      requiereMasAutorizaciones: data['requiereMasAutorizaciones'] as bool?,
      fechaAccion: fecha != null ? DateTime.tryParse(fecha.toString()) : null,
    );
  }

  bool get esExitoso => baseResponse.success;
}

/// Respuesta de detalle de presupuesto
class PresupuestoDetalleResponse {
  final bool success;
  final String? message;
  final PresupuestoEmergenciaEncabezado? encabezado;
  final List<PresupuestoEmergenciaDetalleItem> detalle;

  PresupuestoDetalleResponse({
    required this.success,
    this.message,
    this.encabezado,
    this.detalle = const [],
  });

  factory PresupuestoDetalleResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return PresupuestoDetalleResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      encabezado: data['encabezado'] != null
          ? PresupuestoEmergenciaEncabezado.fromJson(
              Map<String, dynamic>.from(data['encabezado'] as Map),
            )
          : null,
      detalle: (data['detalle'] as List<dynamic>? ?? [])
          .map((e) => PresupuestoEmergenciaDetalleItem.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }

  bool get esExitoso => success;

  double get total => detalle.fold(0, (sum, e) => sum + (e.subtotal ?? 0));

  String get totalFormateado => total.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}
