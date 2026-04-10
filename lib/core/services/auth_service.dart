import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario.dart';
import '../models/login_sigerp_response.dart';
import '../models/perfil_trabajador.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'notification_service.dart';

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
  bool get isAuthenticated => _usuario != null; // sin dependencia de token
  String? get errorMessage => _errorMessage;

  String get cargo => _perfilTrabajador?.cargo ?? '';
  String get area => 'Empresa Andahuasi';

  // Login
  Future<bool> login({
    required String usuario,
    required String password,
    required String empresaId,
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
      };

      debugPrint('🔐 LOGIN REQUEST: $requestBody');

      final response = await _apiService.post(
        'api/LoginSigerp',
        requestBody,
        skipAuthRetry: true, // ← 401 aquí = credenciales incorrectas, no token expirado
      );

      debugPrint('🔐 RAW RESPONSE: $response');

      final loginResponse = LoginSigerpResponse.fromJson(response);

      if (loginResponse.esExitoso) {
        _usuario = Usuario.fromLoginSigerp(loginResponse);

        if (_usuario!.token != null) {
          _apiService.setToken(_usuario!.token);
        }

        await obtenerPerfilTrabajador();
        if (rememberMe) await _saveUserData();
        await NotificationService().configurarUsuario(
          _usuario!.webUser ?? '',
          _usuario!.empresaId ?? '02',
        );

        // Ejecutar navegación pendiente si había una push tocada antes del login
        final pendingData = NotificationService.consumePendingNavigation();
        if (pendingData != null) {
          NotificationService.onNotificationTapped?.call(pendingData);
        }

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
      final response = await _apiService.post(
        'api/PerfilTrabajador/ObtenerPerfilTrabajador',
        {
          'trabId': _usuario!.trabId ?? '',
          'empresaId': _usuario!.empresaId ?? '02',
        },
      );

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
    await NotificationService().limpiarUsuario();
    _usuario = null;
    _perfilTrabajador = null;
    _apiService.setToken(null);
    await _clearUserData();
    notifyListeners();
  }

  // Verificar sesión guardada
  Future<bool> checkSavedSession() async {
    try {
      final userData = await _storage.read(key: AppConstants.userKey);

      if (userData != null) {
        _usuario = Usuario.fromJson(jsonDecode(userData));

        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          _apiService.setToken(token);
        }

        await obtenerPerfilTrabajador();
        await NotificationService().configurarUsuario(
          _usuario!.webUser ?? '',
          _usuario!.empresaId ?? '02',
        );
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
      if (_usuario!.token != null) {
        await _storage.write(key: AppConstants.tokenKey, value: _usuario!.token);
      }
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

  // ===== MODO MOCK =====
  Future<bool> loginMock() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _usuario = Usuario(
      webUser: 'demo_user',
      usuaId: 'USR001',
      apellidoPaterno: 'García',
      apellidoMaterno: 'López',
      nombres: 'Juan Carlos',
      dni: '12345678',
      direccion: 'Av. Principal 123',
      parametros: null,
      trabId: 'TRAB001',
      empresaId: '02',
      contLabFecInicio: DateTime(2020, 1, 15),
      contLabFecFin: null,
      estado: 1,
      token: 'mock_token_development_12345',
    );

    _perfilTrabajador = TrabajadorModel(
      trabId: 'TRAB001',
      nombres: 'Juan Carlos García López',
      trabDNI: '12345678',
      trabDireccion: 'Av. Principal 123, Lima',
      trabCorreoElec: 'jgarcia@andahuasi.pe',
      trabTelef: '999888777',
      cargo: 'Jefe de Logística',
      contLabFecInicio: DateTime(2020, 1, 15),
      contLabFecFin: null,
    );

    _apiService.setToken(_usuario!.token);

    _isLoading = false;
    notifyListeners();
    return true;
  }
  // ===== FIN MODO MOCK =====
}