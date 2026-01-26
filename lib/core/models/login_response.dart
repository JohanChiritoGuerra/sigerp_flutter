import 'base_response.dart';
import 'usuario.dart';

class LoginResponse {
  final BaseResponse baseResponse;
  final String? webUser;
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
  final List<String> setCookieHeaders;

  LoginResponse({
    required this.baseResponse,
    this.webUser,
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
    this.setCookieHeaders = const [],
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? {}),
      webUser: json['webUser'],
      usuaId: json['usuaId'],
      apellidoPaterno: json['apellidoPaterno'],
      apellidoMaterno: json['apellidoMaterno'],
      nombres: json['nombres'],
      dni: json['dni'],
      direccion: json['direccion'],
      parametros: json['parametros'],
      trabId: json['trabId'],
      empresaId: json['empresaId'],
      contLabFecInicio: json['contLabFecInicio'] != null
          ? DateTime.tryParse(json['contLabFecInicio'])
          : null,
      contLabFecFin: json['contLabFecFin'] != null
          ? DateTime.tryParse(json['contLabFecFin'])
          : null,
      estado: json['estado'] ?? 0,
      token: json['token'],
      refreshToken: json['refreshToken'],
      setCookieHeaders: json['setCookieHeaders'] != null
          ? List<String>.from(json['setCookieHeaders'])
          : [],
    );
  }

  // Verificar si el login fue exitoso
  bool get esExitoso => baseResponse.esExitoso;

  // Obtener mensaje de error
  String get mensajeError => baseResponse.mensajeError;

  // Convertir a Usuario (para guardar en la app)
  Usuario toUsuario() {
    return Usuario(
      webUser: webUser,
      usuaId: usuaId,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
      nombres: nombres,
      dni: dni,
      direccion: direccion,
      parametros: parametros,
      trabId: trabId,
      empresaId: empresaId,
      contLabFecInicio: contLabFecInicio,
      contLabFecFin: contLabFecFin,
      estado: estado,
      token: token,
    );
  }
}