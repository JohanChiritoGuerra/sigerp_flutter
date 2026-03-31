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

// ─── Enums ────────────────────────────────────────────────────────────────────

/// Tipo de presupuesto — mapeado desde IdSubtipoPresupuesto del SP
enum TipoPresupuestoEmergencia {
  cargasDiversas,    // 5
  servicioTercero,   // 6
  consumo,           // 8
  inversiones;       // 10

  static TipoPresupuestoEmergencia fromIdSubtipo(int? id) {
    switch (id) {
      case 5:  return TipoPresupuestoEmergencia.cargasDiversas;
      case 6:  return TipoPresupuestoEmergencia.servicioTercero;
      case 8:  return TipoPresupuestoEmergencia.consumo;
      case 10: return TipoPresupuestoEmergencia.inversiones;
      default: return TipoPresupuestoEmergencia.consumo;
    }
  }

  /// Para compatibilidad con código anterior que usaba String
  static TipoPresupuestoEmergencia fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'CARGAS DIVERSAS DE GESTION': return TipoPresupuestoEmergencia.cargasDiversas;
      case 'SERVICIO DE TERCEROS':       return TipoPresupuestoEmergencia.servicioTercero;
      case 'CONSUMOS':                   return TipoPresupuestoEmergencia.consumo;
      case 'INVERSIONES':                return TipoPresupuestoEmergencia.inversiones;
      default:                           return TipoPresupuestoEmergencia.consumo;
    }
  }

  String get label {
    switch (this) {
      case TipoPresupuestoEmergencia.cargasDiversas:  return 'PPTO. EMERGENCIA - CARGAS DIVERSAS';
      case TipoPresupuestoEmergencia.servicioTercero: return 'PPTO. EMERGENCIA - SERVICIO TERCERO';
      case TipoPresupuestoEmergencia.consumo:         return 'PPTO. EMERGENCIA - CONSUMO';
      case TipoPresupuestoEmergencia.inversiones:     return 'PPTO. EMERGENCIA - INVERSIONES';
    }
  }

  String get labelCorto {
    switch (this) {
      case TipoPresupuestoEmergencia.cargasDiversas:  return 'CARGAS DIVERSAS';
      case TipoPresupuestoEmergencia.servicioTercero: return 'SERVICIO TERCERO';
      case TipoPresupuestoEmergencia.consumo:         return 'CONSUMO';
      case TipoPresupuestoEmergencia.inversiones:     return 'INVERSIONES';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoPresupuestoEmergencia.cargasDiversas:  return Icons.receipt_long_outlined;
      case TipoPresupuestoEmergencia.servicioTercero: return Icons.engineering_outlined;
      case TipoPresupuestoEmergencia.consumo:         return Icons.inventory_2_outlined;
      case TipoPresupuestoEmergencia.inversiones:     return Icons.trending_up_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case TipoPresupuestoEmergencia.cargasDiversas:  return const Color(0xFF009688);
      case TipoPresupuestoEmergencia.servicioTercero: return const Color(0xFFFF9800);
      case TipoPresupuestoEmergencia.consumo:         return const Color(0xFF2196F3);
      case TipoPresupuestoEmergencia.inversiones:     return const Color(0xFF9C27B0);
    }
  }

  Color get iconBgColor {
    switch (this) {
      case TipoPresupuestoEmergencia.cargasDiversas:  return const Color(0xFFE0F2F1);
      case TipoPresupuestoEmergencia.servicioTercero: return const Color(0xFFFFF3E0);
      case TipoPresupuestoEmergencia.consumo:         return const Color(0xFFE3F2FD);
      case TipoPresupuestoEmergencia.inversiones:     return const Color(0xFFF3E5F5);
    }
  }
}

/// Estado — mapeado desde EstadoAutorizacion (int) del SP
enum EstadoPresupuesto {
  borrador,    // -1
  pendiente,   //  0
  porAutorizar,//  1
  enRevision,  //  2
  autorizado,  //  3
  atendido,    //  4
  contabilidad,//  5
  logistica,   //  6
  observado;   //  cuando fue devuelto

