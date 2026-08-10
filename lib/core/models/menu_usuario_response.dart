import 'base_response.dart';

class AccesoMenuData {
  final int accesoId;
  final String accNombre;
  final String? accURL;
  final String? accTipo;
  final int? accOrden;

  AccesoMenuData({
    required this.accesoId,
    required this.accNombre,
    this.accURL,
    this.accTipo,
    this.accOrden,
  });

  factory AccesoMenuData.fromJson(Map<String, dynamic> json) {
    return AccesoMenuData(
      accesoId: json['accesoId'] ?? 0,
      accNombre: (json['accNombre'] as String?)?.trim() ?? '',
      accURL: json['accURL'],
      accTipo: json['accTipo']?.toString(),
      accOrden: json['accOrden'],
    );
  }
}

class CategoriaMenuData {
  final int categoriaId;
  final String catNombre;
  final List<AccesoMenuData> accesos;

  CategoriaMenuData({
    required this.categoriaId,
    required this.catNombre,
    this.accesos = const [],
  });

  factory CategoriaMenuData.fromJson(Map<String, dynamic> json) {
    return CategoriaMenuData(
      categoriaId: json['categoriaId'] ?? 0,
      catNombre: json['catNombre'] ?? '',
      accesos: (json['accesos'] as List<dynamic>? ?? [])
          .map((a) => AccesoMenuData.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModuloMenuData {
  final int moduloId;
  final String modNombre;
  final List<CategoriaMenuData> categorias;

  ModuloMenuData({
    required this.moduloId,
    required this.modNombre,
    this.categorias = const [],
  });

  factory ModuloMenuData.fromJson(Map<String, dynamic> json) {
    return ModuloMenuData(
      moduloId: json['moduloId'] ?? 0,
      modNombre: json['modNombre'] ?? '',
      categorias: (json['categorias'] as List<dynamic>? ?? [])
          .map((c) => CategoriaMenuData.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MenuUsuarioResponse {
  final BaseResponse baseResponse;
  final List<ModuloMenuData> modulos;

  MenuUsuarioResponse({
    required this.baseResponse,
    this.modulos = const [],
  });

  factory MenuUsuarioResponse.fromJson(Map<String, dynamic> json) {
    return MenuUsuarioResponse(
      baseResponse: BaseResponse.fromJson(json['baseResponse'] ?? {}),
      modulos: (json['modulos'] as List<dynamic>? ?? [])
          .map((m) => ModuloMenuData.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get esExitoso => baseResponse.esExitoso;

  // Compara por AccNombre (sin distinguir mayúsculas/espacios extra)
  bool tieneAcceso(String accNombre) {
    final buscado = accNombre.trim().toLowerCase();
    return modulos.any(
      (m) => m.categorias.any(
        (c) => c.accesos.any((a) => a.accNombre.toLowerCase() == buscado),
      ),
    );
  }
}
