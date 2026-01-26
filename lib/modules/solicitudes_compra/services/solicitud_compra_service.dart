import '../models/solicitud_compra.dart';
import '../../../core/services/api_service.dart';

class SolicitudCompraService {
  final ApiService _apiService = ApiService();

  /// Obtiene lista de solicitudes pendientes de autorización
  Future<SolicitudCompraListResponse> obtenerSolicitudesPendientes({
    required String trabId,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.post(
        'api/SolicitudCompra/ObtenerListaAutorizar',
        {
          'trabId': trabId,
          'empresaId': empresaId,
          'estado': 'PENDIENTE',
        },
      );

      return SolicitudCompraListResponse.fromJson(response);
    } catch (e) {
      return SolicitudCompraListResponse(
        success: false,
        message: 'Error al obtener solicitudes: $e',
        solicitudes: [],
      );
    }
  }

  /// Obtiene lista de solicitudes autorizadas por el usuario
  Future<SolicitudCompraListResponse> obtenerSolicitudesAutorizadas({
    required String trabId,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.post(
        'api/SolicitudCompra/ObtenerListaAutorizar',
        {
          'trabId': trabId,
          'empresaId': empresaId,
          'estado': 'AUTORIZADO',
        },
      );

      return SolicitudCompraListResponse.fromJson(response);
    } catch (e) {
      return SolicitudCompraListResponse(
        success: false,
        message: 'Error al obtener solicitudes: $e',
        solicitudes: [],
      );
    }
  }

  /// Autoriza una solicitud de compra
  Future<SolicitudCompraActionResponse> autorizarSolicitud({
    required String solicitudId,
    required String trabId,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.post(
        'api/SolicitudCompra/Autorizar',
        {
          'solicitudId': solicitudId,
          'trabId': trabId,
          'empresaId': empresaId,
        },
      );

      return SolicitudCompraActionResponse.fromJson(response);
    } catch (e) {
      return SolicitudCompraActionResponse(
        success: false,
        message: 'Error al autorizar: $e',
      );
    }
  }

  /// Observa una solicitud de compra
  Future<SolicitudCompraActionResponse> observarSolicitud({
    required String solicitudId,
    required String trabId,
    required String empresaId,
    required String motivo,
  }) async {
    try {
      final response = await _apiService.post(
        'api/SolicitudCompra/Observar',
        {
          'solicitudId': solicitudId,
          'trabId': trabId,
          'empresaId': empresaId,
          'motivo': motivo,
        },
      );

      return SolicitudCompraActionResponse.fromJson(response);
    } catch (e) {
      return SolicitudCompraActionResponse(
        success: false,
        message: 'Error al observar: $e',
      );
    }
  }
}

/// Respuesta de lista de solicitudes
class SolicitudCompraListResponse {
  final bool success;
  final String? message;
  final List<SolicitudCompra> solicitudes;
  final int totalRegistros;

  SolicitudCompraListResponse({
    required this.success,
    this.message,
    required this.solicitudes,
    this.totalRegistros = 0,
  });

  factory SolicitudCompraListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<SolicitudCompra> solicitudes = [];

    if (data != null && data['solicitudes'] != null) {
      solicitudes = (data['solicitudes'] as List)
          .map((s) => SolicitudCompra.fromJson(s))
          .toList();
    }

    return SolicitudCompraListResponse(
      success: json['success'] ?? false,
      message: json['message'],
      solicitudes: solicitudes,
      totalRegistros: data?['totalRegistros'] ?? solicitudes.length,
    );
  }

  bool get esExitoso => success;
}

/// Respuesta de acciones (autorizar/observar)
class SolicitudCompraActionResponse {
  final bool success;
  final String? message;
  final String? solicitudId;
  final String? estado;
  final DateTime? fechaAccion;

  SolicitudCompraActionResponse({
    required this.success,
    this.message,
    this.solicitudId,
    this.estado,
    this.fechaAccion,
  });

  factory SolicitudCompraActionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SolicitudCompraActionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      solicitudId: data?['solicitudId'],
      estado: data?['estado'],
      fechaAccion: data?['fechaAutorizacion'] != null
          ? DateTime.tryParse(data['fechaAutorizacion'])
          : (data?['fechaObservacion'] != null
              ? DateTime.tryParse(data['fechaObservacion'])
              : null),
    );
  }

  bool get esExitoso => success;
}
