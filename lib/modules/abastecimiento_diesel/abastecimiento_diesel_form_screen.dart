import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/constants.dart';
import 'models/centro_costo.dart';
import 'models/chofer.dart';
import 'models/item_almacen.dart';
import 'models/jefatura.dart';
import 'services/abastecimiento_diesel_repository.dart';
import 'services/abastecimiento_diesel_service.dart';
import 'widgets/centro_costo_search_field.dart';
import 'widgets/chofer_search_field.dart';
import 'widgets/evidencia_foto_picker.dart';

// Código fijo del ítem de almacén para Diesel: GrpAlmId(2) + ClsAlmId(3) + IteAlmId(3).
const String _kCodigoItemDiesel = '21030010';

// Kilometraje: 7 dígitos cubre hasta 9'999,999 km, más que suficiente para
// cualquier odómetro real y evita que el campo crezca sin límite.
const int _kMaxDigitosKilometraje = 7;

// Da formato de separador de miles (1,234.50) mientras el usuario escribe,
// preservando hasta 2 decimales. La posición del cursor se recalcula en
// base a cuántos caracteres quedan a su derecha (no se fija siempre al
// final), para que borrar/insertar en cualquier punto del número funcione.
class _MilesSeparadorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final sinComas = newValue.text.replaceAll(',', '');
    final match = RegExp(r'^(\d*)(\.(\d{0,2})?)?').firstMatch(sinComas);
    if (match == null) return oldValue;

    final intPart = match.group(1) ?? '';
    final tieneDecimal = sinComas.contains('.');
    final decPart = match.group(3);

    var nuevoTexto = _agregarSeparadorMiles(intPart);
    if (tieneDecimal) {
      nuevoTexto += '.';
      if (decPart != null) nuevoTexto += decPart;
    }

    final caracteresDesdeElFinal = newValue.text.length - newValue.selection.end;
    final nuevaPosicion = (nuevoTexto.length - caracteresDesdeElFinal).clamp(0, nuevoTexto.length);

    return TextEditingValue(
      text: nuevoTexto,
      selection: TextSelection.collapsed(offset: nuevaPosicion),
    );
  }

  String _agregarSeparadorMiles(String digitos) {
    if (digitos.length <= 3) return digitos;
    final buffer = StringBuffer();
    final offset = digitos.length % 3;
    for (var i = 0; i < digitos.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write(',');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }
}

// Bloquea (rechaza el keystroke) cualquier valor que supere el máximo
// permitido, reforzando de forma "dura" el mensaje de error mostrado debajo
// del campo — similar a como un spinner numérico clampa su valor máximo.
class _MaxValorFormatter extends TextInputFormatter {
  final double maxValor;

  _MaxValorFormatter(this.maxValor);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final valor = double.tryParse(newValue.text.replaceAll(',', ''));
    if (valor != null && valor > maxValor) return oldValue;
    return newValue;
  }
}

class AbastecimientoDieselFormScreen extends StatefulWidget {
  const AbastecimientoDieselFormScreen({super.key});

  @override
  State<AbastecimientoDieselFormScreen> createState() => _AbastecimientoDieselFormScreenState();
}

class _AbastecimientoDieselFormScreenState extends State<AbastecimientoDieselFormScreen> {
  final AbastecimientoDieselService _service = AbastecimientoDieselService();
  final AbastecimientoDieselRepository _repository = AbastecimientoDieselRepository();

  // Perú no usa horario de verano: UTC-5 todo el año. Se calcula desde UTC
  // en vez de usar la hora local del dispositivo, porque esta puede venir
  // mal configurada (ej. equipos con zona horaria UTC en vez de America/Lima).
  final DateTime _fecha = DateTime.now().toUtc().subtract(const Duration(hours: 5));

  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController();

  CentroCosto? _centroCosto;
  Jefatura? _jefatura;
  bool _cargandoJefatura = false;
  Chofer? _chofer;
  File? _foto;

  ItemAlmacen? _item;
  bool _cargandoItem = true;

