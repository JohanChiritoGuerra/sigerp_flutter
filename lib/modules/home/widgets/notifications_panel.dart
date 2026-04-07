import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/constants.dart';
import '../../presupuestos_emergencia/models/presupuesto_emergencia.dart';
import '../../presupuestos_emergencia/services/presupuesto_emergencia_service.dart';
import '../../presupuestos_emergencia/presupuesto_emergencia_auth_screen.dart';
import '../../solicitudes_compra/models/solicitud_compra.dart';
import '../../solicitudes_compra/services/solicitud_compra_service.dart';
import '../../solicitudes_compra/solicitud_compra_auth_screen.dart';

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsPanel(),
    );
  }

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  final PresupuestoEmergenciaService _peService = PresupuestoEmergenciaService();
  final SolicitudCompraService _scService = SolicitudCompraService();

  List<PresupuestoEmergenciaListaItem> _presupuestosPendientes = [];
  List<SolicitudCompraListaItem> _solicitudesPendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final usuario = authService.usuario;
    final webUser = usuario?.webUser ?? '';
    final empresaId = usuario?.empresaId ?? '02';

    try {
      final peRes = await _peService.obtenerListasAutorizacion(
        usuario: webUser,
        empresaId: empresaId,
      );
      final scRes = await _scService.obtenerListasAutorizacion(
        usuario: webUser,
        empresaId: empresaId,
      );

      if (mounted) {
        setState(() {
          _presupuestosPendientes = peRes.esExitoso ? peRes.porAutorizar : [];
          _solicitudesPendientes = scRes.esExitoso ? scRes.porAutorizar : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _totalPendientes =>
      _presupuestosPendientes.length + _solicitudesPendientes.length;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
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

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(AppColors.primaryColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: Color(AppColors.primaryColor),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notificaciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (!_isLoading)
                            Text(
                              _totalPendientes > 0
                                  ? '$_totalPendientes pendientes de autorización'
                                  : 'No hay pendientes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Badge con total
                    if (!_isLoading && _totalPendientes > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(AppColors.errorColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_totalPendientes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey[200], height: 1),

              // Contenido
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _totalPendientes == 0
                        ? _buildEmptyState()
                        : ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            children: [
                              // Presupuestos de Emergencia
                              if (_presupuestosPendientes.isNotEmpty) ...[
                                _buildGroupHeader(
                                  icon: Icons.emergency,
                                  title: 'Presupuestos de Emergencia',
                                  count: _presupuestosPendientes.length,
                                  color: Color(AppColors.warningColor),
                                ),
                                ..._presupuestosPendientes.map(
                                  (pe) => _buildPENotificationItem(pe),
                                ),
                                const SizedBox(height: 8),
                              ],

                              // Solicitudes de Compra
                              if (_solicitudesPendientes.isNotEmpty) ...[
                                _buildGroupHeader(
                                  icon: Icons.shopping_cart,
                                  title: 'Solicitudes de Compra',
                                  count: _solicitudesPendientes.length,
                                  color: Color(AppColors.infoColor),
                                ),
                                ..._solicitudesPendientes.map(
                                  (sc) => _buildSCNotificationItem(sc),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Botón ver todas
                              if (_totalPendientes > 0) ...[
                                Divider(color: Colors.grey[200]),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (_presupuestosPendientes.isNotEmpty)
                                      Expanded(
                                        child: _buildGoToButton(
                                          label: 'Ir a Presupuestos',
                                          icon: Icons.emergency,
                                          color: Color(AppColors.warningColor),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const PresupuestoEmergenciaAuthScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (_presupuestosPendientes.isNotEmpty &&
                                        _solicitudesPendientes.isNotEmpty)
                                      const SizedBox(width: 10),
                                    if (_solicitudesPendientes.isNotEmpty)
                                      Expanded(
                                        child: _buildGoToButton(
                                          label: 'Ir a Solicitudes',
                                          icon: Icons.shopping_cart,
                                          color: Color(AppColors.infoColor),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const SolicitudCompraAuthScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(AppColors.successColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 44,
              color: Color(AppColors.successColor),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Todo al día!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No tienes autorizaciones pendientes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.grey[700],
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPENotificationItem(PresupuestoEmergenciaListaItem pe) {
    return _buildNotificationCard(
      accentColor: Color(AppColors.warningColor),
      icon: Icons.emergency,
      codigo: pe.numero,
      titulo: pe.tipoEnum.label,
      monto: null,
      solicitante: pe.usuario,
      fecha: pe.fechaFormateada,
      badge: 'PENDIENTE',
      badgeColor: Color(AppColors.warningColor),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PresupuestoEmergenciaAuthScreen(),
          ),
        );
      },
    );
  }

  Widget _buildSCNotificationItem(SolicitudCompraListaItem sc) {
    final solicitud = SolicitudCompra.fromListaItem(sc);
    return _buildNotificationCard(
      accentColor: Color(AppColors.infoColor),
      icon: Icons.shopping_cart,
      codigo: solicitud.codigo,
      titulo: solicitud.sustento ?? 'Solicitud de Compra',
      monto: null,
      solicitante: solicitud.solicitanteNombre,
      fecha: _formatTimeAgo(solicitud.fechaSolicitud),
      badge: solicitud.tipo.codigo,
      badgeColor: Color(AppColors.infoColor),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SolicitudCompraAuthScreen(),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required Color accentColor,
    required IconData icon,
    required String codigo,
    required String titulo,
    String? monto,
    required String solicitante,
    required String fecha,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: icono + código + badge + fecha
            Row(
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  codigo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  fecha,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Título/descripción
            Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Fila inferior: solicitante + monto
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    solicitante,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (monto != null)
                  Text(
                    monto,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentColor.withAlpha(220),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoToButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}