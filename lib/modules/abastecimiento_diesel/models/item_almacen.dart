class ItemAlmacen {
  final String grpAlmId;
  final String clsAlmId;
  final String iteAlmId;
  final String descripcion;
  final String unidadMedida;

  ItemAlmacen({
    required this.grpAlmId,
    required this.clsAlmId,
    required this.iteAlmId,
    required this.descripcion,
    required this.unidadMedida,
  });

  factory ItemAlmacen.fromJson(Map<String, dynamic> json) {
    return ItemAlmacen(
      grpAlmId: (json['grpAlmId'] as String?)?.trim() ?? '',
      clsAlmId: (json['clsAlmId'] as String?)?.trim() ?? '',
      iteAlmId: (json['iteAlmId'] as String?)?.trim() ?? '',
      descripcion: (json['iteAlmDescDetalle'] as String?)?.trim() ?? '',
      unidadMedida: (json['iteAlmUniMed'] as String?)?.trim() ?? '',
    );
  }
}
