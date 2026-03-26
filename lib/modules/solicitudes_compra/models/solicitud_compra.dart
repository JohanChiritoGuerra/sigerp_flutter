import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── BaseResponse ─────────────────────────────────────────────────────────────
class BaseResponse {
  final bool success;
  final bool exception;
  final String? tipoException;
  final String? message;
  final List<String> errores;

  BaseResponse({
    required this.success,
    this.exception = false,
    this.tipoException,
    this.message,
    this.errores = const [],
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
    success:       json['Success']       ?? json['success']       ?? false,
    exception:     json['Exception']     ?? json['exception']     ?? false,
    tipoException: json['TipoException'] ?? json['tipoException'],
    message:       json['Message']       ?? json['message'],
    errores: ((json['Errores'] ?? json['errores']) as List<dynamic>?)
            ?.map((e) => e.toString()).toList() ?? [],
  );
}

// ─── Tipos de solicitud de compra ────────────────────────────────────────────
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
        return const Color(0xFFAB7AE0); // Morado
      case TipoSolicitudCompra.compraActivoFijo:
        return const Color(0xFFE8915A); // Naranja
      case TipoSolicitudCompra.servicioTercero:
        return const Color(0xFFE57373); // Rojo
      case TipoSolicitudCompra.cargaDiversaGestion:
        return const Color(0xFF4CAF6A); // Verde
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

  static TipoSolicitudCompra fromString(String? value) {
    if (value == null) return TipoSolicitudCompra.compraMateriales;
    
    final upper = value.toUpperCase().trim();
    
    // Códigos cortos
    if (upper == 'CM') return TipoSolicitudCompra.compraMateriales;
    if (upper == 'AF') return TipoSolicitudCompra.compraActivoFijo;
    if (upper == 'ST') return TipoSolicitudCompra.servicioTercero;
    if (upper == 'CD') return TipoSolicitudCompra.cargaDiversaGestion;
    
    // Nombres completos
    if (upper == 'COMPRA DE MATERIALES') return TipoSolicitudCompra.compraMateriales;
    if (upper == 'COMPRA DE ACTIVO FIJO') return TipoSolicitudCompra.compraActivoFijo;
    if (upper == 'SERVICIO DE TERCERO' || upper == 'SERVICIOS DE TERCEROS') return TipoSolicitudCompra.servicioTercero;
    if (upper.contains('CARGA DIVERSA')) return TipoSolicitudCompra.cargaDiversaGestion;
    
    // Variaciones posibles del API
    if (upper.contains('MATERIAL')) return TipoSolicitudCompra.compraMateriales;
    if (upper.contains('ACTIVO') || upper.contains('FIJO')) return TipoSolicitudCompra.compraActivoFijo;
    if (upper.contains('SERVICIO')) return TipoSolicitudCompra.servicioTercero;
    if (upper.contains('CARGA') || upper.contains('DIVERSA')) return TipoSolicitudCompra.cargaDiversaGestion;
    
    return TipoSolicitudCompra.compraMateriales;
  }

  static TipoSolicitudCompra fromTipOpeCompId(int? id) {
    switch (id) {
      case 1: return TipoSolicitudCompra.compraMateriales;
      case 2: return TipoSolicitudCompra.compraActivoFijo;
      case 3: return TipoSolicitudCompra.servicioTercero;
      case 4: return TipoSolicitudCompra.cargaDiversaGestion;
      default: return TipoSolicitudCompra.compraMateriales;
    }
  }
}

