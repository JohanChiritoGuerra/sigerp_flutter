import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../models/presupuesto_emergencia.dart';
import '../services/presupuesto_emergencia_service.dart';

/// Paleta pastel por tipo
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

class PresupuestoDetalleModal extends StatefulWidget {
  final PresupuestoEmergenciaListaItem presupuesto;
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
  State<PresupuestoDetalleModal> createState() =>
      _PresupuestoDetalleModalState();
}

class _PresupuestoDetalleModalState extends State<PresupuestoDetalleModal> {
  final PresupuestoEmergenciaService _service = PresupuestoEmergenciaService();

  bool _isLoading = true;
  String? _error;
  PresupuestoEmergenciaDetalleResponse? _detalle;

  static const Map<TipoPresupuestoEmergencia, _ModalPastel> _paleta = {
    TipoPresupuestoEmergencia.cargasDiversas: _ModalPastel(
      acento: Color(0xFF009688),
      fondoIcono: Color(0xFFE0F2F1),
      fondoMonto: Color(0xFFE8F5E9),
      textoMonto: Color(0xFF00695C),
    ),
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

    PresupuestoEmergenciaDetalleResponse result;
    
    if (widget.modoConsulta) {
      result = await _service.obtenerDetalleConsulta(
        id: widget.presupuesto.idPresupuestoEmergencia,
        idSubtipo: widget.presupuesto.idSubtipoPresupuesto,
        usuario: usuario?.webUser ?? '',
        empresaId: usuario?.empresaId ?? '02',
      );
    } else {
      result = await _service.obtenerDetalle(
        id: widget.presupuesto.idPresupuestoEmergencia,
        idSubtipo: widget.presupuesto.idSubtipoPresupuesto,
        usuario: usuario?.webUser ?? '',
        empresaId: usuario?.empresaId ?? '02',
      );
    }

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
    final pastel =
        _paleta[widget.presupuesto.tipoEnum] ?? _paleta[TipoPresupuestoEmergencia.consumo]!;

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

            // Contenido
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: pastel.acento),
                    )
                  : _error != null
                      ? _buildError(pastel)
                      : _buildContenido(scrollController, pastel),
            ),

            // Botones de acción
            if (widget.mostrarAcciones) _buildBotonesAccion(context, pastel),
          ],
        ),
      ),
    );
  }

  Widget _buildError(_ModalPastel pastel) {
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

  Widget _buildContenido(
    ScrollController scrollController, _ModalPastel pastel) {
    final enc = _detalle?.encabezado;
    final items = _detalle?.detalle ?? [];
    final total = _detalle?.total ?? 0.0;
    final totalFormateado = _detalle?.totalFormateado ?? '0.00';
    // Eliminar esta línea: final moneda = items.isNotEmpty ? (items.first.monedaId ?? 'S/') : 'S/';

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(pastel),
          const SizedBox(height: 20),

          // Información General - Quitar el parámetro moneda
          _buildSeccion(
            icono: Icons.description_outlined,
            titulo: 'INFORMACIÓN',
            pastel: pastel,
            child: _buildInformacionGeneral(pastel, enc, totalFormateado), // ← Quitar moneda
          ),
          const SizedBox(height: 20),

          // Descripción / Uso Motivo
          _buildSeccion(
            icono: Icons.article_outlined,
            titulo: 'DESCRIPCIÓN / USO',
            pastel: pastel,
            child: _buildDescripcion(enc),
          ),
          const SizedBox(height: 20),

          // Items - Quitar el parámetro moneda
          _buildSeccion(
            icono: Icons.inventory_2_outlined,
            titulo: 'ITEMS (${items.length})',
            pastel: pastel,
            child: _buildListaItems(items, pastel), // ← Quitar moneda
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(_ModalPastel pastel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pastel.fondoIcono,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.presupuesto.tipoEnum.icon,
              color: pastel.acento,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.presupuesto.tipoEnum.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: pastel.textoMonto,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Presupuesto #${widget.presupuesto.numero}',
                  style: TextStyle(
                    fontSize: 15,
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

  // ─── Sección genérica ──────────────────────────────────────────────────────

  Widget _buildSeccion({
    required IconData icono,
    required String titulo,
    required _ModalPastel pastel,
    required Widget child,
  }) {
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
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  // ─── Información General ──────────────────────────────────────────────────

  Widget _buildInformacionGeneral(
    _ModalPastel pastel,
    PresupuestoEmergenciaEncabezado? enc,
    String totalFormateado, 
  ) {
    final areaMostrar = widget.presupuesto.area.isNotEmpty 
    ? widget.presupuesto.area 
    : (enc?.area ?? '—');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow('Número', enc?.numero ?? widget.presupuesto.numero),
          _buildInfoRow('Usuario', widget.presupuesto.usuario),
          _buildInfoRow('Área', areaMostrar),
          if ((enc?.gds ?? '').isNotEmpty)
            _buildInfoRow('GDS', enc!.descripcionGds),
                //? enc.descripcionGds
                //: enc.gds),
          if ((enc?.cc ?? '').isNotEmpty)
            _buildInfoRow('C. Costo', enc!.cc),
          _buildInfoRow(
            'Fecha',
            enc?.fechaFormateada ?? widget.presupuesto.fechaFormateada,
          ),
          const Divider(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: pastel.fondoMonto,
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
                  totalFormateado, // ← Ya incluye el símbolo
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: pastel.textoMonto,
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Descripción / UsoMotivo  ← CORREGIDO ─────────────────────────────────

  Widget _buildDescripcion(PresupuestoEmergenciaEncabezado? enc) {
    // Prioridad: usoMotivo → observacion → fallback
    final texto = (enc?.usoMotivo.isNotEmpty == true)
        ? enc!.usoMotivo
        : (enc?.observacion.isNotEmpty == true)
            ? enc!.observacion
            : 'Sin descripción';

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
          color: Colors.grey[800],
          height: 1.5,
        ),
      ),
    );
  }

  // ─── Lista de Items  ← CORREGIDO ──────────────────────────────────────────

  Widget _buildListaItems(
    List<PresupuestoEmergenciaDetalleItem> items,
    _ModalPastel pastel,
  ) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No hay items disponibles',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) => _buildItemCard(item, pastel)).toList(),
    );
  }

  Widget _buildItemCard(
    PresupuestoEmergenciaDetalleItem item,
    _ModalPastel pastel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Código y descripción
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pastel.fondoIcono,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.item,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: pastel.textoMonto,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.itemDes.isEmpty ? '—' : item.itemDes,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Cantidad × precio = subtotal
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_formatCantidad(item.cantidad)} ${item.und}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'x ${item.montoReferencialFormateado}', // ← Ya incluye símbolo
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                item.subtotalFormateado, // ← Ya incluye símbolo
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: pastel.textoMonto,
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
    );
  }

  String _formatCantidad(double cantidad) {
    if (cantidad == cantidad.truncateToDouble()) {
      return cantidad.toInt().toString();
    }
    return cantidad.toStringAsFixed(2);
  }

  // ─── Botones de acción ─────────────────────────────────────────────────────

  Widget _buildBotonesAccion(BuildContext context, _ModalPastel pastel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
          // Botón Autorizar
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
                backgroundColor: pastel.textoMonto,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: pastel.textoMonto.withOpacity(0.4),
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