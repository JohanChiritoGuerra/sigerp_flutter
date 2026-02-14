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
  final PresupuestoEmergencia presupuesto;
  final VoidCallback onTap;
  final bool mostrarEstado;

  const PresupuestoEmergenciaCard({
    super.key,
    required this.presupuesto,
    required this.onTap,
    this.mostrarEstado = false,
  });

  // Paleta pastel según tipo
  static const Map<TipoPresupuestoEmergencia, _CardPastel> _paleta = {
    TipoPresupuestoEmergencia.consumo: _CardPastel(
      acento: Color(0xFFAB7AE0),       // Morado pastel
      fondoIcono: Color(0xFFF3ECFC),
      fondoMonto: Color(0xFFF5EFFE),
      textoMonto: Color(0xFF7E4FC9),
    ),
    TipoPresupuestoEmergencia.inversiones: _CardPastel(
      acento: Color(0xFFE8915A),       // Naranja pastel
      fondoIcono: Color(0xFFFDF0E8),
      fondoMonto: Color(0xFFFEF3EC),
      textoMonto: Color(0xFFC06D34),
    ),
    TipoPresupuestoEmergencia.servicioTercero: _CardPastel(
      acento: Color(0xFFE57373),       // Rojo pastel
      fondoIcono: Color(0xFFFCECEC),
      fondoMonto: Color(0xFFFDEEEE),
      textoMonto: Color(0xFFD32F2F),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final pastel = _paleta[presupuesto.tipoPresupuesto]!;

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
              // ── Borde izquierdo con color pastel ──
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
              // ── Contenido ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ═══ HEADER: Icono + Tipo/Código + Fecha ═══
                      Row(
                        children: [
                          // Icono circular pastel
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: pastel.fondoIcono,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              presupuesto.tipoPresupuesto.icon,
                              color: pastel.acento,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Tipo + código
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  presupuesto.tipoPresupuesto.label,
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
                                  '#${presupuesto.codigo}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Fecha
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

                      // ── Separador sutil ──
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.shade100,
                        ),
                      ),

                      // ═══ BODY: Persona + Sección + Monto ═══
                      Row(
                        children: [
                          // Persona y sección
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
                                        presupuesto.solicitante.nombreCompleto,
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
                                    Text(
                                      presupuesto.solicitante.seccion,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Monto con chip pastel
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: pastel.fondoMonto,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'S/ ${presupuesto.montoCompletoFormateado}',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: pastel.textoMonto,
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
              ),
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
        color = const Color(0xFFE6A23C);
        bgColor = const Color(0xFFFFF8ED);
        icon = Icons.schedule_rounded;
        texto = 'PENDIENTE';
        break;
      case EstadoPresupuesto.enProceso:
        color = const Color(0xFF5B8DEF);
        bgColor = const Color(0xFFEDF3FF);
        icon = Icons.sync_rounded;
        texto = 'EN PROCESO';
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
      case EstadoPresupuesto.enCola:
        color = const Color(0xFF909399);
        bgColor = const Color(0xFFF4F4F5);
        icon = Icons.pause_circle_outline_rounded;
        texto = 'EN COLA';
        break;
    }

    return Align(
      alignment: Alignment.centerRight,
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
