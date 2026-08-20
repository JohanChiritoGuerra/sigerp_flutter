// Estado de un borrador en la cola local (Outbox):
// - pendiente: aún no se intentó enviar, o el último intento falló por
//   conexión (se puede reintentar sin más información).
// - error: el servidor lo rechazó por una regla de negocio permanente
//   (cierre, permiso, configuración faltante, etc.) — necesita que el
//   usuario revise el motivo antes de reintentar, o elimine el borrador.
// - esperandoStock: el servidor lo rechazó puntualmente por falta de stock
//   — a diferencia de "error", esto no es algo que el usuario tenga que
//   corregir ni algo roto: es un recurso que se repone solo con el tiempo,
//   así que se trata más como "pendiente" (reintentable sin más) pero con su
//   propio ícono/texto para no confundirlo con "sin conexión".
enum EstadoBorrador { pendiente, error, esperandoStock }

class BorradorDiesel {
  final int? id;
  final String empresaId;
  final String usuaId;
  final String centroCosto;
  final String centroCostoDescripcion;
  final String choferId;
  final String choferNombre;
  final double cantidad;
  // Fecha del abastecimiento elegida por el chofer (puede ser distinta al
  // día en que el borrador realmente se crea/reintenta) — se reenvía tal
  // cual en cada reintento, nunca se reemplaza por "hoy".
  final DateTime fecha;
  // Al menos uno de los dos debe venir con dato — nunca los dos null a la
  // vez (ya se valida en el formulario antes de llegar acá).
  final int? kilometraje;
  final double? horometro;
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
    required this.fecha,
    required this.kilometraje,
    required this.horometro,
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
      'fecha': fecha.toIso8601String(),
      'kilometraje': kilometraje,
      'horometro': horometro,
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
      // Borradores creados antes de esta migración no tienen 'fecha' guardada
      // — caen a creadoEn (lo más parecido a "qué día se registró" que existía).
      fecha: map['fecha'] != null ? DateTime.parse(map['fecha'] as String) : DateTime.parse(map['creadoEn'] as String),
      kilometraje: map['kilometraje'] as int?,
      horometro: (map['horometro'] as num?)?.toDouble(),
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
