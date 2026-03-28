import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import 'models/solicitud_compra.dart';
import 'services/solicitud_compra_service.dart';
import 'widgets/solicitud_compra_card.dart';
import 'widgets/solicitud_detalle_modal.dart';

class SolicitudCompraAuthScreen extends StatefulWidget {
  const SolicitudCompraAuthScreen({super.key});

  @override
  State<SolicitudCompraAuthScreen> createState() => _SolicitudCompraAuthScreenState();
}

class _SolicitudCompraAuthScreenState extends State<SolicitudCompraAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SolicitudCompraService _service = SolicitudCompraService();

  List<SolicitudCompraListaItem> _solicitudesPendientes = [];
  List<SolicitudCompraListaItem> _solicitudesAutorizadas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarSolicitudes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = context.read<AuthService>();
    final usuario = authService.usuario;

    if (usuario == null) {
      setState(() {
        _isLoading = false;
        _error = 'Usuario no autenticado';
      });
      return;
    }

    try {
      final result = await _service.obtenerListasAutorizacion(
        usuario: usuario.webUser ?? '',
        empresaId: usuario.empresaId ?? '02',
      );

      if (mounted) {
        setState(() {
          if (result.esExitoso) {
            _solicitudesPendientes = result.porAutorizar;
            _solicitudesAutorizadas = result.autorizados;
          } else {
            _error = result.baseResponse.message ?? 'Error al cargar los datos';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error al cargar: $e';
        });
      }
    }
  }

  void _showDetalleModal(SolicitudCompraListaItem solicitud, bool esPendiente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SolicitudDetalleModal(
        solicitud: solicitud,
        mostrarAcciones: esPendiente,
        onAutorizar: () => _autorizarSolicitud(solicitud),
        onObservar: () => _mostrarModalObservacion(solicitud),
      ),
    );
  }

  Future<void> _autorizarSolicitud(SolicitudCompraListaItem solicitud) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final authService = context.read<AuthService>();
    final usuario = authService.usuario;

    final response = await _service.autorizarSolicitud(
      solComCabId: solicitud.solComCabId,
      tipOpeCompId: solicitud.tipOpeCompId,
      usuario: usuario?.webUser ?? '',
      empresaId: usuario?.empresaId ?? '02',
    );

    if (mounted) Navigator.pop(context);

    if (response.esExitoso) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.mensajeOut ?? 'Solicitud autorizada correctamente'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _cargarSolicitudes();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.baseResponse.message ?? 'Error al autorizar'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _mostrarModalObservacion(SolicitudCompraListaItem solicitud) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF5350).withOpacity(0.12),
                blurRadius: 32,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFEF5350), width: 5),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  color: Color(0xFFFFF0F0),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.front_hand_rounded,
                        color: Color(0xFFD32F2F),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Observar Solicitud',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD32F2F),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${solicitud.numero}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Motivo de la observación',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: motivoController,
                      maxLines: 4,
                      maxLength: 500,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Describa el motivo de la observación...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13.5,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.red.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF5350),
                              side: const BorderSide(color: Color(0xFFEF5350), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (motivoController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Debe ingresar un motivo')),
                                );
                                return;
                              }
                              Navigator.pop(dialogContext);
                              await _observarSolicitud(
                                solicitud,
                                motivoController.text.trim(),
                              );
                            },
                            icon: const Icon(Icons.front_hand_rounded, size: 18),
                            label: const Text(
                              'OBSERVAR',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF5350),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _observarSolicitud(SolicitudCompraListaItem solicitud, String motivo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final authService = context.read<AuthService>();
    final usuario = authService.usuario;

    final response = await _service.observarSolicitud(
      solComCabId: solicitud.solComCabId,
      tipOpeCompId: solicitud.tipOpeCompId,
      observacion: motivo,
      usuario: usuario?.webUser ?? '',
      empresaId: usuario?.empresaId ?? '02',
    );

    if (mounted) Navigator.pop(context);

    if (response.esExitoso) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.baseResponse.message ?? 'Solicitud observada correctamente'),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _cargarSolicitudes();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.baseResponse.message ?? 'Error al observar'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Autorización de Solicitudes\nde Compra',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('POR AUTORIZAR'),
                  if (_solicitudesPendientes.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_solicitudesPendientes.length}',
                        style: TextStyle(
                          color: Color(AppColors.primaryColor),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'AUTORIZADOS'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarSolicitudes,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListaSolicitudes(
                      _solicitudesPendientes,
                      esPendiente: true,
                      emptyMessage: 'No hay solicitudes por autorizar',
                    ),
                    _buildListaSolicitudes(
                      _solicitudesAutorizadas,
                      esPendiente: false,
                      emptyMessage: 'No hay solicitudes autorizadas',
                    ),
                  ],
                ),
    );
  }

  Widget _buildListaSolicitudes(
    List<SolicitudCompraListaItem> solicitudes, {
    required bool esPendiente,
    required String emptyMessage,
  }) {
    if (solicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              esPendiente ? Icons.pending_actions : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarSolicitudes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: solicitudes.length + 1,
        itemBuilder: (context, index) {
          if (index == solicitudes.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Desliza hacia abajo para actualizar',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }

          final solicitud = solicitudes[index];
          return SolicitudCompraCard(
            solicitud: solicitud,
            onTap: () => _showDetalleModal(solicitud, esPendiente),
          );
        },
      ),
    );
  }
}