import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar el entorno
  // Development y Production usan la misma API: api.andahuasi.pe
  AppConfig.setEnvironment(Environment.development);

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const SigerpApp());
}