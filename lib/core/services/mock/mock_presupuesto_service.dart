import '../../../modules/presupuestos_emergencia/models/presupuesto_emergencia.dart';
import '../../../modules/presupuestos_emergencia/services/presupuesto_emergencia_service.dart';

/// Servicio mock para presupuestos de emergencia.
/// Devuelve datos de prueba sin hacer llamadas a la API.
class MockPresupuestoEmergenciaService extends PresupuestoEmergenciaService {
  @override
  Future<PresupuestoListResponse> obtenerPresupuestosPendientes({
    required String trabId,
    required String empresaId,
    String? prioridad,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    List<PresupuestoEmergencia> datos = _generarPendientes();

    // Filtrar por prioridad si se especifica
    if (prioridad != null && prioridad != 'TODOS') {
      datos = datos
          .where((p) => p.prioridad.label == prioridad)
          .toList();
    }

    return PresupuestoListResponse(
      success: true,
      message: 'Datos mock cargados correctamente',
      presupuestos: datos,
      totalRegistros: datos.length,
    );
  }

  @override
  Future<PresupuestoListResponse> obtenerPresupuestosAutorizados({
    required String trabId,
    required String empresaId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final datos = _generarAutorizados();

    return PresupuestoListResponse(
      success: true,
      message: 'Datos mock cargados correctamente',
      presupuestos: datos,
      totalRegistros: datos.length,
    );
  }

  @override
  Future<PresupuestoDetalleResponse> obtenerDetalle({
    required String presupId,
    required String trabId,
    required String empresaId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final todos = [..._generarPendientes(), ..._generarAutorizados()];
    final presupuesto = todos.firstWhere(
      (p) => p.presupId == presupId,
      orElse: () => todos.first,
    );

    return PresupuestoDetalleResponse(
      success: true,
      message: 'Detalle mock cargado',
      presupuesto: presupuesto,
    );
  }

  @override
  Future<PresupuestoActionResponse> autorizarPresupuesto({
    required String presupId,
    required String trabId,
    required String empresaId,
    required int nivelAutorizacion,
    String? observacion,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return PresupuestoActionResponse(
      success: true,
      message: 'Presupuesto autorizado correctamente (mock)',
      presupId: presupId,
      estado: 'AUTORIZADO',
      siguienteNivel: nivelAutorizacion + 1,
      requiereMasAutorizaciones: nivelAutorizacion < 3,
      fechaAccion: DateTime.now(),
    );
  }

  @override
  Future<PresupuestoActionResponse> observarPresupuesto({
    required String presupId,
    required String trabId,
    required String empresaId,
    required int nivelAutorizacion,
    required String motivo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return PresupuestoActionResponse(
      success: true,
      message: 'Presupuesto observado correctamente (mock)',
      presupId: presupId,
      estado: 'OBSERVADO',
      fechaAccion: DateTime.now(),
    );
  }

  // =================== DATOS DE PRUEBA ===================

  List<PresupuestoEmergencia> _generarPendientes() {
    return [
      PresupuestoEmergencia(
        presupId: '1',
        codigo: '2026-0156',
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
          ItemPresupuesto(itemId: '1', descripcion: 'Válvula hidráulica', monto: 2500.00),
          ItemPresupuesto(itemId: '2', descripcion: 'Mano de obra', monto: 1800.00),
          ItemPresupuesto(itemId: '3', descripcion: 'Repuestos varios', monto: 950.00),
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
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            estado: EstadoPresupuesto.pendiente,
          ),
          AutorizacionHistorial(
            nivel: 3,
            nombreNivel: 'Gerencia',
            estado: EstadoPresupuesto.enCola,
          ),
        ],
      ),
      PresupuestoEmergencia(
        presupId: '2',
        codigo: '2026-0155',
        prioridad: PrioridadPresupuesto.urgente,
        solicitante: Solicitante(
          trabId: '002',
          nombreCompleto: 'María López Mendoza',
          seccion: 'Logística',
          cargo: 'Coordinadora',
        ),
        montoTotal: 1800.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(hours: 2)),
        descripcion:
            'Adquisición urgente de repuestos para camión de distribución con fallas en el sistema de frenos.',
        estadoActual: EstadoPresupuesto.pendiente,
        nivelAutorizacionActual: 2,
        esmiTurno: true,
        items: [
          ItemPresupuesto(itemId: '1', descripcion: 'Kit de frenos delanteros', monto: 850.00),
          ItemPresupuesto(itemId: '2', descripcion: 'Pastillas de freno', monto: 450.00),
          ItemPresupuesto(itemId: '3', descripcion: 'Mano de obra', monto: 500.00),
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
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            estado: EstadoPresupuesto.pendiente,
          ),
        ],
      ),
      PresupuestoEmergencia(
        presupId: '3',
        codigo: '2026-0154',
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
          ItemPresupuesto(itemId: '1', descripcion: 'Laptop HP Core i5', monto: 2500.00),
          ItemPresupuesto(itemId: '2', descripcion: 'Mouse y teclado inalámbrico', monto: 200.00),
          ItemPresupuesto(itemId: '3', descripcion: 'Monitor LED 24"', monto: 500.00),
        ],
        historialAutorizaciones: [
          AutorizacionHistorial(
            nivel: 1,
            nombreNivel: 'Jefe Sección',
            autorizador: Solicitante(
              trabId: '012',
              nombreCompleto: 'Ana Ríos Gutiérrez',
              seccion: 'Administración',
              cargo: 'Jefa de Sección',
            ),
            estado: EstadoPresupuesto.autorizado,
            fechaAccion: DateTime.now().subtract(const Duration(hours: 4)),
          ),
          AutorizacionHistorial(
            nivel: 2,
            nombreNivel: 'Jefe Departamento',
            estado: EstadoPresupuesto.pendiente,
          ),
        ],
      ),
    ];
  }

