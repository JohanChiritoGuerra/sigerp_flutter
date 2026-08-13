import 'package:connectivity_plus/connectivity_plus.dart';

// Detección de conectividad para el modo offline. connectivity_plus solo
// confirma que hay una interfaz de red activa (wifi/datos), no que haya
// internet real de punta a punta — es una aproximación aceptada a propósito:
// la validación real de "¿llegó al servidor?" ocurre en cada petición HTTP,
// esto solo evita intentarlo cuando es obvio que no hay red.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  Future<bool> isOnline() async {
    final resultados = await _connectivity.checkConnectivity();
    return resultados.any((r) => r != ConnectivityResult.none);
  }

  // Transiciones online/offline (sin duplicados consecutivos) — se usa para
  // avisar cuando la conexión vuelve mientras la pantalla de Diesel está
  // abierta, y así ofrecer enviar los borradores pendientes.
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((resultados) => resultados.any((r) => r != ConnectivityResult.none))
      .distinct();
}