  static EstadoPresupuesto fromEstadoAutorizacion(int? estado) {
    switch (estado) {
      case -1: return EstadoPresupuesto.borrador;
      case 0:  return EstadoPresupuesto.pendiente;
      case 1:  return EstadoPresupuesto.porAutorizar;
      case 2:  return EstadoPresupuesto.enRevision;
      case 3:  return EstadoPresupuesto.autorizado;
      case 4:  return EstadoPresupuesto.atendido;
      case 5:  return EstadoPresupuesto.contabilidad;
      case 6:  return EstadoPresupuesto.logistica;
      default: return EstadoPresupuesto.pendiente;
    }
  }

  String get nombre {
    switch (this) {
      case EstadoPresupuesto.borrador:     return 'BORRADOR';
      case EstadoPresupuesto.pendiente:    return 'PENDIENTE';
      case EstadoPresupuesto.porAutorizar: return 'POR AUTORIZAR';
      case EstadoPresupuesto.enRevision:   return 'EN REVISIÓN';
      case EstadoPresupuesto.autorizado:   return 'AUTORIZADO';
      case EstadoPresupuesto.atendido:     return 'ATENDIDO';
      case EstadoPresupuesto.contabilidad: return 'CONTABILIDAD';
      case EstadoPresupuesto.logistica:    return 'LOGÍSTICA';
      case EstadoPresupuesto.observado:    return 'OBSERVADO';
    }
  }

  Color get color {
    switch (this) {
      case EstadoPresupuesto.borrador:     return const Color(0xFF9E9E9E);
      case EstadoPresupuesto.pendiente:    return const Color(0xFFFF9800);
      case EstadoPresupuesto.porAutorizar: return const Color(0xFF03A9F4);
      case EstadoPresupuesto.enRevision:   return const Color(0xFF2196F3);
      case EstadoPresupuesto.autorizado:   return const Color(0xFF4CAF50);
      case EstadoPresupuesto.atendido:     return const Color(0xFF4CAF50);
      case EstadoPresupuesto.contabilidad: return const Color(0xFF673AB7);
      case EstadoPresupuesto.logistica:    return const Color(0xFF795548);
      case EstadoPresupuesto.observado:    return const Color(0xFFF44336);
    }
  }

  Color get backgroundColor {
    return color.withOpacity(0.1);
  }
  
  IconData get icon {
    switch (this) {
      case EstadoPresupuesto.borrador:     return Icons.edit_outlined;
      case EstadoPresupuesto.pendiente:    return Icons.hourglass_empty;
      case EstadoPresupuesto.porAutorizar: return Icons.pending_outlined;
      case EstadoPresupuesto.enRevision:   return Icons.find_in_page_outlined;
      case EstadoPresupuesto.autorizado:   return Icons.check_circle_outline;
      case EstadoPresupuesto.atendido:     return Icons.task_alt;
      case EstadoPresupuesto.contabilidad: return Icons.account_balance_outlined;
      case EstadoPresupuesto.logistica:    return Icons.local_shipping_outlined;
      case EstadoPresupuesto.observado:    return Icons.cancel_outlined;
    }
  }
}

/// Prioridad del presupuesto
enum PrioridadPresupuesto {
  emergencia,
  urgente,
  normal;

  String get nombre {
    switch (this) {
      case PrioridadPresupuesto.emergencia: return 'EMERGENCIA';
      case PrioridadPresupuesto.urgente:    return 'URGENTE';
      case PrioridadPresupuesto.normal:     return 'NORMAL';
    }
  }

  String get label {
    switch (this) {
      case PrioridadPresupuesto.emergencia: return 'EMERGENCIA';
      case PrioridadPresupuesto.urgente:    return 'URGENTE';
      case PrioridadPresupuesto.normal:     return 'NORMAL';
    }
  }

  Color get color {
    switch (this) {
      case PrioridadPresupuesto.emergencia: return const Color(0xFFF44336);
      case PrioridadPresupuesto.urgente:    return const Color(0xFFFF9800);
      case PrioridadPresupuesto.normal:     return const Color(0xFF4CAF50);
    }
  }

