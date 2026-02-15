import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/services/auth_service.dart';
// Firebase - DESCOMENTAR cuando se configure Firebase:
// import 'core/services/notification_service.dart';
import 'core/utils/constants.dart';
import 'modules/auth/login_screen.dart';
import 'modules/home/home_screen.dart';

/// GlobalKey para navegar desde fuera del widget tree (ej: notificaciones FCM)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SigerpApp extends StatelessWidget {
  const SigerpApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase - DESCOMENTAR cuando se configure Firebase:
    // NotificationService.navigatorKey = navigatorKey;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppColors.primaryColor),
            primary: const Color(AppColors.primaryColor),
            secondary: const Color(AppColors.primaryLightColor),
            surface: const Color(AppColors.surfaceColor),
            background: const Color(AppColors.backgroundColor),
            error: const Color(AppColors.errorColor),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(AppColors.textBodyColor),
            onBackground: const Color(AppColors.textBodyColor),
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
      ),
    );
  }
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