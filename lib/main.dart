import 'package:flutter/material.dart';
import 'app.dart';
import 'core/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar el entorno
  // Development y Production usan la misma API: api.andahuasi.pe
  AppConfig.setEnvironment(Environment.development);
  
  runApp(const SigerpApp());
}