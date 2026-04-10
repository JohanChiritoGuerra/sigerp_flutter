import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/notificacion_push.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notificaciones_push_service.dart';
import '../../../core/utils/constants.dart';
import '../../presupuestos_emergencia/presupuesto_emergencia_auth_screen.dart';
import '../../presupuestos_emergencia/presupuesto_emergencia_consulta_screen.dart';
import '../../solicitudes_compra/solicitud_compra_auth_screen.dart';
import '../../solicitudes_compra/solicitud_compra_consulta_screen.dart';

class NotificationsPanel extends StatefulWidget {
  final VoidCallback? onRefreshNeeded;
  const NotificationsPanel({super.key, this.onRefreshNeeded});

  static Future<void> show(BuildContext context, {VoidCallback? onRefreshNeeded}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsPanel(onRefreshNeeded: onRefreshNeeded),
    );
  }

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  final NotificacionesPushService _service = NotificacionesPushService();

  List<NotificacionPush> _notificaciones = [];
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
      final res = await _service.consultarNoLeidas(
        usuaId: webUser,
        empresaId: empresaId,
      );
      if (mounted) {
        setState(() {
          _notificaciones = res.esExitoso ? res.notificaciones : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onTapNotificacion(NotificacionPush notif) async {
    final authService = context.read<AuthService>();
    final usuario = authService.usuario;
    final webUser = usuario?.webUser ?? '';
    final empresaId = usuario?.empresaId ?? '02';

    // Capturar nav ANTES del pop (contexto sigue válido)
    final tipo = notif.tipo.toUpperCase();
    final nav = Navigator.of(context);

    // Quitar del listado inmediatamente
    setState(() => _notificaciones.removeWhere((n) => n.id == notif.id));

    // Marcar como leída en BD y esperar para evitar race condition con el badge
    await _service.marcarLeida(
      idNotificacion: notif.id,
      usuaId: webUser,
      empresaId: empresaId,
    );

    if (!mounted) return;
    Navigator.pop(context);

    final idRef = notif.idReferencia;
    final onRefresh = widget.onRefreshNeeded;

    switch (tipo) {
      case 'AUTORIZACION':
      case 'ATENCION':
        nav.push(MaterialPageRoute(
          builder: (_) => PresupuestoEmergenciaAuthScreen(
            autoOpenId: idRef != null ? int.tryParse(idRef) : null,
          ),
        )).then((_) => onRefresh?.call());
        break;
      case 'OBSERVACION':
      case 'ATENCION_USUARIO':
        nav.push(MaterialPageRoute(
          builder: (_) => PresupuestoEmergenciaConsultaScreen(
            autoOpenId: idRef != null ? int.tryParse(idRef) : null,
          ),
        )).then((_) => onRefresh?.call());
        break;
      case 'SOLICITUD_PENDIENTE':
      case 'AUTORIZACION_SC':
        nav.push(MaterialPageRoute(
          builder: (_) => SolicitudCompraAuthScreen(autoOpenId: idRef),
        )).then((_) => onRefresh?.call());
        break;
      case 'SOLICITUD_AUTORIZADA':
      case 'SOLICITUD_OBSERVADA':
      case 'SOLICITUD_ERROR':
      case 'OBSERVACION_SC':
      case 'ATENCION_USUARIO_SC':
        nav.push(MaterialPageRoute(
          builder: (_) => SolicitudCompraConsultaScreen(autoOpenId: idRef),
        )).then((_) => onRefresh?.call());
        break;
    }
  }

  int get _totalNoLeidas => _notificaciones.length;

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
                              _totalNoLeidas > 0
                                  ? '$_totalNoLeidas sin leer'
                                  : 'Todo al día',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Badge con total
                    if (!_isLoading && _totalNoLeidas > 0)
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
                          '$_totalNoLeidas',
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
                    : _notificaciones.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _notificaciones.length,
                            itemBuilder: (_, i) =>
                                _buildNotificacionItem(_notificaciones[i]),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificacionItem(NotificacionPush notif) {
    final config = _configForTipo(notif.tipo);
    return GestureDetector(
      onTap: () => _onTapNotificacion(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: config.color, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(config.icon, size: 18, color: config.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.titulo,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(notif.fechaRegistro),
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.mensaje,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: config.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      config.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: config.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            'No tienes notificaciones pendientes',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  _TipoConfig _configForTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'AUTORIZACION':
      case 'ATENCION':
        return _TipoConfig(
          color: Color(AppColors.warningColor),
          icon: Icons.emergency,
          label: 'PRESUPUESTO',
        );
      case 'OBSERVACION':
      case 'ATENCION_USUARIO':
        return _TipoConfig(
          color: Color(AppColors.infoColor),
          icon: Icons.info_outline,
          label: 'PRESUPUESTO',
        );
      case 'SOLICITUD_PENDIENTE':
      case 'AUTORIZACION_SC':
        return _TipoConfig(
          color: Color(AppColors.warningColor),
          icon: Icons.shopping_cart,
          label: 'SOLICITUD',
        );
      case 'SOLICITUD_AUTORIZADA':
        return _TipoConfig(
          color: Color(AppColors.successColor),
          icon: Icons.check_circle_outline,
          label: 'SOLICITUD',
        );
      case 'SOLICITUD_OBSERVADA':
      case 'OBSERVACION_SC':
        return _TipoConfig(
          color: Color(AppColors.errorColor),
          icon: Icons.warning_amber_rounded,
          label: 'SOLICITUD',
        );
      case 'SOLICITUD_ERROR':
        return _TipoConfig(
          color: Color(AppColors.errorColor),
          icon: Icons.error_outline,
          label: 'ERROR',
        );
      default:
        return _TipoConfig(
          color: Color(AppColors.primaryColor),
          icon: Icons.notifications_outlined,
          label: tipo,
        );
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TipoConfig {
  final Color color;
  final IconData icon;
  final String label;
  const _TipoConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}