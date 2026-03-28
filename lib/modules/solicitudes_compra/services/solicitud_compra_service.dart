import '../models/solicitud_compra.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/device_info_helper.dart';

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

  /// Consulta: Tab 1 → PorAutorizar / Tab 2 → Autorizados / Tab 3 → AnuladosRechazados
  Future<SolicitudCompraConsultaResponse> obtenerListasConsulta({
  required String usuario,
  required String empresaId,
  }) async {
    try {
      final response = await _apiService.get(
        'api/solicitud-compra-consulta/grillas/consulta',
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
        'anuladosRechazados': data['anuladosRechazados'] ?? response['anuladosRechazados'] ?? [],
      };

      return SolicitudCompraConsultaResponse.fromJson(normalized);
    } catch (e) {
      return SolicitudCompraConsultaResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error: $e',
        ),
        porAutorizar: const [],
        autorizados: const [],
        anuladosRechazados: const [],
      );
    }
  }

  /// Detalle para consulta (usa el endpoint de consulta)
  Future<SolicitudCompraDetalleResponse> obtenerDetalleConsulta({
    required String solComCabId,
    required int tipOpeCompId,
    required String usuario,
    required String empresaId,
    }) async {
    try {
      final response = await _apiService.get(
        'api/solicitud-compra-consulta/$solComCabId/detalle',
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
  Future<AutorizarSolicitudResponse> autorizarSolicitud({
    required String solComCabId,
    required int tipOpeCompId,
    required String usuario,
    required String empresaId,
  }) async {
    try {
      final nombrePc = await DeviceInfoHelper.getNombreDispositivo();

      final response = await _apiService.post(
        'api/solicitud-compra/autorizar',
        {
          'solComCabId': solComCabId,
          'tipOpeCompId': tipOpeCompId,
          'usuario': usuario,
          'ip': '0.0.0.0',
          'nombrePc': nombrePc,
        },
      );

      return AutorizarSolicitudResponse.fromJson(response);
    } catch (e) {
      return AutorizarSolicitudResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error al autorizar: $e',
        ),
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
  Future<ObservarSolicitudResponse> observarSolicitud({
    required String solComCabId,
    required int tipOpeCompId,
    required String observacion,
    required String usuario,
    required String empresaId,
  }) async {
    try {
      final nombrePc = await DeviceInfoHelper.getNombreDispositivo();

      final response = await _apiService.post(
        'api/solicitud-compra/observar',
        {
          'solComCabId': solComCabId,
          'tipOpeCompId': tipOpeCompId,
          'observacion': observacion,
          'usuario': usuario,
          'ip': '0.0.0.0',
          'nombrePc': nombrePc,
        },
      );

      return ObservarSolicitudResponse.fromJson(response);
    } catch (e) {
      return ObservarSolicitudResponse(
        baseResponse: BaseResponse(
          success: false,
          message: 'Error al observar: $e',
        ),
      );
    }
  }
}