import 'package:flutter/material.dart';
import '../models/solicitud_compra.dart';

/// Paleta pastel por tipo de solicitud
class _SCModalPastel {
  final Color acento;
  final Color fondoClaro;
  final Color textoFuerte;
  final Color fondoMonto;

  const _SCModalPastel({
    required this.acento,
    required this.fondoClaro,
    required this.textoFuerte,
    required this.fondoMonto,
  });
}

class SolicitudDetalleModal extends StatelessWidget {
  final SolicitudCompra solicitud;
  final bool mostrarAcciones;
  final VoidCallback? onAutorizar;
  final VoidCallback? onObservar;

  const SolicitudDetalleModal({
    super.key,
    required this.solicitud,
    this.mostrarAcciones = true,
    this.onAutorizar,
    this.onObservar,
  });

  static const Map<TipoSolicitudCompra, _SCModalPastel> _paleta = {
    TipoSolicitudCompra.compraMateriales: _SCModalPastel(
      acento: Color(0xFFAB7AE0),
      fondoClaro: Color(0xFFF5F0FC),
      textoFuerte: Color(0xFF7E4FC9),
      fondoMonto: Color(0xFFEBE2F7),
    ),
    TipoSolicitudCompra.compraActivoFijo: _SCModalPastel(
      acento: Color(0xFFE8915A),
      fondoClaro: Color(0xFFFFF5ED),
      textoFuerte: Color(0xFFC06D34),
      fondoMonto: Color(0xFFFDEBDA),
    ),
    TipoSolicitudCompra.servicioTercero: _SCModalPastel(
      acento: Color(0xFFE57373),
      fondoClaro: Color(0xFFFFF0F0),
      textoFuerte: Color(0xFFD32F2F),
      fondoMonto: Color(0xFFFDEEEE),
    ),
    TipoSolicitudCompra.cargaDiversaGestion: _SCModalPastel(
      acento: Color(0xFF4CAF6A),
      fondoClaro: Color(0xFFEFF9F3),
      textoFuerte: Color(0xFF2E8B4A),
      fondoMonto: Color(0xFFE0F2E5),
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
                    // Header con tipo de solicitud
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Información General
                    _buildSeccion(
                      icono: Icons.description_outlined,
                      titulo: 'INFORMACIÓN GENERAL',
                      child: _buildInformacionGeneral(),
                    ),
                    const SizedBox(height: 20),

                    // Sustento (movido antes de monto)
                    if (solicitud.sustento != null &&
                        solicitud.sustento!.isNotEmpty) ...[
                      _buildSeccion(
                        icono: Icons.article_outlined,
                        titulo: 'SUSTENTO',
                        child: _buildSustento(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Monto Estimado
                    _buildSeccion(
                      icono: Icons.payments_outlined,
                      titulo: 'MONTO ESTIMADO',
                      child: _buildMontoEstimado(),
                    ),
                    const SizedBox(height: 20),

                    // Items
                    if (solicitud.items.isNotEmpty) ...[
                      _buildSeccion(
                        icono: Icons.inventory_2_outlined,
                        titulo: 'ITEMS (${solicitud.items.length})',
                        child: _buildListaItems(),
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
    final p = _paleta[solicitud.tipo]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: p.fondoClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.acento.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              solicitud.tipo.icon,
              color: p.acento,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              solicitud.tipo.nombre,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.textoFuerte,
                letterSpacing: 0.3,
              ),
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
    final p = _paleta[solicitud.tipo]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: p.textoFuerte),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: p.textoFuerte,
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
          _buildInfoRow('Solicitud', '#${solicitud.codigo}'),
          _buildInfoRow('Fecha', solicitud.fechaFormateada),
          _buildInfoRow('Área', solicitud.areaSolicitante),
          _buildInfoRow('Solicitante', solicitud.solicitanteNombre),
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

  Widget _buildMontoEstimado() {
    final p = _paleta[solicitud.tipo]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: p.fondoMonto,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'S/ ${solicitud.montoCompletoFormateado}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: p.textoFuerte,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaItems() {
    final p = _paleta[solicitud.tipo]!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: solicitud.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == solicitud.items.length - 1;
          
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: p.acento.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.codigo.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.fondoClaro,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.codigo,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: p.acento,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.cantidad} ${item.unidadMedida}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'x S/ ${item.precioUnitarioFormateado}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'S/ ${item.subtotalFormateado}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.textoFuerte,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast) const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSustento() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        solicitud.sustento ?? '',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context) {
    final p = _paleta[solicitud.tipo]!;
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
              icon: const Icon(Icons.front_hand_rounded, size: 20),
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
                backgroundColor: p.textoFuerte,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: p.textoFuerte.withOpacity(0.4),
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
