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

  List<PresupuestoEmergencia> _presupuestosPendientes = [];
  List<PresupuestoEmergencia> _presupuestosAutorizados = [];
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
      // TODO: Descomentar cuando el API esté listo
      // Cargar ambas listas en paralelo
      // final results = await Future.wait([
      //   _service.obtenerPresupuestosPendientes(
      //     trabId: usuario.trabId ?? '',
      //     empresaId: usuario.empresaId ?? '02',
      //   ),
      //   _service.obtenerPresupuestosAutorizados(
      //     trabId: usuario.trabId ?? '',
      //     empresaId: usuario.empresaId ?? '02',
      //   ),
      // ]);

      // Datos de prueba
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _presupuestosPendientes = _generarDatosPrueba();
        _presupuestosAutorizados = _generarDatosAutorizados();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar presupuestos: $e';
      });
    }
  }

  // Datos de prueba para desarrollo
  List<PresupuestoEmergencia> _generarDatosPrueba() {
    return [
      PresupuestoEmergencia(
        presupId: '1',
        codigo: '2024-0156',
        prioridad: PrioridadPresupuesto.emergencia,
        tipoPresupuesto: TipoPresupuestoEmergencia.consumo,
        solicitante: Solicitante(
          trabId: '001',
          nombreCompleto: 'Juan Pérez García',
          seccion: 'Mantenimiento',
          cargo: 'Técnico',
        ),
        montoTotal: 5250.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(minutes: 15)),
        descripcion:
            'Reparación urgente de equipo compresor principal que se encuentra fuera de servicio. Se requiere atención inmediata para evitar pérdidas en la producción.',
        estadoActual: EstadoPresupuesto.pendiente,
        nivelAutorizacionActual: 2,
        esmiTurno: true,
        items: [
          ItemPresupuesto(
            itemId: '1',
            descripcion: 'Válvula hidráulica',
            monto: 2500.00,
          ),
          ItemPresupuesto(
            itemId: '2',
            descripcion: 'Mano de obra',
            monto: 1800.00,
          ),
          ItemPresupuesto(
            itemId: '3',
            descripcion: 'Repuestos varios',
            monto: 950.00,
          ),
        ],
        historialAutorizaciones: [
          AutorizacionHistorial(
            nivel: 1,
            nombreNivel: 'Jefe Sección',
            autorizador: Solicitante(
              trabId: '010',
              nombreCompleto: 'José Martínez Luna',
              seccion: 'Mantenimiento',
              cargo: 'Jefe de Sección',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(minutes: 10)),
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            autorizador: Solicitante(
              trabId: '020',
              nombreCompleto: 'Carlos Ramírez Soto',
              seccion: 'Operaciones',
              cargo: 'Jefe de Departamento',
            ),
            estado: EstadoPresupuesto.pendiente,
            fechaAccion: null,
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 3,
            nombreNivel: 'Gerencia',
            autorizador: null,
            estado: EstadoPresupuesto.enCola,
            fechaAccion: null,
            observacion: null,
          ),
        ],
      ),
      PresupuestoEmergencia(
        presupId: '2',
        codigo: '2024-0155',
        prioridad: PrioridadPresupuesto.urgente,
        tipoPresupuesto: TipoPresupuestoEmergencia.inversiones,
        solicitante: Solicitante(
          trabId: '002',
          nombreCompleto: 'María López Mendoza',
          seccion: 'Logística',
          cargo: 'Coordinadora',
        ),
        montoTotal: 1800.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(hours: 2)),
        descripcion:
            'Adquisición urgente de repuestos para camión de distribución que presenta fallas en el sistema de frenos.',
        estadoActual: EstadoPresupuesto.pendiente,
        nivelAutorizacionActual: 2,
        esmiTurno: true,
        items: [
          ItemPresupuesto(
            itemId: '1',
            descripcion: 'Kit de frenos delanteros',
            monto: 850.00,
          ),
          ItemPresupuesto(
            itemId: '2',
            descripcion: 'Pastillas de freno',
            monto: 450.00,
          ),
          ItemPresupuesto(
            itemId: '3',
            descripcion: 'Mano de obra',
            monto: 500.00,
          ),
        ],
        historialAutorizaciones: [
          AutorizacionHistorial(
            nivel: 1,
            nombreNivel: 'Jefe Sección',
            autorizador: Solicitante(
              trabId: '011',
              nombreCompleto: 'Roberto Díaz Paredes',
              seccion: 'Logística',
              cargo: 'Jefe de Sección',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(hours: 1)),
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            autorizador: null,
            estado: EstadoPresupuesto.pendiente,
            fechaAccion: null,
            observacion: null,
          ),
        ],
      ),
      PresupuestoEmergencia(
        presupId: '3',
        codigo: '2024-0154',
        prioridad: PrioridadPresupuesto.normal,
        tipoPresupuesto: TipoPresupuestoEmergencia.servicioTercero,
        solicitante: Solicitante(
          trabId: '003',
          nombreCompleto: 'Carlos Torres Vega',
          seccion: 'Administración',
          cargo: 'Asistente',
        ),
        montoTotal: 3200.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(hours: 5)),
        descripcion:
            'Compra de equipos de cómputo para nuevos colaboradores del área administrativa.',
        estadoActual: EstadoPresupuesto.pendiente,
        nivelAutorizacionActual: 2,
        esmiTurno: true,
        items: [
          ItemPresupuesto(
            itemId: '1',
            descripcion: 'Laptop HP Core i5',
            monto: 2500.00,
          ),
          ItemPresupuesto(
            itemId: '2',
            descripcion: 'Mouse y teclado inalámbrico',
            monto: 200.00,
          ),
          ItemPresupuesto(
            itemId: '3',
            descripcion: 'Auriculares con micrófono',
            monto: 500.00,
          ),
        ],
        historialAutorizaciones: [
          AutorizacionHistorial(
            nivel: 1,
            nombreNivel: 'Jefe Sección',
            autorizador: Solicitante(
              trabId: '012',
              nombreCompleto: 'Ana García Sánchez',
              seccion: 'Administración',
              cargo: 'Jefe de Sección',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(hours: 4)),
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            autorizador: null,
            estado: EstadoPresupuesto.pendiente,
            fechaAccion: null,
            observacion: null,
          ),
        ],
      ),
      PresupuestoEmergencia(
        presupId: '4',
        codigo: '2024-0153',
        prioridad: PrioridadPresupuesto.emergencia,
        tipoPresupuesto: TipoPresupuestoEmergencia.consumo,
        solicitante: Solicitante(
          trabId: '004',
          nombreCompleto: 'Pedro Ramírez Luna',
          seccion: 'Producción',
          cargo: 'Supervisor',
        ),
        montoTotal: 8500.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(hours: 1)),
        descripcion:
            'Reparación urgente de motor eléctrico de la línea de producción principal. Parada de línea en curso.',
        estadoActual: EstadoPresupuesto.pendiente,
        nivelAutorizacionActual: 2,
        esmiTurno: true,
        items: [
          ItemPresupuesto(
            itemId: '1',
            descripcion: 'Motor eléctrico 50HP',
            monto: 6500.00,
          ),
          ItemPresupuesto(
            itemId: '2',
            descripcion: 'Instalación y cableado',
            monto: 1500.00,
          ),
          ItemPresupuesto(
            itemId: '3',
            descripcion: 'Materiales varios',
            monto: 500.00,
          ),
        ],
        historialAutorizaciones: [
          AutorizacionHistorial(
            nivel: 1,
            nombreNivel: 'Jefe Sección',
            autorizador: Solicitante(
              trabId: '013',
              nombreCompleto: 'Luis Fernández Castro',
              seccion: 'Producción',
              cargo: 'Jefe de Sección',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(minutes: 45)),
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            autorizador: null,
            estado: EstadoPresupuesto.pendiente,
            fechaAccion: null,
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 3,
            nombreNivel: 'Gerencia',
            autorizador: null,
            estado: EstadoPresupuesto.enCola,
            fechaAccion: null,
            observacion: null,
          ),
        ],
      ),
    ];
  }

  List<PresupuestoEmergencia> _generarDatosAutorizados() {
    return [
      PresupuestoEmergencia(
        presupId: '10',
        codigo: '2024-0140',
        prioridad: PrioridadPresupuesto.emergencia,
        tipoPresupuesto: TipoPresupuestoEmergencia.inversiones,
        solicitante: Solicitante(
          trabId: '010',
          nombreCompleto: 'Roberto Díaz Paredes',
          seccion: 'Energía',
          cargo: 'Técnico',
        ),
        montoTotal: 12500.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 2)),
        descripcion:
            'Reparación de generador eléctrico de respaldo. Autorizado previamente.',
        estadoActual: EstadoPresupuesto.autorizado,
        nivelAutorizacionActual: 3,
        esmiTurno: false,
        items: [
          ItemPresupuesto(
            itemId: '1',
            descripcion: 'Bobinado de generador',
            monto: 8500.00,
          ),
          ItemPresupuesto(
            itemId: '2',
            descripcion: 'Regulador de voltaje',
            monto: 2500.00,
          ),
          ItemPresupuesto(
            itemId: '3',
            descripcion: 'Mano de obra',
            monto: 1500.00,
          ),
        ],
        historialAutorizaciones: [
          AutorizacionHistorial(
            nivel: 1,
            nombreNivel: 'Jefe Sección',
            autorizador: Solicitante(
              trabId: '014',
              nombreCompleto: 'Miguel Ángel Soto',
              seccion: 'Energía',
              cargo: 'Jefe de Sección',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(days: 2)),
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            autorizador: Solicitante(
              trabId: '020',
              nombreCompleto: 'Carlos Ramírez Soto',
              seccion: 'Operaciones',
              cargo: 'Jefe de Departamento',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(days: 2)),
            observacion: 'Autorizado por urgencia operativa',
          ),
          AutorizacionHistorial(
            nivel: 3,
            nombreNivel: 'Gerencia',
            autorizador: Solicitante(
              trabId: '030',
              nombreCompleto: 'Fernando García Mendez',
              seccion: 'Gerencia General',
              cargo: 'Gerente General',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(days: 1)),
            observacion: null,
          ),
        ],
      ),
      PresupuestoEmergencia(
        presupId: '11',
        codigo: '2024-0138',
        prioridad: PrioridadPresupuesto.urgente,
        tipoPresupuesto: TipoPresupuestoEmergencia.servicioTercero,
        solicitante: Solicitante(
          trabId: '011',
          nombreCompleto: 'Luis Fernández Castro',
          seccion: 'Mantenimiento',
          cargo: 'Supervisor',
        ),
        montoTotal: 4800.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 5)),
        descripcion: 'Compra de herramientas especializadas para mantenimiento preventivo.',
        estadoActual: EstadoPresupuesto.autorizado,
        nivelAutorizacionActual: 2,
        esmiTurno: false,
        items: [
          ItemPresupuesto(
            itemId: '1',
            descripcion: 'Kit de herramientas hidráulicas',
            monto: 3500.00,
          ),
          ItemPresupuesto(
            itemId: '2',
            descripcion: 'Multímetro digital',
            monto: 800.00,
          ),
          ItemPresupuesto(
            itemId: '3',
            descripcion: 'Llaves dinamométricas',
            monto: 500.00,
          ),
        ],
        historialAutorizaciones: [
          AutorizacionHistorial(
            nivel: 1,
            nombreNivel: 'Jefe Sección',
            autorizador: Solicitante(
              trabId: '010',
              nombreCompleto: 'José Martínez Luna',
              seccion: 'Mantenimiento',
              cargo: 'Jefe de Sección',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(days: 5)),
            observacion: null,
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            autorizador: Solicitante(
              trabId: '020',
              nombreCompleto: 'Carlos Ramírez Soto',
              seccion: 'Operaciones',
              cargo: 'Jefe de Departamento',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(days: 4)),
            observacion: null,
          ),
        ],
      ),
    ];
  }

  void _showDetalleModal(PresupuestoEmergencia presupuesto, bool esPendiente) {
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

  Future<void> _autorizarPresupuesto(PresupuestoEmergencia presupuesto) async {
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

    final response = await _service.autorizarPresupuesto(
      presupId: presupuesto.presupId,
      trabId: usuario?.trabId ?? '',
      empresaId: usuario?.empresaId ?? '02',
      nivelAutorizacion: presupuesto.nivelAutorizacionActual,
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
            content: const Text('Presupuesto autorizado correctamente'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refrescar lista
      _cargarPresupuestos();
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

  void _mostrarModalObservacion(PresupuestoEmergencia presupuesto) {
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
              // Header con fondo rojo pastel
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
                      '#${presupuesto.codigo}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Label
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
                        hintText: 'Describa el motivo (mínimo 10 caracteres)...',
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
                          borderSide: BorderSide(color: Colors.grey[250] ?? Colors.grey[300]!),
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

                    // Botones en fila horizontal
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
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Observar
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (motivoController.text.trim().length < 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('El motivo debe tener al menos 10 caracteres'),
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(dialogContext);
                              await _observarPresupuesto(
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
    );
  }

  Future<void> _observarPresupuesto(
    PresupuestoEmergencia presupuesto,
    String motivo,
  ) async {
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

    final response = await _service.observarPresupuesto(
      presupId: presupuesto.presupId,
      trabId: usuario?.trabId ?? '',
      empresaId: usuario?.empresaId ?? '02',
      nivelAutorizacion: presupuesto.nivelAutorizacionActual,
      motivo: motivo,
    );

    // Cerrar loading
    if (mounted) Navigator.pop(context);

    if (response.esExitoso) {
      // Cerrar modal de detalle
      if (mounted) Navigator.pop(context);

      // Mostrar mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Presupuesto observado correctamente'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refrescar lista
      _cargarPresupuestos();
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
                  const Text('PENDIENTES'),
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
                    // Tab: Pendientes
                    _buildListaPresupuestos(
                      _presupuestosPendientes,
                      esPendiente: true,
                      emptyMessage: 'No tienes presupuestos pendientes',
                    ),
                    // Tab: Autorizados
                    _buildListaPresupuestos(
                      _presupuestosAutorizados,
                      esPendiente: false,
                      emptyMessage: 'No has autorizado presupuestos',
                    ),
                  ],
                ),
    );
  }

  Widget _buildListaPresupuestos(
    List<PresupuestoEmergencia> presupuestos, {
    required bool esPendiente,
    required String emptyMessage,
  }) {
    if (presupuestos.isEmpty) {
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