  double? _stock;
  bool _cargandoStock = true;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarItem();
      _cargarStock();
      // No se espera (fire-and-forget): si toca sincronizar (máx. 1 vez al
      // día) y hay señal, deja Centro de Costo y Jefatura al día para la
      // próxima vez que falte conexión. Con retraso: no le compite ancho de
      // banda a _cargarItem()/_cargarStock() de arriba ni a las búsquedas en
      // vivo que el usuario puede empezar a escribir de inmediato.
      final empresaId = context.read<AuthService>().usuario?.empresaId ?? '02';
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _repository.sincronizarCatalogosSiCorresponde(empresaId: empresaId);
      });
    });
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  Future<void> _cargarItem() async {
    final authService = context.read<AuthService>();
    final empresaId = authService.usuario?.empresaId ?? '02';

    final item = await _service.obtenerItemAlmacen(
      codigoItem: _kCodigoItemDiesel,
      empresaId: empresaId,
    );

    if (!mounted) return;
    setState(() {
      _item = item;
      _cargandoItem = false;
    });
  }

  Future<void> _cargarStock() async {
    final authService = context.read<AuthService>();
    final empresaId = authService.usuario?.empresaId ?? '02';

    final stock = await _service.obtenerStock(empresaId: empresaId);

    if (!mounted) return;
    setState(() {
      _stock = stock;
      _cargandoStock = false;
    });
  }

  String _formatFecha(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _onCentroCostoChanged(CentroCosto? centroCosto) async {
    setState(() {
      _centroCosto = centroCosto;
      _jefatura = null;
    });

    if (centroCosto == null) return;

    final authService = context.read<AuthService>();
    final empresaId = authService.usuario?.empresaId ?? '02';

    setState(() => _cargandoJefatura = true);

    final jefatura = await _repository.obtenerJefatura(
      gerenciaId: centroCosto.gerenciaId,
      dptoId: centroCosto.dptoId,
      seccId: centroCosto.seccId,
      empresaId: empresaId,
    );

    if (!mounted) return;
    setState(() {
      _jefatura = jefatura;
      _cargandoJefatura = false;
    });
  }

  Widget _campoSoloLectura({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _campoNumerico({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? suffixText,
    String? helperText,
    String? errorText,
    bool permiteDecimales = false,
    List<TextInputFormatter>? inputFormatters,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
            if (trailing != null) ...[const Spacer(), trailing],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: permiteDecimales),
          inputFormatters: inputFormatters ??
              [
                permiteDecimales
                    ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                    : FilteringTextInputFormatter.digitsOnly,
              ],
          decoration: InputDecoration(
            hintText: hint,
            helperText: errorText == null ? helperText : null,
            errorText: errorText,
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
            suffixText: suffixText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  String _formatStock(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final entero = partes[0];
    final buffer = StringBuffer();
    final offset = entero.length % 3;
    for (var i = 0; i < entero.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return '${buffer.toString()}.${partes[1]}';
  }

  Widget _buildStockTrailing() {
    if (_cargandoStock) {
      return const SizedBox(
        height: 12,
        width: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_stock == null) return const SizedBox.shrink();
    return Text(
      'Stock: ${_formatStock(_stock!)}${_item?.unidadMedida.isNotEmpty == true ? ' ${_item!.unidadMedida}' : ''}',
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
    );
  }

  // Rango permitido: 1 a 10,000. Se valida en tiempo real, sin bloquear el
  // tipeo (más amigable que impedir caracteres mientras se escribe un decimal).
  String? _errorCantidad(String texto) {
    final limpio = texto.trim().replaceAll(',', '');
    if (limpio.isEmpty) return null;
    final valor = double.tryParse(limpio);
    if (valor == null || valor < 1) return 'La cantidad mínima es 1';
    if (valor > 10000) return 'La cantidad máxima es 10,000';
    return null;
  }

  bool get _puedeGuardar {
    if (_guardando) return false;
    // La Jefatura es solo informativa (el backend la vuelve a resolver a
    // partir del Centro de Costo, no se envía desde acá) — no se exige para
    // habilitar Guardar: podría no estar disponible sin conexión si esa
    // Unidad puntual no tiene jefatura asignada, o si el catálogo local
    // todavía no se sincronizó ni una vez.
    if (_centroCosto == null || _chofer == null || _foto == null) return false;
    if (_errorCantidad(_cantidadController.text) != null) return false;
    if (_cantidadController.text.trim().isEmpty) return false;
    if (_kilometrajeController.text.trim().isEmpty) return false;
    return true;
  }

  Future<void> _guardar() async {
    final authService = context.read<AuthService>();
    final empresaId = authService.usuario?.empresaId ?? '02';
    final usuaId = authService.usuario?.usuaId ?? '';

    final cantidad = double.tryParse(_cantidadController.text.replaceAll(',', ''));
    final kilometraje = int.tryParse(_kilometrajeController.text.replaceAll(',', ''));
    if (cantidad == null || kilometraje == null) return;

    setState(() => _guardando = true);

    final resultado = await _repository.registrar(
      usuaId: usuaId,
      empresaId: empresaId,
      centroCosto: _centroCosto!,
      chofer: _chofer!,
      cantidad: cantidad,
      kilometraje: kilometraje,
      foto: _foto!,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    switch (resultado.estado) {
      case RegistrarDieselEstado.exitoso:
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado.mensaje), backgroundColor: Colors.green),
        );
        break;
      case RegistrarDieselEstado.guardadoComoBorrador:
        // Se guardó localmente, no en el servidor — color distinto al de
        // éxito para que quede claro que aún falta enviarlo de verdad.
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado.mensaje), backgroundColor: Colors.orange, duration: const Duration(seconds: 5)),
        );
        break;
      case RegistrarDieselEstado.rechazado:
        // El servidor sí respondió y rechazó por una regla real. Único caso
        // especial: sin stock — es el único rechazo que puede resolverse
        // solo con el tiempo (llega combustible nuevo), así que se ofrece
        // guardarlo como borrador en vez de perder lo ya completado.
        if (resultado.puedeGuardarComoBorradorPorStock) {
          final guardarComoBorrador = await _mostrarDialogoStockInsuficiente(resultado.mensaje);
          if (guardarComoBorrador == true) {
            await _repository.guardarBorradorPorStock(
              usuaId: usuaId,
              empresaId: empresaId,
              centroCosto: _centroCosto!,
              chofer: _chofer!,
              cantidad: cantidad,
              kilometraje: kilometraje,
              foto: _foto!,
              idempotencyKey: resultado.idempotencyKey!,
              motivo: resultado.mensaje,
            );
            if (!mounted) return;
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Guardado como borrador. Se puede reintentar cuando haya stock disponible.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
            return;
          }
        }
        // Rechazo normal (o el usuario prefirió no guardarlo): se queda en
        // el formulario para que decida qué corregir.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado.mensaje), backgroundColor: Colors.red),
        );
        break;
    }
  }

  Future<bool?> _mostrarDialogoStockInsuficiente(String mensaje) {
    // El título ya dice "Sin stock disponible" — el "Stock insuficiente."
    // inicial del mensaje del backend queda redundante acá (sí se muestra
    // completo en la tarjeta/detalle del borrador, donde no hay título que
    // le dé ese contexto).
    final detalle = mensaje.replaceFirst(RegExp(r'^Stock insuficiente\.?\s*'), '');
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sin stock disponible'),
        content: Text('$detalle\n\nPuedes guardar este registro como borrador y enviarlo más tarde, sin tener que completar el formulario de nuevo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Descartar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar como borrador'),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezadoItem() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Color(AppColors.primaryColor).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(AppColors.primaryColor).withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_gas_station, color: Color(AppColors.primaryColor)),
          const SizedBox(width: 10),
          Expanded(
            child: _cargandoItem
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _item?.descripcion.isNotEmpty == true
                        ? _item!.descripcion
                        : 'Abastecimiento de Diesel',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final empresaId = authService.usuario?.empresaId ?? '02';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Registrar Abastecimiento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEncabezadoItem(),
            const SizedBox(height: 20),

            const Text(
              'Fecha',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            _campoSoloLectura(
              icon: Icons.calendar_today_outlined,
              child: Text(_formatFecha(_fecha), style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 20),

            CentroCostoSearchField(
              empresaId: empresaId,
              value: _centroCosto,
              onChanged: _onCentroCostoChanged,
            ),
            const SizedBox(height: 20),

            const Text(
              'Jefatura',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            _campoSoloLectura(
              icon: Icons.person_outline,
              child: _cargandoJefatura
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _jefatura?.nombreCompleto ??
                          (_centroCosto == null
                              ? 'Selecciona un centro de costo'
                              : 'Sin jefatura asignada'),
                      style: TextStyle(
                        fontSize: 14,
                        color: _jefatura != null ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            ChoferSearchField(
              empresaId: empresaId,
              value: _chofer,
              onChanged: (chofer) => setState(() => _chofer = chofer),
            ),
            const SizedBox(height: 20),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _cantidadController,
              builder: (context, value, _) {
                return _campoNumerico(
                  label: 'Cantidad',
                  controller: _cantidadController,
                  icon: Icons.local_gas_station_outlined,
                  hint: '0.00',
                  suffixText: _item?.unidadMedida.isNotEmpty == true ? _item!.unidadMedida : null,
                  helperText: 'Cantidad mínima: 1',
                  errorText: _errorCantidad(value.text),
                  permiteDecimales: true,
                  trailing: _buildStockTrailing(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                    _MilesSeparadorFormatter(),
                    _MaxValorFormatter(10000),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            _campoNumerico(
              label: 'Kilometraje',
              controller: _kilometrajeController,
              icon: Icons.speed_outlined,
              hint: '0',
              suffixText: 'km',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_kMaxDigitosKilometraje),
                _MilesSeparadorFormatter(),
              ],
            ),
            const SizedBox(height: 20),

            EvidenciaFotoPicker(
              foto: _foto,
              onChanged: (foto) => setState(() => _foto = foto),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: AnimatedBuilder(
            animation: Listenable.merge([_cantidadController, _kilometrajeController]),
            builder: (context, _) {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _puedeGuardar ? _guardar : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryColor),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _guardando
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
