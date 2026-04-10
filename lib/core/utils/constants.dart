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
      return kIsWeb
          ? 'https://localhost:7255/'
          : 'https://192.168.100.101:7255/';
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
      return 'https://localhost:7255/';
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
  
  // ===== MODO MOCK PARA DESARROLLO =====
  // Cambiar a false cuando se conecte con la API real
  static bool useMockData = false;
}

class AppConstants {
  // Nombre de la app
  static const String appName = 'Sigerp';
  static const String appVersion = '1.0.2';
  
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
  
  /// Azul primario - AppBar, botones principales, iconos activos
  /// Opciones: Azul 0xFF1565C0 | Verde 0xFF2EAD4B
  static const int primaryColor = 0xFF1565C0;
  
  /// Azul primario claro - Hover states, fondos destacados
  /// Opciones: Azul 0xFF1E88E5 | Verde 0xFF4CAF50
  static const int primaryLightColor = 0xFF1E88E5;
  
  /// Azul primario oscuro - Textos importantes, encabezados
  /// Opciones: Azul 0xFF0D47A1 | Verde 0xFF1B5E20
  static const int primaryDarkColor = 0xFF0D47A1;
  
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
  /// Opciones: Azul 0xFF0D47A1 | Verde 0xFF1B5E20
  static const int textPrimaryColor = 0xFF0D47A1;
  
  /// Subtítulos, enlaces
  /// Opciones: Azul 0xFF1565C0 | Verde 0xFF2EAD4B
  static const int textSecondaryColor = 0xFF1565C0;
  
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