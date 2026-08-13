import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// La foto que entrega la cámara (vía image_picker) queda en una carpeta de
// CACHÉ de la app — Android puede borrarla sola cuando el celular anda corto
// de espacio, sin avisar. Para un borrador que puede quedar pendiente varios
// días (justo el escenario de "sin señal" que estamos resolviendo), eso es
// un riesgo real: se perdería la evidencia de un diesel que ya se entregó.
//
// Por eso, al crear un borrador, la foto se copia a una carpeta PROPIA y
// permanente de la app (fuera del caché) — y se borra esa copia recién
// cuando el borrador se envía con éxito o se elimina explícitamente.
//
// La misma clase también guarda una copia de las fotos ya DESCARGADAS de
// partes que ya se registraron (pestañas "Mis salidas"/"Anulados") — antes
// solo vivían en memoria mientras la app seguía abierta, así que verlas de
// nuevo sin conexión (ej. varios días después) fallaba siempre. Es una
// carpeta aparte porque el ciclo de vida es distinto: estas fotos nunca se
// borran solas (una foto de evidencia ya registrada no cambia).
class FotoEvidenciaStorage {
  static const _carpetaBorradores = 'borradores_diesel';
  static const _carpetaHistorial = 'fotos_historial_diesel';

  Future<String> guardarCopiaPermanente(File origen) async {
    final directorio = await _directorio(_carpetaBorradores);

    final extension = p.extension(origen.path);
    final nombreUnico = '${DateTime.now().microsecondsSinceEpoch}$extension';
    final destino = p.join(directorio.path, nombreUnico);

    final copia = await origen.copy(destino);
    return copia.path;
  }

  Future<void> eliminarCopia(String path) async {
    try {
      final archivo = File(path);
      if (await archivo.exists()) {
        await archivo.delete();
      }
    } catch (_) {
      // No relanzar: limpiar un archivo que ya no importa no debe romper
      // el flujo (borrado del borrador, envío exitoso, etc.).
    }
  }

  Future<Directory> _directorio(String carpeta) async {
    final directorioBase = await getApplicationDocumentsDirectory();
    final directorio = Directory(p.join(directorioBase.path, carpeta));
    if (!await directorio.exists()) {
      await directorio.create(recursive: true);
    }
    return directorio;
  }

  Future<Uint8List?> leerFotoHistorial({required String empresaId, required int salMatCabId}) async {
    final directorio = await _directorio(_carpetaHistorial);
    final archivo = File(p.join(directorio.path, '$empresaId-$salMatCabId.jpg'));
    if (!await archivo.exists()) return null;
    try {
      return await archivo.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarFotoHistorial({
    required String empresaId,
    required int salMatCabId,
    required Uint8List bytes,
  }) async {
    try {
      final directorio = await _directorio(_carpetaHistorial);
      final archivo = File(p.join(directorio.path, '$empresaId-$salMatCabId.jpg'));
      await archivo.writeAsBytes(bytes);
    } catch (_) {
      // Si no se pudo persistir (ej. sin espacio), no es grave — la próxima
      // vez que haya conexión se vuelve a descargar. No debe romper la
      // visualización de la foto que sí se acaba de traer del servidor.
    }
  }
}
