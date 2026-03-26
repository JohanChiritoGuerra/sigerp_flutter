import 'package:flutter/material.dart';
import '../models/solicitud_compra.dart';

/// Paleta pastel por tipo de solicitud de compra
class _SCPastel {
  final Color acento;
  final Color fondoClaro;
  final Color textoFuerte;
  final Color fondoMonto;

  const _SCPastel({
    required this.acento,
    required this.fondoClaro,
    required this.textoFuerte,
    required this.fondoMonto,
  });
}

class SolicitudCompraCard extends StatelessWidget {
  //final SolicitudCompraListaItem solicitud;
  final SolicitudCompraItemBase solicitud; 
  final VoidCallback onTap;
  final bool mostrarEstado;

  const SolicitudCompraCard({
    super.key,
    required this.solicitud,
    required this.onTap,
    this.mostrarEstado = false,
  });

  static const Map<TipoSolicitudCompra, _SCPastel> _paleta = {
    TipoSolicitudCompra.compraMateriales: _SCPastel(
      acento: Color(0xFFAB7AE0),
      fondoClaro: Color(0xFFF5F0FC),
      textoFuerte: Color(0xFF7E4FC9),
      fondoMonto: Color(0xFFEBE2F7),
    ),
    TipoSolicitudCompra.compraActivoFijo: _SCPastel(
      acento: Color(0xFFE8915A),
      fondoClaro: Color(0xFFFFF5ED),
      textoFuerte: Color(0xFFC06D34),
      fondoMonto: Color(0xFFFDEBDA),
    ),
    TipoSolicitudCompra.servicioTercero: _SCPastel(
      acento: Color(0xFFE57373),
      fondoClaro: Color(0xFFFFF0F0),
      textoFuerte: Color(0xFFD32F2F),
      fondoMonto: Color(0xFFFDEEEE),
    ),
    TipoSolicitudCompra.cargaDiversaGestion: _SCPastel(
      acento: Color(0xFF4CAF6A),
      fondoClaro: Color(0xFFEFF9F3),
      textoFuerte: Color(0xFF2E8B4A),
      fondoMonto: Color(0xFFE0F2E5),
    ),
  };

  String _truncarArea(String area) {
    if (area.isEmpty) return '—';
    // Si tiene el formato con guiones, mostrar solo la última parte
    if (area.contains('-') || area.contains('-->')) {
      // Dividir por '-->' o '-'
      final partes = area.split(RegExp(r'-->|-'));
      if (partes.length > 1) {
        // Tomar la última parte que debería ser la descripción
        return partes.last.trim();
      }
    }
    // Si es muy larga, truncar
    if (area.length > 40) {
      return '${area.substring(0, 37)}...';
    }
    return area;
  }

