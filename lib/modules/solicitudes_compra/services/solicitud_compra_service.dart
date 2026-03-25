import '../models/solicitud_compra.dart';
import '../../../core/services/api_service.dart';

class SolicitudCompraService {
  final ApiService _apiService = ApiService();

  /// Tab 1 → PorAutorizar / Tab 2 → Autorizados
  Future<SolicitudCompraAutorizacionResponse> obtenerListasAutorizacion({
    required String usuario,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.get(
        'api/solicitud-compra/grillas/autorizacion',
        queryParams: {
          'usuario': usuario,
          'empresaId': empresaId,
        },
      );

      // Normaliza por si la API devuelve data/envuelto
      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final normalized = <String, dynamic>{
        'baseResponse': response['baseResponse'] ?? response,
        'porAutorizar': data['porAutorizar'] ?? response['porAutorizar'] ?? [],
        'autorizados': data['autorizados'] ?? response['autorizados'] ?? [],
      };

      return SolicitudCompraAutorizacionResponse.fromJson(normalized);
    } catch (e) {
      return SolicitudCompraAutorizacionResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error: $e',
        ),
        porAutorizar: const [],
        autorizados: const [],
      );
    }
  }

  /// Detalle para el modal
  Future<SolicitudCompraDetalleResponse> obtenerDetalle({
    required String solComCabId,
    required int tipOpeCompId,
    required String usuario,
    required String empresaId,
  }) async {
    try {
      final response = await _apiService.get(
        'api/solicitud-compra/$solComCabId/detalle',
        queryParams: {
          'tipOpeCompId': tipOpeCompId.toString(),
          'usuario': usuario,
          'empresaId': empresaId,
        },
      );

      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final normalized = <String, dynamic>{
        'baseResponse': response['baseResponse'] ?? response,
        'encabezado': data['encabezado'] ?? data['Encabezado'] ?? response['encabezado'] ?? response['Encabezado'],
        'detalle': data['detalle'] ?? data['Detalle'] ?? response['detalle'] ?? response['Detalle'] ?? [],
      };

      return SolicitudCompraDetalleResponse.fromJson(normalized);
    } catch (e) {
      return SolicitudCompraDetalleResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error: $e',
        ),
        detalle: const [],
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

  /// Obtiene lista de solicitudes pendientes de autorización
  Future<SolicitudListResponse> obtenerSolicitudesPendientes({
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

      return SolicitudListResponse.fromJson(response);
    } catch (e) {
      return SolicitudListResponse(
        success: false,
        message: 'Error al obtener solicitudes: $e',
        solicitudes: const [],
        totalRegistros: 0,
      );
    }
  }

  /// Obtiene lista de solicitudes autorizadas por el usuario
  Future<SolicitudListResponse> obtenerSolicitudesAutorizadas({
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

      return SolicitudListResponse.fromJson(response);
    } catch (e) {
      return SolicitudListResponse(
        success: false,
        message: 'Error al obtener solicitudes: $e',
        solicitudes: const [],
        totalRegistros: 0,
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