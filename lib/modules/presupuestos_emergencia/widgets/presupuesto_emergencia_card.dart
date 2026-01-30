import 'package:flutter/material.dart';
import '../models/presupuesto_emergencia.dart';

class PresupuestoEmergenciaCard extends StatelessWidget {
  final PresupuestoEmergencia presupuesto;
  final VoidCallback onTap;
  final bool mostrarEstado;

  const PresupuestoEmergenciaCard({
    super.key,
    required this.presupuesto,
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
                presupuesto.prioridad.colorClaro,
                presupuesto.prioridad.color.withOpacity(0.15),
              ],
            ),
            border: Border(
              left: BorderSide(
                color: presupuesto.prioridad.color,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== FILA 1: Badge prioridad + Código ==========
              Row(
                children: [
                  // Badge de prioridad
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: presupuesto.prioridad.color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          presupuesto.prioridad.icon,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          presupuesto.prioridad.label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Código de presupuesto
                  Text(
                    '#${presupuesto.codigo}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ========== FILA 2: Solicitante ==========
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      presupuesto.solicitante.nombreCompleto,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ========== FILA 3: Sección ==========
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Sección: ${presupuesto.solicitante.seccion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ========== FILA 4: Monto + Tiempo ==========
              Row(
                children: [
                  // Monto
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: presupuesto.prioridad.color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 16,
                          color: presupuesto.prioridad.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'S/ ${presupuesto.montoCompletoFormateado}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: presupuesto.prioridad.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Tiempo relativo
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        presupuesto.tiempoRelativo,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ========== FILA 5: Estado (si es pendiente) ==========
              if (presupuesto.esmiTurno && !mostrarEstado) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFB300),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.hourglass_empty,
                        size: 14,
                        color: Color(0xFFFF8F00),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Esperando tu autorización',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8F00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // ========== FILA 6: Badge de estado (para consultas) ==========
              if (mostrarEstado) ...[
                const SizedBox(height: 10),
                _buildEstadoBadge(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge() {
    Color color;
    Color bgColor;
    IconData icon;
    String texto;

    switch (presupuesto.estadoActual) {
      case EstadoPresupuesto.pendiente:
        color = const Color(0xFFFF9800);
        bgColor = const Color(0xFFFFF3E0);
        icon = Icons.hourglass_empty;
        texto = 'PENDIENTE';
        break;
      case EstadoPresupuesto.enProceso:
        color = const Color(0xFF2196F3);
        bgColor = const Color(0xFFE3F2FD);
        icon = Icons.sync;
        texto = 'EN PROCESO';
        break;
      case EstadoPresupuesto.autorizado:
        color = const Color(0xFF4CAF50);
        bgColor = const Color(0xFFE8F5E9);
        icon = Icons.check_circle_outline;
        texto = 'AUTORIZADO';
        break;
      case EstadoPresupuesto.observado:
        color = const Color(0xFFF44336);
        bgColor = const Color(0xFFFFEBEE);
        icon = Icons.error_outline;
        texto = 'OBSERVADO';
        break;
      case EstadoPresupuesto.enCola:
        color = const Color(0xFF9E9E9E);
        bgColor = const Color(0xFFF5F5F5);
        icon = Icons.pause_circle_outline;
        texto = 'EN COLA';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
