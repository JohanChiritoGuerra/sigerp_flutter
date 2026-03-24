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
  final PresupuestoEmergenciaListaItem presupuesto;
  final VoidCallback onTap;
  final bool mostrarEstado;

  const PresupuestoEmergenciaCard({
    super.key,
    required this.presupuesto,
    required this.onTap,
    this.mostrarEstado = false,
  });

  // CORRECCIÓN 1: Agregar el tipo faltante cargasDiversas
  static const Map<TipoPresupuestoEmergencia, _CardPastel> _paleta = {
    TipoPresupuestoEmergencia.cargasDiversas: _CardPastel(
      acento: Color(0xFF009688),       // Verde azulado
      fondoIcono: Color(0xFFE0F2F1),
      fondoMonto: Color(0xFFE8F5E9),
      textoMonto: Color(0xFF00695C),
    ),
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
    // CORRECCIÓN 2: Usar tipoEnum en lugar de tipoPresupuesto
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
                              // CORRECCIÓN 3: Usar tipoEnum.icon
                              presupuesto.tipoEnum.icon,
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
                                  // CORRECCIÓN 4: Usar tipoEnum.labelCorto o label según prefieras
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
                                  // CORRECCIÓN 5: Usar numero en lugar de codigo
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
                                        // CORRECCIÓN 6: Usar usuario en lugar de solicitante.nombreCompleto
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
                                    Expanded(  // ← Agregar Expanded aquí también
                                      child: Text(
                                        _truncarArea(presupuesto.area), // ← Usar función para truncar
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
                          // Icono de tipo con fondo
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

  String _truncarArea(String area) {
    if (area.contains('-')) {
      final partes = area.split('-');
      return partes.last.trim();
    }
    // Si es muy larga, truncar
    if (area.length > 40) {
      return '${area.substring(0, 27)}...';
    }
    return area;
  }

  Widget _buildEstadoBadge() {
    // CORRECCIÓN 8: Manejar el caso null del estado
    final estado = presupuesto.estadoActual ?? EstadoPresupuesto.pendiente;
    
    Color color;
    Color bgColor;
    IconData icon;
    String texto;

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
      alignment: Alignment.centerLeft, // ← Cambiar de center a centerLeft
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(
          maxWidth: 120, // ← Agregar ancho máximo
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible( // ← Usar Flexible para que el texto se ajuste
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis, // ← Agregar overflow
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}