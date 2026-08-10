import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../models/abastecimiento_diesel_lista_item.dart';

class AbastecimientoDieselCard extends StatelessWidget {
  final AbastecimientoDieselListaItem item;
  final VoidCallback onTap;

  const AbastecimientoDieselCard({super.key, required this.item, required this.onTap});

  String _formatFecha(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
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

  @override
  Widget build(BuildContext context) {
    final primario = Color(AppColors.primaryColor);

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
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: primario,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
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
                                  item.centroCostoDescripcion.isNotEmpty
                                      ? item.centroCostoDescripcion
                                      : item.centroCosto,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E2E3A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '#${item.salMatCabId}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatFecha(item.fecha),
                            style: TextStyle(fontSize: 10.5, color: Colors.grey[400], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.chofer.isNotEmpty ? item.chofer : '—',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF4A4A68)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.speed_outlined, size: 13, color: Colors.grey[400]),
                          const SizedBox(width: 3),
                          Text(
                            '${item.kilometraje} km',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primario.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_gas_station_outlined, size: 12, color: primario),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatCantidad(item.cantidad)}${item.unidadMedida.isNotEmpty ? ' ${item.unidadMedida}' : ''}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primario),
                            ),
                            if (item.tieneFoto) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.photo_camera_outlined, size: 12, color: Colors.grey[500]),
                            ],
                          ],
                        ),
                      ),
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
}
