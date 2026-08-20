import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../models/borrador_diesel.dart';
import '../utils/lectura_unidad.dart';

class BorradorDieselCard extends StatelessWidget {
  final BorradorDiesel borrador;
  final String? unidadMedida;
  final bool reintentando;
  final VoidCallback onReintentar;
  final VoidCallback onEliminar;
  final VoidCallback onTap;

  const BorradorDieselCard({
    super.key,
    required this.borrador,
    this.unidadMedida,
    required this.reintentando,
    required this.onReintentar,
    required this.onEliminar,
    required this.onTap,
  });

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

  Future<void> _confirmarEliminar(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar borrador'),
        content: const Text('Este borrador no se ha enviado al servidor. ¿Deseas eliminarlo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmado == true) onEliminar();
  }

  @override
  Widget build(BuildContext context) {
    final primario = Color(AppColors.primaryColor);
    final esError = borrador.estado == EstadoBorrador.error;
    // "esperandoStock" se trata visualmente como una variante de "pendiente"
    // (mismo color, no es un error del usuario ni algo roto) pero con su
    // propio ícono/texto — para no confundirlo con "sin conexión", que es un
    // motivo totalmente distinto.
    final esEsperandoStock = borrador.estado == EstadoBorrador.esperandoStock;
    final tieneMotivoVisible = (esError || esEsperandoStock) && borrador.motivoError != null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: esError ? Colors.red.shade200 : Colors.orange.shade200, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: primario.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_gas_station, color: primario, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrador.centroCostoDescripcion.isNotEmpty ? borrador.centroCostoDescripcion : borrador.centroCosto,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2E2E3A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatFechaHora(borrador.creadoEn),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    borrador.choferNombre.isNotEmpty ? borrador.choferNombre : borrador.choferId,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF4A4A68)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (icono, texto) in lecturaEntradas(borrador.kilometraje, borrador.horometro))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icono, size: 13, color: Colors.grey[400]),
                            const SizedBox(width: 3),
                            Text(texto, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primario.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_formatCantidad(borrador.cantidad)}${unidadMedida?.isNotEmpty == true ? ' $unidadMedida' : ''}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primario),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: esError ? Colors.red.withValues(alpha: 0.08) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        esError
                            ? Icons.error_outline
                            : (esEsperandoStock ? Icons.production_quantity_limits : Icons.cloud_off),
                        size: 12,
                        color: esError ? Colors.red : Colors.orange[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        esError ? 'Requiere atención' : (esEsperandoStock ? 'Esperando stock' : 'Pendiente de envío'),
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: esError ? Colors.red : Colors.orange[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (tieneMotivoVisible) ...[
              const SizedBox(height: 6),
              Text(
                borrador.motivoError!,
                style: TextStyle(fontSize: 11.5, color: esError ? Colors.red : Colors.orange[800]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _confirmarEliminar(context),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  onPressed: reintentando ? null : onReintentar,
                  icon: reintentando
                      ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.refresh, size: 16),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primario,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}