  static PrioridadPresupuesto fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'EMERGENCIA': return PrioridadPresupuesto.emergencia;
      case 'URGENTE':    return PrioridadPresupuesto.urgente;
      case 'NORMAL':     return PrioridadPresupuesto.normal;
      default:           return PrioridadPresupuesto.normal;
    }
  }
}

// ─── Item base para listas (comparte campos comunes) ─────────────────────────
class PresupuestoEmergenciaItemBase {
  final int idPresupuestoEmergencia;
  final int idSubtipoPresupuesto;
  final bool esCcMultiple;
  final String tipo;
  final String numero;
  final DateTime fecha;
  final String usuario;
  final String area;

  PresupuestoEmergenciaItemBase({
    required this.idPresupuestoEmergencia,
    required this.idSubtipoPresupuesto,
    required this.esCcMultiple,
    required this.tipo,
    required this.numero,
    required this.fecha,
    required this.usuario,
    required this.area,
  });

  // Constructor desde JSON (campos comunes)
  PresupuestoEmergenciaItemBase.fromJson(Map<String, dynamic> json)
      : idPresupuestoEmergencia = json['idPresupuestoEmergencia'] ?? 0,
        idSubtipoPresupuesto = json['idSubtipoPresupuesto'] ?? 0,
        esCcMultiple = json['esCcMultiple'] ?? false,
        tipo = json['tipo'] ?? '',
        numero = json['numero'] ?? '',
        fecha = DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
        usuario = json['usuario'] ?? '',
        area = json['area'] ?? '';

  // Getter para tipoEnum (común)
  TipoPresupuestoEmergencia get tipoEnum =>
      TipoPresupuestoEmergencia.fromString(tipo);

  String get fechaFormateada =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';
}

// ─── Item para autorización (sin campos extra) ───────────────────────────────
class PresupuestoEmergenciaListaItem extends PresupuestoEmergenciaItemBase {
  // Campos adicionales para filtrado (opcionales, no vienen del API de autorización)
  final String? codigo;
  final String? descripcion;
  final EstadoPresupuesto? estadoActual;
  final PrioridadPresupuesto? prioridad;
  final DateTime? fechaSolicitud;
  final String? nombreSolicitante;
  final String? seccionSolicitante;
  final Solicitante? solicitante;

  PresupuestoEmergenciaListaItem({
    required super.idPresupuestoEmergencia,
    required super.idSubtipoPresupuesto,
    required super.esCcMultiple,
    required super.tipo,
    required super.numero,
    required super.fecha,
    required super.usuario,
    required super.area,
    this.codigo,
    this.descripcion,
    this.estadoActual,
    this.prioridad,
    this.fechaSolicitud,
    this.nombreSolicitante,
    this.seccionSolicitante,
  }) : solicitante = (nombreSolicitante != null || seccionSolicitante != null)
          ? Solicitante(
              trabId: '',
              nombreCompleto: nombreSolicitante ?? '',
              seccion: seccionSolicitante ?? '',
              cargo: '',
            )
          : null;

  factory PresupuestoEmergenciaListaItem.fromJson(Map<String, dynamic> json) {
    return PresupuestoEmergenciaListaItem(
      idPresupuestoEmergencia: json['idPresupuestoEmergencia'] ?? 0,
      idSubtipoPresupuesto: json['idSubtipoPresupuesto'] ?? 0,
      esCcMultiple: json['esCcMultiple'] ?? false,
      tipo: json['tipo'] ?? '',
      numero: json['numero'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      usuario: json['usuario'] ?? '',
      area: json['area'] ?? '',
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      estadoActual: json['estadoActual'] != null
          ? EstadoPresupuesto.fromEstadoAutorizacion(json['estadoActual'])
          : null,
      prioridad: json['prioridad'] != null
          ? PrioridadPresupuesto.fromString(json['prioridad'])
          : null,
      fechaSolicitud: json['fechaSolicitud'] != null
          ? DateTime.tryParse(json['fechaSolicitud'])
          : null,
      nombreSolicitante: json['nombreSolicitante'],
      seccionSolicitante: json['seccionSolicitante'],
    );
  }
}

// ─── Item para consulta (con campos adicionales específicos) ─────────────────
class PresupuestoEmergenciaConsultaItem extends PresupuestoEmergenciaItemBase {
  final int estadoAutorizacion;
  final String? estado;           // Solo para PorAtender y Anulados
  final String? usuarioAtencion;  // Solo para Atendidos
  final DateTime? fechaHoraAtencion; // Solo para Atendidos

