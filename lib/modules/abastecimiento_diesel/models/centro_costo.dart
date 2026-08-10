class CentroCosto {
  final String centroCosto;
  final String cenCostDescripcion;
  final String gerenciaId;
  final String dptoId;
  final String seccId;
  final String displayText;

  CentroCosto({
    required this.centroCosto,
    required this.cenCostDescripcion,
    required this.gerenciaId,
    required this.dptoId,
    required this.seccId,
    required this.displayText,
  });

  factory CentroCosto.fromJson(Map<String, dynamic> json) {
    return CentroCosto(
      centroCosto: (json['centroCosto'] as String?)?.trim() ?? '',
      cenCostDescripcion: (json['cenCostDescripcion'] as String?)?.trim() ?? '',
      gerenciaId: (json['gerenciaId'] as String?)?.trim() ?? '',
      dptoId: (json['dptoId'] as String?)?.trim() ?? '',
      seccId: (json['seccId'] as String?)?.trim() ?? '',
      displayText: json['displayText'] as String? ?? '',
    );
  }
}
