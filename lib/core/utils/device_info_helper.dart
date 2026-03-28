import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  /// Retorna un identificador legible del dispositivo.
  /// Android → modelo (ej. "Pixel 6", "SM-A546B")
  /// iOS     → nombre asignado por el usuario (ej. "iPhone de Juan")
  /// Web     → navegador/plataforma
  /// Otros   → "MOBILE"
  static Future<String> getNombreDispositivo() async {
    try {
      if (kIsWeb) {
        final info = await _plugin.webBrowserInfo;
        final browser = info.browserName.name.toUpperCase();
        return 'WEB-$browser';
      }

      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        // brand + model, ej. "SAMSUNG SM-A546B" o "Google Pixel 6"
        final brand = info.brand.toUpperCase();
        final model = info.model.toUpperCase();
        return '$brand $model';
      }

      if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        // nombre asignado por el usuario al iPhone/iPad
        return info.name;
      }

      if (Platform.isWindows) {
        final info = await _plugin.windowsInfo;
        return info.computerName;
      }

      if (Platform.isMacOS) {
        final info = await _plugin.macOsInfo;
        return info.computerName;
      }

      return 'MOBILE';
    } catch (_) {
      return 'MOBILE';
    }
  }
}