  PresupuestoEmergenciaConsultaItem({
    required super.idPresupuestoEmergencia,
    required super.idSubtipoPresupuesto,
    required super.esCcMultiple,
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

  factory PresupuestoEmergenciaConsultaItem.fromJson(Map<String, dynamic> json) {
    return PresupuestoEmergenciaConsultaItem(
      idPresupuestoEmergencia: json['idPresupuestoEmergencia'] ?? 0,
      idSubtipoPresupuesto: json['idSubtipoPresupuesto'] ?? 0,
      esCcMultiple: json['esCcMultiple'] ?? false,
      tipo: json['tipo'] ?? '',
      numero: json['numero'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      usuario: json['usuario'] ?? '',
      area: json['area'] ?? '',
      estadoAutorizacion: json['estadoAutorizacion'] ?? 0,
      estado: json['estado'],
      usuarioAtencion: json['usuarioAtencion'],
      fechaHoraAtencion: json['fechaHoraAtencion'] != null
          ? DateTime.tryParse(json['fechaHoraAtencion'])
          : null,
    );
  }

  // Getter para obtener el estado del presupuesto desde el int
  EstadoPresupuesto get estadoPresupuesto =>
      EstadoPresupuesto.fromEstadoAutorizacion(estadoAutorizacion);

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
class PresupuestoEmergenciaAutorizacionResponse {
  final BaseResponse baseResponse;
  final List<PresupuestoEmergenciaListaItem> porAutorizar;
  final List<PresupuestoEmergenciaListaItem> autorizados;

  PresupuestoEmergenciaAutorizacionResponse({
    required this.baseResponse,
    required this.porAutorizar,
    required this.autorizados,
  });

  factory PresupuestoEmergenciaAutorizacionResponse.fromJson(
          Map<String, dynamic> json) =>
      PresupuestoEmergenciaAutorizacionResponse(
        baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? {}),
        porAutorizar: (json['porAutorizar'] as List<dynamic>? ?? [])
            .map((e) => PresupuestoEmergenciaListaItem.fromJson(e))
            .toList(),
        autorizados: (json['autorizados'] as List<dynamic>? ?? [])
            .map((e) => PresupuestoEmergenciaListaItem.fromJson(e))
            .toList(),
      );

  bool get esExitoso => baseResponse.success;
}

// ─── Response de consulta ─────────────────────────────────────────────────────
class PresupuestoEmergenciaConsultaResponse {
  final BaseResponse baseResponse;
  final List<PresupuestoEmergenciaConsultaItem> porAtender;
  final List<PresupuestoEmergenciaConsultaItem> atendidos;
  final List<PresupuestoEmergenciaConsultaItem> anulados;

  PresupuestoEmergenciaConsultaResponse({
    required this.baseResponse,
    required this.porAtender,
    required this.atendidos,
    required this.anulados,
  });

  factory PresupuestoEmergenciaConsultaResponse.fromJson(
          Map<String, dynamic> json) =>
      PresupuestoEmergenciaConsultaResponse(
        baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? {}),
        porAtender: (json['porAtender'] as List<dynamic>? ?? [])
            .map((e) => PresupuestoEmergenciaConsultaItem.fromJson(e))
            .toList(),
        atendidos: (json['atendidos'] as List<dynamic>? ?? [])
            .map((e) => PresupuestoEmergenciaConsultaItem.fromJson(e))
            .toList(),
        anulados: (json['anulados'] as List<dynamic>? ?? [])
            .map((e) => PresupuestoEmergenciaConsultaItem.fromJson(e))
            .toList(),
      );

  bool get esExitoso => baseResponse.success;
}

// ─── Response de autorizar presupuesto (POST /autorizar) ─────────────────────
class AutorizarPresupuestoResponse {
  final BaseResponse baseResponse;
  final String? mensaje;
  final int? nuevoEstado;
  final String? gdsDestino;
  final String? destinoDescripcion;

  AutorizarPresupuestoResponse({
    required this.baseResponse,
    this.mensaje,
    this.nuevoEstado,
    this.gdsDestino,
    this.destinoDescripcion,
  });

  factory AutorizarPresupuestoResponse.fromJson(Map<String, dynamic> json) =>
      AutorizarPresupuestoResponse(
        baseResponse: BaseResponse.fromJson(
            json['baseResponse'] ?? json),
        mensaje:            json['mensaje']            as String?,
        nuevoEstado:       (json['nuevoEstado']        as num?)?.toInt(),
        gdsDestino:         json['gdsDestino']         as String?,
        destinoDescripcion: json['destinoDescripcion'] as String?,
      );

  bool get esExitoso => baseResponse.success;
}

class ObservarPresupuestoResponse {
  final BaseResponse baseResponse;

  ObservarPresupuestoResponse({required this.baseResponse});

  factory ObservarPresupuestoResponse.fromJson(Map<String, dynamic> json) =>
      ObservarPresupuestoResponse(
        baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? json),
      );

  bool get esExitoso => baseResponse.success;
}

// ─── Response detalle ─────────────────────────────────────────────────────────
class PresupuestoEmergenciaDetalleResponse {
  final BaseResponse baseResponse;
  final PresupuestoEmergenciaEncabezado? encabezado;
  final List<PresupuestoEmergenciaDetalleItem> detalle;