// ─── Estados de solicitud ────────────────────────────────────────────────────
enum EstadoSolicitud {
  pendiente,
  autorizado,
  observado,
  enProceso,
  anulado,
  rechazado,
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
      case 'EN PROCESO':
        return EstadoSolicitud.enProceso;
      case 'ANULADO':
        return EstadoSolicitud.anulado;
      case 'RECHAZADO':
        return EstadoSolicitud.rechazado;
      default:
        return EstadoSolicitud.pendiente;
    }
  }

  static EstadoSolicitud fromEstadoAutorizacion(int? estado) {
    switch (estado) {
      case 0: return EstadoSolicitud.pendiente;
      case 1: return EstadoSolicitud.pendiente; // Por autorizar
      case 2: return EstadoSolicitud.enProceso; // En revisión
      case 3: return EstadoSolicitud.autorizado;
      case 4: return EstadoSolicitud.autorizado; // Atendido
      case -1: return EstadoSolicitud.rechazado;
      default: return EstadoSolicitud.pendiente;
    }
  }

  String get nombre {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return 'PENDIENTE';
      case EstadoSolicitud.enProceso:
        return 'EN PROCESO';
      case EstadoSolicitud.autorizado:
        return 'AUTORIZADO';
      case EstadoSolicitud.observado:
        return 'OBSERVADO';
      case EstadoSolicitud.anulado:
        return 'ANULADO';
      case EstadoSolicitud.rechazado:
        return 'RECHAZADO';
    }
  }

  Color get color {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return const Color(0xFFE6A23C);
      case EstadoSolicitud.enProceso:
        return const Color(0xFF5B8DEF);
      case EstadoSolicitud.autorizado:
        return const Color(0xFF67C23A);
      case EstadoSolicitud.observado:
        return const Color(0xFFEF6B6B);
      case EstadoSolicitud.anulado:
        return const Color(0xFF909399);
      case EstadoSolicitud.rechazado:
        return const Color(0xFFF56C6C);
    }
  }

  Color get backgroundColor {
    return color.withOpacity(0.1);
  }

  IconData get icon {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return Icons.schedule_rounded;
      case EstadoSolicitud.enProceso:
        return Icons.sync_rounded;
      case EstadoSolicitud.autorizado:
        return Icons.check_circle_outline_rounded;
      case EstadoSolicitud.observado:
        return Icons.info_outline_rounded;
      case EstadoSolicitud.anulado:
        return Icons.cancel_outlined;
      case EstadoSolicitud.rechazado:
        return Icons.close_rounded;
    }
  }
}

// ─── Item base para listas (comparte campos comunes) ─────────────────────────
class SolicitudCompraItemBase {
  final String solComCabId;
  final int tipOpeCompId;
  final String tipo;
  final String numero;
  final DateTime fecha;
  final String usuario;
  final String area;

  SolicitudCompraItemBase({
    required this.solComCabId,
    required this.tipOpeCompId,
    required this.tipo,
    required this.numero,
    required this.fecha,
    required this.usuario,
    required this.area,
  });

  // Constructor desde JSON (campos comunes)
  SolicitudCompraItemBase.fromJson(Map<String, dynamic> json)
      : solComCabId = json['solComCabId']?.toString() ?? json['SolComCabId']?.toString() ?? '',
        tipOpeCompId = json['tipOpeCompId'] ?? json['TipOpeCompId'] ?? 0,
        tipo = json['tipo'] ?? json['Tipo'] ?? '',
        numero = json['numero'] ?? json['Numero'] ?? '',
        fecha = DateTime.tryParse(json['fecha'] ?? json['Fecha'] ?? '') ?? DateTime.now(),
        usuario = json['usuario'] ?? json['Usuario'] ?? '',
        area = json['area'] ?? json['Area'] ?? '';

  // Getter para tipoEnum (común)
  TipoSolicitudCompra get tipoEnum => TipoSolicitudCompraExtension.fromString(tipo);

  String get fechaFormateada =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';
}

// ─── Item para autorización (sin campos extra) ───────────────────────────────
class SolicitudCompraListaItem extends SolicitudCompraItemBase {
  SolicitudCompraListaItem({
    required super.solComCabId,
    required super.tipOpeCompId,
    required super.tipo,
    required super.numero,
    required super.fecha,
    required super.usuario,
    required super.area,
  });

