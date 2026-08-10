class AbastecimientoDieselListaItem {
  final int salMatCabId;
  final String numeroDocumento;
  final DateTime fecha;
  final String itemDescripcion;
  final String centroCosto;
  final String centroCostoDescripcion;
  final String chofer;
  final String jefatura;
  final double cantidad;
  final String unidadMedida;
  final double precioUnitario;
  final double total;
  final int kilometraje;
  final bool tieneFoto;

  AbastecimientoDieselListaItem({
    required this.salMatCabId,
    required this.numeroDocumento,
    required this.fecha,
    required this.itemDescripcion,
    required this.centroCosto,
    required this.centroCostoDescripcion,
    required this.chofer,
    required this.jefatura,
    required this.cantidad,
    required this.unidadMedida,
    required this.precioUnitario,
    required this.total,
    required this.kilometraje,
    required this.tieneFoto,
  });

  factory AbastecimientoDieselListaItem.fromJson(Map<String, dynamic> json) {
    return AbastecimientoDieselListaItem(
      salMatCabId: json['salMatCabId'] as int,
      numeroDocumento: (json['numeroDocumento'] as String?)?.trim() ?? '',
      fecha: DateTime.parse(json['fecha'] as String),
      itemDescripcion: (json['itemDescripcion'] as String?)?.trim() ?? '',
      centroCosto: (json['centroCosto'] as String?)?.trim() ?? '',
      centroCostoDescripcion: (json['centroCostoDescripcion'] as String?)?.trim() ?? '',
      chofer: (json['chofer'] as String?)?.trim() ?? '',
      jefatura: (json['jefatura'] as String?)?.trim() ?? '',
      cantidad: (json['cantidad'] as num?)?.toDouble() ?? 0,
      unidadMedida: (json['unidadMedida'] as String?)?.trim() ?? '',
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      kilometraje: json['kilometraje'] as int? ?? 0,
      tieneFoto: json['tieneFoto'] as bool? ?? false,
    );
  }
}
