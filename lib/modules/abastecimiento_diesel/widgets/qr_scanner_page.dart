import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _detectado = false;

  void _onDetect(BarcodeCapture capture) {
    if (_detectado || capture.barcodes.isEmpty) return;

    final valor = capture.barcodes.first.rawValue;
    if (valor == null || valor.trim().isEmpty) return;

    _detectado = true;
    Navigator.pop(context, valor.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear código QR'),
      ),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}
