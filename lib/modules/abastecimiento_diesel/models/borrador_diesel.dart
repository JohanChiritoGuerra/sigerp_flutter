// Estado de un borrador en la cola local (Outbox):
// - pendiente: aún no se intentó enviar, o el último intento falló por
//   conexión (se puede reintentar sin más información).
// - error: el servidor lo rechazó por una regla de negocio (stock, cierre,
//   permiso, etc.) — necesita que el usuario revise el motivo antes de
//   reintentar, o elimine el borrador.
enum EstadoBorrador { pendiente, error }

class BorradorDiesel {
  final int? id;
  final String empresaId;
  final String usuaId;
  final String centroCosto;
  final String centroCostoDescripcion;
  final String choferId;
  final String choferNombre;
  final double cantidad;
  final int kilometraje;
  // Ruta de la copia PERMANENTE de la foto (ver FotoEvidenciaStorage) — no
  // la ruta temporal que entrega la cámara, que el sistema puede borrar.
  final String fotoPath;
  final DateTime creadoEn;
  final EstadoBorrador estado;
  final String? motivoError;
  // Generada una sola vez al crear el borrador y reutilizada en TODOS sus
  // reintentos — permite que el backend detecte un reintento de algo que ya
  // se procesó (ver AbastecimientoDieselRepository.registrar en Flutter y
  // AbastecimientoDieselIdempotencia en el backend). Borradores creados
  // antes de esta migración quedan con '' (se tratan como sin clave).
  final String idempotencyKey;

  BorradorDiesel({
    this.id,
    required this.empresaId,
    required this.usuaId,
    required this.centroCosto,
    required this.centroCostoDescripcion,
    required this.choferId,
    required this.choferNombre,
    required this.cantidad,
    required this.kilometraje,
    required this.fotoPath,
    required this.creadoEn,
    required this.idempotencyKey,
    this.estado = EstadoBorrador.pendiente,
    this.motivoError,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'empresaId': empresaId,
      'usuaId': usuaId,
      'centroCosto': centroCosto,
      'centroCostoDescripcion': centroCostoDescripcion,
      'choferId': choferId,
      'choferNombre': choferNombre,
      'cantidad': cantidad,
      'kilometraje': kilometraje,
      'fotoPath': fotoPath,
      'creadoEn': creadoEn.toIso8601String(),
      'estado': estado.name,
      'motivoError': motivoError,
      'idempotencyKey': idempotencyKey,
    };
  }

  factory BorradorDiesel.fromMap(Map<String, dynamic> map) {
    return BorradorDiesel(
      id: map['id'] as int?,
      empresaId: map['empresaId'] as String,
      usuaId: map['usuaId'] as String,
      centroCosto: map['centroCosto'] as String,
      centroCostoDescripcion: (map['centroCostoDescripcion'] as String?) ?? '',
      choferId: map['choferId'] as String,
      choferNombre: (map['choferNombre'] as String?) ?? '',
      cantidad: (map['cantidad'] as num).toDouble(),
      kilometraje: map['kilometraje'] as int,
      fotoPath: map['fotoPath'] as String,
      creadoEn: DateTime.parse(map['creadoEn'] as String),
      estado: EstadoBorrador.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoBorrador.pendiente,
      ),
      motivoError: map['motivoError'] as String?,
      idempotencyKey: (map['idempotencyKey'] as String?) ?? '',
    );
  }
}
