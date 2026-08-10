import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../models/centro_costo.dart';
import '../services/abastecimiento_diesel_service.dart';
import 'qr_scanner_page.dart';

class CentroCostoSearchField extends StatefulWidget {
  final String empresaId;
  final CentroCosto? value;
  final ValueChanged<CentroCosto?> onChanged;

  const CentroCostoSearchField({
    super.key,
    required this.empresaId,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CentroCostoSearchField> createState() => _CentroCostoSearchFieldState();
}

class _CentroCostoSearchFieldState extends State<CentroCostoSearchField> {
  final AbastecimientoDieselService _service = AbastecimientoDieselService();

  Future<void> _abrirBuscador() async {
    final seleccionado = await showModalBottomSheet<CentroCosto>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CentroCostoSearchSheet(
        empresaId: widget.empresaId,
        service: _service,
      ),
    );

    if (seleccionado != null) {
      widget.onChanged(seleccionado);
    }
  }

  Future<void> _escanear() async {
    final codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );

    if (codigo == null || codigo.trim().isEmpty || !mounted) return;

    final codigoLimpio = codigo.trim();
    final resultados = await _service.buscarCentroCosto(
      filtro: codigoLimpio,
      empresaId: widget.empresaId,
    );

    if (!mounted) return;

    final exacto = resultados.where((c) => c.centroCosto == codigoLimpio);

    if (exacto.isNotEmpty) {
      widget.onChanged(exacto.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el centro de costo "$codigoLimpio"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unidad (Centro de Costo)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _abrirBuscador,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            isEmpty: widget.value == null,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              hintText: 'Toca para buscar por código o descripción...',
              suffixIcon: IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Color(AppColors.primaryColor)),
                onPressed: _escanear,
                tooltip: 'Escanear QR',
              ),
            ),
            child: Tooltip(
              message: widget.value?.displayText ?? '',
              waitDuration: const Duration(milliseconds: 400),
              triggerMode: TooltipTriggerMode.longPress,
              child: Text(
                widget.value?.displayText ?? '',
                style: TextStyle(
                  color: widget.value != null ? Colors.black87 : Colors.grey[500],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CentroCostoSearchSheet extends StatefulWidget {
  final String empresaId;
  final AbastecimientoDieselService service;

  const _CentroCostoSearchSheet({required this.empresaId, required this.service});

  @override
  State<_CentroCostoSearchSheet> createState() => _CentroCostoSearchSheetState();
}

class _CentroCostoSearchSheetState extends State<_CentroCostoSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<CentroCosto> _resultados = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _buscar('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _buscar(value));
  }

  Future<void> _buscar(String filtro) async {
    setState(() => _isLoading = true);
    final resultados = await widget.service.buscarCentroCosto(
      filtro: filtro,
      empresaId: widget.empresaId,
    );
    if (!mounted) return;
    setState(() {
      _resultados = resultados;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por código o descripción...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                onChanged: _onChanged,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _resultados.isEmpty
                      ? Center(
                          child: Text('Sin resultados', style: TextStyle(color: Colors.grey[600])),
                        )
                      : ListView.separated(
                          itemCount: _resultados.length,
                          separatorBuilder: (_, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _resultados[index];
                            return ListTile(
                              title: Text(item.displayText, style: const TextStyle(fontSize: 14)),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
