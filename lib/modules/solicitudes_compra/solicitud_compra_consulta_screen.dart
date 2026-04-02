import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import 'models/solicitud_compra.dart';
import 'services/solicitud_compra_service.dart';
import 'widgets/solicitud_compra_card.dart';
import 'widgets/solicitud_detalle_modal.dart';

class SolicitudCompraConsultaScreen extends StatefulWidget {
  const SolicitudCompraConsultaScreen({super.key});

  @override
  State<SolicitudCompraConsultaScreen> createState() =>
      _SolicitudCompraConsultaScreenState();
}

class _SolicitudCompraConsultaScreenState
    extends State<SolicitudCompraConsultaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SolicitudCompraService _service = SolicitudCompraService();
  final TextEditingController _searchController = TextEditingController();

  // Datos desde el API
  List<SolicitudCompraConsultaItem> _porAutorizar = [];
  List<SolicitudCompraConsultaItem> _autorizados = [];
  List<SolicitudCompraConsultaItem> _anuladosRechazados = [];
  
  // Listas filtradas para mostrar
  List<SolicitudCompraConsultaItem> _itemsFiltrados = [];
  
  bool _isLoading = true;
  String? _error;

  // Filtros
  String _filtroTipo = 'TODOS';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: Por Autorizar, Autorizados, Anulados/Rechazados
    _tabController.addListener(_onTabChanged);
    _cargarSolicitudes();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _aplicarFiltros();
    }
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
      final result = await _service.obtenerListasConsulta(
        usuario: usuario.webUser ?? '',
        empresaId: usuario.empresaId ?? '02',
      );

      if (mounted) {
        setState(() {
          if (result.esExitoso) {
            _porAutorizar = result.porAutorizar;
            _autorizados = result.autorizados;
            _anuladosRechazados = result.anuladosRechazados;
            _aplicarFiltros();
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

  /// Obtiene la lista actual según el tab seleccionado
  List<SolicitudCompraConsultaItem> _getListaActual() {
    switch (_tabController.index) {
      case 0: // Por Autorizar
        return _porAutorizar;
      case 1: // Autorizados
        return _autorizados;
      case 2: // Anulados/Rechazados
        return _anuladosRechazados;
      default:
        return [];
    }
  }

  void _aplicarFiltros() {
    debugPrint('🔍 Aplicando filtros - Tipo: $_filtroTipo, Búsqueda: ${_searchController.text}');
    List<SolicitudCompraConsultaItem> resultado = List.from(_getListaActual());
    debugPrint('📊 Total antes de filtrar por tipo: ${resultado.length}');

    // Filtrar por tipo usando tipOpeCompId
    if (_filtroTipo != 'TODOS') {
      resultado = resultado.where((s) {
        bool match;
        switch (_filtroTipo) {
          case 'CM':
            match = s.tipOpeCompId == 1; // Materiales
            break;
          case 'AF':
            match = s.tipOpeCompId == 4; // Activo Fijo
            break;
          case 'ST':
            match = s.tipOpeCompId == 3; // Servicio Tercero
            break;
          case 'CD':
            match = s.tipOpeCompId == 5; // Carga Diversa
            break;
          default:
            match = true;
        }
        debugPrint('🔎 Item: ${s.numero} - tipOpeCompId: ${s.tipOpeCompId} - Match: $match');
        return match;
      }).toList();
      
      debugPrint('📊 Después de filtrar por tipo: ${resultado.length}');
    }

    // Filtrar por búsqueda
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado.where((s) {
        return s.numero.toLowerCase().contains(query) ||
            s.usuario.toLowerCase().contains(query);
      }).toList();
    }

    // Filtrar por rango de fechas
    if (_rangoFechas != null) {
      resultado = resultado.where((s) {
        return s.fecha.isAfter(_rangoFechas!.start) &&
            s.fecha.isBefore(_rangoFechas!.end.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _itemsFiltrados = resultado;
    });
  }

  void _mostrarDetalleSolicitud(SolicitudCompraConsultaItem solicitud) {
    // Convertir a SolicitudCompraListaItem para el modal
    final listaItem = SolicitudCompraListaItem(
      solComCabId: solicitud.solComCabId,
      tipOpeCompId: solicitud.tipOpeCompId,
      tipo: solicitud.tipo,
      numero: solicitud.numero,
      fecha: solicitud.fecha,
      usuario: solicitud.usuario,
      area: solicitud.area,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SolicitudDetalleModal(
        solicitud: listaItem,
        mostrarAcciones: false, // En consulta no se pueden autorizar/observar
        esConsulta: true, // ← Indicar que es consulta
      ),
    );
  }

  void _mostrarFiltros() {
  // Crear copias temporales de los filtros actuales
  String tempFiltroTipo = _filtroTipo;
  DateTimeRange? tempRangoFechas = _rangoFechas;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Filtros de búsqueda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tipo de Solicitud',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'Todos',
                    selected: tempFiltroTipo == 'TODOS',
                    onSelected: (selected) {
                      setModalState(() => tempFiltroTipo = 'TODOS');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Materiales',
                    selected: tempFiltroTipo == 'CM',
                    color: TipoSolicitudCompra.compraMateriales.color,
                    onSelected: (selected) {
                      setModalState(() => tempFiltroTipo = 'CM');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Activo Fijo',
                    selected: tempFiltroTipo == 'AF',
                    color: TipoSolicitudCompra.compraActivoFijo.color,
                    onSelected: (selected) {
                      setModalState(() => tempFiltroTipo = 'AF');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Servicio',
                    selected: tempFiltroTipo == 'ST',
                    color: TipoSolicitudCompra.servicioTercero.color,
                    onSelected: (selected) {
                      setModalState(() => tempFiltroTipo = 'ST');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Carga Diversa',
                    selected: tempFiltroTipo == 'CD',
                    color: TipoSolicitudCompra.cargaDiversaGestion.color,
                    onSelected: (selected) {
                      setModalState(() => tempFiltroTipo = 'CD');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Rango de fechas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempRangoFechas?.start ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null) {
                          final fin = tempRangoFechas?.end ?? picked;
                          setModalState(() => tempRangoFechas = DateTimeRange(
                            start: picked,
                            end: fin.isBefore(picked) ? picked : fin,
                          ));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                tempRangoFechas != null
                                    ? _formatDate(tempRangoFechas!.start)
                                    : 'Desde',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tempRangoFechas != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempRangoFechas?.end ?? DateTime.now(),
                          firstDate: tempRangoFechas?.start ?? DateTime(2024),
                          lastDate: DateTime.now(),
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null) {
                          final inicio = tempRangoFechas?.start ?? picked;
                          setModalState(() => tempRangoFechas = DateTimeRange(
                            start: inicio,
                            end: picked,
                          ));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                tempRangoFechas != null
                                    ? _formatDate(tempRangoFechas!.end)
                                    : 'Hasta',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tempRangoFechas != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (tempRangoFechas != null) ...[  
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setModalState(() => tempRangoFechas = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          tempFiltroTipo = 'TODOS';
                          tempRangoFechas = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aplicar los filtros temporales a los reales
                        setState(() {
                          _filtroTipo = tempFiltroTipo;
                          _rangoFechas = tempRangoFechas;
                        });
                        Navigator.pop(context);
                        _aplicarFiltros();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildFiltrosModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Filtros de búsqueda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tipo de Solicitud',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'Todos',
                    selected: _filtroTipo == 'TODOS',
                    onSelected: (selected) {
                      setModalState(() => _filtroTipo = 'TODOS');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Materiales',
                    selected: _filtroTipo == 'CM',
                    color: TipoSolicitudCompra.compraMateriales.color,
                    onSelected: (selected) {
                      setModalState(() => _filtroTipo = 'CM');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Activo Fijo',
                    selected: _filtroTipo == 'AF',
                    color: TipoSolicitudCompra.compraActivoFijo.color,
                    onSelected: (selected) {
                      setModalState(() => _filtroTipo = 'AF');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Servicio',
                    selected: _filtroTipo == 'ST',
                    color: TipoSolicitudCompra.servicioTercero.color,
                    onSelected: (selected) {
                      setModalState(() => _filtroTipo = 'ST');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Carga Diversa',
                    selected: _filtroTipo == 'CD',
                    color: TipoSolicitudCompra.cargaDiversaGestion.color,
                    onSelected: (selected) {
                      setModalState(() => _filtroTipo = 'CD');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Rango de fechas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _rangoFechas?.start ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null) {
                          final fin = _rangoFechas?.end ?? picked;
                          setModalState(() => _rangoFechas = DateTimeRange(
                            start: picked,
                            end: fin.isBefore(picked) ? picked : fin,
                          ));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _rangoFechas != null
                                    ? _formatDate(_rangoFechas!.start)
                                    : 'Desde',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _rangoFechas != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _rangoFechas?.end ?? DateTime.now(),
                          firstDate: _rangoFechas?.start ?? DateTime(2024),
                          lastDate: DateTime.now(),
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null) {
                          final inicio = _rangoFechas?.start ?? picked;
                          setModalState(() => _rangoFechas = DateTimeRange(
                            start: inicio,
                            end: picked,
                          ));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _rangoFechas != null
                                    ? _formatDate(_rangoFechas!.end)
                                    : 'Hasta',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _rangoFechas != null ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_rangoFechas != null) ...[  
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setModalState(() => _rangoFechas = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _filtroTipo = 'TODOS';
                          _rangoFechas = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _aplicarFiltros();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    Color? color,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: (color ?? Color(AppColors.primaryColor)).withOpacity(0.2),
      checkmarkColor: color ?? Color(AppColors.primaryColor),
      labelStyle: TextStyle(
        color: selected ? (color ?? Color(AppColors.primaryColor)) : Colors.grey[700],
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
          'Consulta de Solicitudes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtros',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por número, solicitante...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                _searchController.clear();
                                _aplicarFiltros();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => _aplicarFiltros(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  _buildTab('POR AUTORIZAR', _porAutorizar.length),
                  _buildTab('AUTORIZADOS', _autorizados.length),
                  _buildTab('ANULADOS/RECHAZADOS', _anuladosRechazados.length),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildListView(),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Error desconocido',
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
    );
  }

  Widget _buildListView() {
    if (_itemsFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _getMensajeVacio(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron solicitudes',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarSolicitudes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _itemsFiltrados.length,
        itemBuilder: (context, index) {
          final solicitud = _itemsFiltrados[index];
          // Pasar directamente el item de consulta al card
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SolicitudCompraCard(
              solicitud: solicitud, // ← Pasar SolicitudCompraConsultaItem
              onTap: () => _mostrarDetalleSolicitud(solicitud),
              mostrarEstado: true,
            ),
          );
        },
      ),
    );
  }

  String _getMensajeVacio() {
    switch (_tabController.index) {
      case 0:
        return 'No hay solicitudes por autorizar';
      case 1:
        return 'No hay solicitudes autorizadas';
      case 2:
        return 'No hay solicitudes anuladas o rechazadas';
      default:
        return 'No hay solicitudes';
    }
  }
}