  factory SolicitudCompraListaItem.fromJson(Map<String, dynamic> json) {
    return SolicitudCompraListaItem(
      solComCabId: json['solComCabId']?.toString() ?? json['SolComCabId']?.toString() ?? '',
      tipOpeCompId: json['tipOpeCompId'] ?? json['TipOpeCompId'] ?? 0,
      tipo: json['tipo'] ?? json['Tipo'] ?? '',
      numero: json['numero'] ?? json['Numero'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? json['Fecha'] ?? '') ?? DateTime.now(),
      usuario: json['usuario'] ?? json['Usuario'] ?? '',
      area: json['area'] ?? json['Area'] ?? '',
    );
  }
}

// ─── Item para consulta (con campos adicionales específicos) ─────────────────
class SolicitudCompraConsultaItem extends SolicitudCompraItemBase {
  final int estadoAutorizacion;
  final String? estado;           // Solo para PorAutorizar y AnuladosRechazados
  final String? usuarioAtencion;  // Solo para Autorizados
  final DateTime? fechaHoraAtencion; // Solo para Autorizados

  SolicitudCompraConsultaItem({
    required super.solComCabId,
    required super.tipOpeCompId,
    required super.tipo,
    required super.numero,
    required super.fecha,
    required super.usuario,
    required super.area,
    required this.estadoAutorizacion,
    this.estado,
    this.usuarioAtencion,
    this.fechaHoraAtencion,
  });

  factory SolicitudCompraConsultaItem.fromJson(Map<String, dynamic> json) {
    return SolicitudCompraConsultaItem(
      solComCabId: json['solComCabId']?.toString() ?? json['SolComCabId']?.toString() ?? '',
      tipOpeCompId: json['tipOpeCompId'] ?? json['TipOpeCompId'] ?? 0,
      tipo: json['tipo'] ?? json['Tipo'] ?? '',
      numero: json['numero'] ?? json['Numero'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? json['Fecha'] ?? '') ?? DateTime.now(),
      usuario: json['usuario'] ?? json['Usuario'] ?? '',
      area: json['area'] ?? json['Area'] ?? '',
      estadoAutorizacion: json['estadoAutorizacion'] ?? 0,
      estado: json['estado'] ?? json['Estado'],
      usuarioAtencion: json['usuarioAtencion'] ?? json['UsuarioAtencion'],
      fechaHoraAtencion: json['fechaHoraAtencion'] != null
          ? DateTime.tryParse(json['fechaHoraAtencion'].toString())
          : json['FechaHoraAtencion'] != null
              ? DateTime.tryParse(json['FechaHoraAtencion'].toString())
              : null,
    );
  }

  // Getter para obtener el estado de la solicitud desde el int
  EstadoSolicitud get estadoSolicitud =>
      EstadoSolicitudExtension.fromEstadoAutorizacion(estadoAutorizacion);