  List<PresupuestoEmergencia> _generarAutorizados() {
    return [
      PresupuestoEmergencia(
        presupId: '10',
        codigo: '2026-0148',
        prioridad: PrioridadPresupuesto.emergencia,
        tipoPresupuesto: TipoPresupuestoEmergencia.consumo,
        solicitante: Solicitante(
          trabId: '005',
          nombreCompleto: 'Pedro Ramírez Luna',
          seccion: 'Cosecha',
          cargo: 'Supervisor',
        ),
        montoTotal: 8500.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 3)),
        descripcion: 'Reparación de equipo de riego que afecta 20 hectáreas de cultivo.',
        estadoActual: EstadoPresupuesto.autorizado,
        nivelAutorizacionActual: 3,
        esmiTurno: false,
        items: [
          ItemPresupuesto(itemId: '1', descripcion: 'Tubería PVC 6"', monto: 3500.00),
          ItemPresupuesto(itemId: '2', descripcion: 'Bomba de agua 5HP', monto: 3500.00),
          ItemPresupuesto(itemId: '3', descripcion: 'Mano de obra instalación', monto: 1500.00),
        ],
      ),
      PresupuestoEmergencia(
        presupId: '11',
        codigo: '2026-0145',
        prioridad: PrioridadPresupuesto.urgente,
        tipoPresupuesto: TipoPresupuestoEmergencia.servicioTercero,
        solicitante: Solicitante(
          trabId: '006',
          nombreCompleto: 'Rosa Castillo Mendoza',
          seccion: 'Recursos Humanos',
          cargo: 'Analista',
        ),
        montoTotal: 2400.00,
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 5)),
        descripcion: 'Compra de equipos de protección personal para personal de campo.',
        estadoActual: EstadoPresupuesto.autorizado,
        nivelAutorizacionActual: 2,
        esmiTurno: false,
        items: [
          ItemPresupuesto(itemId: '1', descripcion: 'Cascos de seguridad x50', monto: 1200.00),
          ItemPresupuesto(itemId: '2', descripcion: 'Guantes de cuero x50', monto: 600.00),
          ItemPresupuesto(itemId: '3', descripcion: 'Lentes de protección x50', monto: 600.00),
        ],
      ),
    ];
  }
}
