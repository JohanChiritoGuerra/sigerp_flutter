import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

/// Handler de mensajes en background (debe ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 [FCM Background] message: ${message.messageId}');
  // No necesita inicializar Firebase aquí si ya se hizo en main.dart
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// GlobalKey del Navigator para navegar desde fuera del widget tree
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Callback para cuando se toca una notificación y hay datos de navegación
  static void Function(Map<String, dynamic> data)? onNotificationTapped;

  /// Intent pendiente: si llegó una push pero no había sesión activa,
  /// se guarda aquí para ejecutarlo después del login.
  static Map<String, dynamic>? _pendingNavigation;

  /// Consume el intent pendiente y lo devuelve (o null si no hay).
  /// Llamar después del login exitoso.
  static Map<String, dynamic>? consumePendingNavigation() {
    final data = _pendingNavigation;
    _pendingNavigation = null;
    return data;
  }

  /// Usuario autenticado (se establece tras el login / checkSavedSession)
  static String? _webUser;
  static String? _empresaId;
  static String? _cachedToken;

  /// Canal de notificaciones Android (alta prioridad)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'sigerp_high_importance',
    'Notificaciones SIGERP',
    description: 'Notificaciones de autorizaciones pendientes',
    importance: Importance.high,
    playSound: true,
  );

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    // 1. Solicitar permisos
    await _requestPermissions();

    // 2. Configurar notificaciones locales
    await _setupLocalNotifications();

    // 3. Crear canal Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // 4. Configurar handlers de FCM
    _setupFCMHandlers();

    // 5. Obtener y mostrar token FCM (para debug y registro en backend)
    await _getToken();

    // 6. Verificar si la app fue abierta desde una notificación
    await _checkInitialMessage();
  }

  /// Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint('📱 [FCM] Permisos: ${settings.authorizationStatus}');
  }

  /// Configurar notificaciones locales
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Configurar handlers de Firebase Cloud Messaging
  void _setupFCMHandlers() {
    // Mensaje recibido mientras la app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App abierta desde notificación (app estaba en background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Listener para cambio de token
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 [FCM] Token actualizado: $newToken');
      // TODO: Enviar nuevo token al backend
      _sendTokenToBackend(newToken);
    });
  }

  /// Obtener token FCM
  Future<String?> _getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('🔑 [FCM] Token: $token');

      if (token != null) {
        // TODO: Enviar token al backend para asociarlo al usuario
        _sendTokenToBackend(token);
      }

      return token;
    } catch (e) {
      debugPrint('❌ [FCM] Error obteniendo token: $e');
      return null;
    }
  }

  /// Verificar si la app fue abierta desde una notificación (terminated state)
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 [FCM] App abierta desde notificación (terminated)');
      _handleNotificationData(initialMessage.data);
    }
  }

  /// Manejar mensaje recibido en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 [FCM Foreground] ${message.notification?.title ?? message.data['titulo']}');

    // Si no hay bloque notification (mensaje data-only), construir título/cuerpo desde data
    final notification = message.notification;
    final title = notification?.title ?? message.data['titulo'] ?? message.data['title'] ?? 'SIGERP';
    final body  = notification?.body  ?? message.data['mensaje'] ?? message.data['body']  ?? '';

    if (title == 'SIGERP' && body.isEmpty) return;

    // Mostrar notificación local (porque en foreground FCM no la muestra automáticamente)
    _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Pasar datos como payload para que al tocar abra la vista correcta
      payload: jsonEncode(message.data),
    );
  }

  /// App abierta desde notificación (background → foreground)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📲 [FCM] App abierta desde notificación (background)');
    _handleNotificationData(message.data);
  }

  /// Notificación local tocada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👆 [Local] Notificación tocada');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationData(data);
      } catch (e) {
        debugPrint('❌ Error parseando payload: $e');
      }
    }
  }

  /// Procesar datos de navegación de la notificación.
  /// Si no hay sesión activa (sin callback registrado), guarda el intent
  /// como pendiente para ejecutarlo tras el login.
  void _handleNotificationData(Map<String, dynamic> data) {
    debugPrint('📋 [Notification Data] $data');

    if (data.isEmpty) return;

    if (onNotificationTapped != null) {
      onNotificationTapped!(data);
    } else {
      // No hay sesión activa — guardar para ejecutar tras el login
      debugPrint('📌 [FCM] Guardando navegación pendiente hasta el login');
      _pendingNavigation = data;
    }
  }

  /// Enviar token FCM al backend para asociarlo al usuario
  Future<void> _sendTokenToBackend(String token) async {
    _cachedToken = token;
    if (_webUser == null || _empresaId == null) {
      debugPrint('📤 [FCM] Token en caché, esperando usuario autenticado');
      return;
    }
    try {
      await ApiService().post('api/Notificaciones/RegistrarToken', {
        'webUser': _webUser,
        'empresaId': _empresaId,
        'fcmToken': token,
        'nombreDispositivo': Platform.isAndroid ? 'Android' : 'iOS',
        'plataforma': Platform.isAndroid ? 'android' : 'ios',
      });
      debugPrint('✅ [FCM] Token registrado en backend para usuario: $_webUser');
    } catch (e) {
      debugPrint('❌ [FCM] Error registrando token: $e');
    }
  }

  /// Asociar el usuario autenticado al token FCM.
  /// Llamar desde AuthService después del login o checkSavedSession.
  Future<void> configurarUsuario(String webUser, String empresaId) async {
    _webUser = webUser;
    _empresaId = empresaId;
    // Siempre solicitar token fresco en cada login para asegurar que la BD
    // tenga el token vigente del dispositivo, independientemente del usuario anterior.
    await _getToken();
  }

  /// Limpiar usuario (logout)
  /// IMPORTANTE: NO se borra _cachedToken porque el token FCM pertenece al
  /// dispositivo, no al usuario. El siguiente login reutiliza el mismo token.
  /// SÍ se desregistra en el backend para que deje de recibir pushes.
  Future<void> limpiarUsuario() async {
    // Desregistrar token en BD para que el servidor deje de enviar pushes
    if (_webUser != null && _empresaId != null && _cachedToken != null) {
      try {
        await ApiService().post('api/Notificaciones/DesregistrarToken', {
          'webUser': _webUser,
          'empresaId': _empresaId,
          'fcmToken': _cachedToken,
        });
        debugPrint('✅ [FCM] Token desregistrado en backend para usuario: $_webUser');
      } catch (e) {
        debugPrint('⚠️ [FCM] No se pudo desregistrar token: $e');
        // No bloquear el logout aunque falle
      }
    }
    _webUser = null;
    _empresaId = null;
    // _cachedToken se conserva intencionalmente (es del dispositivo)
  }

  /// Suscribirse a un tema (ej: por empresa, por rol)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('📌 [FCM] Suscrito a tema: $topic');
  }

  /// Desuscribirse de un tema
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('📌 [FCM] Desuscrito de tema: $topic');
  }
}
