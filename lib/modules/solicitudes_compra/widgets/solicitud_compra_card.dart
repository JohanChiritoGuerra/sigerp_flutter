import 'package:flutter/material.dart';
import '../models/solicitud_compra.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                solicitud.tipo.color.withOpacity(0.08),
                solicitud.tipo.color.withOpacity(0.15),
              ],
            ),
            border: Border(
              left: BorderSide(
                color: solicitud.tipo.color,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // ========== COLUMNA 1: Icono + Tipo/Área ==========
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    // Icono (sin fondo redondo)
                    Icon(
                      solicitud.tipo.icon,
                      color: solicitud.tipo.color,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fila 1: Tipo
                          Text(
                            solicitud.tipo.nombre,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: solicitud.tipo.color,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Fila 2: Área
                          Text(
                            solicitud.areaSolicitante,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: solicitud.tipo.color.withOpacity(0.7),
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

              // ========== COLUMNA 2: Número + Fecha ==========
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fila 1: Número
                    Text(
                      solicitud.codigo,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Fila 2: Fecha
                    Text(
                      solicitud.fechaFormateada,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // ========== COLUMNA 3: Monto ==========
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'S/ ${solicitud.montoCompletoFormateado}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: solicitud.tipo.color,
                    ),
                  ),
                  if (mostrarEstado) ...[
                    const SizedBox(height: 4),
                    _buildEstadoBadge(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge() {
    Color color;
    String texto;

    switch (solicitud.estado) {
      case EstadoSolicitud.pendiente:
        color = const Color(0xFFFF9800);
        texto = 'PENDIENTE';
        break;
      case EstadoSolicitud.enProceso:
        color = const Color(0xFF2196F3);
        texto = 'EN PROCESO';
        break;
      case EstadoSolicitud.autorizado:
        color = const Color(0xFF4CAF50);
        texto = 'AUTORIZADO';
        break;
      case EstadoSolicitud.observado:
        color = const Color(0xFFF44336);
        texto = 'OBSERVADO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
