class LoginSigerpResponse {
  final bool success;
  final String message;
  final String? usuaId;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? nombres;
  final String? dni;
  final String? direccion;
  final String? parametros;
  final String? trabId;
  final String? empresaId;
  final DateTime? contLabFecInicio;
  final DateTime? contLabFecFin;
  final int estado;
  final String? token;
  final String? refreshToken;

  LoginSigerpResponse({
    required this.success,
    required this.message,
    this.usuaId,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.nombres,
    this.dni,
    this.direccion,
    this.parametros,
    this.trabId,
    this.empresaId,
    this.contLabFecInicio,
    this.contLabFecFin,
    this.estado = 0,
    this.token,
    this.refreshToken,
  });

  bool get esExitoso => success;
  String get mensajeError => message;

  factory LoginSigerpResponse.fromJson(Map<String, dynamic> json) {
    final base = json['baseResponse'] as Map<String, dynamic>? ?? {};
    return LoginSigerpResponse(
      success: base['success'] as bool? ?? false,
      message: base['message'] as String? ?? '',
      usuaId: json['usuaId'] as String?,
      apellidoPaterno: json['apellidoPaterno'] as String?,
      apellidoMaterno: json['apellidoMaterno'] as String?,
      nombres: json['nombres'] as String?,
      dni: json['dNI'] as String?,  // C# serializa "DNI" → "dNI" por convención camelCase
      direccion: json['direccion'] as String?,
      parametros: json['parametros'] as String?,
      trabId: json['trabId'] as String?,
      empresaId: json['empresaId'] as String?,
      contLabFecInicio: json['contLabFecInicio'] != null
          ? DateTime.tryParse(json['contLabFecInicio'])
          : null,
      contLabFecFin: json['contLabFecFin'] != null
          ? DateTime.tryParse(json['contLabFecFin'])
          : null,
      estado: json['estado'] as int? ?? 0,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}