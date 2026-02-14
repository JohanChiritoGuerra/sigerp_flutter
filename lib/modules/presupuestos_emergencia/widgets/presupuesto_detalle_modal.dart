import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../models/presupuesto_emergencia.dart';

/// Paleta pastel por tipo (misma que el card)
class _ModalPastel {
  final Color acento;
  final Color fondoIcono;
  final Color fondoMonto;
  final Color textoMonto;

  const _ModalPastel({
    required this.acento,
    required this.fondoIcono,
    required this.fondoMonto,
    required this.textoMonto,
  });
}

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

  static const Map<TipoPresupuestoEmergencia, _ModalPastel> _paleta = {
    TipoPresupuestoEmergencia.consumo: _ModalPastel(
      acento: Color(0xFFAB7AE0),
      fondoIcono: Color(0xFFF3ECFC),
      fondoMonto: Color(0xFFF5EFFE),
      textoMonto: Color(0xFF7E4FC9),
    ),
    TipoPresupuestoEmergencia.inversiones: _ModalPastel(
      acento: Color(0xFFE8915A),
      fondoIcono: Color(0xFFFDF0E8),
      fondoMonto: Color(0xFFFEF3EC),
      textoMonto: Color(0xFFC06D34),
    ),
    TipoPresupuestoEmergencia.servicioTercero: _ModalPastel(
      acento: Color(0xFFE57373),
      fondoIcono: Color(0xFFFCECEC),
      fondoMonto: Color(0xFFFDEEEE),
      textoMonto: Color(0xFFD32F2F),
    ),
  };

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
    final pastel = _paleta[presupuesto.tipoPresupuesto]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono de tipo con color pastel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pastel.fondoIcono,
              shape: BoxShape.circle,
            ),
            child: Icon(
              presupuesto.tipoPresupuesto.icon,
              color: pastel.acento,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  presupuesto.tipoPresupuesto.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: pastel.textoMonto,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
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
    final pastel = _paleta[presupuesto.tipoPresupuesto]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: pastel.acento),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: pastel.textoMonto,
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
          _buildInfoRow('Fecha', presupuesto.fechaHoraFormateada),
          const Divider(height: 24),
          // Monto total destacado
          Builder(builder: (_) {
            final p = _paleta[presupuesto.tipoPresupuesto]!;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: p.fondoMonto,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'MONTO TOTAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'S/ ${presupuesto.montoCompletoFormateado}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: p.textoMonto,
                    ),
                  ),
                ],
              ),
            );
          }),
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
                      color: _paleta[presupuesto.tipoPresupuesto]!.acento.withOpacity(0.2),
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
                          color: _paleta[presupuesto.tipoPresupuesto]!.acento,
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
                          color: _paleta[presupuesto.tipoPresupuesto]!.textoMonto,
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
          Builder(builder: (_) {
            final p = _paleta[presupuesto.tipoPresupuesto]!;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: p.fondoMonto,
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
                      color: p.textoMonto,
                    ),
                  ),
                  Text(
                    'S/ ${presupuesto.montoCompletoFormateado}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: p.textoMonto,
                    ),
                  ),
                ],
              ),
            );
          }),
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
    final pastel = _paleta[presupuesto.tipoPresupuesto]!;
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
              icon: const Icon(Icons.highlight_off_rounded, size: 20),
              label: const Text(
                'OBSERVAR',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  letterSpacing: 0.3,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF6B6B),
                side: const BorderSide(color: Color(0xFFEF6B6B), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Botón Autorizar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAutorizar,
              icon: const Icon(Icons.verified_rounded, size: 20),
              label: const Text(
                'AUTORIZAR',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: pastel.acento,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: pastel.acento.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
