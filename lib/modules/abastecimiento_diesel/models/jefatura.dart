class Jefatura {
  final String usuaId;
  final String nombreCompleto;
  final String? correoElectronico;
  final String gerenciaId;
  final String dptoId;
  final String seccId;
  final String? seccDescripcion;

  Jefatura({
    required this.usuaId,
    required this.nombreCompleto,
    this.correoElectronico,
    required this.gerenciaId,
    required this.dptoId,
    required this.seccId,
    this.seccDescripcion,
  });

  factory Jefatura.fromJson(Map<String, dynamic> json) {
    return Jefatura(
      usuaId: (json['usuaId'] as String?)?.trim() ?? '',
      nombreCompleto: (json['nombreCompleto'] as String?)?.trim() ?? '',
      correoElectronico: json['correoElectronico'] as String?,
      gerenciaId: (json['gerenciaId'] as String?)?.trim() ?? '',
      dptoId: (json['dptoId'] as String?)?.trim() ?? '',
      seccId: (json['seccId'] as String?)?.trim() ?? '',
      seccDescripcion: json['seccDescripcion'] as String?,
    );
  }
}
