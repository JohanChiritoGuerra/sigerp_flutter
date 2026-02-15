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
  final SolicitudCompra solicitud;
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
      acento: Color(0xFFAB7AE0),       // Morado pastel
      fondoClaro: Color(0xFFF5F0FC),
      textoFuerte: Color(0xFF7E4FC9),
      fondoMonto: Color(0xFFEBE2F7),
    ),
    TipoSolicitudCompra.compraActivoFijo: _SCPastel(
      acento: Color(0xFFE8915A),       // Naranja pastel
      fondoClaro: Color(0xFFFFF5ED),
      textoFuerte: Color(0xFFC06D34),
      fondoMonto: Color(0xFFFDEBDA),
    ),
    TipoSolicitudCompra.servicioTercero: _SCPastel(
      acento: Color(0xFFE57373),       // Rojo pastel
      fondoClaro: Color(0xFFFFF0F0),
      textoFuerte: Color(0xFFD32F2F),
      fondoMonto: Color(0xFFFDEEEE),
    ),
    TipoSolicitudCompra.cargaDiversaGestion: _SCPastel(
      acento: Color(0xFF4CAF6A),       // Verde pastel
      fondoClaro: Color(0xFFEFF9F3),
      textoFuerte: Color(0xFF2E8B4A),
      fondoMonto: Color(0xFFE0F2E5),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final p = _paleta[solicitud.tipo]!;

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══ ROW 1: Badge tipo + código + fecha ═══
                  Row(
                    children: [
                      // Badge tipo con icono
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
                              solicitud.tipo.icon,
                              color: p.acento,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              solicitud.tipo.nombre,
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
                      // Código
                      Text(
                        solicitud.codigo,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      // Fecha
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

                  // ═══ ROW 2: Área + Solicitante + Monto ═══
                  Row(
                    children: [
                      // Info izquierda
                      Expanded(
                        child: Row(
                          children: [
                            // Avatar con iniciales
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: p.fondoClaro,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  solicitud.tipo.codigo,
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
                                    solicitud.areaSolicitante,
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
                                    solicitud.solicitanteNombre,
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
                      const SizedBox(width: 8),
                      // Monto
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.fondoMonto,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'S/ ${solicitud.montoCompletoFormateado}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: p.textoFuerte,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ═══ ESTADO (solo consultas) ═══
                  if (mostrarEstado) ...[
                    const SizedBox(height: 8),
                    _buildEstadoBadge(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoBadge() {
    Color color;
    Color bgColor;
    IconData icon;
    String texto;

    switch (solicitud.estado) {
      case EstadoSolicitud.pendiente:
        color = const Color(0xFFE6A23C);
        bgColor = const Color(0xFFFFF8ED);
        icon = Icons.schedule_rounded;
        texto = 'PENDIENTE';
        break;
      case EstadoSolicitud.enProceso:
        color = const Color(0xFF5B8DEF);
        bgColor = const Color(0xFFEDF3FF);
        icon = Icons.sync_rounded;
        texto = 'EN PROCESO';
        break;
      case EstadoSolicitud.autorizado:
        color = const Color(0xFF67C23A);
        bgColor = const Color(0xFFEFF8EA);
        icon = Icons.check_circle_outline_rounded;
        texto = 'AUTORIZADO';
        break;
      case EstadoSolicitud.observado:
        color = const Color(0xFFEF6B6B);
        bgColor = const Color(0xFFFEF0F0);
        icon = Icons.info_outline_rounded;
        texto = 'OBSERVADO';
        break;
    }

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              texto,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
