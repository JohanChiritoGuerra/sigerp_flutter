import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../models/presupuesto_emergencia.dart';

class PresupuestoDetalleModal extends StatelessWidget {
  final PresupuestoEmergencia presupuesto;
  final bool mostrarAcciones;
  final bool modoConsulta;
  final VoidCallback? onAutorizar;
  final VoidCallback? onObservar;

  const PresupuestoDetalleModal({
    super.key,
    required this.presupuesto,
    this.mostrarAcciones = true,
    this.modoConsulta = false,
    this.onAutorizar,
    this.onObservar,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle para drag
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con prioridad
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Información General
                    _buildSeccion(
                      icono: Icons.description_outlined,
                      titulo: 'INFORMACIÓN',
                      child: _buildInformacionGeneral(),
                    ),
                    const SizedBox(height: 20),

                    // Descripción
                    if (presupuesto.descripcion.isNotEmpty) ...[
                      _buildSeccion(
                        icono: Icons.article_outlined,
                        titulo: 'DESCRIPCIÓN',
                        child: _buildDescripcion(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Items
                    if (presupuesto.items != null &&
                        presupuesto.items!.isNotEmpty) ...[
                      _buildSeccion(
                        icono: Icons.inventory_2_outlined,
                        titulo: 'ITEMS (${presupuesto.items!.length})',
                        child: _buildListaItems(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Historial de autorizaciones
                    if (presupuesto.historialAutorizaciones != null &&
                        presupuesto.historialAutorizaciones!.isNotEmpty) ...[
                      _buildSeccion(
                        icono: Icons.history,
                        titulo: 'HISTORIAL AUTORIZACIONES',
                        child: _buildHistorialAutorizaciones(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 80), // Espacio para los botones
                  ],
                ),
              ),
            ),

            // Botones de acción
            if (mostrarAcciones) _buildBotonesAccion(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            presupuesto.prioridad.colorClaro,
            presupuesto.prioridad.color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: presupuesto.prioridad.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Badge grande de prioridad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: presupuesto.prioridad.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: presupuesto.prioridad.color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  presupuesto.prioridad.icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  presupuesto.prioridad.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Código de presupuesto
          Text(
            'Presupuesto #${presupuesto.codigo}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion({
    required IconData icono,
    required String titulo,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: presupuesto.prioridad.color),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: presupuesto.prioridad.color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInformacionGeneral() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Solicitante', presupuesto.solicitante.nombreCompleto),
          _buildInfoRow('Sección', presupuesto.solicitante.seccion),
          if (presupuesto.solicitante.cargo != null)
            _buildInfoRow('Cargo', presupuesto.solicitante.cargo!),
          _buildInfoRow('Fecha', presupuesto.fechaHoraFormateada),
          const Divider(height: 24),
          // Monto total destacado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: presupuesto.prioridad.colorClaro,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'MONTO TOTAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${presupuesto.montoCompletoFormateado}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: presupuesto.prioridad.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        presupuesto.descripcion,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildListaItems() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...presupuesto.items!.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == presupuesto.items!.length - 1;

            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: presupuesto.prioridad.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Bullet
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: presupuesto.prioridad.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Descripción
                      Expanded(
                        child: Text(
                          item.descripcion,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Monto
                      Text(
                        'S/ ${item.montoFormateado}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: presupuesto.prioridad.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const SizedBox(height: 8),
              ],
            );
          }),
          // Total
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: presupuesto.prioridad.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: presupuesto.prioridad.color,
                  ),
                ),
                Text(
                  'S/ ${presupuesto.montoCompletoFormateado}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: presupuesto.prioridad.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialAutorizaciones() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: presupuesto.historialAutorizaciones!.map((historial) {
          return _buildItemHistorial(historial);
        }).toList(),
      ),
    );
  }

  Widget _buildItemHistorial(AutorizacionHistorial historial) {
    IconData icono;
    Color colorIcono;
    String estadoTexto;

    switch (historial.estado) {
      case EstadoPresupuesto.autorizado:
        icono = Icons.check_circle;
        colorIcono = const Color(0xFF4CAF50);
        estadoTexto = 'Autorizado';
        break;
      case EstadoPresupuesto.observado:
        icono = Icons.cancel;
        colorIcono = const Color(0xFFF44336);
        estadoTexto = 'Observado';
        break;
      case EstadoPresupuesto.pendiente:
        icono = Icons.hourglass_empty;
        colorIcono = const Color(0xFFFF9800);
        estadoTexto = 'PENDIENTE - Tú';
        break;
      case EstadoPresupuesto.enCola:
        icono = Icons.pause_circle_outline;
        colorIcono = const Color(0xFF9E9E9E);
        estadoTexto = 'En cola';
        break;
      default:
        icono = Icons.pending;
        colorIcono = const Color(0xFF9E9E9E);
        estadoTexto = 'En proceso';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorIcono.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono de estado
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorIcono.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icono,
              color: colorIcono,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del nivel
                Row(
                  children: [
                    Text(
                      historial.nombreNivel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorIcono.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        estadoTexto,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorIcono,
                        ),
                      ),
                    ),
                  ],
                ),
                // Nombre del autorizador
                if (historial.autorizador != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    historial.autorizador!.nombreCompleto,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                // Fecha
                if (historial.fechaAccion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    historial.fechaFormateada,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
                // Observación
                if (historial.observacion != null &&
                    historial.observacion!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      historial.observacion!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón Observar
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onObservar?.call();
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('OBSERVAR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(AppColors.errorColor),
                side: BorderSide(color: Color(AppColors.errorColor)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Botón Autorizar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAutorizar,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('AUTORIZAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.successColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