  PresupuestoEmergenciaDetalleResponse({
    required this.baseResponse,
    this.encabezado,
    this.detalle = const [],
  });

  factory PresupuestoEmergenciaDetalleResponse.fromJson(
    Map<String, dynamic> json) {
    // Soporta PascalCase (C# default) y camelCase
    final rawEnc = json['Encabezado'] ?? json['encabezado'];
    final rawDet = json['Detalle'] ?? json['detalle'] ?? [];
    final rawBase = json['BaseResponse'] ?? json['baseResponse'] 
        ?? {'success': json['Success'] ?? json['success'] ?? false};

    return PresupuestoEmergenciaDetalleResponse(
      baseResponse: BaseResponse.fromJson(rawBase),
      encabezado: rawEnc != null
          ? PresupuestoEmergenciaEncabezado.fromJson(rawEnc)
          : null,
      detalle: (rawDet as List<dynamic>)
          .map((e) => PresupuestoEmergenciaDetalleItem.fromJson(e))
          .toList(),
    );
  }

  bool get esExitoso => baseResponse.success;

  /// Total calculado en el cliente igual que el VB
  double get total => detalle.fold(0, (sum, e) => sum + (e.subtotal ?? 0));

  /// Total incluyendo IGV (18%)
  double get totalConIgv => total * 1.18;

  String get totalFormateado {
    final valor = totalConIgv;
    final simbolo = detalle.isNotEmpty ? detalle.first.monedaSimbolo : '';
    
    if (simbolo.isEmpty) {
      // Forzar 2 decimales
      return valor.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    
    // Formatear número con 2 decimales forzados
    final numeroConDecimales = valor.toStringAsFixed(2);
    final partes = numeroConDecimales.split('.');
    final parteEntera = partes[0];
    final parteDecimal = partes[1];
    
    // Agregar separadores de miles a la parte entera
    final parteEnteraFormateada = parteEntera.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    
    // Colocar símbolo a la izquierda
    return '$simbolo $parteEnteraFormateada.$parteDecimal';
  }
}

// ─── Encabezado de detalle ────────────────────────────────────────────────────
class PresupuestoEmergenciaEncabezado {
  final String numero;
  final DateTime? fecha;
  final String gds;
  final String descripcionGds;
  final String area;
  final String cc;
  final String observacion;
  final String usoMotivo;

