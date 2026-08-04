# SIGERP Mobile — Documentación Técnica General

> Propósito: Documentar el funcionamiento de la app Flutter para coordinar la implementación de endpoints en el API (ASP.NET Core), incluyendo el registro de tokens FCM para notificaciones push.

---

## 1. Visión General

La aplicación móvil **SIGERP** consume una API REST en ASP.NET Core. Está construida en Flutter con los siguientes pilares:

| Aspecto | Detalle |
|---|---|
| Framework | Flutter (Dart) |
| Gestión de estado | Provider (`ChangeNotifier`) |
| Almacenamiento seguro | `flutter_secure_storage` |
| HTTP | Cliente propio `ApiService` (Singleton) |
| Autenticación | JWT Bearer Token |
| Dispositivo | `device_info_plus` (nombre del equipo para auditoría) |
| Notificaciones | Firebase Cloud Messaging + `flutter_local_notifications` (**activo**) |

---

## 2. Entornos y URL Base

```dart
// Entorno activo: Environment.development
```

| Entorno | URL (desde móvil) |
|---|---|
| `development` | `https://192.168.100.101:7255/` |
| `staging` | `https://staging.apitrab.andahuasi.com/` |
| `production` | `https://apitrab.andahuasi.com/` |

> La URL base se configura una sola vez en `main.dart` y la usa el `ApiService` para todas las peticiones.

---

## 3. Flujo de Autenticación (Login)

### 3.1 Pantalla de Login

El usuario ingresa tres datos:
- **Usuario** (`usuaId` — identificador de usuario web)
- **Contraseña**
- **Empresa** (default: `"02"`)

### 3.2 Llamada al API

```
POST api/LoginSigerp
Content-Type: application/json
```

**Request body:**
```json
{
  "usuario": "JPEREZ",
  "password": "****",
  "empresaId": "02"
}
```

**Response body esperado:**
```json
{
  "baseResponse": {
    "success": true,
    "message": "Login exitoso"
  },
  "usuaId": "JPEREZ",
  "apellidoPaterno": "Pérez",
  "apellidoMaterno": "García",
  "nombres": "Juan Carlos",
  "dNI": "12345678",
  "direccion": "Av. Principal 123",
  "parametros": "",
  "trabId": "TRAB001",
  "empresaId": "02",
  "contLabFecInicio": "2022-01-01T00:00:00",
  "contLabFecFin": null,
  "estado": 1,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

> **NOTA IMPORTANTE para el API:** El campo `usuaId` del response es el que la app usa como identificador de usuario en TODAS las llamadas posteriores (se guarda internamente como `webUser`). No confundir con `trabId`.

### 3.3 Flujo post-login

```
LoginSigerp exitoso
    → setToken(jwt)  [ApiService Singleton — incluye token en headers de todas las peticiones]
    → POST api/PerfilTrabajador/ObtenerPerfilTrabajador  [carga datos del trabajador]
    → _saveUserData()  [persiste en FlutterSecureStorage]
    → NotificationService.configurarUsuario(webUser, empresaId)
        → POST api/Notificaciones/RegistrarToken  [registra el FCM token del dispositivo]
    → navegar a HomeScreen
