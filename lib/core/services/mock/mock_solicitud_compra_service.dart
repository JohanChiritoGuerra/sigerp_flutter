import '../../../modules/solicitudes_compra/models/solicitud_compra.dart';
import '../../../modules/solicitudes_compra/services/solicitud_compra_service.dart';

/// Servicio mock para solicitudes de compra.
/// Devuelve datos de prueba sin hacer llamadas a la API.
class MockSolicitudCompraService extends SolicitudCompraService {
  @override
  Future<SolicitudCompraListResponse> obtenerSolicitudesPendientes({
    required String trabId,
    required String empresaId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final datos = _generarPendientes();

    return SolicitudCompraListResponse(
      success: true,
      message: 'Datos mock cargados correctamente',
      solicitudes: datos,
      totalRegistros: datos.length,
    );
  }

  @override
  Future<SolicitudCompraListResponse> obtenerSolicitudesAutorizadas({
    required String trabId,
    required String empresaId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final datos = _generarAutorizadas();

    return SolicitudCompraListResponse(
      success: true,
      message: 'Datos mock cargados correctamente',
      solicitudes: datos,
      totalRegistros: datos.length,
    );
  }

  @override
  Future<SolicitudCompraActionResponse> autorizarSolicitud({
    required String solicitudId,
    required String trabId,
    required String empresaId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return SolicitudCompraActionResponse(
      success: true,
      message: 'Solicitud autorizada correctamente (mock)',
      solicitudId: solicitudId,
      estado: 'AUTORIZADO',
      fechaAccion: DateTime.now(),
    );
  }

  @override
  Future<SolicitudCompraActionResponse> observarSolicitud({
    required String solicitudId,
    required String trabId,
    required String empresaId,
    required String motivo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return SolicitudCompraActionResponse(
      success: true,
      message: 'Solicitud observada correctamente (mock)',
      solicitudId: solicitudId,
      estado: 'OBSERVADO',
      fechaAccion: DateTime.now(),
    );
  }

  // =================== DATOS DE PRUEBA ===================

  List<SolicitudCompra> _generarPendientes() {
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

  List<SolicitudCompra> _generarAutorizadas() {
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
}