  String get fechaHoraAtencionFormateada {
    if (fechaHoraAtencion == null) return '';
    return '${fechaHoraAtencion!.day.toString().padLeft(2, '0')}/'
        '${fechaHoraAtencion!.month.toString().padLeft(2, '0')}/'
        '${fechaHoraAtencion!.year} '
        '${fechaHoraAtencion!.hour.toString().padLeft(2, '0')}:'
        '${fechaHoraAtencion!.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Response de autorización ─────────────────────────────────────────────────
class SolicitudCompraAutorizacionResponse {
  final BaseResponse baseResponse;
  final List<SolicitudCompraListaItem> porAutorizar;
  final List<SolicitudCompraListaItem> autorizados;

  SolicitudCompraAutorizacionResponse({
    required this.baseResponse,
    required this.porAutorizar,
    required this.autorizados,
  });

  factory SolicitudCompraAutorizacionResponse.fromJson(Map<String, dynamic> json) {
    final rawBase = json['baseResponse'] ?? json;
    final porAutorizarList = json['porAutorizar'] ?? [];
    final autorizadosList = json['autorizados'] ?? [];

    return SolicitudCompraAutorizacionResponse(
      baseResponse: BaseResponse.fromJson(rawBase),
      porAutorizar: (porAutorizarList as List<dynamic>)
          .map((e) => SolicitudCompraListaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      autorizados: (autorizadosList as List<dynamic>)
          .map((e) => SolicitudCompraListaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get esExitoso => baseResponse.success;
}

// ─── Response de consulta ─────────────────────────────────────────────────────
class SolicitudCompraConsultaResponse {
  final BaseResponse baseResponse;
  final List<SolicitudCompraConsultaItem> porAutorizar;
  final List<SolicitudCompraConsultaItem> autorizados;
  final List<SolicitudCompraConsultaItem> anuladosRechazados;

  SolicitudCompraConsultaResponse({
    required this.baseResponse,
    required this.porAutorizar,
    required this.autorizados,
    required this.anuladosRechazados,
  });

  factory SolicitudCompraConsultaResponse.fromJson(Map<String, dynamic> json) {
    final rawBase = json['baseResponse'] ?? json;
    final porAutorizarList = json['porAutorizar'] ?? [];
    final autorizadosList = json['autorizados'] ?? [];
    final anuladosList = json['anuladosRechazados'] ?? [];

    return SolicitudCompraConsultaResponse(
      baseResponse: BaseResponse.fromJson(rawBase),
      porAutorizar: (porAutorizarList as List<dynamic>)
          .map((e) => SolicitudCompraConsultaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      autorizados: (autorizadosList as List<dynamic>)
          .map((e) => SolicitudCompraConsultaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      anuladosRechazados: (anuladosList as List<dynamic>)
          .map((e) => SolicitudCompraConsultaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get esExitoso => baseResponse.success;
}

// ─── Encabezado de detalle ───────────────────────────────────────────────────
class SolicitudCompraEncabezado {
  final String numero;
  final DateTime? fecha;
  final String gds;
  final String descripcionGds;
  final String area;
  final String cc;
  final String observacion;
  final String usoMotivo;

  SolicitudCompraEncabezado({
    required this.numero,
    this.fecha,
    required this.gds,
    required this.descripcionGds,
    required this.area,
    required this.cc,
    required this.observacion,
    required this.usoMotivo,
  });

  factory SolicitudCompraEncabezado.fromJson(Map<String, dynamic> json) =>
      SolicitudCompraEncabezado(
        numero: json['numero'] ?? json['Numero'] ?? '',
        fecha: json['fecha'] != null
            ? DateTime.tryParse(json['fecha'].toString())
            : json['Fecha'] != null
                ? DateTime.tryParse(json['Fecha'].toString())
                : null,
        gds: json['gds'] ?? json['GDS'] ?? json['Gds'] ?? '',
        descripcionGds: json['descripcionGds'] ?? json['DescripcionGDS'] ?? json['DescripcionGds'] ?? '',
        area: json['area'] ?? json['Area'] ?? '',
        cc: json['cc'] ?? json['CC'] ?? '',
        observacion: json['observacion'] ?? json['Observacion'] ?? '',
        usoMotivo: json['usoMotivo'] ?? json['UsoMotivo'] ?? '',
      );

  String get fechaFormateada {
    if (fecha == null) return '';
    return '${fecha!.day.toString().padLeft(2, '0')}/'
           '${fecha!.month.toString().padLeft(2, '0')}/'
           '${fecha!.year}';
  }
}

// ─── Item de detalle ─────────────────────────────────────────────────────────
class SolicitudCompraDetalleItem {
  final String cc;
  final String ccDes;
  final String item;
  final String itemDes;
  final double cantidad;
  final String und;
  final String monedaId;
  final String monedaAbrev;
  final double? montoReferencial;
  final double? subtotal;

  SolicitudCompraDetalleItem({
    required this.cc,
    required this.ccDes,
    required this.item,
    required this.itemDes,
    required this.cantidad,
    required this.und,
    required this.monedaId,
    required this.monedaAbrev,
    this.montoReferencial,
    this.subtotal,
  });

  factory SolicitudCompraDetalleItem.fromJson(Map<String, dynamic> json) =>
      SolicitudCompraDetalleItem(
        cc: json['cc'] ?? json['CC'] ?? '',
        ccDes: json['ccDes'] ?? json['CCDes'] ?? '',
        item: json['item'] ?? json['Item'] ?? '',
        itemDes: json['itemDes'] ?? json['ItemDes'] ?? '',
        cantidad: (json['cantidad'] as num?)?.toDouble() ?? (json['Cantidad'] as num?)?.toDouble() ?? 0,
        und: json['und'] ?? json['Und'] ?? '',
        monedaId: json['monedaId'] ?? json['MonedaId'] ?? '',
        monedaAbrev: json['monedaAbrev'] ?? json['MonedaAbrev'] ?? 'S/',
        montoReferencial: (json['montoReferencial'] as num?)?.toDouble() ?? (json['MontoReferencial'] as num?)?.toDouble(),
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? (json['Subtotal'] as num?)?.toDouble(),
      );

  String get monedaSimbolo => monedaAbrev;

  String _formatNumber(double value, String simbolo) {
    if (simbolo.isEmpty) {
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return formatter.format(value);
    }
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: simbolo,
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  String get montoReferencialFormateado {
    final val = montoReferencial ?? 0.0;
    return _formatNumber(val, monedaSimbolo);
  }

  String get subtotalFormateado {
    final val = subtotal ?? 0.0;
    return _formatNumber(val, monedaSimbolo);
  }
}

// ─── Response de detalle ────────────────────────────────────────────────────
class SolicitudCompraDetalleResponse {
  final BaseResponse baseResponse;
  final SolicitudCompraEncabezado? encabezado;
  final List<SolicitudCompraDetalleItem> detalle;

  SolicitudCompraDetalleResponse({
    required this.baseResponse,
    this.encabezado,
    this.detalle = const [],
  });

  factory SolicitudCompraDetalleResponse.fromJson(Map<String, dynamic> json) {
    final rawBase = json['baseResponse'] ?? json;
    final rawEnc = json['Encabezado'] ?? json['encabezado'];
    final rawDet = json['detalle'] ?? json['Detalle'] ?? [];

    return SolicitudCompraDetalleResponse(
      baseResponse: BaseResponse.fromJson(rawBase),
      encabezado: rawEnc != null
          ? SolicitudCompraEncabezado.fromJson(rawEnc as Map<String, dynamic>)
          : null,
      detalle: (rawDet as List<dynamic>)
          .map((e) => SolicitudCompraDetalleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get esExitoso => baseResponse.success;

  double get total => detalle.fold(0, (sum, e) => sum + (e.subtotal ?? 0));

  String get totalFormateado {
    final valor = total;
    final simbolo = detalle.isNotEmpty ? detalle.first.monedaAbrev : 'S/';
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$simbolo ${formatter.format(valor)}';
  }
}

// ─── Item de solicitud (para uso interno) ────────────────────────────────────
class ItemSolicitud {
  final String id;
  final String codigo;
  final String descripcion;
  final String unidadMedida;
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
    final cantidad = (json['cantidad'] as num?)?.toInt() ?? 1;
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

  String get precioUnitarioFormateado {
    return precioUnitario.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get subtotalFormateado {
    return subtotal.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// ─── Modelo principal de Solicitud de Compra ─────────────────────────────────
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

  factory SolicitudCompra.fromListaItem(SolicitudCompraListaItem item) {
    return SolicitudCompra(
      id: item.solComCabId,
      codigo: item.numero,
      tipo: item.tipoEnum,
      areaSolicitante: item.area,
      solicitanteNombre: item.usuario,
      solicitanteId: '',
      fechaSolicitud: item.fecha,
      montoTotal: 0.0,
      sustento: null,
      items: [],
      estado: EstadoSolicitud.pendiente,
    );
  }

  factory SolicitudCompra.fromDetalle({
    required SolicitudCompraListaItem listaItem,
    required SolicitudCompraEncabezado? encabezado,
    required List<SolicitudCompraDetalleItem> detalleItems,
    EstadoSolicitud? estado,
  }) {
    final items = detalleItems.map((d) => ItemSolicitud(
      id: d.item,
      codigo: d.item,
      descripcion: d.itemDes,
      unidadMedida: d.und,
      cantidad: d.cantidad.toInt(),
      precioUnitario: d.montoReferencial ?? 0,
      subtotal: d.subtotal ?? 0,
    )).toList();

    final total = detalleItems.fold(0.0, (sum, d) => sum + (d.subtotal ?? 0));

    return SolicitudCompra(
      id: listaItem.solComCabId,
      codigo: listaItem.numero,
      tipo: listaItem.tipoEnum,
      areaSolicitante: encabezado?.area ?? listaItem.area,
      solicitanteNombre: listaItem.usuario,
      solicitanteId: '',
      fechaSolicitud: listaItem.fecha,
      montoTotal: total,
      sustento: encabezado?.usoMotivo ?? encabezado?.observacion,
      items: items,
      estado: estado ?? EstadoSolicitud.pendiente,
    );
  }

  String get fechaFormateada {
    return '${fechaSolicitud.day.toString().padLeft(2, '0')}/${fechaSolicitud.month.toString().padLeft(2, '0')}/${fechaSolicitud.year}';
  }

  String get montoFormateado {
    if (montoTotal >= 1000) {
      return '${(montoTotal / 1000).toStringAsFixed(1)}K';
    }
    return montoTotal.toStringAsFixed(0);
  }

  String get montoCompletoFormateado {
    final formatter = NumberFormat('#,###.00', 'es_PE');
    return formatter.format(montoTotal);
  }
}

// ─── Response de acciones (autorizar/observar) ──────────────────────────────
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
    final data = json['data'] as Map<String, dynamic>?;
    return SolicitudCompraActionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      solicitudId: data?['solicitudId']?.toString(),
      estado: data?['estado']?.toString(),
      fechaAccion: data?['fechaAutorizacion'] != null
          ? DateTime.tryParse(data?['fechaAutorizacion'])
          : data?['fechaObservacion'] != null
              ? DateTime.tryParse(data?['fechaObservacion'])
              : null,
    );
  }

  bool get esExitoso => success;
}

// ─── Response de lista de solicitudes ────────────────────────────────────────
class SolicitudListResponse extends BaseResponse {
  final List<SolicitudCompraListaItem> solicitudes;
  final int totalRegistros;

  SolicitudListResponse({
    required bool success,
    String? message,
    required this.solicitudes,
    required this.totalRegistros,
  }) : super(
    success: success,
    message: message,
  );

  SolicitudListResponse.fromBaseResponse({
    required BaseResponse baseResponse,
    required this.solicitudes,
    int totalRegistros = 0,
  }) : totalRegistros = totalRegistros,
       super(
         success: baseResponse.success,
         exception: baseResponse.exception,
         tipoException: baseResponse.tipoException,
         message: baseResponse.message,
         errores: baseResponse.errores,
       );

  factory SolicitudListResponse.fromJson(Map<String, dynamic> json) {
    List<SolicitudCompraListaItem> items = [];
    
    if (json['solicitudes'] is List<dynamic>) {
      items = (json['solicitudes'] as List<dynamic>)
          .map((e) => SolicitudCompraListaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['data'] is Map<String, dynamic> && 
               (json['data'] as Map<String, dynamic>)['solicitudes'] is List<dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      items = (dataMap['solicitudes'] as List<dynamic>)
          .map((e) => SolicitudCompraListaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return SolicitudListResponse(
      success:        json['success']        ?? false,
      message:        json['message'],
      solicitudes:    items,
      totalRegistros: json['totalRegistros'] ?? items.length,
    );
  }
}