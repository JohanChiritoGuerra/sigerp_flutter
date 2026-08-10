import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import 'abastecimiento_diesel_form_screen.dart';
import 'models/abastecimiento_diesel_lista_item.dart';
import 'services/abastecimiento_diesel_service.dart';
import 'widgets/abastecimiento_diesel_card.dart';
import 'widgets/abastecimiento_diesel_detalle_modal.dart';

class AbastecimientoDieselScreen extends StatefulWidget {
  const AbastecimientoDieselScreen({super.key});

  @override
  State<AbastecimientoDieselScreen> createState() => _AbastecimientoDieselScreenState();
}

class _AbastecimientoDieselScreenState extends State<AbastecimientoDieselScreen> {
  final AbastecimientoDieselService _service = AbastecimientoDieselService();
  final TextEditingController _searchController = TextEditingController();

  List<AbastecimientoDieselListaItem> _items = [];
  List<AbastecimientoDieselListaItem> _itemsFiltrados = [];
  bool _isLoading = true;
  String? _error;
  DateTimeRange? _rangoFechas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthService>().puedeConsultarDiesel) {
        _cargar();
      } else {
        // Sin acceso de Consultar: no tiene sentido pedir el listado al backend.
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _empresaId => context.read<AuthService>().usuario?.empresaId ?? '02';

  Future<void> _cargar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.listar(empresaId: _empresaId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
        _aplicarFiltros();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar: $e';
      });
    }
  }

  void _aplicarFiltros() {
    var resultado = List<AbastecimientoDieselListaItem>.from(_items);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado.where((item) {
        return item.centroCostoDescripcion.toLowerCase().contains(query) ||
            item.centroCosto.toLowerCase().contains(query) ||
            item.chofer.toLowerCase().contains(query);
      }).toList();
    }

    if (_rangoFechas != null) {
      resultado = resultado.where((item) {
        return item.fecha.isAfter(_rangoFechas!.start.subtract(const Duration(seconds: 1))) &&
            item.fecha.isBefore(_rangoFechas!.end.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() => _itemsFiltrados = resultado);
  }

  Future<void> _mostrarFiltros() async {
    DateTimeRange? seleccion = _rangoFechas;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Text('Filtro de fechas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _botonFecha(
                          label: seleccion != null ? _formatDate(seleccion!.start) : 'Desde',
                          activo: seleccion != null,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: seleccion?.start ?? DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                              locale: const Locale('es', 'ES'),
                            );
                            if (picked != null) {
                              final fin = seleccion?.end ?? picked;
                              setModalState(() => seleccion = DateTimeRange(
                                    start: picked,
                                    end: fin.isBefore(picked) ? picked : fin,
                                  ));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _botonFecha(
                          label: seleccion != null ? _formatDate(seleccion!.end) : 'Hasta',
                          activo: seleccion != null,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: seleccion?.end ?? DateTime.now(),
                              firstDate: seleccion?.start ?? DateTime(2024),
                              lastDate: DateTime.now(),
                              locale: const Locale('es', 'ES'),
                            );
                            if (picked != null) {
                              final inicio = seleccion?.start ?? picked;
                              setModalState(() => seleccion = DateTimeRange(start: inicio, end: picked));
                            }
                          },
                        ),
                      ),
                      if (seleccion != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setModalState(() => seleccion = null),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setModalState(() => seleccion = null),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Limpiar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _rangoFechas = seleccion);
                            Navigator.pop(context);
                            _aplicarFiltros();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(AppColors.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _botonFecha({required String label, required bool activo, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
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
                label,
                style: TextStyle(fontSize: 13, color: activo ? Colors.black : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _abrirFormulario() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AbastecimientoDieselFormScreen()),
    );
    if (resultado == true) {
      _cargar();
    }
  }

  void _mostrarDetalle(AbastecimientoDieselListaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AbastecimientoDieselDetalleModal(item: item, empresaId: _empresaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final puedeRegistrar = authService.puedeRegistrarDiesel;
    final puedeConsultar = authService.puedeConsultarDiesel;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Abastecimiento de Diesel',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtros',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar por unidad, chofer...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => _aplicarFiltros(),
              ),
            ),
          ),
        ),
      ),
      body: !puedeConsultar
          ? _buildSinAccesoConsulta()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorView()
                  : _buildListView(puedeRegistrar),
      floatingActionButton: puedeRegistrar
          ? FloatingActionButton(
              backgroundColor: Color(AppColors.primaryColor),
              onPressed: _abrirFormulario,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSinAccesoConsulta() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes acceso para consultar el historial',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
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
          Text(_error ?? 'Error desconocido', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildListView(bool puedeRegistrar) {
    if (_itemsFiltrados.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_gas_station_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      _items.isEmpty ? 'Sin registros de abastecimiento' : 'No se encontraron resultados',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                    if (puedeRegistrar && _items.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Usa el botón + para registrar uno nuevo',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Deja espacio abajo para la barra/gestos de navegación del sistema y para
    // que el FAB (+) no tape la última tarjeta — sin esto, en celulares con
    // controles de navegación al pie, el último ítem queda parcialmente oculto.
    final paddingInferior = 8.0 + MediaQuery.of(context).padding.bottom + (puedeRegistrar ? 72.0 : 0.0);

    return RefreshIndicator(
      onRefresh: _cargar,
      color: Color(AppColors.primaryColor),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: paddingInferior),
        itemCount: _itemsFiltrados.length,
        itemBuilder: (context, index) {
          final item = _itemsFiltrados[index];
          return AbastecimientoDieselCard(item: item, onTap: () => _mostrarDetalle(item));
        },
      ),
    );
  }
}
