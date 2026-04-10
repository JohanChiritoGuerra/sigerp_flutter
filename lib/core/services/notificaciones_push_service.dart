import 'package:flutter/foundation.dart';
import '../models/notificacion_push.dart';
import 'api_service.dart';

class NotificacionesPushService {
  final ApiService _api = ApiService();

  /// Consulta las notificaciones no leídas del usuario desde la BD.
  Future<ConsultarNotificacionesResponse> consultarNoLeidas({
    required String usuaId,
    required String empresaId,
    int pagina = 1,
    int registros = 50,
  }) async {
    try {
      final response = await _api.get(
        'api/Notificaciones/consultar',
        queryParams: {
          'usuaId':        usuaId,
          'empresaId':     empresaId,
          'soloNoLeidas':  'true',
          'pagina':        pagina.toString(),
          'registros':     registros.toString(),
        },
      );
      return ConsultarNotificacionesResponse.fromJson(response);
    } catch (e) {
      debugPrint('❌ [NotificacionesPushService] Error consultando: $e');
      return ConsultarNotificacionesResponse(
        esExitoso: false,
        notificaciones: [],
        totalRegistros: 0,
      );
    }
  }

  /// Marca una notificación como leída en la BD.
  Future<bool> marcarLeida({
    required int idNotificacion,
    required String usuaId,
    required String empresaId,
  }) async {
    try {
      await _api.post('api/Notificaciones/marcar-leida', {
        'idNotificacion': idNotificacion,
        'usuaId':         usuaId,
        'empresaId':      empresaId,
      });
      return true;
    } catch (e) {
      debugPrint('❌ [NotificacionesPushService] Error marcando leída: $e');
      return false;
    }
  }
}
