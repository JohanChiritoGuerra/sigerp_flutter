import 'dart:io';
import 'package:flutter/material.dart';
import '../models/borrador_diesel.dart';

// Detalle de un borrador (aún no enviado) — mismo lenguaje visual que
// AbastecimientoDieselDetalleModal, pero con los datos que SÍ existen antes
// de enviarse: sin número de parte, sin jefatura (no se guarda en el
// borrador), sin precio/total (nunca los hubo), y la foto se lee del
// archivo local, no del servidor.
class BorradorDieselDetalleModal extends StatelessWidget {
  final BorradorDiesel borrador;
  final String unidadMedida;

  const BorradorDieselDetalleModal({super.key, required this.borrador, required this.unidadMedida});

  bool get _esError => borrador.estado == EstadoBorrador.error;
  Color get _acento => _esError ? Colors.red.shade400 : Colors.orange.shade700;
  Color get _fondoClaro => _acento.withValues(alpha: 0.08);

  String _formatFechaHora(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} $hh:$min';
  }

  String _formatCantidad(double valor) {
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

  void _verFotoCompleta(BuildContext context, File archivo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(archivo, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      if (_esError && borrador.motivoError != null) ...[
                        const SizedBox(height: 16),
                        _buildMotivoError(),
                      ],
                      const SizedBox(height: 24),
                      _buildSeccion(
                        icono: Icons.description_outlined,
                        titulo: 'INFORMACIÓN GENERAL',
                        child: _buildInformacionGeneral(),
                      ),
                      const SizedBox(height: 20),
                      _buildSeccion(
                        icono: Icons.photo_camera_outlined,
                        titulo: 'FOTO DE EVIDENCIA',
                        child: _buildFoto(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: _fondoClaro, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _acento.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.local_gas_station, color: _acento, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // El ítem de un borrador es siempre Diesel (fijo) — igual que
                // en "Mis salidas"/"Anulados", el encabezado muestra el
                // nombre del ÍTEM, no la Unidad (esa ya tiene su propia fila
                // más abajo, en Información general).
                Text(
                  'Abastecimiento de Diesel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _acento, letterSpacing: 0.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(_esError ? Icons.error_outline : Icons.cloud_off, size: 13, color: _acento.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      _esError ? 'Requiere atención' : 'Pendiente de envío',
                      style: TextStyle(fontSize: 12, color: _acento.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.close, color: _acento), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildMotivoError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(borrador.motivoError!, style: const TextStyle(fontSize: 12.5, color: Colors.red)),
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
            Icon(icono, size: 18, color: _acento),
            const SizedBox(width: 8),
            Text(titulo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _acento, letterSpacing: 0.5)),
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
          SizedBox(width: 110, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
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

  Widget _buildInfoRowCantidad() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 110, child: Text('Cantidad', style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _fondoClaro, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_gas_station, size: 14, color: _acento),
                const SizedBox(width: 5),
                Text(
                  '${_formatCantidad(borrador.cantidad)}${unidadMedida.isNotEmpty ? ' $unidadMedida' : ''}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _acento),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionGeneral() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildInfoRowCantidad(),
          _buildInfoRow(
            'Unidad',
            borrador.centroCostoDescripcion.isNotEmpty
                ? '${borrador.centroCosto} - ${borrador.centroCostoDescripcion}'
                : borrador.centroCosto,
          ),
          _buildInfoRow('Chofer', borrador.choferNombre.isNotEmpty ? borrador.choferNombre : borrador.choferId),
          _buildInfoRow('Kilometraje', '${borrador.kilometraje} km'),
          _buildInfoRow('Creado', _formatFechaHora(borrador.creadoEn)),
        ],
      ),
    );
  }

  Widget _buildFoto(BuildContext context) {
    final archivo = File(borrador.fotoPath);
    if (!archivo.existsSync()) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            'La foto ya no está disponible en el dispositivo',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _verFotoCompleta(context, archivo),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            color: Colors.grey[100],
            child: Image.file(archivo, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
