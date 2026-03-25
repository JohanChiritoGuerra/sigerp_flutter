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

  List<SolicitudCompraListaItem> _todasSolicitudes = [];
  List<SolicitudCompraListaItem> _solicitudesFiltradas = [];
  bool _isLoading = true;
  String? _error;

  // Filtros
  String _filtroTipo = 'TODOS';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      final result = await _service.obtenerListasAutorizacion(
        usuario: usuario.webUser ?? '',
        empresaId: usuario.empresaId ?? '02',
      );

      if (mounted) {
        setState(() {
          if (result.esExitoso) {
            // Combinar pendientes y autorizados para consulta
            _todasSolicitudes = [...result.porAutorizar, ...result.autorizados];
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

  void _aplicarFiltros() {
    List<SolicitudCompraListaItem> resultado = List.from(_todasSolicitudes);

    // Filtrar por tab (estado) - En consulta, solo por tipo de lista
    switch (_tabController.index) {
      case 0: // Todos
        break;
      case 1: // Pendientes
        // En consulta, mostrar los que están en porAutorizar
        resultado = resultado.where((s) => 
          _solicitudesPendientesIds.contains(s.solComCabId)
        ).toList();
        break;
      case 2: // Autorizados
        resultado = resultado.where((s) => 
          _solicitudesAutorizadasIds.contains(s.solComCabId)
        ).toList();
        break;
      case 3: // Observados
        // Por ahora no tenemos observados en la lista
        resultado = [];
        break;
    }

    // Filtrar por tipo
    if (_filtroTipo != 'TODOS') {
      resultado = resultado.where((s) {
        switch (_filtroTipo) {
          case 'CM':
            return s.tipoEnum == TipoSolicitudCompra.compraMateriales;
          case 'AF':
            return s.tipoEnum == TipoSolicitudCompra.compraActivoFijo;
          case 'ST':
            return s.tipoEnum == TipoSolicitudCompra.servicioTercero;
          case 'CD':
            return s.tipoEnum == TipoSolicitudCompra.cargaDiversaGestion;
          default:
            return true;
        }
      }).toList();
    }

    // Filtrar por búsqueda
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado.where((s) {
        return s.numero.toLowerCase().contains(query) ||
            s.usuario.toLowerCase().contains(query) ||
            s.area.toLowerCase().contains(query);
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
      _solicitudesFiltradas = resultado;
    });
  }

  // Para poder filtrar por estado en consulta
  Set<String> get _solicitudesPendientesIds => 
      _todasSolicitudes.where((s) => s.tipOpeCompId > 0).map((s) => s.solComCabId).toSet();
  
  Set<String> get _solicitudesAutorizadasIds => 
      _todasSolicitudes.where((s) => s.tipOpeCompId > 0).map((s) => s.solComCabId).toSet();

  void _mostrarDetalleSolicitud(SolicitudCompraListaItem solicitud) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SolicitudDetalleModal(
        solicitud: solicitud,
        mostrarAcciones: false,
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltrosModal(),
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
              InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    initialDateRange: _rangoFechas,
                    locale: const Locale('es', 'ES'),
                  );
                  if (picked != null) {
                    setModalState(() => _rangoFechas = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _rangoFechas != null
                              ? '${_formatDate(_rangoFechas!.start)} - ${_formatDate(_rangoFechas!.end)}'
                              : 'Seleccionar rango de fechas',
                          style: TextStyle(
                            color: _rangoFechas != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                      if (_rangoFechas != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setModalState(() => _rangoFechas = null);
                          },
                        ),
                    ],
                  ),
                ),
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
                      hintText: 'Buscar por código, solicitante...',
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
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Todos'),
                        const SizedBox(width: 4),
                        _buildBadge(_todasSolicitudes.length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pendientes'),
                        const SizedBox(width: 4),
                        _buildBadge(_solicitudesPendientesIds.length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Autorizados'),
                        const SizedBox(width: 4),
                        _buildBadge(_solicitudesAutorizadasIds.length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Observados'),
                        const SizedBox(width: 4),
                        _buildBadge(0),
                      ],
                    ),
                  ),
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

  Widget _buildBadge(int count) {
    return Container(
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
    if (_solicitudesFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay solicitudes',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron solicitudes con los filtros seleccionados',
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
        itemCount: _solicitudesFiltradas.length,
        itemBuilder: (context, index) {
          final solicitud = _solicitudesFiltradas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SolicitudCompraCard(
              solicitud: solicitud,
              onTap: () => _mostrarDetalleSolicitud(solicitud),
              mostrarEstado: true,
            ),
          );
        },
      ),
    );
  }
}