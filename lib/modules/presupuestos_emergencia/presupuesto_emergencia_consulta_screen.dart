import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import 'models/presupuesto_emergencia.dart';
import 'services/presupuesto_emergencia_service.dart';
import 'widgets/presupuesto_emergencia_card.dart';
import 'widgets/presupuesto_detalle_modal.dart';

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

  // Datos desde el API
  List<PresupuestoEmergenciaConsultaItem> _porAtender = [];
  List<PresupuestoEmergenciaConsultaItem> _atendidos = [];
  List<PresupuestoEmergenciaConsultaItem> _anulados = [];
  
  // Listas filtradas para mostrar
  List<PresupuestoEmergenciaConsultaItem> _itemsFiltrados = [];
  
  bool _isLoading = true;
  String? _error;
  
  // Filtros
  String _filtroPrioridad = 'TODOS';
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: Por Atender, Atendidos, Anulados
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
      final result = await _service.obtenerListasConsulta(
        usuario: usuario.webUser ?? '',
        empresaId: usuario.empresaId ?? '02',
      );

      setState(() {
        if (result.esExitoso) {
          _porAtender = result.porAtender;
          _atendidos = result.atendidos;
          _anulados = result.anulados;
          _aplicarFiltros();
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

  /// Obtiene la lista actual según el tab seleccionado
  List<PresupuestoEmergenciaConsultaItem> _getListaActual() {
    switch (_tabController.index) {
      case 0: // Por Atender
        return _porAtender;
      case 1: // Atendidos
        return _atendidos;
      case 2: // Anulados
        return _anulados;
      default:
        return [];
    }
  }

  void _aplicarFiltros() {
    List<PresupuestoEmergenciaConsultaItem> resultado = List.from(_getListaActual());

    // Filtrar por búsqueda (número, usuario, área)
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado.where((p) {
        return p.numero.toLowerCase().contains(query) ||
            p.usuario.toLowerCase().contains(query) ||
            p.area.toLowerCase().contains(query);
      }).toList();
    }

    // Filtrar por rango de fechas
    if (_rangoFechas != null) {
      resultado = resultado.where((p) {
        return p.fecha.isAfter(_rangoFechas!.start) &&
            p.fecha.isBefore(_rangoFechas!.end.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _itemsFiltrados = resultado;
    });
  }

  void _mostrarDetallePresupuesto(PresupuestoEmergenciaConsultaItem presupuesto) {
    // Convertir a PresupuestoEmergenciaListaItem para el modal
    final listaItem = PresupuestoEmergenciaListaItem(
      idPresupuestoEmergencia: presupuesto.idPresupuestoEmergencia,
      idSubtipoPresupuesto: presupuesto.idSubtipoPresupuesto,
      esCcMultiple: presupuesto.esCcMultiple,
      tipo: presupuesto.tipo,
      numero: presupuesto.numero,
      fecha: presupuesto.fecha,
      usuario: presupuesto.usuario,
      area: presupuesto.area,
      estadoActual: presupuesto.estadoPresupuesto,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PresupuestoDetalleModal(
        presupuesto: listaItem,
        mostrarAcciones: false,
        modoConsulta: true,
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

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
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
                      hintText: 'Buscar por número, usuario...',
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
                  _buildTab('POR ATENDER', _porAtender.length),
                  _buildTab('ATENDIDOS', _atendidos.length),
                  _buildTab('ANULADOS', _anulados.length),
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
            onPressed: _cargarPresupuestos,
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
            'No se encontraron presupuestos',
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
      itemCount: _itemsFiltrados.length,
      itemBuilder: (context, index) {
        final presupuesto = _itemsFiltrados[index];
        // Pasar directamente el item de consulta al card (sin convertir)
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PresupuestoEmergenciaCard(
            presupuesto: presupuesto, // ← Pasar PresupuestoEmergenciaConsultaItem
            onTap: () => _mostrarDetallePresupuesto(presupuesto),
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
        return 'No hay presupuestos por atender';
      case 1:
        return 'No hay presupuestos atendidos';
      case 2:
        return 'No hay presupuestos anulados';
      default:
        return 'No hay presupuestos';
    }
  }
}