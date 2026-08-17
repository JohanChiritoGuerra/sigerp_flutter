import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/constants.dart';
import 'abastecimiento_diesel_form_screen.dart';
import 'models/abastecimiento_diesel_lista_item.dart';
import 'models/borrador_diesel.dart';
import 'services/abastecimiento_diesel_repository.dart';
import 'widgets/abastecimiento_diesel_card.dart';
import 'widgets/abastecimiento_diesel_detalle_modal.dart';
import 'widgets/borrador_diesel_card.dart';
import 'widgets/borrador_diesel_detalle_modal.dart';

// El ítem de un borrador siempre es Diesel — a diferencia de "Mis salidas"
// (que ya trae su propia unidadMedida del servidor), acá no hay ningún dato
// del servidor detrás del borrador todavía, así que se deja fijo.
const String _kUnidadMedidaDiesel = 'GAL';

const List<String> _kNombresMes = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const List<String> _kNombresMesAbrev = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

DateTime _primerDiaDelMes(DateTime fecha) => DateTime(fecha.year, fecha.month, 1);

// Bandera simple (no un RouteObserver completo, solo hay una instancia
// relevante a la vez) para que el aviso global de reconexión (ver app.dart)
// sepa si esta pantalla ya está mostrando su propio aviso en este momento, y
// no lo duplique.
bool dieselScreenAbierta = false;

class AbastecimientoDieselScreen extends StatefulWidget {
  final int initialTabIndex;

  const AbastecimientoDieselScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AbastecimientoDieselScreen> createState() => _AbastecimientoDieselScreenState();
}

class _AbastecimientoDieselScreenState extends State<AbastecimientoDieselScreen> with SingleTickerProviderStateMixin {
  final AbastecimientoDieselRepository _repository = AbastecimientoDieselRepository();
  final ConnectivityService _connectivity = ConnectivityService();
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;
  StreamSubscription<bool>? _conexionSub;
  bool? _ultimoEstadoOnline;

  List<AbastecimientoDieselListaItem> _items = [];
  List<AbastecimientoDieselListaItem> _itemsFiltrados = [];
  bool _isLoading = true;
  String? _error;
  bool _esDatoCacheado = false;
  DateTime? _sincronizadoEn;
  DateTime _mesSeleccionado = _primerDiaDelMes(DateTime.now());

  List<AbastecimientoDieselListaItem> _itemsAnulados = [];
  List<AbastecimientoDieselListaItem> _itemsAnuladosFiltrados = [];
  bool _isLoadingAnulados = true;
  String? _errorAnulados;
  bool _esDatoCacheadoAnulados = false;
  DateTime? _sincronizadoEnAnulados;
  DateTime _mesSeleccionadoAnulados = _primerDiaDelMes(DateTime.now());

  List<BorradorDiesel> _borradores = [];
  bool _cargandoBorradores = true;
  final Set<int> _reintentandoIds = {};

  // Evita que el aviso de "Conexión recuperada" se reinicie con cada
  // parpadeo de conectividad (connectivity_plus a veces reporta el
  // reingreso a "online" en varios pasos intermedios muy seguidos mientras
  // la señal real se estabiliza) — mientras ya esté mostrándose, un nuevo
  // parpadeo no lo reemplaza ni le reinicia el conteo de 8s.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _reconexionSnackBarController;

