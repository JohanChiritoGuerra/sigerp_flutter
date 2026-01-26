import 'base_response.dart';

class TrabajadorModel {
  final String trabId;
  final String nombres;
  final String trabDNI;
  final String trabDireccion;
  final String trabCorreoElec;
  final String trabTelef;
  final String cargo;
  final DateTime? contLabFecInicio;
  final DateTime? contLabFecFin;

  TrabajadorModel({
    this.trabId = '',
    this.nombres = '',
    this.trabDNI = '',
    this.trabDireccion = '',
    this.trabCorreoElec = '',
    this.trabTelef = '',
    this.cargo = '',
    this.contLabFecInicio,
    this.contLabFecFin,
  });

  factory TrabajadorModel.fromJson(Map<String, dynamic> json) {
    return TrabajadorModel(
      trabId: json['trabId'] ?? '',
      nombres: json['nombres'] ?? '',
      trabDNI: json['trabDNI'] ?? '',
      trabDireccion: json['trabDireccion'] ?? '',
      trabCorreoElec: json['trabCorreoElec'] ?? '',
      trabTelef: json['trabTelef'] ?? '',
      cargo: json['cargo'] ?? '',
      contLabFecInicio: json['contLabFecInicio'] != null
          ? DateTime.tryParse(json['contLabFecInicio'])
          : null,
      contLabFecFin: json['contLabFecFin'] != null
          ? DateTime.tryParse(json['contLabFecFin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trabId': trabId,
      'nombres': nombres,
      'trabDNI': trabDNI,
      'trabDireccion': trabDireccion,
      'trabCorreoElec': trabCorreoElec,
      'trabTelef': trabTelef,
      'cargo': cargo,
      'contLabFecInicio': contLabFecInicio?.toIso8601String(),
      'contLabFecFin': contLabFecFin?.toIso8601String(),
    };
  }
}

class PerfilTrabajadorResponse {
  final TrabajadorModel perfilTrabajador;
  final BaseResponse baseResponse;

  PerfilTrabajadorResponse({
    required this.perfilTrabajador,
    required this.baseResponse,
  });

  factory PerfilTrabajadorResponse.fromJson(Map<String, dynamic> json) {
    return PerfilTrabajadorResponse(
      perfilTrabajador: TrabajadorModel.fromJson(json['perfilTrabajador'] ?? {}),
      baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? {}),
    );
  }

  bool get esExitoso => baseResponse.esExitoso;
}