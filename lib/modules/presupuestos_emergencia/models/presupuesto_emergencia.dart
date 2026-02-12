import 'package:flutter/material.dart';

/// Tipo de presupuesto de emergencia
enum TipoPresupuestoEmergencia {
  consumo,
  inversiones,
  servicioTercero;

  static TipoPresupuestoEmergencia fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CONSUMO':
        return TipoPresupuestoEmergencia.consumo;
      case 'INVERSIONES':
        return TipoPresupuestoEmergencia.inversiones;
      case 'SERVICIO_TERCERO':
      case 'SERVICIO TERCERO':
        return TipoPresupuestoEmergencia.servicioTercero;
      default:
        return TipoPresupuestoEmergencia.consumo;
    }
  }

  String get label {
    switch (this) {
      case TipoPresupuestoEmergencia.consumo:
        return 'PPTO. EMERGENCIA - CONSUMO';
      case TipoPresupuestoEmergencia.inversiones:
        return 'PPTO. EMERGENCIA - INVERSIONES';
      case TipoPresupuestoEmergencia.servicioTercero:
        return 'PPTO. EMERGENCIA - SERVICIO TERCERO';
    }
  }

  String get labelCorto {
    switch (this) {
      case TipoPresupuestoEmergencia.consumo:
        return 'CONSUMO';
      case TipoPresupuestoEmergencia.inversiones:
        return 'INVERSIONES';
      case TipoPresupuestoEmergencia.servicioTercero:
        return 'SERVICIO TERCERO';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoPresupuestoEmergencia.consumo:
        return Icons.inventory_2_outlined;
      case TipoPresupuestoEmergencia.inversiones:
        return Icons.trending_up_rounded;
      case TipoPresupuestoEmergencia.servicioTercero:
        return Icons.engineering_outlined;
    }
  }

  Color get iconColor {
    switch (this) {
      case TipoPresupuestoEmergencia.consumo:
        return const Color(0xFF2196F3); // Azul
      case TipoPresupuestoEmergencia.inversiones:
        return const Color(0xFF9C27B0); // Púrpura
      case TipoPresupuestoEmergencia.servicioTercero:
        return const Color(0xFFFF9800); // Naranja
    }
  }

  Color get iconBgColor {
    switch (this) {
      case TipoPresupuestoEmergencia.consumo:
        return const Color(0xFFE3F2FD);
      case TipoPresupuestoEmergencia.inversiones:
        return const Color(0xFFF3E5F5);
      case TipoPresupuestoEmergencia.servicioTercero:
        return const Color(0xFFFFF3E0);
    }
  }
}

/// Prioridades de presupuesto de emergencia
enum PrioridadPresupuesto {
  emergencia,
  urgente,
  normal;

  static PrioridadPresupuesto fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'EMERGENCIA':
        return PrioridadPresupuesto.emergencia;
      case 'URGENTE':
        return PrioridadPresupuesto.urgente;
      case 'NORMAL':
        return PrioridadPresupuesto.normal;
      default:
        return PrioridadPresupuesto.normal;
    }
  }

  /// Color rojo unificado para todos los presupuestos de emergencia
  Color get color => const Color(0xFFF44336);

  /// Color claro rojo unificado
  Color get colorClaro => const Color(0xFFFFEBEE);

  String get label {
    switch (this) {
      case PrioridadPresupuesto.emergencia:
        return 'EMERGENCIA';
      case PrioridadPresupuesto.urgente:
        return 'URGENTE';
      case PrioridadPresupuesto.normal:
        return 'NORMAL';
    }
  }

  IconData get icon {
    switch (this) {
      case PrioridadPresupuesto.emergencia:
        return Icons.error;
      case PrioridadPresupuesto.urgente:
        return Icons.warning_amber;
      case PrioridadPresupuesto.normal:
        return Icons.info_outline;
    }
  }
}

/// Estados de presupuesto
enum EstadoPresupuesto {
  pendiente,
  autorizado,
  observado,
  enProceso,
  enCola;

