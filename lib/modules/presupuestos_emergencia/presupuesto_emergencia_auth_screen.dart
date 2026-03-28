import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import 'models/presupuesto_emergencia.dart';
import 'services/presupuesto_emergencia_service.dart';
import 'widgets/presupuesto_emergencia_card.dart';
import 'widgets/presupuesto_detalle_modal.dart';

class PresupuestoEmergenciaAuthScreen extends StatefulWidget {
  const PresupuestoEmergenciaAuthScreen({super.key});

  @override
  State<PresupuestoEmergenciaAuthScreen> createState() =>
      _PresupuestoEmergenciaAuthScreenState();
}

class _PresupuestoEmergenciaAuthScreenState
    extends State<PresupuestoEmergenciaAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PresupuestoEmergenciaService _service = PresupuestoEmergenciaService();

  List<PresupuestoEmergenciaListaItem> _presupuestosPendientes = [];
  List<PresupuestoEmergenciaListaItem> _presupuestosAutorizados = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarPresupuestos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarPresupuestos() async {
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
      // CORRECCIÓN 1: Usar el método correcto obtenerListasAutorizacion
      final result = await _service.obtenerListasAutorizacion(
        usuario: usuario.webUser ?? '',
        empresaId: usuario.empresaId ?? '02',
      );

      setState(() {
        if (result.esExitoso) {
          _presupuestosPendientes = result.porAutorizar;
          _presupuestosAutorizados = result.autorizados;
        } else {
          _error = result.baseResponse.message ?? 'Error al cargar los datos';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar: $e';
      });
    }
  }

  void _showDetalleModal(PresupuestoEmergenciaListaItem presupuesto, bool esPendiente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PresupuestoDetalleModal(
        presupuesto: presupuesto,
        mostrarAcciones: esPendiente,
        onAutorizar: () => _autorizarPresupuesto(presupuesto),
        onObservar: () => _mostrarModalObservacion(presupuesto),
      ),
    );
  }

  void _autorizarPresupuesto(PresupuestoEmergenciaListaItem presupuesto) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header verde
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF2E7D32),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Autorizar Presupuesto?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${presupuesto.numero}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  Text(
                    'Esta acción enviará el presupuesto al siguiente nivel de autorización.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _ejecutarAutorizacion(presupuesto);
                          },
                          icon: const Icon(Icons.verified_rounded, size: 18),
                          label: const Text(
                            'AUTORIZAR',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
    );
  }

  Future<void> _ejecutarAutorizacion(
      PresupuestoEmergenciaListaItem presupuesto) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final authService = context.read<AuthService>();
    final usuario = authService.usuario;

    final response = await _service.autorizar(
      idPresupuestoEmergencia: presupuesto.idPresupuestoEmergencia,
      usuario: usuario?.webUser ?? '',
      empresaId: usuario?.empresaId ?? '02',
    );

    if (mounted) Navigator.pop(context); // cierra loading

    if (response.esExitoso) {
      if (mounted) Navigator.pop(context); // cierra modal de detalle
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response.mensaje ?? 'Presupuesto autorizado correctamente'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _cargarPresupuestos();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response.baseResponse.message ?? 'Error al autorizar'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _mostrarModalObservacion(PresupuestoEmergenciaListaItem presupuesto) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stfContext, setDialogState) => Dialog(
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF0F0), Color(0xFFFCE4EC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.front_hand_rounded,
                          color: Color(0xFFD32F2F),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Observar Presupuesto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD32F2F),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${presupuesto.numero}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
                            borderSide: BorderSide(color: Colors.grey[300]!),
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
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (motivoController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(stfContext).showSnackBar(
                                    const SnackBar(
                                      content: Text('La observación no puede estar vacía'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(dialogContext);
                                await _ejecutarObservacion(
                                  presupuesto,
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
      ),
    );
  }

  Future<void> _ejecutarObservacion(
    PresupuestoEmergenciaListaItem presupuesto,
    String observacion,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final authService = context.read<AuthService>();
    final usuario = authService.usuario;

    final response = await _service.observar(
      idPresupuestoEmergencia: presupuesto.idPresupuestoEmergencia,
      observacion: observacion,
      usuario: usuario?.webUser ?? '',
      empresaId: usuario?.empresaId ?? '02',
    );

    if (mounted) Navigator.pop(context);

    if (response.esExitoso) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.baseResponse.message ?? 'Presupuesto observado correctamente'),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _cargarPresupuestos();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.baseResponse.message ?? 'Error al observar'),
            backgroundColor: Colors.red[700],
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
          'Autorizar Presupuesto\nde Emergencia',
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
                  if (_presupuestosPendientes.isNotEmpty) ...[
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
                        '${_presupuestosPendientes.length}',
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
                        onPressed: _cargarPresupuestos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab: Por Autorizar
                    _buildListaPresupuestos(
                      _presupuestosPendientes,
                      esPendiente: true,
                      emptyMessage: 'No hay presupuestos por autorizar',
                    ),
                    // Tab: Autorizados
                    _buildListaPresupuestos(
                      _presupuestosAutorizados,
                      esPendiente: false,
                      emptyMessage: 'No hay presupuestos autorizados',
                    ),
                  ],
                ),
    );
  }

  Widget _buildListaPresupuestos(
    List<PresupuestoEmergenciaListaItem> presupuestos, {
    required bool esPendiente,
    required String emptyMessage,
  }) {
    if (presupuestos.isEmpty) {
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
      onRefresh: _cargarPresupuestos,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: presupuestos.length + 1, // +1 para el mensaje de refresh
        itemBuilder: (context, index) {
          // Último item: mensaje de actualización
          if (index == presupuestos.length) {
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

          final presupuesto = presupuestos[index];
          return PresupuestoEmergenciaCard(
            presupuesto: presupuesto,
            onTap: () => _showDetalleModal(presupuesto, esPendiente),
          );
        },
      ),
    );
  }
}