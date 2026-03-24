import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import 'models/presupuesto_emergencia.dart';
import 'services/presupuesto_emergencia_service.dart';
import 'widgets/presupuesto_emergencia_card.dart';

/// Pantalla de consulta de presupuestos de emergencia (solo lectura)
/// Permite ver el historial de todos los presupuestos sin opciones de autorización
class PresupuestoEmergenciaConsultaScreen extends StatefulWidget {
  const PresupuestoEmergenciaConsultaScreen({super.key});

  @override
  State<PresupuestoEmergenciaConsultaScreen> createState() =>
      _PresupuestoEmergenciaConsultaScreenState();
}

class _PresupuestoEmergenciaConsultaScreenState
    extends State<PresupuestoEmergenciaConsultaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PresupuestoEmergenciaService _service = PresupuestoEmergenciaService();
  final TextEditingController _searchController = TextEditingController();

  List<PresupuestoEmergenciaListaItem> _todosPresupuestos = [];
  List<PresupuestoEmergenciaListaItem> _presupuestosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  
  // Filtros
  final String _filtroEstado = 'TODOS';
  String _filtroPrioridad = 'TODOS';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _cargarPresupuestos();
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
      // TODO: Implementar llamada real al API
      // final presupuestos = await _service.obtenerTodosPresupuestos(
      //   trabId: usuario.trabId ?? '',
      //   empresaId: usuario.empresaId ?? '02',
      // );

      // Datos de prueba
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _todosPresupuestos = []; // TODO: Cargar desde API
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar presupuestos: $e';
      });
    }
  }

  void _aplicarFiltros() {
    List<PresupuestoEmergenciaListaItem> resultado = List.from(_todosPresupuestos);

    // Filtrar por tab (estado)
    switch (_tabController.index) {
      case 0: // Todos
        break;
      case 1: // Pendientes
        resultado = resultado
            .where((p) =>
                p.estadoActual == EstadoPresupuesto.pendiente ||
                p.estadoActual == EstadoPresupuesto.porAutorizar)
            .toList();
        break;
      case 2: // Autorizados
        resultado = resultado
            .where((p) => p.estadoActual == EstadoPresupuesto.autorizado)
            .toList();
        break;
      case 3: // Observados
        resultado = resultado
            .where((p) => p.estadoActual == EstadoPresupuesto.observado)
            .toList();
        break;
    }

    // Filtrar por prioridad
    if (_filtroPrioridad != 'TODOS') {
      resultado = resultado.where((p) {
        switch (_filtroPrioridad) {
          case 'EMERGENCIA':
            return p.prioridad == PrioridadPresupuesto.emergencia;
          case 'URGENTE':
            return p.prioridad == PrioridadPresupuesto.urgente;
          case 'NORMAL':
            return p.prioridad == PrioridadPresupuesto.normal;
          default:
            return true;
        }
      }).toList();
    }

    // Filtrar por búsqueda
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado.where((p) {
        return (p.codigo?.toLowerCase().contains(query) ?? false) ||
            (p.descripcion?.toLowerCase().contains(query) ?? false) ||
            (p.solicitante?.nombreCompleto.toLowerCase().contains(query) ?? false) ||
            (p.solicitante?.seccion.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtrar por rango de fechas
    if (_rangoFechas != null) {
      resultado = resultado.where((p) {
        if (p.fechaSolicitud == null) return false;
        return p.fechaSolicitud!.isAfter(_rangoFechas!.start) &&
            p.fechaSolicitud!
                .isBefore(_rangoFechas!.end.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _presupuestosFiltrados = resultado;
    });
  }

  // TODO: Reemplazar con datos reales del API
  // List<PresupuestoEmergenciaListaItem> _generarDatosPrueba() {
  //   return [];
  // }

  void _mostrarDetallePresupuesto(PresupuestoEmergenciaListaItem presupuesto) {
    // TODO: Implementar modal de detalles con datos reales del API
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => PresupuestoDetalleModal(
    //     presupuesto: presupuesto,
    //     mostrarAcciones: false,
    //     modoConsulta: true,
    //     onAutorizar: null,
    //     onObservar: null,
    //   ),
    // );
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
              // Handle
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

              // Título
              const Text(
                'Filtros de búsqueda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Filtro por prioridad
              const Text(
                'Prioridad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'Todos',
                    selected: _filtroPrioridad == 'TODOS',
                    onSelected: (selected) {
                      setModalState(() => _filtroPrioridad = 'TODOS');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Emergencia',
                    selected: _filtroPrioridad == 'EMERGENCIA',
                    color: Colors.red,
                    onSelected: (selected) {
                      setModalState(() => _filtroPrioridad = 'EMERGENCIA');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Urgente',
                    selected: _filtroPrioridad == 'URGENTE',
                    color: Colors.orange,
                    onSelected: (selected) {
                      setModalState(() => _filtroPrioridad = 'URGENTE');
                    },
                  ),
                  _buildFilterChip(
                    label: 'Normal',
                    selected: _filtroPrioridad == 'NORMAL',
                    color: Colors.green,
                    onSelected: (selected) {
                      setModalState(() => _filtroPrioridad = 'NORMAL');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filtro por rango de fechas
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

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _filtroPrioridad = 'TODOS';
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
          'Consulta de Presupuestos',
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
              // Barra de búsqueda
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
                      hintText: 'Buscar por código, descripción...',
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
              // Tabs
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
                        _buildBadge(_todosPresupuestos.length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pendientes'),
                        const SizedBox(width: 4),
                        _buildBadge(_todosPresupuestos
                            .where((p) =>
                                p.estadoActual == EstadoPresupuesto.pendiente ||
                                p.estadoActual == EstadoPresupuesto.porAutorizar)
                            .length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Autorizados'),
                        const SizedBox(width: 4),
                        _buildBadge(_todosPresupuestos
                            .where((p) =>
                                p.estadoActual == EstadoPresupuesto.autorizado)
                            .length),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Observados'),
                        const SizedBox(width: 4),
                        _buildBadge(_todosPresupuestos
                            .where((p) =>
                                p.estadoActual == EstadoPresupuesto.observado)
                            .length),
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
            onPressed: _cargarPresupuestos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (_presupuestosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay presupuestos',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron presupuestos con los filtros seleccionados',
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
      onRefresh: _cargarPresupuestos,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _presupuestosFiltrados.length,
        itemBuilder: (context, index) {
          final presupuesto = _presupuestosFiltrados[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PresupuestoEmergenciaCard(
              presupuesto: presupuesto,
              onTap: () => _mostrarDetallePresupuesto(presupuesto),
              mostrarEstado: true,
            ),
          );
        },
      ),
    );
  }
}
