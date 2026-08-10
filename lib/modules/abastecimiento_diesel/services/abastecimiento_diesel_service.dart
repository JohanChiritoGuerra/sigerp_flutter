import 'dart:io';
import 'dart:typed_data';
import '../../../core/models/base_response.dart';
import '../../../core/services/api_service.dart';
import '../models/abastecimiento_diesel_lista_item.dart';
import '../models/centro_costo.dart';
import '../models/chofer.dart';
import '../models/item_almacen.dart';
import '../models/jefatura.dart';

class AbastecimientoDieselResultado {
  final bool exito;
  final String mensaje;

  AbastecimientoDieselResultado({required this.exito, required this.mensaje});
}

class AbastecimientoDieselService {
  final ApiService _apiService = ApiService();

  Future<AbastecimientoDieselResultado> registrar({
    required String codigoCentroCosto,
    required String trabIdChofer,
    required double cantidad,
    required int kilometraje,
    required String empresaId,
    required File foto,
  }) async {
    final response = await _apiService.postMultipart(
      'api/AbastecimientoDiesel/Registrar',
      {
        'codigoCentroCosto': codigoCentroCosto,
        'trabIdChofer': trabIdChofer,
        'cantidad': cantidad.toString(),
        'kilometraje': kilometraje.toString(),
        'empresaId': empresaId,
      },
      foto,
      'foto',
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    return AbastecimientoDieselResultado(
      exito: baseResponse.esExitoso,
      mensaje: baseResponse.message ?? (baseResponse.esExitoso
          ? 'Registrado correctamente'
          : 'No se pudo registrar el abastecimiento'),
    );
  }

  Future<List<AbastecimientoDieselListaItem>> listar({required String empresaId}) async {
    final response = await _apiService.get(
      'api/AbastecimientoDiesel/Listar',
      queryParams: {'empresaId': empresaId},
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => AbastecimientoDieselListaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Uint8List?> obtenerFoto({required int salMatCabId, required String empresaId}) async {
    return await _apiService.getBytes(
      'api/AbastecimientoDiesel/Foto/$salMatCabId',
      queryParams: {'empresaId': empresaId},
    );
  }

  Future<double?> obtenerStock({required String empresaId}) async {
    final response = await _apiService.get(
      'api/AbastecimientoDiesel/Stock',
      queryParams: {'empresaId': empresaId},
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return null;

    final stock = response['stock'];
    if (stock == null) return null;
    return (stock as num).toDouble();
  }

  Future<ItemAlmacen?> obtenerItemAlmacen({
    required String codigoItem,
    required String empresaId,
  }) async {
    final response = await _apiService.get(
      'api/ItemAlmacen/ObtenerPorCodigo',
      queryParams: {
        'codigoItem': codigoItem,
        'empresaId': empresaId,
      },
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return null;

    final itemJson = response['item'] as Map<String, dynamic>?;
    if (itemJson == null) return null;

    return ItemAlmacen.fromJson(itemJson);
  }

  Future<List<CentroCosto>> buscarCentroCosto({
    required String filtro,
    required String empresaId,
    String cenCostCost = '81',
  }) async {
    final response = await _apiService.get(
      'api/CentroCosto/Buscar',
      queryParams: {
        'filtro': filtro,
        'empresaId': empresaId,
        'cenCostCost': cenCostCost,
      },
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CentroCosto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Jefatura?> obtenerJefatura({
    required String gerenciaId,
    required String dptoId,
    required String seccId,
    required String empresaId,
  }) async {
    final response = await _apiService.get(
      'api/Jefatura/PorCentroCosto',
      queryParams: {
        'gerenciaId': gerenciaId,
        'dptoId': dptoId,
        'seccId': seccId,
        'empresaId': empresaId,
      },
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return null;

    final jefaturaJson = response['jefatura'] as Map<String, dynamic>?;
    if (jefaturaJson == null) return null;

    return Jefatura.fromJson(jefaturaJson);
  }

  Future<List<Chofer>> buscarChofer({
    required String filtro,
    required String empresaId,
  }) async {
    final response = await _apiService.get(
      'api/Trabajador/Buscar',
      queryParams: {
        'filtro': filtro,
        'empresaId': empresaId,
      },
    );

    final baseResponse = BaseResponse.fromJson(response['baseResponse'] ?? {});
    if (!baseResponse.esExitoso) return [];

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((e) => Chofer.fromJson(e as Map<String, dynamic>)).toList();
  }
}
