import '../models/menu_usuario_response.dart';
import 'api_service.dart';

class MenuService {
  final ApiService _apiService = ApiService();

  Future<MenuUsuarioResponse> obtenerMenuUsuarioMobile({
    required String usuarioId,
    required String empresaId,
  }) async {
    final response = await _apiService.get(
      'api/Menu/ObtenerMenuUsuarioMobile',
      queryParams: {
        'usuarioId': usuarioId,
        'empresaId': empresaId,
      },
    );
    return MenuUsuarioResponse.fromJson(response);
  }
}