  static EstadoPresupuesto fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDIENTE':
        return EstadoPresupuesto.pendiente;
      case 'AUTORIZADO':
        return EstadoPresupuesto.autorizado;
      case 'OBSERVADO':
        return EstadoPresupuesto.observado;
      case 'EN_PROCESO':
        return EstadoPresupuesto.enProceso;
      case 'EN_COLA':
        return EstadoPresupuesto.enCola;
      default:
        return EstadoPresupuesto.pendiente;
    }
  }

  String get nombre {
    switch (this) {
      case EstadoPresupuesto.pendiente:
        return 'PENDIENTE';
      case EstadoPresupuesto.autorizado:
        return 'AUTORIZADO';
      case EstadoPresupuesto.observado:
        return 'OBSERVADO';
      case EstadoPresupuesto.enProceso:
        return 'EN PROCESO';
      case EstadoPresupuesto.enCola:
        return 'EN COLA';
    }
  }

  Color get color {
    switch (this) {
      case EstadoPresupuesto.pendiente:
        return const Color(0xFFFF9800); // Naranja
      case EstadoPresupuesto.autorizado:
        return const Color(0xFF4CAF50); // Verde
      case EstadoPresupuesto.observado:
        return const Color(0xFFF44336); // Rojo
      case EstadoPresupuesto.enProceso:
        return const Color(0xFF2196F3); // Azul
      case EstadoPresupuesto.enCola:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  IconData get icon {
    switch (this) {
      case EstadoPresupuesto.pendiente:
        return Icons.hourglass_empty;
      case EstadoPresupuesto.autorizado:
        return Icons.check_circle;
      case EstadoPresupuesto.observado:
        return Icons.cancel;
      case EstadoPresupuesto.enProceso:
        return Icons.pending;
      case EstadoPresupuesto.enCola:
        return Icons.pause_circle_outline;
    }
  }
}

/// Solicitante del presupuesto
class Solicitante {
  final String trabId;
  final String nombreCompleto;
  final String seccion;
  final String? cargo;

  Solicitante({
    required this.trabId,
    required this.nombreCompleto,
    required this.seccion,
    this.cargo,
  });

  factory Solicitante.fromJson(Map<String, dynamic> json) {
    return Solicitante(
      trabId: json['trabId'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      seccion: json['seccion'] ?? '',
      cargo: json['cargo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trabId': trabId,
      'nombreCompleto': nombreCompleto,
      'seccion': seccion,
      'cargo': cargo,
    };
  }
}

/// Item de presupuesto
class ItemPresupuesto {
  final String itemId;
  final String descripcion;
  final double monto;

  ItemPresupuesto({
    required this.itemId,
    required this.descripcion,
    required this.monto,
  });

  factory ItemPresupuesto.fromJson(Map<String, dynamic> json) {
    return ItemPresupuesto(
      itemId: json['itemId'] ?? '',
      descripcion: json['descripcion'] ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'descripcion': descripcion,
      'monto': monto,
    };
  }

  /// Formato de monto
  String get montoFormateado {
    return monto.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// Historial de autorizaciones
class AutorizacionHistorial {
  final int nivel;
  final String nombreNivel;
  final Solicitante? autorizador;
  final EstadoPresupuesto estado;
  final DateTime? fechaAccion;
  final String? observacion;

  AutorizacionHistorial({
    required this.nivel,
    required this.nombreNivel,
    this.autorizador,
    required this.estado,
    this.fechaAccion,
    this.observacion,
  });

  factory AutorizacionHistorial.fromJson(Map<String, dynamic> json) {
    return AutorizacionHistorial(
      nivel: json['nivel'] ?? 0,
      nombreNivel: json['nombreNivel'] ?? '',
      autorizador: json['autorizador'] != null
          ? Solicitante.fromJson(json['autorizador'])
          : null,
      estado: EstadoPresupuesto.fromString(json['estado']),
      fechaAccion: json['fechaAccion'] != null
          ? DateTime.tryParse(json['fechaAccion'])
          : null,
      observacion: json['observacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nivel': nivel,
      'nombreNivel': nombreNivel,
      'autorizador': autorizador?.toJson(),
      'estado': estado.nombre,
      'fechaAccion': fechaAccion?.toIso8601String(),
      'observacion': observacion,
    };
  }

  /// Formato de fecha
  String get fechaFormateada {
    if (fechaAccion == null) return '';
    final hora = fechaAccion!.hour > 12 ? fechaAccion!.hour - 12 : fechaAccion!.hour;
    final amPm = fechaAccion!.hour >= 12 ? 'PM' : 'AM';
    return '${fechaAccion!.day.toString().padLeft(2, '0')}/${fechaAccion!.month.toString().padLeft(2, '0')}/${fechaAccion!.year} • ${hora.toString().padLeft(2, '0')}:${fechaAccion!.minute.toString().padLeft(2, '0')} $amPm';
  }
}

/// Modelo principal de Presupuesto de Emergencia
class PresupuestoEmergencia {
  final String presupId;
  final String codigo;
  final PrioridadPresupuesto prioridad;
  final TipoPresupuestoEmergencia tipoPresupuesto;
  final Solicitante solicitante;
  final double montoTotal;
  final DateTime fechaSolicitud;
  final String descripcion;
  final EstadoPresupuesto estadoActual;
  final int nivelAutorizacionActual;
  final bool esmiTurno;
  final List<ItemPresupuesto>? items;
  final List<AutorizacionHistorial>? historialAutorizaciones;

  PresupuestoEmergencia({
    required this.presupId,
    required this.codigo,
    required this.prioridad,
    this.tipoPresupuesto = TipoPresupuestoEmergencia.consumo,
    required this.solicitante,
    required this.montoTotal,
    required this.fechaSolicitud,
    required this.descripcion,
    required this.estadoActual,
    required this.nivelAutorizacionActual,
    required this.esmiTurno,
    this.items,
    this.historialAutorizaciones,
  });

  factory PresupuestoEmergencia.fromJson(Map<String, dynamic> json) {
    return PresupuestoEmergencia(
      presupId: json['presupId'] ?? '',
      codigo: json['codigo'] ?? '',
      prioridad: PrioridadPresupuesto.fromString(json['prioridad']),
      tipoPresupuesto: TipoPresupuestoEmergencia.fromString(json['tipoPresupuesto']),
      solicitante: Solicitante.fromJson(json['solicitante'] ?? {}),
      montoTotal: (json['montoTotal'] as num?)?.toDouble() ?? 0.0,
      fechaSolicitud:
          DateTime.tryParse(json['fechaSolicitud'] ?? '') ?? DateTime.now(),
      descripcion: json['descripcion'] ?? '',
      estadoActual: EstadoPresupuesto.fromString(json['estadoActual']),
      nivelAutorizacionActual: json['nivelAutorizacionActual'] ?? 1,
      esmiTurno: json['esmiTurno'] ?? false,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => ItemPresupuesto.fromJson(i))
              .toList()
          : null,
      historialAutorizaciones: json['historialAutorizaciones'] != null
          ? (json['historialAutorizaciones'] as List)
              .map((h) => AutorizacionHistorial.fromJson(h))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'presupId': presupId,
      'codigo': codigo,
      'prioridad': prioridad.label,
      'tipoPresupuesto': tipoPresupuesto.labelCorto,
      'solicitante': solicitante.toJson(),
      'montoTotal': montoTotal,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'descripcion': descripcion,
      'estadoActual': estadoActual.nombre,
      'nivelAutorizacionActual': nivelAutorizacionActual,
      'esmiTurno': esmiTurno,
      'items': items?.map((i) => i.toJson()).toList(),
      'historialAutorizaciones':
          historialAutorizaciones?.map((h) => h.toJson()).toList(),
    };
  }

  /// Tiempo relativo desde la solicitud
  String get tiempoRelativo {
    final now = DateTime.now();
    final difference = now.difference(fechaSolicitud);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  /// Formato de fecha corta dd/MM/yyyy
  String get fechaFormateada {
    return '${fechaSolicitud.day.toString().padLeft(2, '0')}/${fechaSolicitud.month.toString().padLeft(2, '0')}/${fechaSolicitud.year}';
  }

  /// Formato de fecha completa
  String get fechaHoraFormateada {
    final hora = fechaSolicitud.hour > 12
        ? fechaSolicitud.hour - 12
        : fechaSolicitud.hour;
    final amPm = fechaSolicitud.hour >= 12 ? 'PM' : 'AM';
    return '${fechaSolicitud.day.toString().padLeft(2, '0')}/${fechaSolicitud.month.toString().padLeft(2, '0')}/${fechaSolicitud.year} ${hora.toString().padLeft(2, '0')}:${fechaSolicitud.minute.toString().padLeft(2, '0')} $amPm';
  }

  /// Formato de monto con separador de miles
  String get montoFormateado {
    if (montoTotal >= 1000) {
      return '${(montoTotal / 1000).toStringAsFixed(1)}K';
    }
    return montoTotal.toStringAsFixed(0);
  }

  /// Formato de monto completo
  String get montoCompletoFormateado {
    return montoTotal.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
