import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _empresaController = TextEditingController(text: '02');
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _empresaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    
    final success = await authService.login(
      usuario: _usuarioController.text.trim(),
      password: _passwordController.text,
      empresaId: _empresaController.text.trim(),
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: Color(AppColors.errorColor),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con imagen difuminada
          Image.asset(
            'assets/images/login_background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback a un color si no existe la imagen
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(AppColors.primaryColor).withOpacity(0.8),
                      Color(AppColors.primaryDarkColor),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Capa de blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Contenido
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            
                            // Logo título en la parte superior izquierda
                            Image.asset(
                              'assets/images/login_title.png',
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                            
                            const Spacer(flex: 2),
                            
                            // Texto "Bienvenido"
                            Center(
                              child: Text(
                                'Bienvenido',
                                style: GoogleFonts.dancingScript(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Formulario
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Campo Usuario
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _usuarioController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Usuario',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        errorStyle: const TextStyle(color: Colors.yellowAccent),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Ingrese su usuario';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Campo Contraseña
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Contraseña',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword 
                                                ? Icons.visibility_off 
                                                : Icons.visibility,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        errorStyle: const TextStyle(color: Colors.yellowAccent),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese su contraseña';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Checkbox Recordarme
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          fillColor: WidgetStateProperty.resolveWith((states) {
                                            if (states.contains(WidgetState.selected)) {
                                              return Color(AppColors.primaryColor);
                                            }
                                            return Colors.white.withOpacity(0.3);
                                          }),
                                          checkColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white.withOpacity(0.5),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _rememberMe = !_rememberMe;
                                          });
                                        },
                                        child: Text(
                                          'Recordarme',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 30),
                                  
                                  // Botón Ingresar
                                  SizedBox(
                                    width: double.infinity,
                                    child: Consumer<AuthService>(
                                      builder: (context, authService, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xDDFFFFFF),
                                                Color(0xAAFFFFFF),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.25),
                                                blurRadius: 16,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 2),
                                              ),
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: authService.isLoading ? null : _login,
                                              borderRadius: BorderRadius.circular(16),
                                              splashColor: Colors.white.withOpacity(0.3),
                                              highlightColor: Colors.white.withOpacity(0.1),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 18),
                                                child: Center(
                                                  child: authService.isLoading
                                                      ? const SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            color: Color(0xFF37474F),
                                                          ),
                                                        )
                                                      : const Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.login_rounded,
                                                              color: Color(0xFF37474F),
                                                              size: 21,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Ingresar',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w800,
                                                                color: Color(0xFF37474F),
                                                                letterSpacing: 0.8,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  // ===== BOTÓN MODO DEMO (solo desarrollo) =====
                                  if (AppConfig.useMockData) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton(
                                        onPressed: () async {
                                          final authService = context.read<AuthService>();
                                          final success = await authService.loginMock();
                                          if (success && mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                        ),
                                        child: Text(
                                          '🔧 Entrar en modo Demo',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  // ===== FIN BOTÓN MODO DEMO =====
                                ],
                              ),
                            ),
                            
                            const Spacer(flex: 1),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}