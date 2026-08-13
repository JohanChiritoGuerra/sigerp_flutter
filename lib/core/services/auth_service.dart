import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/login_sigerp_response.dart';
import '../models/menu_usuario_response.dart';
import '../models/perfil_trabajador.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'menu_service.dart';
import 'notification_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final MenuService _menuService = MenuService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // AccNombre exactos configurados en la BD (Modulo=Finanzas/Gestión estratégica)
  static const _accAutorizarPresupuesto = 'Autorizar - ppto emergencia';
  static const _accConsultarPresupuesto = 'Consultar - ppto emergencia';
  static const _accAutorizarSolicitud = 'Autorizar - solicitud de compra';
  static const _accConsultarSolicitud = 'Consultar - solicitud de compra';
  static const _accRegistrarDiesel = 'Registrar - abastecimiento diesel';
  static const _accConsultarDiesel = 'Consultar - abastecimiento diesel';

  Usuario? _usuario;
  TrabajadorModel? _perfilTrabajador;
  MenuUsuarioResponse? _menu;
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

  // Permisos mobile (Modulo/Categoria/Acceso + RolAcceso/UsuarioAcceso.Mobile=1)
  bool get puedeAutorizarPresupuesto => _menu?.tieneAcceso(_accAutorizarPresupuesto) ?? false;
  bool get puedeConsultarPresupuesto => _menu?.tieneAcceso(_accConsultarPresupuesto) ?? false;
  bool get puedeAutorizarSolicitud => _menu?.tieneAcceso(_accAutorizarSolicitud) ?? false;
  bool get puedeConsultarSolicitud => _menu?.tieneAcceso(_accConsultarSolicitud) ?? false;
  bool get puedeRegistrarDiesel => _menu?.tieneAcceso(_accRegistrarDiesel) ?? false;
  bool get puedeConsultarDiesel => _menu?.tieneAcceso(_accConsultarDiesel) ?? false;

  // Login
  //
  // rememberMe siempre es true: los choferes/jefaturas de campo pueden pasar
  // días sin señal, así que la sesión (y el token largo que el backend emite
  // para "recordarme") no puede depender de que alguien se acuerde de marcar
  // una casilla. El parámetro se deja configurable solo por si en el futuro
  // hace falta un flujo que explícitamente NO deba persistir sesión.
  Future<bool> login({
    required String usuario,
    required String password,
    required String empresaId,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestBody = {
        'usuario': usuario,
        'password': password,
        'empresaId': empresaId,
        'rememberMe': rememberMe,
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
        if (loginResponse.refreshToken != null) {
          _apiService.setRefreshToken(loginResponse.refreshToken);
        }

        await obtenerPerfilTrabajador();
        await _cargarMenuMobile();
        // La sesión se guarda siempre (rememberMe es true por defecto) — sin
        // esto, reabrir la app sin conexión no tendría nada que restaurar.
        await _saveUserData();
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

  // Vuelve a pedir el menú de accesos al backend — se usa cuando la app
  // vuelve a primer plano, para reflejar accesos otorgados/revocados
  // mientras la sesión ya estaba abierta (sin esto, solo se ven al
  // volver a iniciar sesión).
  Future<void> refrescarMenu() => _cargarMenuMobile();

  // Renueva el token en silencio cada vez que hay oportunidad (la app vuelve
  // a primer plano con señal), igual que hacen Facebook/apps de campo tipo
  // Salesforce: no esperan a que el token expire y falle una petición, lo
  // renuevan antes, de forma invisible para el usuario. Si falla (sin señal,
  // o el refresh token ya venció), no pasa nada aquí — el mecanismo
  // reactivo de ApiService (reintentar tras un 401) sigue siendo el respaldo.
  Future<void> refrescarSesion() async {
    if (_usuario == null) return;
    await _apiService.renovarTokenSiEsPosible();
  }

  // Obtener accesos mobile del usuario (autorizar/consultar presupuesto y solicitud)
  //
  // Sin conexión, un pedido nuevo simplemente no puede llegar al backend —
  // en vez de dejar al usuario sin menú, se cae al último menú que sí se
  // descargó con éxito (guardado localmente). Es solo un tema visual: la
  // acción real (Registrar/Listar, etc.) siempre revalida el acceso puntual
  // en el servidor, así que una copia desactualizada acá no compromete nada.
  Future<void> _cargarMenuMobile() async {
    if (_usuario?.usuaId == null) return;

    try {
      final menuRemoto = await _menuService.obtenerMenuUsuarioMobile(
        usuarioId: _usuario!.usuaId!,
        empresaId: _usuario!.empresaId ?? '02',
      );
      if (menuRemoto.esExitoso) {
        _menu = menuRemoto;
        await _guardarMenuCache(menuRemoto);
        notifyListeners();
        return;
      }
      await _cargarMenuDesdeCache();
    } catch (e) {
      debugPrint('Error al obtener menú mobile: $e');
      await _cargarMenuDesdeCache();
    }
  }

  String get _claveMenuCache => 'menu_cache_${_usuario?.usuaId}';

  Future<void> _guardarMenuCache(MenuUsuarioResponse menu) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_claveMenuCache, jsonEncode(menu.modulosToJson()));
    } catch (e) {
      debugPrint('Error al guardar caché del menú: $e');
    }
  }

  Future<void> _cargarMenuDesdeCache() async {
    if (_menu != null) return; // ya hay un menú en memoria (de esta misma sesión), no lo pisamos con la caché
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_claveMenuCache);
      if (data == null) return;
      _menu = MenuUsuarioResponse.desdeCache(jsonDecode(data) as List<dynamic>);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar caché del menú: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    // Mejor esfuerzo: intenta invalidar la sesión en el servidor (con
    // timeout corto). El borrado local de abajo sucede siempre, haya o no
    // señal en este momento — el usuario nunca se queda esperando por esto.
    await _apiService.invalidarSesionRemota();

    await NotificationService().limpiarUsuario();
    _usuario = null;
    _perfilTrabajador = null;
    _menu = null;
    _apiService.setToken(null);
    _apiService.setRefreshToken(null);
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
        final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
        if (refreshToken != null) {
          _apiService.setRefreshToken(refreshToken);
        }

        // Renovación proactiva también al arrancar la app desde cero (no
        // solo al volver de segundo plano) — es el momento más común en que
        // un token pudo quedar viejo tras varios días sin abrir la app.
        await refrescarSesion();

        await obtenerPerfilTrabajador();
        await _cargarMenuMobile();
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
      if (_apiService.refreshToken != null) {
        await _storage.write(key: AppConstants.refreshTokenKey, value: _apiService.refreshToken);
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
    await _storage.delete(key: AppConstants.refreshTokenKey);
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