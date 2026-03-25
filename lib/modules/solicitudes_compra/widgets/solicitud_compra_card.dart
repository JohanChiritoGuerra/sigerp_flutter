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
  final SolicitudCompraListaItem solicitud;
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
    if (area.contains('-->')) {
      final partes = area.split('-->');
      return partes.last.trim();
    }
    if (area.length > 40) {
      return '${area.substring(0, 37)}...';
    }
    return area;
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

              // ROW 2: Área + Solicitante
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
                                _truncarArea(solicitud.area),
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
    // Por ahora, como el estado no viene en la lista, usamos un placeholder
    // En la pantalla de consulta se puede determinar según el tab
    final color = Colors.grey[500]!;
    final bgColor = Colors.grey[100]!;
    final icon = Icons.info_outline_rounded;
    final texto = 'PENDIENTE';

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