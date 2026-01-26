import 'package:flutter/material.dart';

/// Tipos de solicitud de compra
enum TipoSolicitudCompra {
  compraMateriales,
  compraActivoFijo,
  servicioTercero,
  cargaDiversaGestion,
}

extension TipoSolicitudCompraExtension on TipoSolicitudCompra {
  String get nombre {
    switch (this) {
      case TipoSolicitudCompra.compraMateriales:
        return 'COMPRA DE MATERIALES';
      case TipoSolicitudCompra.compraActivoFijo:
        return 'COMPRA DE ACTIVO FIJO';
      case TipoSolicitudCompra.servicioTercero:
        return 'SERVICIO DE TERCERO';
      case TipoSolicitudCompra.cargaDiversaGestion:
        return 'CARGA DIVERSA DE GESTIÓN';
    }
  }

  String get codigo {
    switch (this) {
      case TipoSolicitudCompra.compraMateriales:
        return 'CM';
      case TipoSolicitudCompra.compraActivoFijo:
        return 'AF';
      case TipoSolicitudCompra.servicioTercero:
        return 'ST';
      case TipoSolicitudCompra.cargaDiversaGestion:
        return 'CD';
    }
  }

  Color get color {
    switch (this) {
      case TipoSolicitudCompra.compraMateriales:
        return const Color(0xFF1565C0); // Azul principal
      case TipoSolicitudCompra.compraActivoFijo:
        return const Color(0xFFE65100); // Naranja oscuro
      case TipoSolicitudCompra.servicioTercero:
        return const Color(0xFF2E7D32); // Verde
      case TipoSolicitudCompra.cargaDiversaGestion:
        return const Color(0xFF5E35B1); // Púrpura profundo
    }
  }

  /// Color oscuro para títulos en el modal
  Color get colorOscuro {
    switch (this) {
      case TipoSolicitudCompra.compraMateriales:
        return const Color(0xFF0D47A1); // Azul muy oscuro
      case TipoSolicitudCompra.compraActivoFijo:
        return const Color(0xFFBF360C); // Naranja muy oscuro
      case TipoSolicitudCompra.servicioTercero:
        return const Color(0xFF1B5E20); // Verde muy oscuro
      case TipoSolicitudCompra.cargaDiversaGestion:
        return const Color(0xFF311B92); // Púrpura muy oscuro
    }
  }

  Color get backgroundColor {
    return color.withOpacity(0.1);
  }

  IconData get icon {
    switch (this) {
      case TipoSolicitudCompra.compraMateriales:
        return Icons.inventory_2;
      case TipoSolicitudCompra.compraActivoFijo:
        return Icons.precision_manufacturing;
      case TipoSolicitudCompra.servicioTercero:
        return Icons.engineering;
      case TipoSolicitudCompra.cargaDiversaGestion:
        return Icons.category;
    }
  }

  static TipoSolicitudCompra fromCodigo(String? codigo) {
    switch (codigo?.toUpperCase()) {
      case 'CM':
        return TipoSolicitudCompra.compraMateriales;
      case 'AF':
        return TipoSolicitudCompra.compraActivoFijo;
      case 'ST':
        return TipoSolicitudCompra.servicioTercero;
      case 'CD':
        return TipoSolicitudCompra.cargaDiversaGestion;
      default:
        return TipoSolicitudCompra.compraMateriales;
    }
  }
}

/// Estados de solicitud
enum EstadoSolicitud {
  pendiente,
  autorizado,
  observado,
  enProceso,
}

extension EstadoSolicitudExtension on EstadoSolicitud {
  static EstadoSolicitud fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDIENTE':
        return EstadoSolicitud.pendiente;
      case 'AUTORIZADO':
        return EstadoSolicitud.autorizado;
      case 'OBSERVADO':
        return EstadoSolicitud.observado;
      case 'EN_PROCESO':
        return EstadoSolicitud.enProceso;
      default:
        return EstadoSolicitud.pendiente;
    }
  }

  String get nombre {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return 'PENDIENTE';
      case EstadoSolicitud.autorizado:
        return 'AUTORIZADO';
      case EstadoSolicitud.observado:
        return 'OBSERVADO';
      case EstadoSolicitud.enProceso:
        return 'EN PROCESO';
    }
  }
}

/// Item de solicitud
class ItemSolicitud {
  final String id;
  final String codigo; // Código de 8 caracteres
  final String descripcion;
  final String unidadMedida; // Unidad de medida abreviada (UND, KG, LT, etc.)
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  ItemSolicitud({
    required this.id,
    this.codigo = '',
    required this.descripcion,
    this.unidadMedida = 'UND',
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory ItemSolicitud.fromJson(Map<String, dynamic> json) {
    final cantidad = json['cantidad'] ?? 1;
    final precioUnitario = (json['precioUnitario'] as num?)?.toDouble() ?? 0.0;
    return ItemSolicitud(
      id: json['itemId'] ?? '',
      codigo: json['codigo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      unidadMedida: json['unidadMedida'] ?? 'UND',
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: precioUnitario * cantidad,
    );
  }

  /// Formato de precio unitario
  String get precioUnitarioFormateado {
    return precioUnitario.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Formato de subtotal
  String get subtotalFormateado {
    return subtotal.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// Modelo principal de Solicitud de Compra
class SolicitudCompra {
  final String id;
  final String codigo;
  final TipoSolicitudCompra tipo;
  final String areaSolicitante;
  final String solicitanteNombre;
  final String solicitanteId;
  final DateTime fechaSolicitud;
  final double montoTotal;
  final String? sustento;
  final List<ItemSolicitud> items;
  final EstadoSolicitud estado;

  SolicitudCompra({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.areaSolicitante,
    required this.solicitanteNombre,
    required this.solicitanteId,
    required this.fechaSolicitud,
    required this.montoTotal,
    this.sustento,
    required this.items,
    required this.estado,
  });

  factory SolicitudCompra.fromJson(Map<String, dynamic> json) {
    return SolicitudCompra(
      id: json['solicitudId'] ?? '',
      codigo: json['codigo'] ?? '',
      tipo: TipoSolicitudCompraExtension.fromCodigo(json['tipoSolicitud']),
      areaSolicitante: json['areaSolicitante'] ?? '',
      solicitanteNombre: json['solicitante']?['nombreCompleto'] ?? '',
      solicitanteId: json['solicitante']?['trabId'] ?? '',
      fechaSolicitud: DateTime.tryParse(json['fechaSolicitud'] ?? '') ?? DateTime.now(),
      montoTotal: (json['montoTotal'] as num?)?.toDouble() ?? 0.0,
      sustento: json['sustento'] ?? json['observaciones'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ItemSolicitud.fromJson(item))
              .toList() ??
          [],
      estado: EstadoSolicitudExtension.fromString(json['estado']),
    );
  }

  /// Formato de fecha corta dd/MM/yyyy
  String get fechaFormateada {
    return '${fechaSolicitud.day.toString().padLeft(2, '0')}/${fechaSolicitud.month.toString().padLeft(2, '0')}/${fechaSolicitud.year}';
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