  PresupuestoEmergenciaEncabezado({
    required this.numero,
    this.fecha,
    required this.gds,
    required this.descripcionGds,
    required this.area,
    required this.cc,
    required this.observacion,
    required this.usoMotivo,
  });

  factory PresupuestoEmergenciaEncabezado.fromJson(
    Map<String, dynamic> json) =>
  PresupuestoEmergenciaEncabezado(
    numero:         json['Numero']         ?? json['numero']         ?? '',
    fecha: json['Fecha'] != null 
        ? DateTime.tryParse(json['Fecha'].toString()) 
        : json['fecha'] != null 
            ? DateTime.tryParse(json['fecha'].toString()) 
            : null,
    gds:            json['Gds']            ?? json['gds']            
                 ?? json['GDS']            ?? '',
    descripcionGds: json['DescripcionGds'] ?? json['descripcionGds'] 
                 ?? json['DescripcionGDS'] ?? '',
    area:           json['Area']           ?? json['area']           ?? '',
    cc:             json['Cc']             ?? json['cc']             
                 ?? json['CC']             ?? '',
    observacion:    json['Observacion']    ?? json['observacion']    ?? '',
    usoMotivo:      json['UsoMotivo']      ?? json['usoMotivo']      ?? '',
  );

  String get fechaFormateada {
    if (fecha == null) return '';
    return '${fecha!.day.toString().padLeft(2, '0')}/'
           '${fecha!.month.toString().padLeft(2, '0')}/'
           '${fecha!.year}';
  }
}

// ─── Item de detalle ──────────────────────────────────────────────────────────
class PresupuestoEmergenciaDetalleItem {
  final String cc;
  final String ccDes;
  final String item;
  final String itemDes;
  final double cantidad;
  final String und;
  final String? monedaId;
  final String? monedaAbrev;
  final double? montoReferencial;
  final double? subtotal;

  PresupuestoEmergenciaDetalleItem({
    required this.cc,
    required this.ccDes,
    required this.item,
    required this.itemDes,
    required this.cantidad,
    required this.und,
    this.monedaId,
    this.monedaAbrev,
    this.montoReferencial,
    this.subtotal,
  });

  factory PresupuestoEmergenciaDetalleItem.fromJson(
    Map<String, dynamic> json) =>
  PresupuestoEmergenciaDetalleItem(
    cc:               json['Cc']               ?? json['cc']   
                   ?? json['CC']               ?? '',
    ccDes:            json['CcDes']            ?? json['ccDes'] 
                   ?? json['CCDes']            ?? '',
    item:             json['Item']             ?? json['item']            ?? '',
    itemDes:          json['ItemDes']          ?? json['itemDes']         ?? '',
    cantidad:        (json['Cantidad']         ?? json['cantidad'] as num?)
                         ?.toDouble() ?? 0,
    und:              json['Und']              ?? json['und']             ?? '',
    monedaId:         json['MonedaId']         ?? json['monedaId'],
    monedaAbrev:      json['MonedaAbrev']      ?? json['monedaAbrev']     ?? 'S/.',
    montoReferencial:(json['MontoReferencial'] ?? json['montoReferencial'] as num?)
                         ?.toDouble(),
    subtotal:        (json['Subtotal']         ?? json['subtotal'] as num?)
                         ?.toDouble(),
  );

  String get monedaSimbolo {
    if (monedaAbrev == null || monedaAbrev!.isEmpty) return '';
    return monedaAbrev!;
  }

  String get subtotalFormateado {
    final val = subtotal ?? 0.0;
    return _formatNumber(val, monedaSimbolo);
  }

  String get montoReferencialFormateado {
    final val = montoReferencial ?? 0.0;
    return _formatNumber(val, monedaSimbolo);
  }

  String _formatNumber(double value, String simbolo) {
    if (simbolo.isEmpty) {
      final formatter = NumberFormat('#,###.##', 'es_PE');
      return formatter.format(value);
    }
    
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: simbolo,
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
}

// ─── Clases auxiliares ────────────────────────────────────────────────────────

/// Solicitante/Usuario
class Solicitante {
  final String trabId;
  final String nombreCompleto;
  final String seccion;
  final String cargo;

