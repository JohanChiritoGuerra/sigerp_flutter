import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../models/solicitud_compra.dart';
import '../services/solicitud_compra_service.dart';

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

class SolicitudDetalleModal extends StatefulWidget {
  final SolicitudCompraListaItem solicitud;
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
  State<SolicitudDetalleModal> createState() => _SolicitudDetalleModalState();
}

class _SolicitudDetalleModalState extends State<SolicitudDetalleModal> {
  final SolicitudCompraService _service = SolicitudCompraService();
  bool _isLoading = true;
  String? _error;
  SolicitudCompraDetalleResponse? _detalle;

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
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = context.read<AuthService>();
      final usuario = authService.usuario;

      final result = await _service.obtenerDetalle(
        solComCabId: widget.solicitud.solComCabId,
        tipOpeCompId: widget.solicitud.tipOpeCompId,
        usuario: usuario?.webUser ?? '',
        empresaId: usuario?.empresaId ?? '02',
      );

      if (mounted) {
        setState(() {
          if (result.esExitoso) {
            _detalle = result;
          } else {
            _error = result.baseResponse.message ?? 'Error al cargar detalle';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _paleta[widget.solicitud.tipoEnum]!;

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
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: p.acento))
                  : _error != null
                      ? _buildError(p)
                      : SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(p),
                              const SizedBox(height: 24),
                              _buildSeccion(
                                icono: Icons.description_outlined,
                                titulo: 'INFORMACIÓN GENERAL',
                                pastel: p,
                                child: _buildInformacionGeneral(),
                              ),
                              const SizedBox(height: 20),
                              if (_detalle?.encabezado?.usoMotivo != null &&
                                  _detalle!.encabezado!.usoMotivo.isNotEmpty) ...[
                                _buildSeccion(
                                  icono: Icons.article_outlined,
                                  titulo: 'SUSTENTO',
                                  pastel: p,
                                  child: _buildSustento(),
                                ),
                                const SizedBox(height: 20),
                              ],
                              _buildSeccion(
                                icono: Icons.payments_outlined,
                                titulo: 'MONTO ESTIMADO',
                                pastel: p,
                                child: _buildMontoEstimado(p),
                              ),
                              const SizedBox(height: 20),
                              if (_detalle?.detalle.isNotEmpty ?? false) ...[
                                _buildSeccion(
                                  icono: Icons.inventory_2_outlined,
                                  titulo: 'ITEMS (${_detalle?.detalle.length ?? 0})',
                                  pastel: p,
                                  child: _buildListaItems(p),
                                ),
                              ],
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
            ),
            if (widget.mostrarAcciones) _buildBotonesAccion(context, p),
          ],
        ),
      ),
    );
  }

  Widget _buildError(_SCModalPastel pastel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarDetalle,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: pastel.acento,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(_SCModalPastel p) {
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
              widget.solicitud.tipoEnum.icon,
              color: p.acento,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.solicitud.tipoEnum.nombre,
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
    required _SCModalPastel pastel,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: pastel.textoFuerte),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: pastel.textoFuerte,
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
    final enc = _detalle?.encabezado;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Solicitud', '#${widget.solicitud.numero}'),
          _buildInfoRow('Fecha', widget.solicitud.fechaFormateada),
          _buildInfoRow('Área', widget.solicitud.area),
          _buildInfoRow('Solicitante', widget.solicitud.usuario),
          if ((enc?.cc ?? '').isNotEmpty) _buildInfoRow('C. Costo', enc!.cc),
          if ((enc?.descripcionGds ?? '').isNotEmpty || (enc?.gds ?? '').isNotEmpty)
            _buildInfoRow('GDS',
                (enc?.descripcionGds ?? '').isNotEmpty
                    ? enc!.descripcionGds
                    : enc!.gds),
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
              value.isEmpty ? '—' : value,
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

  Widget _buildMontoEstimado(_SCModalPastel p) {
    final total = _detalle?.totalFormateado ?? 'S/ 0.00';
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
            total,
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

  Widget _buildListaItems(_SCModalPastel p) {
    final items = _detalle?.detalle ?? [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          
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
                            item.item,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: p.acento,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.itemDes,
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
                            '${_formatCantidad(item.cantidad)} ${item.und}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'x ${item.montoReferencialFormateado}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.subtotalFormateado,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.textoFuerte,
                          ),
                        ),
                      ],
                    ),
                    if (item.cc.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.account_tree_outlined,
                              size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            'CC: ${item.cc}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
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

  String _formatCantidad(double cantidad) {
    if (cantidad == cantidad.truncateToDouble()) {
      return cantidad.toInt().toString();
    }
    return cantidad.toStringAsFixed(2);
  }

  Widget _buildSustento() {
    final texto = _detalle?.encabezado?.usoMotivo ?? 
                  _detalle?.encabezado?.observacion ?? 
                  'Sin descripción';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context, _SCModalPastel p) {
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
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onObservar?.call();
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
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onAutorizar,
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