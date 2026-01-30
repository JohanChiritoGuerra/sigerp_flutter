import '../models/presupuesto_emergencia.dart';
import '../../../core/services/api_service.dart';

class PresupuestoEmergenciaService {
  final ApiService _apiService = ApiService();

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
        presupuestos: [],
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
        presupuestos: [],
      );
    }
  }

  /// Obtiene el detalle completo de un presupuesto
  Future<PresupuestoDetalleResponse> obtenerDetalle({
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
        success: false,
        message: 'Error al autorizar: $e',
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
        success: false,
        message: 'Error al observar: $e',
      );
    }
  }
}

/// Respuesta de lista de presupuestos
class PresupuestoListResponse {
  final bool success;
  final String? message;
  final List<PresupuestoEmergencia> presupuestos;
  final int totalRegistros;
  final int paginaActual;
  final int totalPaginas;

  PresupuestoListResponse({
    required this.success,
    this.message,
    required this.presupuestos,
    this.totalRegistros = 0,
    this.paginaActual = 1,
    this.totalPaginas = 1,
  });

  factory PresupuestoListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<PresupuestoEmergencia> presupuestos = [];

    if (data != null && data['presupuestos'] != null) {
      presupuestos = (data['presupuestos'] as List)
          .map((p) => PresupuestoEmergencia.fromJson(p))
          .toList();
    }

    return PresupuestoListResponse(
      success: json['success'] ?? false,
      message: json['message'],
      presupuestos: presupuestos,
      totalRegistros: data?['totalRegistros'] ?? presupuestos.length,
      paginaActual: data?['paginaActual'] ?? 1,
      totalPaginas: data?['totalPaginas'] ?? 1,
    );
  }

  bool get esExitoso => success;
}

/// Respuesta de detalle de presupuesto
class PresupuestoDetalleResponse {
  final bool success;
  final String? message;
  final PresupuestoEmergencia? presupuesto;

  PresupuestoDetalleResponse({
    required this.success,
    this.message,
    this.presupuesto,
  });

  factory PresupuestoDetalleResponse.fromJson(Map<String, dynamic> json) {
    return PresupuestoDetalleResponse(
      success: json['success'] ?? false,
      message: json['message'],
      presupuesto: json['data'] != null
          ? PresupuestoEmergencia.fromJson(json['data'])
          : null,
    );
  }

  bool get esExitoso => success;
}

/// Respuesta de acciones (autorizar/observar)
class PresupuestoActionResponse {
  final bool success;
  final String? message;
  final String? presupId;
  final String? estado;
  final int? siguienteNivel;
  final bool? requiereMasAutorizaciones;
  final DateTime? fechaAccion;

  PresupuestoActionResponse({
    required this.success,
    this.message,
    this.presupId,
    this.estado,
    this.siguienteNivel,
    this.requiereMasAutorizaciones,
    this.fechaAccion,
  });

  factory PresupuestoActionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return PresupuestoActionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      presupId: data?['presupId'],
      estado: data?['estado'],
      siguienteNivel: data?['siguienteNivel'],
      requiereMasAutorizaciones: data?['requiereMasAutorizaciones'],
      fechaAccion: data?['fechaAutorizacion'] != null
          ? DateTime.tryParse(data['fechaAutorizacion'])
          : (data?['fechaObservacion'] != null
              ? DateTime.tryParse(data['fechaObservacion'])
              : null),
    );
  }

  bool get esExitoso => success;
}