  Widget _buildInfoDinamica(SolicitudCompraConsultaItem consultaItem, _SCPastel p) {
  // Determinar qué información mostrar según el tab
  String linea1 = '';
  String linea2 = '';
  IconData icono = Icons.info_outline;
  Color iconColor = p.acento;
  String? fechaInfo;
  
  // Caso 1: Autorizados (tiene usuarioAtencion)
  if (consultaItem.usuarioAtencion != null && consultaItem.usuarioAtencion!.isNotEmpty) {
    linea1 = 'AUTORIZADO POR';
    linea2 = consultaItem.usuarioAtencion!;
    icono = Icons.check_circle_outline;
    iconColor = EstadoSolicitud.autorizado.color;
    
    // Mostrar fecha solo si es válida
    if (consultaItem.fechaHoraAtencion != null) {
      final fecha = consultaItem.fechaHoraAtencion!;
      // Validar que no sea fecha por defecto (01/01/0001 00:00)
      if (fecha.year > 1 && !(fecha.year == 1 && fecha.month == 1 && fecha.day == 1)) {
        fechaInfo = consultaItem.fechaHoraAtencionFormateada;
      }
    }
  }
  // Caso 2: Anulados/Rechazados
  else if (consultaItem.estado != null && consultaItem.estado!.contains('ANULADO O RECHAZADO:')) {
    linea1 = 'MOTIVO';
    final partes = consultaItem.estado!.split(':');
    final motivo = partes.length > 1 ? partes[1].trim() : '';
    linea2 = motivo.isNotEmpty ? motivo : 'S/N';
    icono = Icons.cancel_outlined;
    iconColor = EstadoSolicitud.anulado.color;
    // No mostrar fecha para anulados
  }
  // Caso 3: PorAutorizar (tiene estado textual)
  else if (consultaItem.estado != null && consultaItem.estado!.isNotEmpty) {
    // Extraer el texto del estado
    if (consultaItem.estado!.contains('EN ESPERA DE AUTORIZACION:')) {
      linea1 = 'ESTADO';
      final partes = consultaItem.estado!.split(':');
      linea2 = partes.length > 1 ? 'EN ESPERA' : consultaItem.estado!;
      icono = Icons.schedule;
      iconColor = EstadoSolicitud.pendiente.color;
    } else if (consultaItem.estado!.contains('OBSERVADO:')) {
      linea1 = 'OBSERVACIÓN';
      final partes = consultaItem.estado!.split(':');
      linea2 = partes.length > 1 ? partes[1].trim() : consultaItem.estado!;
      icono = Icons.info_outline;
      iconColor = EstadoSolicitud.observado.color;
    } else if (consultaItem.estado!.contains('FALTA ENVIAR')) {
      linea1 = 'ESTADO';
      linea2 = 'FALTA ENVIAR PARA AUTORIZAR';
      icono = Icons.warning_amber_rounded;
      iconColor = EstadoSolicitud.pendiente.color;
    } else {
      linea1 = 'ESTADO';
      linea2 = consultaItem.estado!;
      icono = Icons.info_outline;
      iconColor = EstadoSolicitud.pendiente.color;
    }
    // No mostrar fecha para por autorizar
  }
  // Caso 4: Por defecto
  else {
    linea1 = 'ESTADO';
    linea2 = consultaItem.estadoSolicitud.nombre;
    icono = consultaItem.estadoSolicitud.icon;
    iconColor = consultaItem.estadoSolicitud.color;
  }
  
  return Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: p.fondoClaro,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            icono,
            color: iconColor,
            size: 18,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              linea1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              linea2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (fechaInfo != null) ...[
              const SizedBox(height: 2),
              Text(
                fechaInfo,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    final p = _paleta[solicitud.tipoEnum]!;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.acento.withOpacity(0.35), width: 1.3),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ROW 1: Badge tipo + código + fecha
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.fondoClaro,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: p.acento.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          solicitud.tipoEnum.icon,
                          color: p.acento,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          solicitud.tipoEnum.nombre,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: p.textoFuerte,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    solicitud.numero,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    solicitud.fechaFormateada,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ROW 2: Información según el tipo
              if (mostrarEstado && solicitud is SolicitudCompraConsultaItem) ...[
                const SizedBox(height: 8),
                _buildInfoDinamica(solicitud as SolicitudCompraConsultaItem, p),
              ] else ...[
                // Para autorización: mostrar área y solicitante
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: p.fondoClaro,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                solicitud.tipoEnum.codigo,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: p.acento,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _truncarArea(solicitud.area.isNotEmpty ? solicitud.area : '-'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  solicitud.usuario,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // ESTADO (solo consultas)
              if (mostrarEstado) ...[
                const SizedBox(height: 8),
                _buildEstadoBadge(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge() {
    if (!mostrarEstado) return const SizedBox.shrink();
    
    // Determinar estado según el tipo de item
    Color color;
    Color bgColor;
    IconData icon;
    String texto;
    
    // Si es un item de consulta
    if (solicitud is SolicitudCompraConsultaItem) {
      final consultaItem = solicitud as SolicitudCompraConsultaItem;
      
      // Caso 1: Autorizados (tiene usuarioAtencion)
      if (consultaItem.usuarioAtencion != null && consultaItem.usuarioAtencion!.isNotEmpty) {
        color = EstadoSolicitud.autorizado.color;
        bgColor = EstadoSolicitud.autorizado.backgroundColor;
        icon = EstadoSolicitud.autorizado.icon;
        texto = 'AUTORIZADO';
      }
      // Caso 2: Tiene estado textual (PorAutorizar o AnuladosRechazados)
      else if (consultaItem.estado != null && consultaItem.estado!.isNotEmpty) {
        if (consultaItem.estado!.contains('EN ESPERA')) {
          color = EstadoSolicitud.pendiente.color;
          bgColor = EstadoSolicitud.pendiente.backgroundColor;
          icon = EstadoSolicitud.pendiente.icon;
          texto = 'PENDIENTE';
        } else if (consultaItem.estado!.contains('OBSERVADO')) {
          color = EstadoSolicitud.observado.color;
          bgColor = EstadoSolicitud.observado.backgroundColor;
          icon = EstadoSolicitud.observado.icon;
          texto = 'OBSERVADO';
        } else if (consultaItem.estado!.contains('ANULADO')) {
          color = EstadoSolicitud.anulado.color;
          bgColor = EstadoSolicitud.anulado.backgroundColor;
          icon = EstadoSolicitud.anulado.icon;
          texto = 'ANULADO';
        } else if (consultaItem.estado!.contains('RECHAZADO')) {
          color = EstadoSolicitud.rechazado.color;
          bgColor = EstadoSolicitud.rechazado.backgroundColor;
          icon = EstadoSolicitud.rechazado.icon;
          texto = 'RECHAZADO';
        } else if (consultaItem.estado!.contains('FALTA ENVIAR')) {
          color = EstadoSolicitud.pendiente.color;
          bgColor = EstadoSolicitud.pendiente.backgroundColor;
          icon = EstadoSolicitud.pendiente.icon;
          texto = 'PENDIENTE';
        } else {
          color = EstadoSolicitud.pendiente.color;
          bgColor = EstadoSolicitud.pendiente.backgroundColor;
          icon = EstadoSolicitud.pendiente.icon;
          texto = consultaItem.estado!.split(':').first.trim();
        }
      }
      // Caso 3: Por defecto
      else {
        color = EstadoSolicitud.pendiente.color;
        bgColor = EstadoSolicitud.pendiente.backgroundColor;
        icon = EstadoSolicitud.pendiente.icon;
        texto = consultaItem.estadoSolicitud.nombre;
      }
    } 
    // Si es item de autorización, no mostrar estado
    else {
      return const SizedBox.shrink();
    }
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(maxWidth: 140),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}