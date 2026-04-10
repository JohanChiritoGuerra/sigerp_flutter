import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_version.dart';
import '../../../core/utils/constants.dart';
import '../../auth/login_screen.dart';

class ProfileBottomSheet extends StatelessWidget {
  const ProfileBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final usuario = authService.usuario;
    final perfil = authService.perfilTrabajador;
    final nombreCompleto = usuario?.nombreCompleto ?? 'Usuario';

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle de arrastre
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Contenido scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 20),

                    // Avatar grande + nombre + cargo
                    _buildHeader(context, nombreCompleto, authService.cargo),

                    const SizedBox(height: 24),

                    // Separador
                    Divider(color: Colors.grey[200], thickness: 1),

                    const SizedBox(height: 16),

                    // Sección: Información Personal
                    _buildSectionTitle('INFORMACIÓN PERSONAL'),
                    const SizedBox(height: 12),

                    _buildInfoTile(
                      icon: Icons.badge_outlined,
                      label: 'DNI',
                      value: perfil?.trabDNI ?? usuario?.dni ?? 'No disponible',
                    ),
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      label: 'Usuario',
                      value: usuario?.webUser ?? 'No disponible',
                    ),
                    _buildInfoTile(
                      icon: Icons.work_outline,
                      label: 'Cargo',
                      value: perfil?.cargo ?? 'No disponible',
                    ),
                    _buildInfoTile(
                      icon: Icons.business_outlined,
                      label: 'Empresa',
                      value: authService.area,
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200], thickness: 1),
                    const SizedBox(height: 16),

                    // Sección: Contacto
                    _buildSectionTitle('CONTACTO'),
                    const SizedBox(height: 12),

                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      label: 'Correo',
                      value: perfil?.trabCorreoElec.isNotEmpty == true
                          ? perfil!.trabCorreoElec
                          : 'No registrado',
                    ),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: perfil?.trabTelef.isNotEmpty == true
                          ? perfil!.trabTelef
                          : 'No registrado',
                    ),
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Dirección',
                      value: perfil?.trabDireccion.isNotEmpty == true
                          ? perfil!.trabDireccion
                          : usuario?.direccion ?? 'No registrada',
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200], thickness: 1),
                    const SizedBox(height: 16),

                    // Sección: Laboral
                    _buildSectionTitle('INFORMACIÓN LABORAL'),
                    const SizedBox(height: 12),

                    _buildInfoTile(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha de Ingreso',
                      value: _formatDate(
                        perfil?.contLabFecInicio ?? usuario?.contLabFecInicio,
                      ),
                    ),
                    _buildInfoTile(
                      icon: Icons.numbers,
                      label: 'Código Trabajador',
                      value: usuario?.trabId ?? 'No disponible',
                    ),
                    _buildInfoTile(
                      icon: Icons.verified_outlined,
                      label: 'Estado',
                      value: (usuario?.estado ?? 0) == 1 ? 'Activo' : 'Inactivo',
                      valueColor: (usuario?.estado ?? 0) == 1
                          ? Color(AppColors.successColor)
                          : Color(AppColors.errorColor),
                    ),

                    const SizedBox(height: 28),

                    // Botón Cerrar Sesión
                    _buildLogoutButton(context),

                    const SizedBox(height: 16),

                    // Versión
                    Center(
                      child: Text(
                        'SIGERP v$kAppVersion',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String nombre, String cargo) {
    return Column(
      children: [
        // Avatar grande
        CircleAvatar(
          radius: 40,
          backgroundColor: Color(AppColors.primaryColor),
          child: Text(
            _getInitials(nombre),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Nombre completo
        Text(
          nombre,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Cargo con chip
        if (cargo.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Color(AppColors.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cargo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(AppColors.primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? Colors.black87,
                    fontWeight: valueColor != null ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context); // Cerrar bottom sheet
          _showLogoutDialog(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(AppColors.errorColor),
          side: BorderSide(color: Color(AppColors.errorColor).withOpacity(0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Color(AppColors.errorColor), size: 24),
            const SizedBox(width: 10),
            const Text('Cerrar Sesión'),
          ],
        ),
        content: const Text('¿Está seguro que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final authService = ctx.read<AuthService>();
              await authService.logout();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  ctx,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.errorColor),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
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
}
