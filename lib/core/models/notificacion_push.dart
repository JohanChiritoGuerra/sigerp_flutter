class NotificacionPush {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String? idReferencia;
  final bool leida;
  final DateTime fechaRegistro;
  final DateTime? fechaEnvio;

  NotificacionPush({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.idReferencia,
    required this.leida,
    required this.fechaRegistro,
    this.fechaEnvio,
  });

  factory NotificacionPush.fromJson(Map<String, dynamic> json) {
    return NotificacionPush(
      id:            json['id'] as int,
      titulo:        json['titulo']?.toString() ?? '',
      mensaje:       json['mensaje']?.toString() ?? '',
      tipo:          json['tipo']?.toString() ?? '',
      idReferencia:  json['idReferencia']?.toString(),
      leida:         json['leida'] == true,
      fechaRegistro: DateTime.tryParse(json['fechaRegistro']?.toString() ?? '') ?? DateTime.now(),
      fechaEnvio:    json['fechaEnvio'] != null
          ? DateTime.tryParse(json['fechaEnvio'].toString())
          : null,
    );
  }
}

class ConsultarNotificacionesResponse {
  final bool esExitoso;
  final List<NotificacionPush> notificaciones;
  final int totalRegistros;

  ConsultarNotificacionesResponse({
    required this.esExitoso,
    required this.notificaciones,
    required this.totalRegistros,
  });

  factory ConsultarNotificacionesResponse.fromJson(Map<String, dynamic> json) {
    final base = json['baseResponse'] as Map<String, dynamic>?;
    final lista = (json['notificaciones'] as List<dynamic>? ?? [])
        .map((e) => NotificacionPush.fromJson(e as Map<String, dynamic>))
        .toList();
    return ConsultarNotificacionesResponse(
      esExitoso:      base?['success'] == true,
      notificaciones: lista,
      totalRegistros: json['totalRegistros'] as int? ?? lista.length,
    );
  }
}
