import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario.dart';
import '../models/login_response.dart';
import '../models/perfil_trabajador.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Usuario? _usuario;
  TrabajadorModel? _perfilTrabajador;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Usuario? get usuario => _usuario;
  TrabajadorModel? get perfilTrabajador => _perfilTrabajador;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _usuario != null && _usuario!.token != null;
  String? get errorMessage => _errorMessage;

  // Obtener cargo (del endpoint)
  String get cargo => _perfilTrabajador?.cargo ?? '';

  // Área fija por ahora
  String get area => 'Empresa Andahuasi';

  // Login
  Future<bool> login({
    required String usuario,
    required String password,
    required String empresaId,
    String? deviceFingerprint,
    String? deviceType,
    String? userAgent,
    String? ipAddress,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestBody = {
        'usuario': usuario,
        'password': password,
        'empresaId': empresaId,
        'deviceFingerprint': deviceFingerprint ?? 'flutter_app',
        'deviceType': deviceType ?? 'Mobile',
        'userAgent': userAgent ?? 'Sigerp Flutter App',
        'ipAddress': ipAddress ?? '127.0.0.1',
        'rememberMe': rememberMe,
      };
      
      // Debug: imprimir el body que se envía
      print('🔐 LOGIN REQUEST: $requestBody');
      
      final response = await _apiService.post('api/LoginWeb/login', requestBody);
      
      // Debug: imprimir la respuesta
      print('🔐 LOGIN RESPONSE: $response');

      final loginResponse = LoginResponse.fromJson(response);

      if (loginResponse.esExitoso) {
        _usuario = loginResponse.toUsuario();
        _apiService.setToken(_usuario!.token);

        // Obtener perfil del trabajador
        await obtenerPerfilTrabajador();

        // Guardar datos en storage seguro
        await _saveUserData();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = loginResponse.mensajeError;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtener perfil del trabajador
  Future<void> obtenerPerfilTrabajador() async {
    if (_usuario == null) return;

    try {
      final response = await _apiService.post('api/PerfilTrabajador/ObtenerPerfilTrabajador', {
        'trabId': _usuario!.trabId ?? '',
        'empresaId': _usuario!.empresaId ?? '02',
      });

      final perfilResponse = PerfilTrabajadorResponse.fromJson(response);

      if (perfilResponse.esExitoso) {
        _perfilTrabajador = perfilResponse.perfilTrabajador;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al obtener perfil: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    _usuario = null;
    _perfilTrabajador = null;
    _apiService.setToken(null);
    await _clearUserData();
    notifyListeners();
  }

  // Verificar si hay sesión guardada
  Future<bool> checkSavedSession() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      final userData = await _storage.read(key: AppConstants.userKey);

      if (token != null && userData != null) {
        _usuario = Usuario.fromJson(jsonDecode(userData));
        _apiService.setToken(token);

        // Obtener perfil actualizado
        await obtenerPerfilTrabajador();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Guardar datos del usuario
  Future<void> _saveUserData() async {
    if (_usuario != null) {
      await _storage.write(
        key: AppConstants.tokenKey,
        value: _usuario!.token,
      );
      await _storage.write(
        key: AppConstants.userKey,
        value: jsonEncode(_usuario!.toJson()),
      );
    }
  }

  // Limpiar datos guardados
  Future<void> _clearUserData() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }
}