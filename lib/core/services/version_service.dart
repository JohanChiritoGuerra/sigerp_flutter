import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import '../utils/constants.dart';
import '../utils/app_version.dart';

class VersionCheckResult {
  final bool actualizado;
  final String versionMinima;
  final String urlDescarga;

  VersionCheckResult({
    required this.actualizado,
    required this.versionMinima,
    required this.urlDescarga,
  });
}

class VersionService {
  static final VersionService _instance = VersionService._internal();
  factory VersionService() => _instance;
  VersionService._internal();

  /// Verifica si la versión instalada [kAppVersion] es válida comparándola
  /// con la versión mínima que devuelve el endpoint.
  /// Retorna null si no se puede conectar (se permite continuar).
  Future<VersionCheckResult?> verificarVersion() async {
    try {
      final baseUrl = AppConfig.apiBaseUrl;
      final uri = Uri.parse('${baseUrl}api/App/Version');

      // Cliente que acepta certificados auto-firmados (igual que ApiService)
      final client = IOClient(
        HttpClient()
          ..badCertificateCallback = (cert, host, port) => true,
      );

      final response = await client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      client.close();

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final versionMinima = (data['versionMinima'] as String? ?? '0.0.0').trim();
      final urlDescarga = (data['urlDescarga'] as String? ?? '').trim();

      final actualizado = _comparar(kAppVersion, versionMinima) >= 0;

      return VersionCheckResult(
        actualizado: actualizado,
        versionMinima: versionMinima,
        urlDescarga: urlDescarga,
      );
    } catch (e) {
      debugPrint('⚠️ [Version] No se pudo verificar versión: $e');
      return null; // Si falla la red, se permite continuar
    }
  }

  /// Compara versiones semánticas. Retorna:
  ///  1 si a > b,  0 si a == b,  -1 si a < b
  int _comparar(String a, String b) {
    final pa = a.split('.').map(int.tryParse).toList();
    final pb = b.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final va = (i < pa.length ? pa[i] : null) ?? 0;
      final vb = (i < pb.length ? pb[i] : null) ?? 0;
      if (va > vb) return 1;
      if (va < vb) return -1;
    }
    return 0;
  }
}
