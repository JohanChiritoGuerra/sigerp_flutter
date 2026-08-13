import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
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

  Function()? onTokenExpired;
  Function(String newToken)? onTokenRefreshed;

  Map<String, String> _headers({bool includeAuth = true}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (includeAuth && _token != null) 'Authorization': 'Bearer $_token',
  };

  void setToken(String? token) => _token = token;
  void setRefreshToken(String? refreshToken) => _refreshToken = refreshToken;

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  // Cliente HTTP reutilizable — ignora certificados autofirmados (app interna
  // de empresa). Se crea UNA sola vez y se reutiliza en todas las peticiones:
  // antes se creaba un HttpClient nuevo en cada llamada, lo que descartaba el
  // keep-alive y forzaba un handshake TCP/TLS desde cero cada vez (esto era
  // buena parte de la demora reportada, sobre todo con varias llamadas
  // concurrentes como las que dispara la pantalla principal).
  http.Client? _client;

  http.Client _createClient() {
    if (_client != null) return _client!;
    if (!kIsWeb) {
      final ioClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      _client = IOClient(ioClient);
    } else {
      _client = http.Client();
    }
    return _client!;
  }

  // GET
  //
  // timeoutSeconds: opcional, para llamadas de fondo que pueden tardar más de
  // lo normal (ej. sincronizar el catálogo completo de choferes, +9,000
  // filas) sin que eso afecte el timeout de las llamadas interactivas
  // normales, donde 30s ya es demasiada espera si algo se cuelga.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool retry = true,
    int? timeoutSeconds,
  }) async {
    try {
      final client = _createClient();

      Uri url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

      if (queryParams != null) {
        url = url.replace(
          queryParameters: queryParams.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
      }

      final response = await client
          .get(url, headers: _headers())
          .timeout(Duration(seconds: timeoutSeconds ?? AppConstants.connectionTimeout));

      return await _processResponse(
        response,
        () => get(endpoint, queryParams: queryParams, retry: false, timeoutSeconds: timeoutSeconds),
        retry,
      );

    } on http.ClientException catch (_) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // POST
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool retry = true,
    bool skipAuthRetry = false,
  }) async {
    try {
      final client = _createClient();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await client
          .post(url, headers: _headers(), body: jsonEncode(body))
          .timeout(Duration(seconds: AppConstants.connectionTimeout));
      return await _processResponse(
        response,
        () => post(endpoint, body, retry: false),
        retry,
        skipAuthRetry: skipAuthRetry,
      );
    } on http.ClientException catch (_) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // GET binario (imágenes/archivos) — usa el mismo cliente que ignora el
  // certificado autofirmado; Image.network no lo hace y por eso nunca carga.
  Future<Uint8List?> getBytes(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final client = _createClient();

      Uri url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      if (queryParams != null) {
        url = url.replace(
          queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
        );
      }

      final response = await client
          .get(url, headers: _headers(includeAuth: true)..remove('Content-Type'))
          .timeout(Duration(seconds: AppConstants.connectionTimeout));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error al descargar bytes de $endpoint: $e');
      return null;
    }
  }

  // POST multipart (con archivo adjunto)
  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    File file,
    String fileFieldName, {
    bool retry = true,
  }) async {
    try {
      final client = _createClient();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });
      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath(fileFieldName, file.path));

      final streamedResponse = await client
          .send(request)
          .timeout(Duration(seconds: AppConstants.connectionTimeout));
      final response = await http.Response.fromStream(streamedResponse);

      return await _processResponse(
        response,
        () => postMultipart(endpoint, fields, file, fileFieldName, retry: false),
        retry,
      );
    } on http.ClientException catch (_) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // PUT
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool retry = true,
  }) async {
    try {
      final client = _createClient();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await client
          .put(url, headers: _headers(), body: jsonEncode(body))
          .timeout(Duration(seconds: AppConstants.connectionTimeout));
      return await _processResponse(response, () => put(endpoint, body, retry: false), retry);
    } on http.ClientException catch (_) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // DELETE
  Future<Map<String, dynamic>> delete(String endpoint, {bool retry = true}) async {
    try {
      final client = _createClient();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final response = await client
          .delete(url, headers: _headers())
          .timeout(Duration(seconds: AppConstants.connectionTimeout));
      return await _processResponse(response, () => delete(endpoint, retry: false), retry);
    } on http.ClientException catch (_) {
      return _errorResponse('Error de red. Verifica tu conexión a internet.');
    } catch (e) {
      return _errorResponse('Error de conexión: $e');
    }
  }

  // Procesar respuesta
  Future<Map<String, dynamic>> _processResponse(
    http.Response response,
    Future<Map<String, dynamic>> Function() retryRequest,
    bool canRetry, {
    bool skipAuthRetry = false,
  }) async {
    debugPrint('📡 STATUS CODE: ${response.statusCode}');
    debugPrint('📡 RESPONSE BODY: "${response.body}"');

    try {
      if (response.body.isEmpty) {
        return _errorResponse('El servidor retornó una respuesta vacía (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      // 401: solo intentar refresh si NO es endpoint de login
      if (response.statusCode == 401 && !skipAuthRetry && canRetry && _refreshToken != null) {
        final refreshed = await _attemptRefreshToken();
        if (refreshed) {
          return await retryRequest();
        } else {
          _handleTokenExpired();
          return _errorResponse('Sesión expirada. Por favor inicie sesión nuevamente.');
        }
      }

      // Login con credenciales incorrectas u otros errores: retornar JSON del backend directo
      return data;

    } catch (e) {
      debugPrint('❌ Parse error - Body: "${response.body}"');
      return _errorResponse('Error al procesar respuesta del servidor (${response.statusCode})');
    }
  }

  // Avisa al servidor para invalidar el refresh token al cerrar sesión —
  // "mejor esfuerzo": el logout local (borrar todo del celular) NUNCA debe
  // depender de esto. Timeout corto a propósito y nunca lanza: si no hay
  // señal en ese momento, simplemente no se pudo avisar, y el token en el
  // servidor quedará vivo hasta su expiración natural — no es ideal, pero
  // tampoco bloquea al usuario que solo quiere cerrar sesión ya.
  Future<void> invalidarSesionRemota() async {
    if (_refreshToken == null) return;
    try {
      final client = _createClient();
      final url = Uri.parse('${AppConstants.apiBaseUrl}api/LoginSigerp/logout');
      await client
          .post(
            url,
            headers: _headers(includeAuth: false),
            body: jsonEncode({'refreshToken': _refreshToken}),
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('No se pudo invalidar la sesión en el servidor: $e');
    }
  }

  // Renovación proactiva (no espera a que una petición falle con 401): se
  // usa cuando la app vuelve a primer plano con señal, para que el token
  // casi nunca llegue a expirar de verdad mientras el usuario siga abriendo
  // la app de vez en cuando. Si no hay refresh token guardado o falla (sin
  // señal, refresh token vencido), simplemente no hace nada — el mecanismo
  // reactivo ante un 401 sigue funcionando igual como respaldo.
  Future<bool> renovarTokenSiEsPosible() => _attemptRefreshToken();

  // Intentar refrescar el token
  Future<bool> _attemptRefreshToken() async {
    if (_isRefreshing) {
      await Future.delayed(const Duration(seconds: 1));
      return _token != null;
    }

    _isRefreshing = true;

    try {
      _refreshToken ??= await _storage.read(key: AppConstants.refreshTokenKey);

      if (_refreshToken == null) return false;

      final client = _createClient();
      final url = Uri.parse('${AppConstants.apiBaseUrl}api/LoginSigerp/refresh');
      final response = await client
          .post(
            url,
            headers: _headers(includeAuth: false),
            body: jsonEncode({'refreshToken': _refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['token'] ?? data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        if (newToken != null) {
          _token = newToken;
          if (newRefreshToken != null) {
            _refreshToken = newRefreshToken;
            await _storage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);
          }
          await _storage.write(key: AppConstants.tokenKey, value: newToken);
          onTokenRefreshed?.call(newToken);
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error al refrescar token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _handleTokenExpired() {
    _token = null;
    _refreshToken = null;
    _storage.delete(key: AppConstants.tokenKey);
    _storage.delete(key: AppConstants.refreshTokenKey);
    onTokenExpired?.call();
  }

  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

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