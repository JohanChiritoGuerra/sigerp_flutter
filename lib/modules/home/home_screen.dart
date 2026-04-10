import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notificaciones_push_service.dart';
import '../../core/utils/app_version.dart';
import '../../core/utils/constants.dart';
import '../auth/login_screen.dart';
import '../presupuestos_emergencia/presupuesto_emergencia_auth_screen.dart';
import '../presupuestos_emergencia/presupuesto_emergencia_consulta_screen.dart';
import '../presupuestos_emergencia/services/presupuesto_emergencia_service.dart';
import '../solicitudes_compra/solicitud_compra_auth_screen.dart';
import '../solicitudes_compra/solicitud_compra_consulta_screen.dart';
import '../solicitudes_compra/services/solicitud_compra_service.dart';
import 'widgets/module_card.dart';
import 'widgets/notifications_panel.dart';
import 'widgets/profile_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PresupuestoEmergenciaService _peService = PresupuestoEmergenciaService();
  final SolicitudCompraService _scService = SolicitudCompraService();
  final NotificacionesPushService _notifService = NotificacionesPushService();

  int _pendientesPresupuesto = 0;
  int _pendientesSolicitud = 0;
  int _notificacionesNoLeidas = 0;
  int _consultaPresupuesto = 0;
  int _consultaSolicitud = 0;
  DateTime? _ultimaActualizacion;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
    // Cuando llega una push en foreground, refrescar el conteo del badge
    FirebaseMessaging.onMessage.listen((_) {
      _refreshNotificacionesCount();
    });
  }

  Future<void> _refreshNotificacionesCount() async {
    if (!mounted) return;
    final authService = context.read<AuthService>();
    final usuario = authService.usuario;
    final webUser = usuario?.webUser ?? '';
    final empresaId = usuario?.empresaId ?? '02';
    final res = await _notifService.consultarNoLeidas(
      usuaId: webUser,
      empresaId: empresaId,
    );
    if (mounted) {
      setState(() {
        _notificacionesNoLeidas = res.esExitoso ? res.notificaciones.length : 0;
      });
    }
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final usuario = authService.usuario;
    final webUser = usuario?.webUser ?? '';
    final empresaId = usuario?.empresaId ?? '02';

    try {
      final peFuture = _peService.obtenerListasAutorizacion(
        usuario: webUser,
        empresaId: empresaId,
      );
      final scFuture = _scService.obtenerListasAutorizacion(
        usuario: webUser,
        empresaId: empresaId,
      );
      final peConsultaFuture = _peService.obtenerListasConsulta(
        usuario: webUser,
        empresaId: empresaId,
      );
      final scConsultaFuture = _scService.obtenerListasConsulta(
        usuario: webUser,
        empresaId: empresaId,
      );

      final notifFuture = _notifService.consultarNoLeidas(
        usuaId: webUser,
        empresaId: empresaId,
      );

      final peRes        = await peFuture;
      final scRes        = await scFuture;
      final peConsultaRes = await peConsultaFuture;
      final scConsultaRes = await scConsultaFuture;
      final notifRes     = await notifFuture;

      if (mounted) {
        setState(() {
          _pendientesPresupuesto  = peRes.esExitoso ? peRes.porAutorizar.length : 0;
          _pendientesSolicitud    = scRes.esExitoso ? scRes.porAutorizar.length : 0;
          _notificacionesNoLeidas = notifRes.esExitoso ? notifRes.notificaciones.length : 0;
          _consultaPresupuesto   = peConsultaRes.esExitoso
              ? peConsultaRes.porAtender.length + peConsultaRes.atendidos.length + peConsultaRes.anulados.length
              : 0;
          _consultaSolicitud     = scConsultaRes.esExitoso
              ? scConsultaRes.porAutorizar.length + scConsultaRes.autorizados.length + scConsultaRes.anuladosRechazados.length
              : 0;
          _ultimaActualizacion   = DateTime.now();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  String _formatUltimaActualizacion() {
    if (_ultimaActualizacion == null) return 'Actualizando...';
    final now = DateTime.now();
    final diff = now.difference(_ultimaActualizacion!);
    if (diff.inSeconds < 30) return 'Hace un momento';
    if (diff.inMinutes < 1) return 'Hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    // Formato hora
    final h = _ultimaActualizacion!.hour.toString().padLeft(2, '0');
    final m = _ultimaActualizacion!.minute.toString().padLeft(2, '0');
    return 'Hoy a las $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final usuario = authService.usuario;
    final nombreCompleto = usuario?.nombreCompleto ?? 'Usuario';
    final primerNombre = nombreCompleto.split(' ').first;

    // Determinar permisos (simulado - debe venir del backend)
    final tienePermisoPresupuesto = true; // Cambiar según lógica real
    final tienePermisoSolicitud = true;   // Cambiar según lógica real
    final tieneAlgunPermiso = tienePermisoPresupuesto || tienePermisoSolicitud;
    
    // Usar conteos dinámicos del estado
    final pendientesPresupuesto = _pendientesPresupuesto;
    final pendientesSolicitud = _pendientesSolicitud;
    final totalPendientes = pendientesPresupuesto + pendientesSolicitud;
    final totalNotificaciones = _notificacionesNoLeidas;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          '👋 HOLA, $primerNombre',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Notificaciones con badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () async {
                  await NotificationsPanel.show(
                    context,
                    onRefreshNeeded: () {
                      if (mounted) _refreshNotificacionesCount();
                    },
                  );
                  if (mounted) _refreshNotificacionesCount();
                },
              ),
              if (totalNotificaciones > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(AppColors.errorColor),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$totalNotificaciones',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Avatar de usuario
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => ProfileBottomSheet.show(context),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _getInitials(nombreCompleto),
                  style: TextStyle(
                    color: Color(AppColors.primaryColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authService, tienePermisoPresupuesto, tienePermisoSolicitud),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Color(AppColors.primaryColor),
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje de autorizaciones pendientes - Diseño moderno tipo encabezado MD
            if (tieneAlgunPermiso && totalPendientes > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(AppColors.warningColor),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Tienes ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: '$totalPendientes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(AppColors.errorColor),
                                fontSize: 16,
                              ),
                            ),
                            const TextSpan(
                              text: ' autorizaciones pendientes',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Espacio entre AppBar/banner y la sección
            if (tieneAlgunPermiso && totalPendientes == 0)
              const SizedBox(height: 20),

            // Sección AUTORIZAR (solo si tiene algún permiso) - CON FRANJA
            if (tieneAlgunPermiso)
              _buildSectionWithBand(
                title: 'AUTORIZAR',
                backgroundColor: Colors.grey[50]!,
                children: [
                  if (tienePermisoPresupuesto)
                    Expanded(
                      child: ModuleCard(
                        icon: Icons.emergency,
                        title: 'Presupuesto\nEmergencia',
                        pendingCount: pendientesPresupuesto,
                        color: Color(AppColors.warningColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PresupuestoEmergenciaAuthScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  if (tienePermisoPresupuesto && tienePermisoSolicitud)
                    const SizedBox(width: 12),
                  if (tienePermisoSolicitud)
                    Expanded(
                      child: ModuleCard(
                        icon: Icons.shopping_cart,
                        title: 'Solicitud\nCompra',
                        pendingCount: pendientesSolicitud,
                        color: Color(AppColors.infoColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SolicitudCompraAuthScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            
            // Espacio entre secciones con fondo del home
            const SizedBox(height: 16),
            
            // Sección CONSULTAS (siempre visible) - CON FRANJA
            _buildSectionWithBand(
              title: 'CONSULTAS',
              backgroundColor: Colors.grey[50]!,
              children: [
                Expanded(
                  child: ModuleCard(
                    icon: Icons.description_outlined,
                    title: 'Ver\nPresupuesto\nEmergencia',
                    subtitle: 'Ver ($_consultaPresupuesto)',
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PresupuestoEmergenciaConsultaScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModuleCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Ver\nSolicitud\nCompra',
                    subtitle: 'Ver ($_consultaSolicitud)',
                    color: Color(AppColors.successColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SolicitudCompraConsultaScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Espacio final y última actualización
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
              
                  const SizedBox(height: 24),
              
                  // Última actualización
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey[600],
                            ),
                          )
                        else
                          Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        const SizedBox(width: 4),
                        Text(
                          'Última actualización: ${_formatUltimaActualizacion()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Column(
      children: [
        // Línea delgada con degradado
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(AppColors.primaryColor).withOpacity(0.2),
                Color(AppColors.primaryColor),
                Color(AppColors.primaryColor).withOpacity(0.2),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Título centrado en negro y bold
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  // Nuevo método para crear secciones con franja de color
  Widget _buildSectionWithBand({
    required String title,
    required Color backgroundColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Column(
        children: [
          // Línea superior con degradado
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.1),
                  Colors.grey.withOpacity(0.4),
                  Colors.grey.withOpacity(0.1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Título alineado a la derecha con padding
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Cards en fila con padding horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: children,
            ),
          ),
          const SizedBox(height: 16),
          // Línea inferior con degradado
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.1),
                  Colors.grey.withOpacity(0.4),
                  Colors.grey.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthService authService, 
      bool tienePermisoPresupuesto, bool tienePermisoSolicitud) {
    final usuario = authService.usuario;
    final nombreCompleto = usuario?.nombreCompleto ?? 'Usuario';
    final webUser = usuario?.webUser ?? '';
    final cargo = authService.cargo;
    
    return Drawer(
      child: Column(
        children: [
          // Header del Drawer con información del usuario
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Color(AppColors.primaryColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    _getInitials(nombreCompleto),
                    style: TextStyle(
                      color: Color(AppColors.primaryColor),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nombreCompleto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Inicio',
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 1),

                // Sección AUTORIZAR (solo si tiene algún permiso)
                if (tienePermisoPresupuesto || tienePermisoSolicitud) ...[
                  _buildDrawerSection('AUTORIZAR'),
                  if (tienePermisoPresupuesto)
                    _buildDrawerItem(
                      context,
                      icon: Icons.emergency,
                      title: 'Autorizar Presupuesto\nde Emergencia',
                      color: Color(AppColors.warningColor),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PresupuestoEmergenciaAuthScreen(),
                          ),
                        );
                      },
                    ),
                  if (tienePermisoSolicitud)
                    _buildDrawerItem(
                      context,
                      icon: Icons.shopping_cart,
                      title: 'Autorizar Solicitud\nde Compra',
                      color: Color(AppColors.infoColor),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SolicitudCompraAuthScreen(),
                          ),
                        );
                      },
                    ),
                  const Divider(height: 1),
                ],

                // Sección CONSULTAS (siempre visible)
                _buildDrawerSection('CONSULTAS'),
                _buildDrawerItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Ver Presupuestos de Emergencia',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PresupuestoEmergenciaConsultaScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: 'Ver Solicitudes de Compra',
                  color: Color(AppColors.successColor),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SolicitudCompraConsultaScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Cerrar sesión al final
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  color: Color(AppColors.errorColor),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'v$kAppVersion • Build $kAppBuild',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    // Si no se proporciona color, usar el color primario para seleccionado o gris para no seleccionado
    final iconColor = color ?? (isSelected ? Color(AppColors.primaryColor) : Colors.grey[700]!);

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Color(AppColors.primaryColor) : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Color(AppColors.primaryColor).withOpacity(0.1),
      onTap: onTap,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Está seguro que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authService = context.read<AuthService>();
              await authService.logout();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.errorColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
