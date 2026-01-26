import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../models/solicitud_compra.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            solicitud.tipo.color.withOpacity(0.1),
            solicitud.tipo.color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: solicitud.tipo.color,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            solicitud.tipo.icon,
            color: solicitud.tipo.color,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              solicitud.tipo.nombre,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: solicitud.tipo.color,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: solicitud.tipo.colorOscuro),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: solicitud.tipo.colorOscuro,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: solicitud.tipo.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'S/ ${solicitud.montoCompletoFormateado}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: solicitud.tipo.color,
            ),
          ),
        ],
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
                    color: solicitud.tipo.color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila 1: Código y Descripción
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Código
                        if (item.codigo.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: solicitud.tipo.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.codigo,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: solicitud.tipo.color,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Fila 2: Cantidad, Unidad, Precio Unitario, Subtotal
                    Row(
                      children: [
                        // Cantidad y Unidad
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
                        // Precio unitario
                        Text(
                          'x S/ ${item.precioUnitarioFormateado}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        // Subtotal
                        Text(
                          'S/ ${item.subtotalFormateado}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: solicitud.tipo.colorOscuro,
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
