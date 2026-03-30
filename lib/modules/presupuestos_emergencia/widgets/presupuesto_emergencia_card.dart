import 'package:flutter/material.dart';
import '../models/presupuesto_emergencia.dart';

/// Paleta pastel por tipo de presupuesto
class _CardPastel {
  final Color acento;      // borde izq + icono texto
  final Color fondoIcono;  // bg del icono
  final Color fondoMonto;  // bg del chip de monto
  final Color textoMonto;  // color texto monto

  const _CardPastel({
    required this.acento,
    required this.fondoIcono,
    required this.fondoMonto,
    required this.textoMonto,
  });
}

class PresupuestoEmergenciaCard extends StatelessWidget {
  final PresupuestoEmergenciaItemBase presupuesto; 
  final VoidCallback onTap;
  final bool mostrarEstado;

  const PresupuestoEmergenciaCard({
    super.key,
    required this.presupuesto,
    required this.onTap,
    this.mostrarEstado = false,
  });

  static const Map<TipoPresupuestoEmergencia, _CardPastel> _paleta = {
    TipoPresupuestoEmergencia.cargasDiversas: _CardPastel(
      acento: Color(0xFF009688),
      fondoIcono: Color(0xFFE0F2F1),
      fondoMonto: Color(0xFFE8F5E9),
      textoMonto: Color(0xFF00695C),
    ),
    TipoPresupuestoEmergencia.consumo: _CardPastel(
      acento: Color(0xFFAB7AE0),
      fondoIcono: Color(0xFFF3ECFC),
      fondoMonto: Color(0xFFF5EFFE),
      textoMonto: Color(0xFF7E4FC9),
    ),
    TipoPresupuestoEmergencia.inversiones: _CardPastel(
      acento: Color(0xFFE8915A),
      fondoIcono: Color(0xFFFDF0E8),
      fondoMonto: Color(0xFFFEF3EC),
      textoMonto: Color(0xFFC06D34),
    ),
    TipoPresupuestoEmergencia.servicioTercero: _CardPastel(
      acento: Color(0xFFE57373),
      fondoIcono: Color(0xFFFCECEC),
      fondoMonto: Color(0xFFFDEEEE),
      textoMonto: Color(0xFFD32F2F),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final pastel = _paleta[presupuesto.tipoEnum]!;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: pastel.acento,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: pastel.fondoIcono,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              presupuesto.tipoEnum.icon,
                              color: pastel.acento,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  presupuesto.tipoEnum.labelCorto,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: pastel.textoMonto,
                                    letterSpacing: 0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '#${presupuesto.numero}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            presupuesto.fechaFormateada,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),

                      // BODY
                      if (mostrarEstado && presupuesto is PresupuestoEmergenciaConsultaItem) ...[
                        _buildInfoDinamica(presupuesto as PresupuestoEmergenciaConsultaItem, pastel),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[400]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          presupuesto.usuario,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF4A4A68),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(Icons.domain_rounded, size: 12, color: Colors.grey[400]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _truncarArea(presupuesto.area.isNotEmpty ? presupuesto.area : '—'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: pastel.fondoIcono,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                presupuesto.tipoEnum.icon,
                                color: pastel.acento,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (mostrarEstado) ...[
                        const SizedBox(height: 8),
                        _buildEstadoBadge(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncarArea(String area) {
    if (area.contains('-')) {
      final partes = area.split('-');
      return partes.last.trim();
    }
    if (area.length > 40) {
      return '${area.substring(0, 27)}...';
    }
    return area;
  }

  Widget _buildInfoDinamica(PresupuestoEmergenciaConsultaItem consultaItem, _CardPastel p) {
    String linea1 = '';
    String linea2 = '';
    IconData icono = Icons.info_outline;
    Color iconColor = p.acento;
    String? fechaInfo;
    
    // Atendidos (tiene usuarioAtencion)
    if (consultaItem.usuarioAtencion != null && consultaItem.usuarioAtencion!.isNotEmpty) {
      linea1 = 'ATENDIDO POR';
      linea2 = consultaItem.usuarioAtencion!;
      icono = Icons.check_circle_outline;
      iconColor = EstadoPresupuesto.atendido.color;
      
      if (consultaItem.fechaHoraAtencion != null) {
        final fecha = consultaItem.fechaHoraAtencion!;
        if (fecha.year > 1 && !(fecha.year == 1 && fecha.month == 1 && fecha.day == 1)) {
          fechaInfo = consultaItem.fechaHoraAtencionFormateada;
        }
      }
    }
    // Anulados
    else if (consultaItem.estado != null && consultaItem.estado!.contains('ANULADO:')) {
      linea1 = 'MOTIVO';
      final partes = consultaItem.estado!.split(':');
      final motivo = partes.length > 1 ? partes[1].trim() : '';
      linea2 = motivo.isNotEmpty ? motivo : 'S/N';
      icono = Icons.cancel_outlined;
      iconColor = EstadoPresupuesto.observado.color;
    }
    // Por Atender (tiene estado textual)
    else if (consultaItem.estado != null && consultaItem.estado!.isNotEmpty) {
      if (consultaItem.estado!.contains('EN ESPERA DE AUTORIZACION:')) {
        linea1 = 'ESTADO';
        final partes = consultaItem.estado!.split(':');
        linea2 = partes.length > 1 ? 'EN ESPERA' : consultaItem.estado!;
        icono = Icons.schedule;
        iconColor = EstadoPresupuesto.pendiente.color;
      } else if (consultaItem.estado!.contains('OBSERVADO:')) {
        linea1 = 'OBSERVACIÓN';
        final partes = consultaItem.estado!.split(':');
        linea2 = partes.length > 1 ? partes[1].trim() : consultaItem.estado!;
        icono = Icons.info_outline;
        iconColor = EstadoPresupuesto.observado.color;
      } else if (consultaItem.estado!.contains('FALTA ENVIAR')) {
        linea1 = 'ESTADO';
        linea2 = 'FALTA ENVIAR PARA AUTORIZAR';
        icono = Icons.warning_amber_rounded;
        iconColor = EstadoPresupuesto.pendiente.color;
      } else if (consultaItem.estado!.contains('EN EL DPTO. PRESUPUESTO')) {
        linea1 = 'ESTADO';
        linea2 = 'EN PRESUPUESTO';
        icono = Icons.account_balance_outlined;
        iconColor = EstadoPresupuesto.contabilidad.color;
      } else if (consultaItem.estado!.contains('FALTA CUENTA CONTABLE')) {
        linea1 = 'ESTADO';
        linea2 = 'FALTA CUENTA CONTABLE';
        icono = Icons.numbers_outlined;
        iconColor = EstadoPresupuesto.contabilidad.color;
      } else if (consultaItem.estado!.contains('FALTA PRECIO UNITARIO')) {
        linea1 = 'ESTADO';
        linea2 = 'FALTA PRECIO UNITARIO';
        icono = Icons.payments_outlined;
        iconColor = EstadoPresupuesto.logistica.color;
      } else {
        linea1 = 'ESTADO';
        linea2 = consultaItem.estado!;
        icono = Icons.info_outline;
        iconColor = EstadoPresupuesto.pendiente.color;
      }
    }
    // Por defecto
    else {
      linea1 = 'ESTADO';
      linea2 = consultaItem.estadoPresupuesto.nombre;
      icono = consultaItem.estadoPresupuesto.icon;
      iconColor = consultaItem.estadoPresupuesto.color;
    }
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: p.fondoIcono,
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

  Widget _buildEstadoBadge() {
    if (!mostrarEstado) return const SizedBox.shrink();
    
    // Si es un item de consulta
    if (presupuesto is PresupuestoEmergenciaConsultaItem) {
      final consultaItem = presupuesto as PresupuestoEmergenciaConsultaItem;
      
      Color color;
      Color bgColor;
      IconData icon;
      String texto;
      
      // Atendidos (tiene usuarioAtencion)
      if (consultaItem.usuarioAtencion != null && consultaItem.usuarioAtencion!.isNotEmpty) {
        color = EstadoPresupuesto.atendido.color;
        bgColor = EstadoPresupuesto.atendido.color.withOpacity(0.1);
        icon = EstadoPresupuesto.atendido.icon;
        texto = 'ATENDIDO';
      }
      // Tiene estado textual
      else if (consultaItem.estado != null && consultaItem.estado!.isNotEmpty) {
        if (consultaItem.estado!.contains('ANULADO')) {
          color = EstadoPresupuesto.observado.color;
          bgColor = EstadoPresupuesto.observado.color.withOpacity(0.1);
          icon = EstadoPresupuesto.observado.icon;
          texto = 'ANULADO';
        } else if (consultaItem.estado!.contains('EN ESPERA')) {
          color = EstadoPresupuesto.pendiente.color;
          bgColor = EstadoPresupuesto.pendiente.color.withOpacity(0.1);
          icon = EstadoPresupuesto.pendiente.icon;
          texto = 'EN ESPERA';
        } else if (consultaItem.estado!.contains('OBSERVADO')) {
          color = EstadoPresupuesto.observado.color;
          bgColor = EstadoPresupuesto.observado.color.withOpacity(0.1);
          icon = EstadoPresupuesto.observado.icon;
          texto = 'OBSERVADO';
        } else if (consultaItem.estado!.contains('FALTA ENVIAR')) {
          color = EstadoPresupuesto.pendiente.color;
          bgColor = EstadoPresupuesto.pendiente.color.withOpacity(0.1);
          icon = EstadoPresupuesto.pendiente.icon;
          texto = 'PENDIENTE';
        } else if (consultaItem.estado!.contains('EN EL DPTO. PRESUPUESTO')) {
          color = EstadoPresupuesto.contabilidad.color;
          bgColor = EstadoPresupuesto.contabilidad.color.withOpacity(0.1);
          icon = EstadoPresupuesto.contabilidad.icon;
          texto = 'EN PRESUPUESTO';
        } else if (consultaItem.estado!.contains('FALTA CUENTA CONTABLE')) {
          color = EstadoPresupuesto.contabilidad.color;
          bgColor = EstadoPresupuesto.contabilidad.color.withOpacity(0.1);
          icon = EstadoPresupuesto.contabilidad.icon;
          texto = 'FALTA CUENTA';
        } else if (consultaItem.estado!.contains('FALTA PRECIO UNITARIO')) {
          color = EstadoPresupuesto.logistica.color;
          bgColor = EstadoPresupuesto.logistica.color.withOpacity(0.1);
          icon = EstadoPresupuesto.logistica.icon;
          texto = 'FALTA PRECIO';
        } else {
          color = EstadoPresupuesto.pendiente.color;
          bgColor = EstadoPresupuesto.pendiente.color.withOpacity(0.1);
          icon = EstadoPresupuesto.pendiente.icon;
          texto = 'PENDIENTE';
        }
      } else {
        color = consultaItem.estadoPresupuesto.color;
        bgColor = consultaItem.estadoPresupuesto.color.withOpacity(0.1);
        icon = consultaItem.estadoPresupuesto.icon;
        texto = consultaItem.estadoPresupuesto.nombre;
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
    
    // Para autorización: mostrar estado normal
    // Solo se ejecuta si presupuesto es PresupuestoEmergenciaListaItem
    Color color;
    Color bgColor;
    IconData icon;
    String texto;

    // Intentar obtener estadoActual si está disponible
    EstadoPresupuesto estado;
    if (presupuesto is PresupuestoEmergenciaListaItem) {
      estado = (presupuesto as PresupuestoEmergenciaListaItem).estadoActual ?? EstadoPresupuesto.pendiente;
    } else {
      estado = EstadoPresupuesto.pendiente;
    }

    switch (estado) {
      case EstadoPresupuesto.pendiente:
        color = const Color(0xFFE6A23C);
        bgColor = const Color(0xFFFFF8ED);
        icon = Icons.schedule_rounded;
        texto = 'PENDIENTE';
        break;
      case EstadoPresupuesto.enRevision:
        color = const Color(0xFF5B8DEF);
        bgColor = const Color(0xFFEDF3FF);
        icon = Icons.sync_rounded;
        texto = 'EN REVISIÓN';
        break;
      case EstadoPresupuesto.autorizado:
        color = const Color(0xFF67C23A);
        bgColor = const Color(0xFFEFF8EA);
        icon = Icons.check_circle_outline_rounded;
        texto = 'AUTORIZADO';
        break;
      case EstadoPresupuesto.observado:
        color = const Color(0xFFEF6B6B);
        bgColor = const Color(0xFFFEF0F0);
        icon = Icons.info_outline_rounded;
        texto = 'OBSERVADO';
        break;
      case EstadoPresupuesto.porAutorizar:
        color = const Color(0xFF909399);
        bgColor = const Color(0xFFF4F4F5);
        icon = Icons.pause_circle_outline_rounded;
        texto = 'POR AUTORIZAR';
        break;
      case EstadoPresupuesto.borrador:
        color = const Color(0xFF909399);
        bgColor = const Color(0xFFF4F4F5);
        icon = Icons.edit_outlined;
        texto = 'BORRADOR';
        break;
      case EstadoPresupuesto.atendido:
        color = const Color(0xFF67C23A);
        bgColor = const Color(0xFFEFF8EA);
        icon = Icons.task_alt;
        texto = 'ATENDIDO';
        break;
      case EstadoPresupuesto.contabilidad:
        color = const Color(0xFF673AB7);
        bgColor = const Color(0xFFF3E5F5);
        icon = Icons.account_balance_outlined;
        texto = 'CONTABILIDAD';
        break;
      case EstadoPresupuesto.logistica:
        color = const Color(0xFF795548);
        bgColor = const Color(0xFFD7CCC8);
        icon = Icons.local_shipping_outlined;
        texto = 'LOGÍSTICA';
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(maxWidth: 120),
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