```

> El mismo flujo de registro de token ocurre en `checkSavedSession()` (cuando el usuario ya tenía sesión guardada y reabre la app).

### 3.4 Llamada al perfil del trabajador

```
POST api/PerfilTrabajador/ObtenerPerfilTrabajador
Authorization: Bearer {token}
Content-Type: application/json
```

**Request body:**
```json
{
  "trabId": "TRAB001",
  "empresaId": "02"
}
```

---

## 4. Almacenamiento de Sesión

La app usa `FlutterSecureStorage` (almacenamiento cifrado del dispositivo). Las claves utilizadas son:

| Clave | Contenido | Cuándo se escribe |
|---|---|---|
| `auth_token` | JWT token (String) | Al hacer login exitoso |
| `user_data` | JSON del objeto `Usuario` | Al hacer login exitoso |
| `refresh_token` | Refresh token | Reservado (no usado aún) |
| `permissions_data` | Permisos | Reservado (no usado aún) |

### Objeto `Usuario` almacenado (JSON):

```json
{
  "webUser": "JPEREZ",
  "usuaId": "JPEREZ",
  "apellidoPaterno": "Pérez",
  "apellidoMaterno": "García",
  "nombres": "Juan Carlos",
  "dni": "12345678",
  "direccion": "Av. Principal 123",
  "parametros": "",
  "trabId": "TRAB001",
  "empresaId": "02",
  "contLabFecInicio": "2022-01-01T00:00:00.000",
  "contLabFecFin": null,
  "estado": 1,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

> **`webUser` = `usuaId`** — Este valor es el identificador que se envía al API en todas las acciones (autorizar, observar, filtros de grilla, etc.).

### Restauración de sesión al abrir la app:

```
SplashScreen.initState()
    → AuthService.checkSavedSession()
        → leer 'user_data' de storage
        → reconstruir Usuario
        → setToken(jwt)
        → obtenerPerfilTrabajador()
        → ir a HomeScreen (si exitoso) o LoginScreen (si falla)
```

---

## 5. Modelo de Datos: `Usuario`

| Campo Flutter | Tipo | Origen (login response) | Uso en el API |
|---|---|---|---|
| `webUser` | `String?` | mapeado desde `usuaId` | Identificador principal del usuario en todas las peticiones |
| `usuaId` | `String?` | `usuaId` | Igual a `webUser` |
| `trabId` | `String?` | `trabId` | Solo para `ObtenerPerfilTrabajador` |
| `empresaId` | `String?` | `empresaId` | Se envía en cada operación |
| `token` | `String?` | `token` | JWT — Bearer en cada header |
| `apellidoPaterno` | `String?` | `apellidoPaterno` | Visualización |
| `apellidoMaterno` | `String?` | `apellidoMaterno` | Visualización |
| `nombres` | `String?` | `nombres` | Visualización |
| `dni` | `String?` | `dNI` | Visualización |
| `estado` | `int` | `estado` | 1=activo, 0=inactivo |

---

## 6. Endpoints Implementados en Flutter

### 6.1 Autenticación

| Endpoint | Método | Descripción |
|---|---|---|
| `api/LoginSigerp` | POST | Login principal |
| `api/PerfilTrabajador/ObtenerPerfilTrabajador` | POST | Datos del trabajador post-login |
| `api/Auth/refresh-token` | POST | Renovar token (implementado, pendiente de activar fully) |

### 6.2 Presupuesto de Emergencia (PE)

| Endpoint | Método | Params |
|---|---|---|
| `api/presupuesto-emergencia/grillas/autorizacion` | GET | `usuario, empresaId` |
| `api/presupuesto-emergencia-consulta/grillas/consulta` | GET | `usuario, empresaId` |
| `api/presupuesto-emergencia/{id}/detalle` | GET | `idSubtipo, usuario, empresaId` |
| `api/presupuesto-emergencia-consulta/{id}/detalle` | GET | `idSubtipo, usuario, empresaId` |
| `api/presupuesto-emergencia/autorizar` | POST | Body JSON |
| `api/presupuesto-emergencia/observar` | POST | Body JSON |

**Body autorizar PE:**
```json
{
  "idPresupuestoEmergencia": 123,
  "usuario": "JPEREZ",
  "empresaId": "02",
  "observacion": "",
  "nombrePc": "Samsung Galaxy S22",
  "ip": "0.0.0.0"
}
```

**Body observar PE:**
```json
{
  "idPresupuestoEmergencia": 123,
  "observacion": "Falta documentación de respaldo",
  "usuario": "JPEREZ",
  "empresaId": "02",
  "nombrePc": "Samsung Galaxy S22",
  "ip": "0.0.0.0"
}
```

### 6.3 Solicitud de Compra (SC)

| Endpoint | Método | Params |
|---|---|---|
| `api/solicitud-compra/grillas/autorizacion` | GET | `usuario, empresaId` |
| `api/solicitud-compra-consulta/grillas/consulta` | GET | `usuario, empresaId` |
| `api/solicitud-compra/{solComCabId}/detalle` | GET | `tipOpeCompId, usuario, empresaId` |
| `api/solicitud-compra-consulta/{solComCabId}/detalle` | GET | `tipOpeCompId, usuario, empresaId` |
| `api/solicitud-compra/autorizar` | POST | Body JSON |
| `api/solicitud-compra/observar` | POST | Body JSON |

**Body autorizar SC:**
```json
{
  "solComCabId": "SC-2024-001",
  "tipOpeCompId": 1,
  "usuario": "JPEREZ",
  "empresaId": "02",
  "nombrePc": "Samsung Galaxy S22",
  "ip": "0.0.0.0"
}
```

**Body observar SC:**
```json
{
  "solComCabId": "SC-2024-001",
  "tipOpeCompId": 1,
  "observacion": "Precio fuera de rango autorizado",
  "usuario": "JPEREZ",
  "empresaId": "02",
  "nombrePc": "Samsung Galaxy S22",
  "ip": "0.0.0.0"
}
```

---

## 7. Autenticación HTTP (ApiService)

El `ApiService` es un Singleton que:
1. Incluye automáticamente `Authorization: Bearer {token}` en cada petición
2. Al recibir un `401 Unauthorized`, intenta hacer refresh del token automáticamente (un solo reintento)
3. Si el refresh falla → hace logout y redirige al login

```
Petición HTTP
    → header: Authorization: Bearer {jwt}
    → Si 401 → POST api/Auth/refresh-token → nuevo token → reintenta
    → Si 401 de nuevo → logout() → LoginScreen
```

---

## 8. Firebase FCM — Estado Actual y Lo Que Se Necesita

### 8.1 Estado actual en Flutter

| Componente | Estado |
|---|---|
| `firebase_messaging` | ✅ Activo |
| `flutter_local_notifications` | ✅ Activo |
| `google-services.json` | ✅ Colocado en `android/app/` |
| `Firebase.initializeApp()` en `main.dart` | ✅ Activo |
| `NotificationService.initialize()` | ✅ Activo |
| `navigatorKey` en `MaterialApp` | ✅ Asignado a `NotificationService` |
| `onNotificationTapped` | ✅ Implementado — navega según `tipo` (`PE`/`SC`) |
| `_sendTokenToBackend()` | ✅ Llama a `POST api/Notificaciones/RegistrarToken` |
| Registro tras login | ✅ `AuthService.login()` llama a `configurarUsuario()` |
| Registro al reabrir app | ✅ `AuthService.checkSavedSession()` llama a `configurarUsuario()` |
| Limpieza en logout | ✅ `AuthService.logout()` llama a `limpiarUsuario()` |

### 8.2 Qué genera Firebase en el dispositivo

Cuando Firebase esté activo, al iniciar la app se generará automáticamente un **FCM Token** (también llamado *device token* o *registration token*). Este token es:
- **Único por dispositivo + app**
- **Caduca y se renueva** (Firebase notifica cuando cambia)
- Necesario para que el backend envíe push notifications a ese dispositivo específico

### 8.3 ¿Es necesario guardarlo en el backend? SÍ

Para enviar notificaciones push desde el API, el backend necesita:
1. Conocer el FCM token de cada dispositivo/usuario
2. Asociarlo al usuario (`webUser` / `usuaId`)
3. Llamar a `FirebaseAdmin.Messaging.SendAsync()` con ese token cuando ocurra un evento (nueva PE, nueva SC, etc.)

### 8.4 Endpoint requerido en el API — `RegistrarToken`

> ⚠️ **Este es el único endpoint que falta implementar en el backend para que las notificaciones funcionen end-to-end.**

```
POST api/Notificaciones/RegistrarToken
Authorization: Bearer {token}     ← JWT del usuario logueado
Content-Type: application/json
```

**Request body EXACTO que envía la app Flutter:**
```json
{
  "webUser": "JPEREZ",
  "empresaId": "02",
  "fcmToken": "dGhpcyBpcyBhIHNhbXBsZSB0b2tlbiBmb3IgZGVtb3...",
  "nombreDispositivo": "android",
  "plataforma": "android"
}
```

> Nota: `nombreDispositivo` actualmente envía `"android"` o `"iOS"` (literal). Si en el futuro se activa `device_info_plus` para este endpoint, se enviará el nombre real del equipo.

**Response body esperado por la app:**
```json
{
  "baseResponse": {
    "success": true,
    "message": "Token registrado correctamente"
  }
}
```

> La app **no falla ni lanza error** si este endpoint no existe aún — el error se captura en un `try/catch` silencioso con `debugPrint`. Las demás funciones (login, autorizar, observar) siguen funcionando con normalidad.

**Tabla sugerida en base de datos:**

```sql
CREATE TABLE NotificacionesTokens (
    Id          INT IDENTITY PRIMARY KEY,
    WebUser     VARCHAR(50)  NOT NULL,
    EmpresaId   VARCHAR(10)  NOT NULL,
    FcmToken    VARCHAR(500) NOT NULL,
    Dispositivo VARCHAR(200) NULL,
    Plataforma  VARCHAR(20)  NULL,     -- 'android' | 'ios'
    FechaRegistro DATETIME   NOT NULL DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL,
    Activo      BIT          NOT NULL DEFAULT 1
)
```

> Un usuario puede tener múltiples dispositivos. El token debe actualizarse (no duplicarse) cuando Firebase renueva el token del mismo dispositivo.

### 8.5 Cuándo envía el token la app Flutter (flujo real implementado)

Existen **tres momentos** en los que la app intenta registrar el token:

**1. Login exitoso:**
```
POST api/LoginSigerp  → ok
    → setToken(jwt)
    → POST api/PerfilTrabajador/ObtenerPerfilTrabajador
    → _saveUserData()
    → NotificationService.configurarUsuario(webUser, empresaId)
        → si ya tiene token FCM en caché → POST api/Notificaciones/RegistrarToken
        → si no tiene token aún         → solicita token a Firebase → POST api/Notificaciones/RegistrarToken
```

**2. Reapertura de app con sesión guardada (`checkSavedSession`):**
```
App abierta → leer user_data del storage → reconstruir Usuario
    → setToken(jwt)
    → POST api/PerfilTrabajador/ObtenerPerfilTrabajador
    → NotificationService.configurarUsuario(webUser, empresaId)
        → POST api/Notificaciones/RegistrarToken
```

**3. Renovación automática de token FCM (Firebase):**
```
Firebase renueva token
    → onTokenRefresh listener
    → POST api/Notificaciones/RegistrarToken  (con el nuevo token)
```

**Logout:**
```
AuthService.logout()
    → NotificationService.limpiarUsuario()  [borra webUser/empresaId en memoria local]
    → clearUserData()
```
> La app actualmente **no llama a un endpoint de eliminación de token** en el logout. Si se requiere invalidar el token en el backend al cerrar sesión, se debe implementar `POST api/Notificaciones/EliminarToken` y la app lo llamará.

### 8.6 Payload FCM esperado por la app (cuando el backend envíe push)

La app ya tiene lógica para manejar este payload:

```json
{
  "tipo": "PE",
  "id": "123",
  "accion": "autorizar"
}
```

| Campo | Valores | Acción en la app |
|---|---|---|
| `tipo` | `"PE"` | Navega a pantalla de autorización de Presupuesto de Emergencia |
| `tipo` | `"SC"` | Navega a pantalla de autorización de Solicitud de Compra |
| `id` | ID del documento | Se usa para abrir el detalle directamente |
| `accion` | `"autorizar"` | Contexto de la notificación |

### 8.7 Tres escenarios de recepción de notificaciones

| Escenario | Comportamiento actual (cuando se active) |
|---|---|
| **App en primer plano** | Muestra notificación local con `flutter_local_notifications` en canal `sigerp_high_importance` |
| **App en segundo plano** | El sistema Android muestra la notificación; al tocarla, la app recibe el payload y navega |
| **App cerrada** | Al tocar la notificación, la app arranca y procesa el mensaje inicial (`getInitialMessage`) |

---

## 9. Resumen de Campos Clave para el API

| Campo Flutter | Nombre en JSON | Descripción | Obligatorio |
|---|---|---|---|
| `usuario?.webUser` | `"usuario"` | Identificador del usuario (= `usuaId`) | Sí, en todas las operaciones |
| `empresaId` | `"empresaId"` | Código de empresa (ej: `"02"`) | Sí, en todas las operaciones |
| `DeviceInfoHelper.getNombreDispositivo()` | `"nombrePc"` | Nombre del dispositivo Android/iOS | Sí, en autorizar/observar |
| `"0.0.0.0"` | `"ip"` | IP del dispositivo (no disponible en mobile) | Sí, en autorizar/observar |

---

## 10. Checklist para Implementar FCM en el Backend

**Flutter — Completado ✅**
- [x] `google-services.json` colocado en `android/app/`
- [x] Plugin Gradle `com.google.gms.google-services` habilitado en `settings.gradle.kts` y `app/build.gradle.kts`
- [x] `Firebase.initializeApp()` activo en `main.dart`
- [x] `NotificationService.initialize()` activo en `main.dart`
- [x] `_sendTokenToBackend()` implementado → llama a `POST api/Notificaciones/RegistrarToken`
- [x] `NotificationService.configurarUsuario()` llamado tras login y checkSavedSession
- [x] `NotificationService.limpiarUsuario()` llamado en logout
- [x] Navegación por notificación implementada (`PE` → pantalla PE, `SC` → pantalla SC)

**Backend — Pendiente ❌**
- [ ] Crear tabla `NotificacionesTokens` en la BD (ver esquema en sección 8.4)
- [ ] Crear endpoint `POST api/Notificaciones/RegistrarToken` ← **prioridad máxima**
- [ ] Instalar `FirebaseAdmin` NuGet (`FirebaseAdmin` de Google)
- [ ] Configurar `FirebaseApp.Create()` con el archivo de Service Account de Firebase Console
- [ ] En el flujo de Autorizar/Observar (PE y SC), disparar notificación push al autorizador siguiente usando el payload `{tipo, id, accion}`
- [ ] Manejar tokens inválidos: si Firebase retorna `registration-token-not-registered`, marcar `Activo = 0` en la tabla
- [ ] (Opcional) Crear endpoint `POST api/Notificaciones/EliminarToken` para invalidar token al hacer logout

---

## 11. Estado Final de Firebase en Flutter

Todo el código Flutter de Firebase está **activo y funcionando**. No hay más pasos pendientes en el lado mobile.

| Archivo Flutter | Estado |
|---|---|
| `android/app/google-services.json` | ✅ Presente |
| `android/settings.gradle.kts` | ✅ Plugin `google-services 4.4.2` activo |
| `android/app/build.gradle.kts` | ✅ Plugin `google-services` aplicado |
| `lib/main.dart` | ✅ Firebase + NotificationService inicializados |
| `lib/app.dart` | ✅ `navigatorKey` y `onNotificationTapped` configurados |
| `lib/core/services/notification_service.dart` | ✅ `_sendTokenToBackend()` llama al API real |
| `lib/core/services/auth_service.dart` | ✅ Token se registra en login, checkSavedSession y se limpia en logout |

**El único paso restante es en el backend: implementar `POST api/Notificaciones/RegistrarToken`.**
