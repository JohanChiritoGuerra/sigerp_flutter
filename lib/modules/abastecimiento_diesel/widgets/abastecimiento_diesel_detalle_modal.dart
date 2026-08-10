import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../models/abastecimiento_diesel_lista_item.dart';
import '../services/abastecimiento_diesel_service.dart';

class AbastecimientoDieselDetalleModal extends StatefulWidget {
  final AbastecimientoDieselListaItem item;
  final String empresaId;

  const AbastecimientoDieselDetalleModal({
    super.key,
    required this.item,
    required this.empresaId,
  });

  @override
  State<AbastecimientoDieselDetalleModal> createState() => _AbastecimientoDieselDetalleModalState();
}

// Misma paleta de un solo color (azul corporativo) usada en el resto de la app,
// pero derivada al mismo patrón acento/fondoClaro/textoFuerte/fondoMonto que
// ya usan los modales de Solicitud de Compra y Presupuesto de Emergencia.
class _Pastel {
  static const Color acento = Color(AppColors.primaryColor);
  static Color fondoClaro = acento.withValues(alpha: 0.08);
  static const Color textoFuerte = Color(AppColors.primaryColor);
  static Color fondoMonto = acento.withValues(alpha: 0.10);
}

class _AbastecimientoDieselDetalleModalState extends State<AbastecimientoDieselDetalleModal> {
  final AbastecimientoDieselService _service = AbastecimientoDieselService();
  Future<Uint8List?>? _fotoFuture;

  @override
  void initState() {
    super.initState();
    if (widget.item.tieneFoto) {
      _fotoFuture = _service.obtenerFoto(salMatCabId: widget.item.salMatCabId, empresaId: widget.empresaId);
    }
  }

  String _formatFecha(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  }

  String _formatNumero(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final entero = partes[0];
    final buffer = StringBuffer();
    final offset = entero.length % 3;
    for (var i = 0; i < entero.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return '${buffer.toString()}.${partes[1]}';
  }

  void _verFotoCompleta(BuildContext context, Uint8List bytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
          body: Center(
            child: InteractiveViewer(
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
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
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  // Bottom con MediaQuery: en celulares con controles de navegación al pie,
                  // sin esto la foto (último elemento) queda parcialmente tapada.
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, item),
                      const SizedBox(height: 24),
                      _buildSeccion(
                        icono: Icons.description_outlined,
                        titulo: 'INFORMACIÓN GENERAL',
                        child: _buildInformacionGeneral(item),
                      ),
                      const SizedBox(height: 20),
                      _buildSeccion(
                        icono: Icons.local_gas_station_outlined,
                        titulo: 'ÍTEM',
                        child: _buildItem(item),
                      ),
                      const SizedBox(height: 20),
                      _buildSeccion(
                        icono: Icons.payments_outlined,
                        titulo: 'TOTAL',
                        child: _buildTotal(item),
                      ),
                      const SizedBox(height: 20),
                      _buildSeccion(
                        icono: Icons.photo_camera_outlined,
                        titulo: 'FOTO DE EVIDENCIA',
                        child: _buildFoto(item),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AbastecimientoDieselListaItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _Pastel.fondoClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _Pastel.acento.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_gas_station, color: _Pastel.acento, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemDescripcion.isNotEmpty ? item.itemDescripcion : 'Abastecimiento de Diesel',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _Pastel.textoFuerte, letterSpacing: 0.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '#${item.numeroDocumento.isNotEmpty ? item.numeroDocumento : item.salMatCabId}',
                  style: TextStyle(fontSize: 12, color: _Pastel.textoFuerte.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion({required IconData icono, required String titulo, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: _Pastel.textoFuerte),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _Pastel.textoFuerte, letterSpacing: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionGeneral(AbastecimientoDieselListaItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildInfoRow('Fecha', _formatFecha(item.fecha)),
          _buildInfoRow(
            'Unidad',
            item.centroCostoDescripcion.isNotEmpty ? '${item.centroCosto} - ${item.centroCostoDescripcion}' : item.centroCosto,
          ),
          _buildInfoRow('Jefatura', item.jefatura),
          _buildInfoRow('Chofer', item.chofer),
          _buildInfoRow('Kilometraje', '${item.kilometraje} km'),
        ],
      ),
    );
  }

  Widget _buildItem(AbastecimientoDieselListaItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _Pastel.acento.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _Pastel.fondoClaro, borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  '21030010',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _Pastel.acento, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.itemDescripcion.isNotEmpty ? item.itemDescripcion : 'Diesel',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                child: Text(
                  '${_formatNumero(item.cantidad)}${item.unidadMedida.isNotEmpty ? ' ${item.unidadMedida}' : ''}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                ),
              ),
              const SizedBox(width: 8),
              Text('x ${_formatNumero(item.precioUnitario)}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const Spacer(),
              Text(
                'S/. ${_formatNumero(item.total)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _Pastel.textoFuerte),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(AbastecimientoDieselListaItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: _Pastel.fondoMonto, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(
            'S/. ${_formatNumero(item.total)}',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _Pastel.textoFuerte),
          ),
        ],
      ),
    );
  }

  Widget _buildFoto(AbastecimientoDieselListaItem item) {
    if (!item.tieneFoto) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text('Sin foto de evidencia', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: _fotoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        final bytes = snapshot.data;
        if (bytes == null) {
          return AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 32)),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _verFotoCompleta(context, bytes),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: Colors.grey[100],
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }
}