  @override
  void initState() {
    super.initState();
    dieselScreenAbierta = true;
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AuthService>().puedeConsultarDiesel) {
        _cargar();
        _cargarAnulados();
      } else {
        // Sin acceso de Consultar: no tiene sentido pedir el listado al backend.
        setState(() {
          _isLoading = false;
          _isLoadingAnulados = false;
        });
      }
      _cargarBorradores();
      // No se espera (fire-and-forget): mantiene Centro de Costo, Jefatura y
      // Chofer al día (máx. 1 vez al día) para cuando falte conexión más tarde.
      // Con un pequeño retraso: sin esto, compite por ancho de banda con
      // _cargar()/_cargarAnulados() de arriba justo en el peor momento (la
      // pantalla que el usuario está mirando en este instante) — sobre todo
      // notorio la primera vez que se sincronizan los +9,000 choferes.
      final empresaId = context.read<AuthService>().usuario?.empresaId ?? '02';
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _repository.sincronizarCatalogosSiCorresponde(empresaId: empresaId);
      });
    });

    // Aviso (no bloqueante, con la pantalla activa) cuando vuelve la conexión
    // y hay borradores pendientes — nunca se reintenta en segundo plano sin
    // que el usuario lo vea.
    _connectivity.isOnline().then((online) => _ultimoEstadoOnline = online);
    _conexionSub = _connectivity.onStatusChange.listen(_onConectividadCambio);
  }

  @override
  void dispose() {
    dieselScreenAbierta = false;
    _searchController.dispose();
    _tabController.dispose();
    _conexionSub?.cancel();
    super.dispose();
  }

  String get _empresaId => context.read<AuthService>().usuario?.empresaId ?? '02';
  String get _usuaId => context.read<AuthService>().usuario?.usuaId ?? '';

  Future<void> _onConectividadCambio(bool online) async {
    final eraOffline = _ultimoEstadoOnline == false;
    _ultimoEstadoOnline = online;
    if (!online || !eraOffline || !mounted) return;

    final pendientes = await _repository.contarBorradoresPendientes(usuaId: _usuaId, empresaId: _empresaId);
    if (pendientes == 0 || !mounted) return;

    // Evitar reiniciar el SnackBar de reconexión si ya está visible por un
    // parpadeo anterior. Cuando el usuario lanza una acción que debe
    // reemplazar el aviso (ej. el resultado de un reintento) esa acción
    // seguirá usando `clearSnackBars()` explícitamente antes de mostrar,
    // lo que también libera este guard (clearSnackBars dispara `closed`).
    if (_reconexionSnackBarController != null) return;

    _reconexionSnackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conexión recuperada. Tienes $pendientes borrador${pendientes == 1 ? '' : 'es'} pendiente${pendientes == 1 ? '' : 's'}.'),
        backgroundColor: Colors.blueGrey[800],
        duration: const Duration(seconds: 8),
        action: SnackBarAction(label: 'Enviar', textColor: Colors.white, onPressed: _enviarTodosPendientes),
      ),
    );
    // Garantía adicional: si por alguna razón el `closed` no se completa
    // (timer pausado o bug), forzamos el cierre pasado el tiempo esperado.
    final controllerRef = _reconexionSnackBarController;
    Future.delayed(const Duration(seconds: 9), () {
      if (controllerRef != null && _reconexionSnackBarController == controllerRef) {
        try {
          controllerRef.close();
        } catch (_) {
          // ignore: no-op
        }
      }
    });
    _reconexionSnackBarController!.closed.then((_) {
      _reconexionSnackBarController = null;
    });
  }

  Future<void> _cargar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resultado = await _repository.listar(
        usuaId: _usuaId,
        empresaId: _empresaId,
        anio: _mesSeleccionado.year,
        mes: _mesSeleccionado.month,
      );
      if (!mounted) return;
      setState(() {
        _items = resultado.items;
        _esDatoCacheado = resultado.esDatoCacheado;
        _sincronizadoEn = resultado.sincronizadoEn;
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

  Future<void> _cargarAnulados() async {
    setState(() {
      _isLoadingAnulados = true;
      _errorAnulados = null;
    });

    try {
      final resultado = await _repository.listarAnulados(
        usuaId: _usuaId,
        empresaId: _empresaId,
        anio: _mesSeleccionadoAnulados.year,
        mes: _mesSeleccionadoAnulados.month,
      );
      if (!mounted) return;
      setState(() {
        _itemsAnulados = resultado.items;
        _esDatoCacheadoAnulados = resultado.esDatoCacheado;
        _sincronizadoEnAnulados = resultado.sincronizadoEn;
        _isLoadingAnulados = false;
        _aplicarFiltros();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingAnulados = false;
        _errorAnulados = 'Error al cargar: $e';
      });
    }
  }

  Future<void> _cargarBorradores() async {
    final lista = await _repository.listarBorradores(usuaId: _usuaId, empresaId: _empresaId);
    if (!mounted) return;
    setState(() {
      _borradores = lista;
      _cargandoBorradores = false;
    });
  }

  Future<RegistrarDieselResultado?> _reintentarBorrador(BorradorDiesel borrador, {bool mostrarResultado = true}) async {
    if (borrador.id == null) return null;
    setState(() => _reintentandoIds.add(borrador.id!));

    final resultado = await _repository.reintentarBorrador(borrador);

    if (!mounted) return resultado;
    setState(() => _reintentandoIds.remove(borrador.id!));
    await _cargarBorradores();
    if (resultado.estado == RegistrarDieselEstado.exitoso) _cargar();

    if (mostrarResultado && mounted) {
      // Reemplaza cualquier SnackBar en cola (ej. el de "Conexión
      // recuperada" aún visible) — el resultado de ESTE reintento puntual
      // siempre debe mostrarse de inmediato, no quedar esperando turno.
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado.mensaje),
          backgroundColor: switch (resultado.estado) {
            RegistrarDieselEstado.exitoso => Colors.green,
            RegistrarDieselEstado.guardadoComoBorrador => Colors.orange,
            RegistrarDieselEstado.rechazado => Colors.red,
          },
        ),
      );
    }
    return resultado;
  }

  Future<void> _enviarTodosPendientes() async {
    // Antes intentaba igual aunque no hubiera conexión (cada reintento no
    // hacía nada) y al final SIEMPRE mostraba "se terminó de procesar" —
    // sonaba a éxito aunque en los hechos no se hubiera enviado ninguno.
    if (!await _connectivity.isOnline()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sigue sin conexión. Los borradores continúan pendientes.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return;
    }

    await _cargarBorradores();
    final pendientes = _borradores.where((b) => b.estado == EstadoBorrador.pendiente).toList();
    var enviados = 0;
    for (final b in pendientes) {
      final resultado = await _reintentarBorrador(b, mostrarResultado: false);
      if (resultado?.estado == RegistrarDieselEstado.exitoso) enviados++;
    }
    if (!mounted) return;

    final mensaje = pendientes.isEmpty
        ? 'No había borradores pendientes por enviar.'
        : enviados == 0
            ? 'No se pudo enviar ningún borrador — revisa el motivo en cada tarjeta.'
            : enviados == pendientes.length
                ? 'Se enviaron los $enviados borrador${enviados == 1 ? '' : 'es'} pendientes.'
                : 'Se enviaron $enviados de ${pendientes.length} borradores.';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.blueGrey),
    );
  }

  Future<void> _eliminarBorrador(BorradorDiesel borrador) async {
    await _repository.eliminarBorrador(borrador);
    await _cargarBorradores();
  }

  // El filtro de fechas ya no aplica sobre datos descargados de más — el mes
  // a mostrar se decide ANTES de pedirle al servidor (ver _cambiarMes), así
  // que acá solo queda el buscador de texto.
  List<AbastecimientoDieselListaItem> _filtrar(List<AbastecimientoDieselListaItem> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return List<AbastecimientoDieselListaItem>.from(items);

    return items.where((item) {
      return item.centroCostoDescripcion.toLowerCase().contains(query) ||
          item.centroCosto.toLowerCase().contains(query) ||
          item.chofer.toLowerCase().contains(query) ||
          item.numeroDocumento.toLowerCase().contains(query);
    }).toList();
  }

  void _aplicarFiltros() {
    setState(() {
      _itemsFiltrados = _filtrar(_items);
      _itemsAnuladosFiltrados = _filtrar(_itemsAnulados);
    });
  }

  bool get _esMesActual => _mesSeleccionado.year == DateTime.now().year && _mesSeleccionado.month == DateTime.now().month;
  bool get _esMesActualAnulados =>
      _mesSeleccionadoAnulados.year == DateTime.now().year && _mesSeleccionadoAnulados.month == DateTime.now().month;

  void _cambiarMes(int deltaMeses) {
    setState(() => _mesSeleccionado = DateTime(_mesSeleccionado.year, _mesSeleccionado.month + deltaMeses, 1));
    _cargar();
  }

  void _cambiarMesAnulados(int deltaMeses) {
    setState(() => _mesSeleccionadoAnulados = DateTime(_mesSeleccionadoAnulados.year, _mesSeleccionadoAnulados.month + deltaMeses, 1));
    _cargarAnulados();
  }

  Future<void> _abrirSelectorMes({required DateTime actual, required ValueChanged<DateTime> onSeleccionar}) async {
    final elegido = await showDialog<DateTime>(
      context: context,
      builder: (context) => _SelectorMesDialog(mesActual: actual),
    );
    if (elegido == null) return;
    onSeleccionar(elegido);
  }

  Widget _tabConContador(String texto, int cantidad, Color colorBadge) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(texto),
          if (cantidad > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: colorBadge, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '$cantidad',
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
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

  String _formatFechaHora(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${_formatDate(dt)} $hh:$min';
  }

  // Navegador de mes: reemplaza el antiguo filtro "Desde/Hasta" — ahora el
  // mes elegido acá es lo que decide qué se le pide al servidor (o a la
  // copia local), no un filtro visual sobre datos ya descargados. El botón
  // "siguiente" se deshabilita en el mes actual: no tiene sentido navegar a
  // un mes futuro que todavía no tiene datos.
  Widget _buildSelectorMes({
    required DateTime mes,
    required bool esMesActual,
    required VoidCallback onAnterior,
    required VoidCallback onSiguiente,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: Color(AppColors.primaryColor),
            onPressed: onAnterior,
            tooltip: 'Mes anterior',
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_kNombresMes[mes.month - 1]} ${mes.year}',
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF2E2E3A)),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[500], size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: esMesActual ? Colors.grey[300] : Color(AppColors.primaryColor),
            onPressed: esMesActual ? null : onSiguiente,
            tooltip: 'Mes siguiente',
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSinConexion(DateTime? sincronizadoEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: Colors.orange.withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sincronizadoEn != null
                  ? 'Sin conexión — mostrando datos de ${_formatFechaHora(sincronizadoEn)}'
                  : 'Sin conexión — mostrando la última copia guardada',
              style: const TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirFormulario() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AbastecimientoDieselFormScreen()),
    );
    if (resultado == true) {
      _cargar();
      _cargarBorradores();
    }
  }

  void _mostrarDetalle(AbastecimientoDieselListaItem item, {bool anulado = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AbastecimientoDieselDetalleModal(item: item, empresaId: _empresaId, anulado: anulado),
    );
  }

  void _mostrarDetalleBorrador(BorradorDiesel borrador) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BorradorDieselDetalleModal(borrador: borrador, unidadMedida: _kUnidadMedidaDiesel),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64 + 46),
          child: Column(
            children: [
              Padding(
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
                      hintText: 'Buscar por unidad, chofer, N° parte...',
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
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  _tabConContador('Mis salidas', _items.length, Colors.white24),
                  _tabConContador('Borradores', _borradores.length, Colors.orange),
                  _tabConContador('Anulados', _itemsAnulados.length, Colors.red.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              if (puedeConsultar) ...[
                _buildSelectorMes(
                  mes: _mesSeleccionado,
                  esMesActual: _esMesActual,
                  onAnterior: () => _cambiarMes(-1),
                  onSiguiente: () => _cambiarMes(1),
                  onTap: () => _abrirSelectorMes(
                    actual: _mesSeleccionado,
                    onSeleccionar: (elegido) {
                      setState(() => _mesSeleccionado = elegido);
                      _cargar();
                    },
                  ),
                ),
                if (_esDatoCacheado && _sincronizadoEn != null && !_isLoading) _buildBannerSinConexion(_sincronizadoEn),
              ],
              Expanded(
                child: !puedeConsultar
                    ? _buildSinAccesoConsulta()
                    : _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? _buildErrorView(_error, _cargar)
                            : _buildListView(
                                _itemsFiltrados,
                                _items,
                                puedeRegistrar,
                                onRefresh: _cargar,
                                mensajeVacio: 'Sin registros este mes',
                                sinConexionSinDatos: _esDatoCacheado && _sincronizadoEn == null,
                              ),
              ),
            ],
          ),
          _buildBorradoresView(puedeRegistrar),
          Column(
            children: [
              if (puedeConsultar) ...[
                _buildSelectorMes(
                  mes: _mesSeleccionadoAnulados,
                  esMesActual: _esMesActualAnulados,
                  onAnterior: () => _cambiarMesAnulados(-1),
                  onSiguiente: () => _cambiarMesAnulados(1),
                  onTap: () => _abrirSelectorMes(
                    actual: _mesSeleccionadoAnulados,
                    onSeleccionar: (elegido) {
                      setState(() => _mesSeleccionadoAnulados = elegido);
                      _cargarAnulados();
                    },
                  ),
                ),
                if (_esDatoCacheadoAnulados && _sincronizadoEnAnulados != null && !_isLoadingAnulados)
                  _buildBannerSinConexion(_sincronizadoEnAnulados),
              ],
              Expanded(
                child: !puedeConsultar
                    ? _buildSinAccesoConsulta()
                    : _isLoadingAnulados
                        ? const Center(child: CircularProgressIndicator())
                        : _errorAnulados != null
                            ? _buildErrorView(_errorAnulados, _cargarAnulados)
                            : _buildListView(
                                _itemsAnuladosFiltrados,
                                _itemsAnulados,
                                puedeRegistrar,
                                onRefresh: _cargarAnulados,
                                mensajeVacio: 'Sin partes anulados este mes',
                                anulado: true,
                                sinConexionSinDatos: _esDatoCacheadoAnulados && _sincronizadoEnAnulados == null,
                              ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildErrorView(String? mensaje, Future<void> Function() onReintentar) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(mensaje ?? 'Error desconocido', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildListView(
    List<AbastecimientoDieselListaItem> itemsFiltrados,
    List<AbastecimientoDieselListaItem> itemsSinFiltrar,
    bool puedeRegistrar, {
    required Future<void> Function() onRefresh,
    String mensajeVacio = 'Sin registros de abastecimiento',
    bool anulado = false,
    // true cuando lo que se está mostrando es la copia local y ESTE mes en
    // particular nunca se sincronizó con éxito (a diferencia de "el mes
    // genuinamente no tiene registros") — para no confundir "no hay nada"
    // con "no se pudo descargar todavía".
    bool sinConexionSinDatos = false,
  }) {
    if (itemsFiltrados.isEmpty) {
      final vacioPorFaltaDeDescarga = itemsSinFiltrar.isEmpty && sinConexionSinDatos;
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      vacioPorFaltaDeDescarga ? Icons.cloud_off : Icons.local_gas_station_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vacioPorFaltaDeDescarga
                          ? 'Sin conexión — no tienes este mes descargado'
                          : (itemsSinFiltrar.isEmpty ? mensajeVacio : 'No se encontraron resultados'),
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (vacioPorFaltaDeDescarga)
                      Text(
                        'Conéctate para descargar los datos de este mes',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      )
                    else if (puedeRegistrar && itemsSinFiltrar.isEmpty)
                      Text(
                        'Usa el botón + para registrar uno nuevo',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
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
      onRefresh: onRefresh,
      color: Color(AppColors.primaryColor),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: paddingInferior),
        itemCount: itemsFiltrados.length,
        itemBuilder: (context, index) {
          final item = itemsFiltrados[index];
          return AbastecimientoDieselCard(
            item: item,
            anulado: anulado,
            onTap: () => _mostrarDetalle(item, anulado: anulado),
          );
        },
      ),
    );
  }

  Widget _buildBorradoresView(bool puedeRegistrar) {
    if (_cargandoBorradores) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_borradores.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargarBorradores,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.drafts_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Sin borradores pendientes', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text(
                      'Si registras sin conexión, aparecerá aquí',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final paddingInferior = 8.0 + MediaQuery.of(context).padding.bottom + (puedeRegistrar ? 72.0 : 0.0);

    return RefreshIndicator(
      onRefresh: _cargarBorradores,
      color: Color(AppColors.primaryColor),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: paddingInferior),
        itemCount: _borradores.length,
        itemBuilder: (context, index) {
          final borrador = _borradores[index];
          return BorradorDieselCard(
            borrador: borrador,
            unidadMedida: _kUnidadMedidaDiesel,
            reintentando: borrador.id != null && _reintentandoIds.contains(borrador.id),
            onReintentar: () => _reintentarBorrador(borrador),
            onEliminar: () => _eliminarBorrador(borrador),
            onTap: () => _mostrarDetalleBorrador(borrador),
          );
        },
      ),
    );
  }
}

// Selector de mes/año en forma de grilla (patrón clásico de "elegir mes" —
// como el de la mayoría de apps bancarias para ver estados de cuenta por
// mes). Se separa del State principal porque necesita su propio año en
// pantalla (independiente del mes ya elegido), navegable con flechas.
class _SelectorMesDialog extends StatefulWidget {
  final DateTime mesActual;

  const _SelectorMesDialog({required this.mesActual});

  @override
  State<_SelectorMesDialog> createState() => _SelectorMesDialogState();
}

class _SelectorMesDialogState extends State<_SelectorMesDialog> {
  late int _anioMostrado = widget.mesActual.year;

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final primario = Color(AppColors.primaryColor);
    final anioEsFuturo = _anioMostrado >= ahora.year;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _anioMostrado--),
                  tooltip: 'Año anterior',
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    '$_anioMostrado',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: anioEsFuturo ? Colors.grey[300] : null,
                  onPressed: anioEsFuturo ? null : () => setState(() => _anioMostrado++),
                  tooltip: 'Año siguiente',
                ),
              ],
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.6,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              children: List.generate(12, (i) {
                final mesNumero = i + 1;
                final esFuturo = _anioMostrado > ahora.year || (_anioMostrado == ahora.year && mesNumero > ahora.month);
                final esSeleccionado = _anioMostrado == widget.mesActual.year && mesNumero == widget.mesActual.month;

                return Material(
                  color: esSeleccionado ? primario : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: esFuturo ? null : () => Navigator.pop(context, DateTime(_anioMostrado, mesNumero, 1)),
                    child: Center(
                      child: Text(
                        _kNombresMesAbrev[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: esSeleccionado ? FontWeight.w700 : FontWeight.w500,
                          color: esSeleccionado ? Colors.white : (esFuturo ? Colors.grey[400] : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
