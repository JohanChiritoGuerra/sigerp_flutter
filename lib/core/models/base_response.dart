class BaseResponse {
  final bool success;
  final bool exception;
  final String? tipoException;
  final String? message;
  final List<String> errores;

  BaseResponse({
    this.success = false,
    this.exception = false,
    this.tipoException,
    this.message,
    this.errores = const [],
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['success'] ?? false,
      exception: json['exception'] ?? false,
      tipoException: json['tipoException'],
      message: json['message'],
      errores: json['errores'] != null
          ? List<String>.from(json['errores'])
          : [],
    );
  }

  // Verificar si la respuesta es exitosa
  bool get esExitoso => success && !exception;

  // Obtener mensaje de error
  String get mensajeError {
    if (errores.isNotEmpty) {
      return errores.join('\n');
    }
    return message ?? 'Error desconocido';
  }
}