import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/version_service.dart';
import 'core/utils/app_version.dart';
import 'core/utils/constants.dart';
import 'modules/abastecimiento_diesel/abastecimiento_diesel_screen.dart';
import 'modules/abastecimiento_diesel/services/abastecimiento_diesel_repository.dart';
import 'modules/auth/login_screen.dart';
import 'modules/home/home_screen.dart';
import 'modules/presupuestos_emergencia/presupuesto_emergencia_auth_screen.dart';
import 'modules/presupuestos_emergencia/presupuesto_emergencia_consulta_screen.dart';
import 'modules/solicitudes_compra/solicitud_compra_auth_screen.dart';
import 'modules/solicitudes_compra/solicitud_compra_consulta_screen.dart';

/// GlobalKey para navegar desde fuera del widget tree (ej: notificaciones FCM)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// GlobalKey para mostrar SnackBars desde fuera del widget tree (ej: aviso de
/// reconexión con borradores pendientes, sin importar en qué pantalla esté
/// parado el usuario en ese momento).
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SigerpApp extends StatelessWidget {
  const SigerpApp({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService.navigatorKey = navigatorKey;
    NotificationService.onNotificationTapped = (data) {
      final tipo = data['tipo']?.toString().toUpperCase();
      final nav = navigatorKey.currentState;
      if (nav == null) return;

      // El ID de referencia puede venir como 'idReferencia' o 'id'
      final idRef = data['idReferencia']?.toString() ?? data['id']?.toString();

      switch (tipo) {
        // Presupuesto de Emergencia — alguien debe autorizar
        case 'AUTORIZACION':
        // Presupuesto de Emergencia — el área de presupuesto debe atender
        case 'ATENCION':
          nav.push(MaterialPageRoute(
            builder: (_) => PresupuestoEmergenciaAuthScreen(
              autoOpenId: idRef != null ? int.tryParse(idRef) : null,
            ),
          ));
          break;

        // Presupuesto de Emergencia — el creador fue observado o su PE fue atendido
        case 'OBSERVACION':
        case 'ATENCION_USUARIO':
          nav.push(MaterialPageRoute(
            builder: (_) => PresupuestoEmergenciaConsultaScreen(
              autoOpenId: idRef != null ? int.tryParse(idRef) : null,
            ),
          ));
          break;

        // Solicitud de Compra — alguien debe autorizar (tipo antiguo)
        case 'AUTORIZACION_SC':
        // Solicitud de Compra — pendiente de autorización de jefe/gerente
        case 'SOLICITUD_PENDIENTE':
          nav.push(MaterialPageRoute(
            builder: (_) => SolicitudCompraAuthScreen(autoOpenId: idRef),
          ));
          break;

        // Solicitud de Compra — el creador fue observado o su SC fue atendida (tipo antiguo)
        case 'OBSERVACION_SC':
        case 'ATENCION_USUARIO_SC':
        // Solicitud de Compra — notificaciones al creador desde los SPs
        case 'SOLICITUD_AUTORIZADA':
        case 'SOLICITUD_OBSERVADA':
        case 'SOLICITUD_ERROR':
          nav.push(MaterialPageRoute(
            builder: (_) => SolicitudCompraConsultaScreen(autoOpenId: idRef),
          ));
          break;

        // Compatibilidad con tipos anteriores PE / SC
        case 'PE':
          nav.push(MaterialPageRoute(
            builder: (_) => PresupuestoEmergenciaAuthScreen(
              autoOpenId: idRef != null ? int.tryParse(idRef) : null,
            ),
          ));
          break;
        case 'SC':
          nav.push(MaterialPageRoute(
            builder: (_) => SolicitudCompraAuthScreen(autoOpenId: idRef),
          ));
          break;
      }
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: _AppLifecycleObserver(
        child: MaterialApp(
        title: AppConstants.appName,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppColors.primaryColor),
            primary: const Color(AppColors.primaryColor),
            secondary: const Color(AppColors.primaryLightColor),
            surface: const Color(AppColors.surfaceColor),
            error: const Color(AppColors.errorColor),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(AppColors.textBodyColor),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(AppColors.backgroundColor),
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            headlineLarge: GoogleFonts.poppins(
              color: const Color(AppColors.textPrimaryColor),
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: GoogleFonts.poppins(
              color: const Color(AppColors.textPrimaryColor),
              fontWeight: FontWeight.w600,
            ),
            titleLarge: GoogleFonts.poppins(
              color: const Color(AppColors.textPrimaryColor),
              fontWeight: FontWeight.w600,
            ),
            titleMedium: GoogleFonts.poppins(
              color: const Color(AppColors.textSecondaryColor),
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: GoogleFonts.poppins(
              color: const Color(AppColors.textBodyColor),
            ),
            bodyMedium: GoogleFonts.poppins(
              color: const Color(AppColors.textBodyColor),
            ),
            bodySmall: GoogleFonts.poppins(
              color: const Color(AppColors.textMutedColor),
            ),
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: const Color(AppColors.primaryColor),
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(AppColors.primaryColor),
              side: const BorderSide(color: Color(AppColors.primaryColor)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppColors.primaryColor),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(AppColors.greyLightColor)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(AppColors.greyLightColor)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(AppColors.primaryColor), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: const TextStyle(color: Color(AppColors.greyMediumColor)),
            labelStyle: const TextStyle(color: Color(AppColors.textMutedColor)),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(AppColors.greyLightColor),
            thickness: 1,
          ),
          iconTheme: const IconThemeData(
            color: Color(AppColors.primaryColor),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(AppColors.primaryColor),
            foregroundColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
        scaffoldMessengerKey: scaffoldMessengerKey,
        ),
      ),
    );
  }
}

/// Refresca el menú de accesos cuando la app vuelve a primer plano — así se
/// reflejan permisos otorgados/revocados mientras la sesión ya estaba abierta,
/// sin tener que cerrar sesión y volver a entrar.
class _AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  const _AppLifecycleObserver({required this.child});

  @override
  State<_AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<_AppLifecycleObserver> with WidgetsBindingObserver {
  final ConnectivityService _connectivity = ConnectivityService();
  final AbastecimientoDieselRepository _dieselRepository = AbastecimientoDieselRepository();
  StreamSubscription<bool>? _conexionSub;
  bool? _ultimoEstadoOnline;
  AuthService? _authService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Aviso de reconexión con borradores de Diesel pendientes, sin importar
    // en qué pantalla esté el usuario en ese momento — antes solo se veía si
    // justo estaba parado en la pantalla de Diesel. Si esa pantalla SÍ está
    // abierta, ella misma ya muestra su propio aviso en el momento exacto
    // (más inmediato), así que acá se evita duplicarlo.
    _connectivity.isOnline().then((online) => _ultimoEstadoOnline = online);
    _conexionSub = _connectivity.onStatusChange.listen(_onConectividadCambio);

    // Sincroniza los catálogos de Diesel (Centro de Costo/Jefatura/Chofer) ni
    // bien hay sesión activa con acceso al módulo — así no dependen de que el
    // usuario entre manualmente a "Abastecimiento de Diesel" para que queden
    // disponibles offline más tarde. sincronizarCatalogosSiCorresponde() ya
    // tiene su propio límite de 24h adentro, así que no importa que esto se
    // dispare varias veces (login, sesión restaurada, cada refresco de menú).
    _authService = context.read<AuthService>();
    _authService!.addListener(_onAuthCambio);
    _onAuthCambio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _conexionSub?.cancel();
    _authService?.removeListener(_onAuthCambio);
    super.dispose();
  }

  void _onAuthCambio() {
    final authService = _authService;
    if (authService == null) return;
    final usuario = authService.usuario;
    if (usuario == null) return;
    if (!authService.puedeRegistrarDiesel && !authService.puedeConsultarDiesel) return;

    // Retraso a propósito: si esto arranca en el mismo instante del login,
    // compite por ancho de banda con lo primero que el usuario realmente
    // quiere ver (ej. abre "Mis salidas" apenas entra) — sobre todo grave en
    // la primera sincronización de la instalación, cuando los 3 catálogos
    // (incluidos los +9,000 choferes) se bajan enteros de una. Unos segundos
    // de margen le dan prioridad a esa primera pantalla.
    final empresaId = usuario.empresaId ?? '02';
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _dieselRepository.sincronizarCatalogosSiCorresponde(empresaId: empresaId);
    });
  }

  Future<void> _onConectividadCambio(bool online) async {
    final eraOffline = _ultimoEstadoOnline == false;
    _ultimoEstadoOnline = online;
    if (!online || !eraOffline || dieselScreenAbierta || !mounted) return;

    final authService = context.read<AuthService>();
    final usuario = authService.usuario;
    if (usuario == null) return;

    final pendientes = await _dieselRepository.contarBorradoresPendientes(
      usuaId: usuario.usuaId ?? '',
      empresaId: usuario.empresaId ?? '02',
    );
    if (pendientes == 0) return;

    // El plugin de conectividad a veces reporta el reingreso a "online" en
    // varios pasos intermedios muy seguidos mientras la conexión real se
    // estabiliza (ej. wifi reconectando) — cada uno dispara este método de
    // nuevo, y como los SnackBar se ENCOLAN (no se reemplazan), sin esto
    // terminaban apilándose varios avisos idénticos uno atrás de otro,
    // dando la sensación de un aviso "pegado" que no se iba nunca. Al
    // limpiar la cola antes de mostrar, nunca hay más de uno a la vez.
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          'Conexión recuperada. Tienes $pendientes borrador${pendientes == 1 ? '' : 'es'} de Diesel pendiente${pendientes == 1 ? '' : 's'}.',
        ),
        backgroundColor: Colors.blueGrey[800],
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () => navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const AbastecimientoDieselScreen(initialTabIndex: 1)),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authService = context.read<AuthService>();
      if (authService.usuario != null) {
        authService.refrescarMenu();
        authService.refrescarSesion();
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Color verde del logo de la empresa
  static const Color _logoColor = Color(0xFF2EAD4B); // Verde principal

  @override
  void initState() {
    super.initState();

    // Controlador para rotación del anillo
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Controlador para efecto de pulso suave en el logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkSession();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar versión antes de continuar
    final versionResult = await VersionService().verificarVersion();
    if (!mounted) return;

    if (versionResult != null && !versionResult.actualizado) {
      await _mostrarModalActualizacion(versionResult.versionMinima);
      return; // App bloqueada, el usuario debe ir a Sistemas
    }

    // En modo mock, ir directo al login sin verificar sesión guardada
    if (AppConfig.useMockData) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final hasSession = await authService.checkSavedSession();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasSession ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  Future<void> _mostrarModalActualizacion(String versionMinima) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 28),
              SizedBox(width: 10),
              Text('Versión desactualizada',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu versión de SIGERP no está actualizada.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Text(
                'Acércate al Departamento de Sistemas para instalar la versión más reciente.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Versión instalada:  $kAppVersion',
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('Versión requerida:  $versionMinima',
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anillo giratorio alrededor del logo
              RotationTransition(
                turns: _rotationController,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _RingPainter(
                    color: _logoColor,
                  ),
                ),
              ),

              // Logo con efecto de pulso suave
              ScaleTransition(
                scale: _pulseAnimation,
                child: Image.asset(
                  'assets/images/logo_color.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter para dibujar un arco/anillo parcial que gira
class _RingPainter extends CustomPainter {
  final Color color;

  _RingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    // Dibujar arco parcial (120 grados = 2.094 radianes)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // ángulo inicial
      2.094, // longitud del arco (~120 grados)
      false,
      paint,
    );

    // Segundo arco opuesto para balance visual
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159, // 180 grados
      2.094,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}