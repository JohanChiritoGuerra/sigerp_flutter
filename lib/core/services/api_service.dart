import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? _refreshToken;
  final _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;
  
  // Callbacks para cuando el token expira
  Function()? onTokenExpired;
  Function(String newToken)? onTokenRefreshed;

  // Headers base para las peticiones
  Map<String, String> _headers({bool includeAuth = true}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (includeAuth && _token != null) 'Authorization': 'Bearer $_token',
  };

  // Configurar tokens
  void setToken(String? token) {
    _token = token;
  }
  
  void setRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
  }

  // Obtener token actual
  String? get token => _token;
  String? get refreshToken => _refreshToken;

  // Petición GET con retry automático
  Future<Map<String, dynamic>> get(String endpoint, {bool retry = true}) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.get(url, headers: _headers())
          .timeout(Duration(seconds: AppConstants.connectionTimeout));
      
      return await _processResponse(response, () => get(endpoint, retry: false), retry);
    } on http.ClientException catch (e) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // Petición POST con retry automático
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> body, 
    {bool retry = true}
  ) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: AppConstants.connectionTimeout));
      
      return await _processResponse(response, () => post(endpoint, body, retry: false), retry);
    } on http.ClientException catch (e) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // Petición PUT con retry automático
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> body,
    {bool retry = true}
  ) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: AppConstants.connectionTimeout));
      
      return await _processResponse(response, () => put(endpoint, body, retry: false), retry);
    } on http.ClientException catch (e) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // Petición DELETE con retry automático
  Future<Map<String, dynamic>> delete(String endpoint, {bool retry = true}) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await http.delete(url, headers: _headers())
          .timeout(Duration(seconds: AppConstants.connectionTimeout));
      
      return await _processResponse(response, () => delete(endpoint, retry: false), retry);
    } on http.ClientException catch (e) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // Procesar respuesta con manejo automático de refresh token
  Future<Map<String, dynamic>> _processResponse(
    http.Response response,
    Future<Map<String, dynamic>> Function() retryRequest,
    bool canRetry,
  ) async {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Respuesta exitosa
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } 
      
      // Token expirado - intentar refresh
      if (response.statusCode == 401 && canRetry && _refreshToken != null) {
        final refreshed = await _attemptRefreshToken();
        if (refreshed) {
          // Reintentar la petición original con el nuevo token
          return await retryRequest();
        } else {
          // Refresh falló, cerrar sesión
          _handleTokenExpired();
          return _errorResponse('Sesión expirada. Por favor inicie sesión nuevamente.');
        }
      }
      
      // Otros errores
      return data;
    } catch (e) {
      return _errorResponse('Error al procesar respuesta: $e');
    }
  }

  // Intentar refrescar el token
  Future<bool> _attemptRefreshToken() async {
    if (_isRefreshing) {
      // Ya hay un refresh en proceso, esperar
      await Future.delayed(const Duration(seconds: 1));
      return _token != null;
    }
    
    _isRefreshing = true;
    
    try {
      // Cargar refresh token del storage si no está en memoria
      _refreshToken ??= await _storage.read(key: AppConstants.refreshTokenKey);
      
      if (_refreshToken == null) {
        return false;
      }
      
      final url = Uri.parse('${AppConstants.apiBaseUrl}api/Auth/refresh-token');
      final response = await http.post(
        url,
        headers: _headers(includeAuth: false),
        body: jsonEncode({
          'refreshToken': _refreshToken,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Extraer nuevo token según la estructura de tu API
        final newToken = data['token'] ?? data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        
        if (newToken != null) {
          _token = newToken;
          if (newRefreshToken != null) {
            _refreshToken = newRefreshToken;
            await _storage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);
          }
          await _storage.write(key: AppConstants.tokenKey, value: newToken);
          
          // Notificar que el token se refrescó
          onTokenRefreshed?.call(newToken);
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error al refrescar token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // Manejar token expirado
  void _handleTokenExpired() {
    _token = null;
    _refreshToken = null;
    _storage.delete(key: AppConstants.tokenKey);
    _storage.delete(key: AppConstants.refreshTokenKey);
    
    // Notificar que el token expiró
    onTokenExpired?.call();
  }

  // Limpiar tokens (para logout)
  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // Respuesta de error genérica
  Map<String, dynamic> _errorResponse(String message) {
    return {
      'baseResponse': {
        'success': false,
        'exception': true,
        'message': message,
        'errores': [message],
      }
    };
  }
}