  Solicitante({
    required this.trabId,
    required this.nombreCompleto,
    required this.seccion,
    required this.cargo,
  });

  factory Solicitante.fromJson(Map<String, dynamic> json) => Solicitante(
    trabId:           json['trabId']           ?? '',
    nombreCompleto:   json['nombreCompleto']   ?? '',
    seccion:          json['seccion']          ?? '',
    cargo:            json['cargo']            ?? '',
  );
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

  factory ItemPresupuesto.fromJson(Map<String, dynamic> json) => ItemPresupuesto(
    itemId:      json['itemId']      ?? '',
    descripcion: json['descripcion'] ?? '',
    monto:      (json['monto'] as num?)?.toDouble() ?? 0,
  );

  String get montoFormateado {
    return monto.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

/// Historial de autorización
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

  factory AutorizacionHistorial.fromJson(Map<String, dynamic> json) => AutorizacionHistorial(
    nivel:         json['nivel']         ?? 0,
    nombreNivel:   json['nombreNivel']   ?? '',
    autorizador: json['autorizador'] != null
        ? Solicitante.fromJson(json['autorizador'])
        : null,
    estado: EstadoPresupuesto.fromEstadoAutorizacion(json['estado']),
    fechaAccion: json['fechaAccion'] != null
        ? DateTime.tryParse(json['fechaAccion'])
        : null,
    observacion:   json['observacion'],
  );

  String get fechaFormateada {
    if (fechaAccion == null) return '';
    return '${fechaAccion!.day.toString().padLeft(2, '0')}/'
           '${fechaAccion!.month.toString().padLeft(2, '0')}/'
           '${fechaAccion!.year} '
           '${fechaAccion!.hour.toString().padLeft(2, '0')}:'
           '${fechaAccion!.minute.toString().padLeft(2, '0')}';
  }
}

/// Presupuesto de emergencia completo (para detalle)
class PresupuestoEmergencia {
  final String presupId;
  final String codigo;
  final TipoPresupuestoEmergencia tipoPresupuesto;
  final PrioridadPresupuesto prioridad;
  final Solicitante solicitante;
  final double montoTotal;
  final DateTime fechaSolicitud;
  final String descripcion;
  final EstadoPresupuesto estadoActual;
  final int nivelAutorizacionActual;
  final bool esmiTurno;
  final List<ItemPresupuesto> items;
  final List<AutorizacionHistorial> historialAutorizaciones;

  PresupuestoEmergencia({
    required this.presupId,
    required this.codigo,
    required this.tipoPresupuesto,
    required this.prioridad,
    required this.solicitante,
    required this.montoTotal,
    required this.fechaSolicitud,
    required this.descripcion,
    required this.estadoActual,
    required this.nivelAutorizacionActual,
    required this.esmiTurno,
    required this.items,
    required this.historialAutorizaciones,
  });

  factory PresupuestoEmergencia.fromJson(Map<String, dynamic> json) => PresupuestoEmergencia(
    presupId:                    json['presupId']                    ?? '',
    codigo:                      json['codigo']                      ?? '',
    tipoPresupuesto: TipoPresupuestoEmergencia.fromString(json['tipoPresupuesto']),
    prioridad:       PrioridadPresupuesto.fromString(json['prioridad']),
    solicitante:     Solicitante.fromJson(json['solicitante'] ?? {}),
    montoTotal:     (json['montoTotal']     as num?)?.toDouble() ?? 0,
    fechaSolicitud: DateTime.tryParse(json['fechaSolicitud'] ?? '') ?? DateTime.now(),
    descripcion:                 json['descripcion']                 ?? '',
    estadoActual:    EstadoPresupuesto.fromEstadoAutorizacion(json['estadoActual']),
    nivelAutorizacionActual:     json['nivelAutorizacionActual']     ?? 0,
    esmiTurno:                   json['esmiTurno']                   ?? false,
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => ItemPresupuesto.fromJson(e))
        .toList(),
    historialAutorizaciones: (json['historialAutorizaciones'] as List<dynamic>? ?? [])
        .map((e) => AutorizacionHistorial.fromJson(e))
        .toList(),
  );

