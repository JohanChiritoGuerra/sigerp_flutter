
import 'package:sigerp_flutter/core/models/login_sigerp_response.dart';

class Usuario {
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

  Usuario({
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
  });

  // Nombre completo del usuario
  String get nombreCompleto {
    final partes = [nombres, apellidoPaterno, apellidoMaterno];
    return partes.where((p) => p != null && p.isNotEmpty).join(' ');
  }

  // Crear Usuario desde JSON (respuesta de la API)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      webUser: (json['webUser'] as String?)?.trim(),
      usuaId: (json['usuaId'] as String?)?.trim(),
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
    );
  }

  // Convertir Usuario a JSON (para guardar en storage)
  Map<String, dynamic> toJson() {
    return {
      'webUser': webUser,
      'usuaId': usuaId,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'nombres': nombres,
      'dni': dni,
      'direccion': direccion,
      'parametros': parametros,
      'trabId': trabId,
      'empresaId': empresaId,
      'contLabFecInicio': contLabFecInicio?.toIso8601String(),
      'contLabFecFin': contLabFecFin?.toIso8601String(),
      'estado': estado,
      'token': token,
    };
  }

  // Verificar si el usuario está activo
  bool get estaActivo => estado == 1;

  // Método copyWith para crear una copia con cambios
  Usuario copyWith({
    String? webUser,
    String? usuaId,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombres,
    String? dni,
    String? direccion,
    String? parametros,
    String? trabId,
    String? empresaId,
    DateTime? contLabFecInicio,
    DateTime? contLabFecFin,
    int? estado,
    String? token,
  }) {
    return Usuario(
      webUser: webUser ?? this.webUser,
      usuaId: usuaId ?? this.usuaId,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombres: nombres ?? this.nombres,
      dni: dni ?? this.dni,
      direccion: direccion ?? this.direccion,
      parametros: parametros ?? this.parametros,
      trabId: trabId ?? this.trabId,
      empresaId: empresaId ?? this.empresaId,
      contLabFecInicio: contLabFecInicio ?? this.contLabFecInicio,
      contLabFecFin: contLabFecFin ?? this.contLabFecFin,
      estado: estado ?? this.estado,
      token: token ?? this.token,
    );
  }

  factory Usuario.fromLoginSigerp(LoginSigerpResponse r) {
    return Usuario(
      webUser: r.usuaId?.trim(),
      usuaId: r.usuaId?.trim(),
      apellidoPaterno: r.apellidoPaterno,
      apellidoMaterno: r.apellidoMaterno,
      nombres: r.nombres,
      dni: r.dni,
      direccion: r.direccion,
      parametros: r.parametros,
      trabId: r.trabId,
      empresaId: r.empresaId,
      contLabFecInicio: r.contLabFecInicio,
      contLabFecFin: r.contLabFecFin,
      estado: r.estado,
      token: r.token,
    );
  }
}