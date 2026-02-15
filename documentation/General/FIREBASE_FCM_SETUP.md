# Guía de Configuración Firebase Cloud Messaging (FCM)

## Estado Actual
El código Flutter para notificaciones push está **preparado pero deshabilitado** hasta que se configure el proyecto Firebase.

## Pasos para Activar FCM

### 1. Crear Proyecto Firebase
1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Crear proyecto nuevo o usar existente
3. Registrar app Android con package: `com.andahuasi.sigerp_flutter`
4. Descargar `google-services.json`
5. Colocar en `android/app/google-services.json`

### 2. Descomentar Dependencias en `pubspec.yaml`
```yaml
# Cambiar de:
# firebase_core: ^3.10.0
# firebase_messaging: ^15.2.10
# flutter_local_notifications: ^19.5.0

# A:
firebase_core: ^3.10.0
firebase_messaging: ^15.2.10
flutter_local_notifications: ^19.5.0
```
Luego ejecutar: `flutter pub get`

### 3. Descomentar Plugin en Gradle

**`android/settings.gradle.kts`:**
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

**`android/app/build.gradle.kts`:**
```kotlin
id("com.google.gms.google-services")
```

### 4. Descomentar Código en `lib/main.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';

// Y en main():
await Firebase.initializeApp();
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
final notificationService = NotificationService();
await notificationService.initialize();
```

### 5. Descomentar en `lib/app.dart`
```dart
import 'core/services/notification_service.dart';

// Y en build():
NotificationService.navigatorKey = navigatorKey;
```

### 6. Implementar en Backend
- Endpoint para registrar token FCM del dispositivo
- Lógica para enviar notificaciones cuando hay documentos pendientes
- Payload de notificación con estructura:
```json
{
  "tipo": "PE",         // PE = Presupuesto Emergencia, SC = Solicitud Compra
  "id": "12345",        // ID del documento
  "accion": "autorizar" // Acción sugerida
}
```

## Archivos Involucrados
| Archivo | Estado |
|---------|--------|
| `lib/core/services/notification_service.dart` | ✅ Listo |
| `lib/main.dart` | ⏸️ Comentado |
| `lib/app.dart` | ⏸️ Comentado (navigatorKey listo) |
| `pubspec.yaml` | ⏸️ Deps comentadas |
| `android/settings.gradle.kts` | ⏸️ Plugin comentado |
| `android/app/build.gradle.kts` | ⏸️ Plugin comentado |
| `android/app/google-services.json` | ❌ Falta descargar de Firebase |