  String get fechaFormateada =>
      '${fechaSolicitud.day.toString().padLeft(2, '0')}/'
      '${fechaSolicitud.month.toString().padLeft(2, '0')}/'
      '${fechaSolicitud.year}';

  String get fechaHoraFormateada =>
      '${fechaSolicitud.day.toString().padLeft(2, '0')}/'
      '${fechaSolicitud.month.toString().padLeft(2, '0')}/'
      '${fechaSolicitud.year} '
      '${fechaSolicitud.hour.toString().padLeft(2, '0')}:'
      '${fechaSolicitud.minute.toString().padLeft(2, '0')}';

  String get montoCompletoFormateado =>
      montoTotal.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

/// Response genérica para lista con presupuestos
class PresupuestoListResponse extends BaseResponse {
  final List<PresupuestoEmergenciaListaItem> presupuestos;
  final int totalRegistros;

  PresupuestoListResponse({
    required bool success,
    String? message,
    required this.presupuestos,
    required this.totalRegistros,
  }) : super(
    success: success,
    message: message,
  );

  PresupuestoListResponse.fromBaseResponse({
    required BaseResponse baseResponse,
    required this.presupuestos,
    int totalRegistros = 0,
  }) : totalRegistros = totalRegistros,
       super(
         success: baseResponse.success,
         exception: baseResponse.exception,
         tipoException: baseResponse.tipoException,
         message: baseResponse.message,
         errores: baseResponse.errores,
       );

  factory PresupuestoListResponse.fromJson(Map<String, dynamic> json) {
    List<PresupuestoEmergenciaListaItem> items = [];
    
    if (json['presupuestos'] is List<dynamic>) {
      items = (json['presupuestos'] as List<dynamic>)
          .map((e) => PresupuestoEmergenciaListaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['data'] is Map<String, dynamic> && 
               (json['data'] as Map<String, dynamic>)['presupuestos'] is List<dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      items = (dataMap['presupuestos'] as List<dynamic>)
          .map((e) => PresupuestoEmergenciaListaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PresupuestoListResponse(
      success:         json['success']         ?? false,
      message:         json['message'],
      presupuestos:    items,
      totalRegistros:  json['totalRegistros']  ?? items.length,
    );
  }
}

/// Response para detalle de presupuesto
class PresupuestoDetalleResponse extends BaseResponse {
  final PresupuestoEmergencia? presupuesto;

  PresupuestoDetalleResponse({
    required bool success,
    String? message,
    this.presupuesto,
  }) : super(
    success: success,
    message: message,
  );

  factory PresupuestoDetalleResponse.fromJson(Map<String, dynamic> json) => PresupuestoDetalleResponse(
    success:     json['success']     ?? false,
    message:     json['message'],
    presupuesto: json['presupuesto'] != null
        ? PresupuestoEmergencia.fromJson(json['presupuesto'])
        : null,
  );
}

/// Response para acciones (autorizar, observar)
class PresupuestoActionResponse extends BaseResponse {
  final String presupId;
  final String estado;
  final int? siguienteNivel;
  final bool requiereMasAutorizaciones;
  final DateTime? fechaAccion;

  PresupuestoActionResponse({
    required bool success,
    String? message,
    required this.presupId,
    required this.estado,
    this.siguienteNivel,
    this.requiereMasAutorizaciones = false,
    this.fechaAccion,
  }) : super(
    success: success,
    message: message,
  );

  factory PresupuestoActionResponse.fromJson(Map<String, dynamic> json) => PresupuestoActionResponse(
    success:                    json['success']                    ?? false,
    message:                    json['message'],
    presupId:                   json['presupId']                   ?? '',
    estado:                     json['estado']                     ?? '',
    siguienteNivel:            json['siguienteNivel'],
    requiereMasAutorizaciones:  json['requiereMasAutorizaciones']  ?? false,
    fechaAccion: json['fechaAccion'] != null
        ? DateTime.tryParse(json['fechaAccion'])
        : null,
  );
}