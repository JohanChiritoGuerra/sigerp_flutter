// Constantes de la aplicación SIGERP

import 'package:flutter/foundation.dart' show kIsWeb;

enum Environment { development, staging, production }

class AppConfig {
  static Environment _currentEnvironment = Environment.development;
  
  // Configurar el entorno actual
  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }
  
  // Obtener la URL base según el entorno
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        // Todos usan la API de producción por defecto
        return 'https://api.andahuasi.pe/';
      case Environment.staging:
        return 'https://staging.api.andahuasi.pe/';
      case Environment.production:
        return 'https://api.andahuasi.pe/';
    }
  }
  
  // URL para Web específicamente (siempre usa el dominio para CORS)
  static String get webApiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'https://api.andahuasi.pe/';
      case Environment.staging:
        return 'https://staging.api.andahuasi.pe/';
      case Environment.production:
        return 'https://api.andahuasi.pe/';
    }
  }
  
  // Obtener entorno actual
  static Environment get environment => _currentEnvironment;
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isProduction => _currentEnvironment == Environment.production;
}

class AppConstants {
  // Nombre de la app
  static const String appName = 'Sigerp';
  static const String appVersion = '1.0.0';
  
  // API Base URL - Diferencia entre Web (necesita dominio para CORS) y Móvil
  static String get apiBaseUrl => kIsWeb ? AppConfig.webApiBaseUrl : AppConfig.apiBaseUrl;
  
  // Timeouts
  static const int connectionTimeout = 30; // segundos
  static const int receiveTimeout = 30; // segundos
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String permissionsKey = 'permissions_data';
  
  // Retry configuration para refresh token
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
}

class AppColors {
  // ========== COLORES PRINCIPALES ==========
  // Ver: documentation/General/PALETA_DE_COLORES.md
  
  /// Verde primario - AppBar, botones principales, iconos activos
  static const int primaryColor = 0xFF2EAD4B;
  
  /// Verde primario claro - Hover states, fondos destacados
  static const int primaryLightColor = 0xFF4CAF50;
  
  /// Verde primario oscuro - Textos importantes, encabezados
  static const int primaryDarkColor = 0xFF1B5E20;
  
  /// Color secundario - Textos del cuerpo
  static const int secondaryColor = 0xFF424242;
  
  /// Color de acento - Elementos interactivos secundarios
  static const int accentColor = 0xFF1E88E5;
  
  // ========== COLORES NEUTROS ==========
  
  /// Fondo general de la app
  static const int backgroundColor = 0xFFFAFAFA;
  
  /// Tarjetas, contenedores
  static const int surfaceColor = 0xFFF5F5F5;
  
  /// Bordes, divisores, líneas
  static const int greyLightColor = 0xFFE0E0E0;
  
  /// Textos secundarios, placeholders
  static const int greyMediumColor = 0xFF9E9E9E;
  
  /// Textos terciarios, subtítulos
  static const int greyDarkColor = 0xFF616161;
  
  // ========== COLORES DE TEXTO ==========
  
  /// Títulos principales, encabezados destacados
  static const int textPrimaryColor = 0xFF1B5E20;
  
  /// Subtítulos, enlaces
  static const int textSecondaryColor = 0xFF2EAD4B;
  
  /// Texto general del cuerpo
  static const int textBodyColor = 0xFF424242;
  
  /// Textos secundarios, descripciones
  static const int textMutedColor = 0xFF757575;
  
  // ========== COLORES DE ESTADO ==========
  
  /// Éxito, aprobado
  static const int successColor = 0xFF4CAF50;
  
  /// Advertencia, pendiente
  static const int warningColor = 0xFFFF9800;
  
  /// Error, rechazado
  static const int errorColor = 0xFFF44336;
  
  /// Información, en proceso
  static const int infoColor = 0xFF2196F3;
  
  // ========== ESTADOS DE SOLICITUDES ==========
  
  static const int pendienteColor = 0xFFFF9800;    // Naranja
  static const int autorizadoColor = 0xFF4CAF50;   // Verde
  static const int observadoColor = 0xFFF44336;    // Rojo
  static const int enProcesoColor = 0xFF2196F3;    // Azul
}