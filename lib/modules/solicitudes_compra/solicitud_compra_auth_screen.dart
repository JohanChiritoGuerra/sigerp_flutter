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

  List<SolicitudCompra> _solicitudesPendientes = [];
  List<SolicitudCompra> _solicitudesAutorizadas = [];
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
      // TODO: Descomentar cuando el API esté listo
      // Cargar ambas listas en paralelo
      // final results = await Future.wait([
      //   _service.obtenerSolicitudesPendientes(
      //     trabId: usuario.trabId ?? '',
      //     empresaId: usuario.empresaId ?? '02',
      //   ),
      //   _service.obtenerSolicitudesAutorizadas(
      //     trabId: usuario.trabId ?? '',
      //     empresaId: usuario.empresaId ?? '02',
      //   ),
      // ]);

      // Datos de prueba
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _solicitudesPendientes = _generarDatosPrueba();
        _solicitudesAutorizadas = _generarDatosAutorizados();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar solicitudes: $e';
      });
    }
  }

  // Datos de prueba para desarrollo
  List<SolicitudCompra> _generarDatosPrueba() {
    return [
      SolicitudCompra(
        id: '1',
        codigo: 'SC-2026-00145',
        tipo: TipoSolicitudCompra.compraMateriales,
        areaSolicitante: 'SISTEMAS',
        solicitanteNombre: 'Juan Pérez García',
        solicitanteId: '001',
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 1)),
        montoTotal: 12500.00,
        sustento: 'Requerimiento urgente para renovación de equipos del área de desarrollo. Se necesitan laptops y monitores para el nuevo personal.',
        items: [
          ItemSolicitud(id: '1', codigo: '01020304', descripcion: 'Laptop HP Core i7 16GB RAM', unidadMedida: 'UND', cantidad: 5, precioUnitario: 1800.00, subtotal: 9000.00),
          ItemSolicitud(id: '2', codigo: '01020512', descripcion: 'Monitor 27" LG UltraWide', unidadMedida: 'UND', cantidad: 5, precioUnitario: 700.00, subtotal: 3500.00),
        ],
        estado: EstadoSolicitud.pendiente,
      ),
      SolicitudCompra(
        id: '2',
        codigo: 'SC-2026-00142',
        tipo: TipoSolicitudCompra.compraActivoFijo,
        areaSolicitante: 'ENERGÍA',
        solicitanteNombre: 'Carlos López Mendoza',
        solicitanteId: '002',
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 2)),
        montoTotal: 45800.00,
        sustento: 'Adquisición de generador eléctrico de respaldo para planta principal.',
        items: [
          ItemSolicitud(id: '1', codigo: '05010001', descripcion: 'Generador Eléctrico 50KW Caterpillar', unidadMedida: 'UND', cantidad: 1, precioUnitario: 45800.00, subtotal: 45800.00),
        ],
        estado: EstadoSolicitud.pendiente,
      ),
      SolicitudCompra(
        id: '3',
        codigo: 'SC-2026-00140',
        tipo: TipoSolicitudCompra.servicioTercero,
        areaSolicitante: 'RECURSOS HUMANOS',
        solicitanteNombre: 'María Torres Vega',
        solicitanteId: '003',
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 3)),
        montoTotal: 8200.00,
        sustento: 'Contratación de servicio de capacitación en seguridad ocupacional para todo el personal.',
        items: [
          ItemSolicitud(id: '1', codigo: '09010101', descripcion: 'Capacitación SST - 40 horas', unidadMedida: 'SRV', cantidad: 1, precioUnitario: 8200.00, subtotal: 8200.00),
        ],
        estado: EstadoSolicitud.pendiente,
      ),
      SolicitudCompra(
        id: '4',
        codigo: 'SC-2026-00138',
        tipo: TipoSolicitudCompra.cargaDiversaGestion,
        areaSolicitante: 'ADMINISTRACIÓN',
        solicitanteNombre: 'Ana María Sánchez',
        solicitanteId: '004',
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 4)),
        montoTotal: 3500.00,
        sustento: 'Gastos de representación para evento corporativo con proveedores.',
        items: [
          ItemSolicitud(id: '1', codigo: '08050201', descripcion: 'Catering evento corporativo', unidadMedida: 'SRV', cantidad: 1, precioUnitario: 2500.00, subtotal: 2500.00),
          ItemSolicitud(id: '2', codigo: '08050305', descripcion: 'Material promocional impreso', unidadMedida: 'KIT', cantidad: 1, precioUnitario: 1000.00, subtotal: 1000.00),
        ],
        estado: EstadoSolicitud.pendiente,
      ),
      SolicitudCompra(
        id: '5',
        codigo: 'SC-2026-00135',
        tipo: TipoSolicitudCompra.compraMateriales,
        areaSolicitante: 'LOGÍSTICA',
        solicitanteNombre: 'Pedro Ramírez Luna',
        solicitanteId: '005',
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 5)),
        montoTotal: 15300.00,
        sustento: 'Compra de repuestos para mantenimiento preventivo de flota vehicular.',
        items: [
          ItemSolicitud(id: '1', codigo: '03020101', descripcion: 'Kit de frenos delanteros', unidadMedida: 'JGO', cantidad: 10, precioUnitario: 850.00, subtotal: 8500.00),
          ItemSolicitud(id: '2', codigo: '03020205', descripcion: 'Filtros de aceite motor', unidadMedida: 'UND', cantidad: 20, precioUnitario: 120.00, subtotal: 2400.00),
          ItemSolicitud(id: '3', codigo: '03020301', descripcion: 'Aceite motor sintético 5W30', unidadMedida: 'GLN', cantidad: 40, precioUnitario: 110.00, subtotal: 4400.00),
        ],
        estado: EstadoSolicitud.pendiente,
      ),
    ];
  }

  List<SolicitudCompra> _generarDatosAutorizados() {
    return [
      SolicitudCompra(
        id: '10',
        codigo: 'SC-2026-00120',
        tipo: TipoSolicitudCompra.compraMateriales,
        areaSolicitante: 'COSECHA',
        solicitanteNombre: 'Roberto Díaz Paredes',
        solicitanteId: '010',
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 10)),
        montoTotal: 22000.00,
        sustento: 'Compra de herramientas para temporada de cosecha.',
        items: [
          ItemSolicitud(id: '1', codigo: '02010101', descripcion: 'Machetes de acero templado', unidadMedida: 'UND', cantidad: 50, precioUnitario: 120.00, subtotal: 6000.00),
          ItemSolicitud(id: '2', codigo: '02010205', descripcion: 'Guantes de cuero reforzado', unidadMedida: 'PAR', cantidad: 100, precioUnitario: 45.00, subtotal: 4500.00),
          ItemSolicitud(id: '3', codigo: '02010310', descripcion: 'Botas de jebe caña alta', unidadMedida: 'PAR', cantidad: 50, precioUnitario: 85.00, subtotal: 4250.00),
          ItemSolicitud(id: '4', codigo: '02010415', descripcion: 'Cascos de seguridad', unidadMedida: 'UND', cantidad: 50, precioUnitario: 65.00, subtotal: 3250.00),
          ItemSolicitud(id: '5', codigo: '02010520', descripcion: 'Lentes de protección', unidadMedida: 'UND', cantidad: 100, precioUnitario: 40.00, subtotal: 4000.00),
        ],
        estado: EstadoSolicitud.autorizado,
      ),
      SolicitudCompra(
        id: '11',
        codigo: 'SC-2026-00115',
        tipo: TipoSolicitudCompra.servicioTercero,
        areaSolicitante: 'MANTENIMIENTO',
        solicitanteNombre: 'Luis Fernández Castro',
        solicitanteId: '011',
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 12)),
        montoTotal: 18500.00,
        sustento: 'Servicio de mantenimiento correctivo de maquinaria.',
        items: [
          ItemSolicitud(id: '1', codigo: '09020101', descripcion: 'Mant. correctivo tractor John Deere', unidadMedida: 'SRV', cantidad: 1, precioUnitario: 8500.00, subtotal: 8500.00),
          ItemSolicitud(id: '2', codigo: '09020102', descripcion: 'Mant. correctivo cosechadora', unidadMedida: 'SRV', cantidad: 1, precioUnitario: 10000.00, subtotal: 10000.00),
        ],
        estado: EstadoSolicitud.autorizado,
      ),
    ];
  }

  void _showDetalleModal(SolicitudCompra solicitud, bool esPendiente) {
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

  Future<void> _autorizarSolicitud(SolicitudCompra solicitud) async {
    // Mostrar loading
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
      solicitudId: solicitud.id,
      trabId: usuario?.trabId ?? '',
      empresaId: usuario?.empresaId ?? '02',
    );

    // Cerrar loading
    if (mounted) Navigator.pop(context);

    if (response.esExitoso) {
      // Cerrar modal de detalle
      if (mounted) Navigator.pop(context);

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Solicitud autorizada correctamente'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refrescar lista
      _cargarSolicitudes();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Error al autorizar'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _mostrarModalObservacion(SolicitudCompra solicitud) {
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
              // Header con barra lateral roja
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
                            '#${solicitud.codigo}',
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

              // Body
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

                    // Campo de texto
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

                    // Botones en fila (diferente al PE que los tiene apilados)
                    Row(
                      children: [
                        // Cancelar
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
                        // Observar
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

  Future<void> _observarSolicitud(SolicitudCompra solicitud, String motivo) async {
    // Mostrar loading
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
      solicitudId: solicitud.id,
      trabId: usuario?.trabId ?? '',
      empresaId: usuario?.empresaId ?? '02',
      motivo: motivo,
    );

    // Cerrar loading
    if (mounted) Navigator.pop(context);

    if (response.esExitoso) {
      // Cerrar modal de detalle (el dialog de observación ya se cerró antes de llamar esta función)
      if (mounted) Navigator.pop(context);

      // Mostrar mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Solicitud observada correctamente'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refrescar lista
      _cargarSolicitudes();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Error al observar'),
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
            const Tab(text: 'AUTORIZADO'),
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
                    // Tab: Por Autorizar
                    _buildListaSolicitudes(
                      _solicitudesPendientes,
                      esPendiente: true,
                      emptyMessage: 'No tienes solicitudes pendientes',
                    ),
                    // Tab: Autorizados
                    _buildListaSolicitudes(
                      _solicitudesAutorizadas,
                      esPendiente: false,
                      emptyMessage: 'No has autorizado solicitudes',
                    ),
                  ],
                ),
    );
  }

  Widget _buildListaSolicitudes(
    List<SolicitudCompra> solicitudes, {
    required bool esPendiente,
    required String emptyMessage,
  }) {
    if (solicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              esPendiente ? Icons.check_circle_outline : Icons.history,
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
        itemCount: solicitudes.length + 1, // +1 para el mensaje de refresh
        itemBuilder: (context, index) {
          // Último item: mensaje de actualización
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
