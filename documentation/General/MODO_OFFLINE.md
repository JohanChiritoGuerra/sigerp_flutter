# SIGERP Mobile — Modo Offline

> Propósito: Explicar, de punta a punta y para cualquier persona que se sume al proyecto, cómo funciona el modo offline de la app: sesión/login, accesos, catálogos, historial y el registro de operaciones sin conexión (borradores). El caso de uso concreto donde todo esto está implementado hoy es **Abastecimiento de Diesel**, pero el patrón está pensado para reutilizarse en otros módulos.

---

## 1. ¿Por qué offline?

Gran parte de los usuarios de esta app (choferes, jefaturas de campo) trabajan en zonas del campo/planta con señal intermitente o nula durante horas o días. La app no puede asumir que siempre hay conexión — tiene que:

1. Dejar entrar al usuario sin pedirle que vuelva a loguearse cada vez que no hay señal.
2. Mostrar accesos y catálogos (aunque sea una copia un poco vieja) en vez de pantallas en blanco.
3. Dejar que el usuario **registre operaciones igual**, guardándolas localmente para enviarlas después.

Todo el diseño gira en torno a una idea simple: **"mostrar algo, aunque no sea lo más fresco, es casi siempre mejor que no mostrar nada"** — excepto al momento de escribir datos de negocio (registrar un abastecimiento), donde nunca se inventa un resultado: si no hay confirmación real del servidor, queda como pendiente.

---

## 2. Detección de conectividad

Todo el sistema depende de una sola pieza: `ConnectivityService` (`lib/core/services/connectivity_service.dart`).

```dart
class ConnectivityService {
  Future<bool> isOnline();              // ¿hay una interfaz de red activa?
  Stream<bool> get onStatusChange;      // avisa cuando cambia online <-> offline
}
```

Importante: esto **no** garantiza que haya Internet real de punta a punta, solo que el teléfono tiene wifi o datos móviles activos (vía el paquete `connectivity_plus`). Es una aproximación intencional — sirve para decidir "¿intento llamar al API o voy directo a la copia local?", pero la confirmación real de que el servidor respondió ocurre en cada petición HTTP. Si `isOnline()` dice que sí pero el servidor no contesta, cada capa (login, catálogos, borradores) tiene su propio manejo de ese fallo tardío.

---

## 3. Sesión y Login

### 3.1 La sesión siempre se recuerda

Antes existía un checkbox "Recordarme". Se quitó: para un chofer que puede pasar días sin abrir la app o sin señal, la sesión **siempre** se guarda — no tiene sentido que dependa de que alguien haya marcado una casilla.

```dart
// AuthService.login(...)
Future<bool> login({
  required String usuario,
  required String password,
  required String empresaId,
  bool rememberMe = true,   // siempre true en la práctica
}) async { ... }
```

Al loguearse con éxito, `AuthService` guarda en `flutter_secure_storage` (almacenamiento cifrado del sistema operativo):

- El **token JWT** (`AppConstants.tokenKey`)
- El **refresh token** (`AppConstants.refreshTokenKey`)
- Los datos del usuario en JSON (`AppConstants.userKey`)

Al volver a abrir la app, `checkSavedSession()` lee esos tres valores y restaura la sesión sin pedir usuario/contraseña.

### 3.2 Duración de los tokens (backend)

| Token | Duración normal | Duración "recordarme" (la que se usa siempre en mobile) |
|---|---|---|
| JWT (access token) | 8 horas | **24 horas** |
| Refresh token | 8 horas | **60 días** |

El patrón está inspirado en apps de campo tipo Salesforce Field Service (30-90 días de refresh token) y en cómo Facebook renueva sesiones sin pedirle nada al usuario.

### 3.3 Renovación silenciosa (proactiva)

En vez de esperar a que el JWT expire y una petición falle con 401, la app intenta renovarlo **antes**, en dos momentos:

- Al **arrancar la app** (dentro de `checkSavedSession()`).
- Cada vez que la **app vuelve a primer plano** (`_AppLifecycleObserver` en `lib/app.dart`, evento `AppLifecycleState.resumed`).

```dart
// AuthService.refrescarSesion()
Future<void> refrescarSesion() async {
  if (_usuario == null) return;
  await _apiService.renovarTokenSiEsPosible();
}
```

Si no hay señal en ese momento, o el refresh token ya venció, esto simplemente no hace nada — no lanza errores, no interrumpe al usuario. Sigue existiendo el mecanismo **reactivo** como respaldo: si una petición cualquiera responde 401, `ApiService` intenta refrescar el token una vez y reintenta esa misma petición antes de rendirse (ver `_processResponse` en `api_service.dart`).

### 3.4 Logout (con invalidación remota "mejor esfuerzo")

Al cerrar sesión, la app intenta avisarle al servidor (`POST api/LoginSigerp/logout`) para invalidar la sesión en Redis — pero con un timeout corto (5s) y sin lanzar excepción si falla. El borrado **local** (secure storage) siempre ocurre, haya o no señal en ese momento:

```dart
Future<void> logout() async {
  await _apiService.invalidarSesionRemota(); // mejor esfuerzo, nunca bloquea
  // ...borra todo lo local sin importar el resultado de arriba...
}
```

---

## 4. Accesos (menú de permisos)

Los permisos (`puedeRegistrarDiesel`, `puedeConsultarDiesel`, etc.) vienen de `GET api/Menu/ObtenerMenuUsuarioMobile`, que se llama justo después del login y cada vez que la app vuelve a primer plano (`refrescarMenu()`), para reflejar accesos otorgados/revocados sin que el usuario tenga que volver a loguearse.

### 4.1 Copia local del menú

Igual que la sesión, el menú se cachea en `shared_preferences` (clave `menu_cache_<usuaId>`). Si el pedido al servidor falla (sin señal), se usa la última copia guardada:

```dart
Future<void> _cargarMenuMobile() async {
  try {
    final menuRemoto = await _menuService.obtenerMenuUsuarioMobile(...);
    if (menuRemoto.esExitoso) {
      _menu = menuRemoto;
      await _guardarMenuCache(menuRemoto);
      return;
    }
    await _cargarMenuDesdeCache();
  } catch (e) {
    await _cargarMenuDesdeCache();
  }
}
```

Esto es **solo un tema visual** (mostrar u ocultar botones/pestañas). No es una fuente de verdad de seguridad.

### 4.2 La validación real vive en el backend

`[Authorize]` en un controller de ASP.NET Core solo confirma que el JWT es válido — **no** que el usuario conserva ese acceso puntual en este momento (pudo habérsele revocado después de emitido el token). Por eso cada acción sensible (`Registrar`, `Listar`, `ListarAnulados` de Abastecimiento de Diesel) revalida el acceso específico contra `RolAcceso`/`UsuarioAcceso` en cada llamada, vía `IValidacionAccesoService.TieneAccesoMobile(usuaId, empresaId, accNombre)`:

```csharp
if (!await _validacionAccesoService.TieneAccesoMobile(usuaId, empresaId, AccesoRegistrar))
{
    return StatusCode(403, ...);
}
```

En resumen: **el menú cacheado decide qué se muestra; el backend decide qué se permite hacer.** Aunque la copia local del menú esté desactualizada (por ejemplo, mostrando un botón que ya no debería tener), la petición real al servidor la va a rechazar igual con 403.

---

## 5. Catálogos offline (Centro de Costo, Jefatura, Chofer)

El formulario de registro de Diesel necesita tres catálogos para autocompletar: **Centro de Costo** (unidad), **Jefatura** (se deriva de la unidad) y **Chofer**. Los tres se sincronizan como una "foto completa" (espejo total) en SQLite local, no como un caché parcial ni incremental.

### 5.1 Por qué espejo completo y no caché parcial

- **Centro de Costo**: ~379 filas. Trivial.
- **Jefatura**: no existía un SP que trajera "todas" — se agregó uno nuevo (`Usp_Get_TodasLasJefaturas_Flutter`) en vez de pedir la jefatura de cada Centro de Costo una por una (eso generaba cientos de llamadas simultáneas y tumbaba el servidor de pruebas la primera vez que se probó).
- **Chofer**: +9,000 trabajadores. Se evaluó un modelo híbrido (traer solo los primeros 1000 y acumular con las búsquedas en vivo) pero se descartó: el payload completo pesa apenas 1-2 MB, así que no vale la pena la complejidad de un caché parcial o de sincronización incremental. Se agregó un SP nuevo sin `TOP` (`Usp_Get_TodosLosTrabajadores_Flutter`).

### 5.2 Sincronización con límite de una vez al día

```dart
// AbastecimientoDieselRepository.sincronizarCatalogosSiCorresponde
Future<void> sincronizarCatalogosSiCorresponde({required String empresaId}) async {
  if (!await _connectivity.isOnline()) return;

  final ultimaSync = await _obtenerUltimaSincronizacionCatalogos(empresaId);
  final yaToca = ultimaSync == null || DateTime.now().difference(ultimaSync) > const Duration(hours: 24);
  if (!yaToca) return;

  // trae Centro de Costo + Jefatura + Chofer y reemplaza el espejo local completo
  // ...
  await _guardarUltimaSincronizacionCatalogos(empresaId, DateTime.now());
}
```

Estos catálogos casi no cambian de un día a otro, así que sincronizarlos en cada apertura del módulo sería gastar señal y batería para traer una y otra vez lo mismo. La marca de tiempo se guarda en `shared_preferences` (clave `diesel_catalogos_sync_<empresaId>`, compartida entre los tres catálogos) y se dispara "fire-and-forget" (sin bloquear la pantalla).

**No hace falta entrar al módulo para que se disparen.** `_AppLifecycleObserverState` (`lib/app.dart`) escucha los cambios de `AuthService` (login, sesión restaurada, refresco de menú) y llama a `sincronizarCatalogosSiCorresponde()` apenas hay una sesión activa con acceso a Diesel (`puedeRegistrarDiesel || puedeConsultarDiesel`) — así, con solo tener señal en el momento del login (que siempre la tiene, es requisito para loguearse), los catálogos quedan disponibles offline sin que el usuario tenga que visitar el módulo a propósito. Como la función ya se autolimita a una vez cada 24h, no importa que esto dispare varias veces por sesión (login, cada resume de la app, cada refresco de menú) — la inmensa mayoría de esas llamadas son no-ops instantáneos.

Se optó por poner este listener en `app.dart` y no dentro de `AuthService` para no mezclar responsabilidades: el core de sesión no necesita saber nada de Diesel. `app.dart` ya cumple el rol de "punto de conexión entre módulos" (ahí también vive el aviso global de reconexión de borradores, ver §7.7), así que es el lugar natural para esto.

### 5.3 Cómo se consultan

- **Centro de Costo** y **Chofer**: si hay conexión, la búsqueda se hace en vivo contra el API (más preciso y actualizado); si no hay conexión, cae a buscar en la copia local SQLite.
- **Jefatura**: siempre se lee de la copia local, haya o no conexión — no existe (ni debería existir) un endpoint de "jefatura puntual por Centro de Costo" llamado desde el celular; el catálogo completo ya se sincronizó aparte.

---

## 6. Historial ("Mis salidas" y "Anulados")

El listado de abastecimientos registrados por el usuario sigue un patrón **cache-then-network acotado por mes**: intenta traer del servidor el mes que se esté viendo y, si lo logra, guarda esa porción como copia local; si falla (o no hay conexión), muestra la copia local de ese mismo mes.

```dart
Future<ListaDieselResultado> listar({
  required String usuaId,
  required String empresaId,
  required int anio,
  required int mes,
}) async {
  if (await _connectivity.isOnline()) {
    try {
      final remoto = await _api.listar(empresaId: empresaId, anio: anio, mes: mes);
      await _local.reemplazarSalidasDelMes(empresaId: empresaId, usuaId: usuaId, anio: anio, mes: mes, lista: remoto);
      return ListaDieselResultado(items: remoto, esDatoCacheado: false, sincronizadoEn: DateTime.now());
    } catch (_) { /* cae al bloque de abajo */ }
  }
  final local = await _local.obtenerSalidasDelMesLocal(empresaId: empresaId, usuaId: usuaId, anio: anio, mes: mes);
  return ListaDieselResultado(items: local, esDatoCacheado: true, sincronizadoEn: ...);
}
```

Cuando la pantalla está mostrando datos de la copia local, aparece un aviso ("Sin conexión — mostrando datos de...") con la fecha/hora de la última sincronización exitosa **de ese mes**.

**Anulados** (partes con `SalMatCabAnu = 1`) usa exactamente el mismo patrón, pero como una lista completamente aparte: tabla local separada por un flag `anulado` (0/1), endpoint distinto (`ListarAnulados`) y su propia marca de tiempo de sincronización por mes — así nunca se mezcla con "Mis salidas" ni una sincronización pisa a la otra. Cada pestaña navega su propio mes de forma independiente.

La búsqueda en ambas pestañas filtra por unidad, chofer **y** por el número de parte (`numeroDocumento`, formato "Año-Correlativo", ej. `2026-022368`), siempre dentro del mes que se esté viendo.

### 6.1 Por qué por mes, y qué implica offline

Antes, `Listar`/`ListarAnulados` traían **todo** el historial del usuario, sin límite — un chofer con años de antigüedad terminaba descargando (y guardando localmente) miles de registros en cada sincronización, un payload que solo iba a crecer con el tiempo. Ahora el backend acota la consulta con un rango de fechas sargable (`SalMatCabFecEnt >= @Desde AND < @Hasta`, un mes calendario), y la pantalla reemplazó el antiguo filtro "Desde/Hasta" por un **selector de mes** (flechas ‹mes› + un diálogo de mes/año al tocar el nombre del mes) en cada pestaña.

La copia local dejó de ser un mirror completo y pasó a **acumular por mes**: `reemplazarSalidasDelMes` solo borra/reinserta la porción del mes consultado, dejando intactos los demás meses ya sincronizados antes — el mismo principio que el caché de fotos (§6.2): se guarda lo que el usuario realmente fue mirando, no todo "por si acaso".

Esto trae un matiz importante para el modo offline: **un mes solo está disponible sin conexión si se visitó alguna vez con conexión**. La pantalla distingue explícitamente dos casos de lista vacía:
- El mes genuinamente no tiene registros (`sincronizadoEn` no nulo, la sincronización sí llegó a completarse).
- El mes nunca se sincronizó y no hay conexión ahora (`sincronizadoEn` nulo) — se muestra "Sin conexión — no tienes este mes descargado" en vez del mensaje normal de "sin registros", para no confundir ambos casos.

### 6.2 Las fotos de partes ya registrados también quedan disponibles offline

La foto de evidencia de un parte se guarda en disco la primera vez que se descarga (`FotoEvidenciaStorage.guardarFotoHistorial`, carpeta aparte de la de los borradores) y desde ahí se lee directo, sin volver a preguntarle al servidor — una foto de evidencia ya registrada nunca cambia, así que no hace falta. `AbastecimientoDieselRepository.obtenerFoto()` es quien decide esto (disco primero, red solo si no está y hay conexión):

```dart
Future<Uint8List?> obtenerFoto({required int salMatCabId, required String empresaId}) async {
  final enDisco = await _fotoStorage.leerFotoHistorial(empresaId: empresaId, salMatCabId: salMatCabId);
  if (enDisco != null) return enDisco;
  if (!await _connectivity.isOnline()) return null;
  final bytes = await _api.obtenerFoto(salMatCabId: salMatCabId, empresaId: empresaId);
  if (bytes != null) await _fotoStorage.guardarFotoHistorial(empresaId: empresaId, salMatCabId: salMatCabId, bytes: bytes);
  return bytes;
}
```

El guardado es lazy (solo la foto que el usuario realmente abrió alguna vez), así el espacio usado crece con el uso real y no con el tamaño total del historial.

---

## 7. Registrar sin conexión: Borradores (patrón Outbox)

Esta es la pieza más delicada del modo offline: **qué pasa cuando el usuario intenta registrar un abastecimiento y no hay señal (o el servidor no responde a tiempo)**.

### 7.1 Idea general (estilo "borrador" de Gmail)

En vez de bloquear al usuario o perder lo que cargó, el intento de registro se guarda localmente como **borrador pendiente**, en una tabla SQLite que funciona como "bandeja de salida" (outbox). El usuario puede seguir usando la app, y más tarde — cuando vuelva la señal — reintenta el envío, manualmente.

**Reintento manual, no automático en segundo plano** — con una sola excepción: si la conexión vuelve mientras la pantalla de Diesel sigue abierta, aparece un aviso (SnackBar) no bloqueante ofreciendo enviar los pendientes con un botón. Nunca se reintenta solo, en silencio, sin que el usuario lo vea — la razón es que un reintento fallido silencioso (ej. porque cambió el stock, se cerró el mes, etc.) podría dejar al usuario pensando que ya está registrado cuando no lo está.

### 7.2 Los tres resultados posibles al registrar

```dart
enum RegistrarDieselEstado { exitoso, guardadoComoBorrador, rechazado }
```

| Resultado | Cuándo ocurre | Qué ve el usuario |
|---|---|---|
| `exitoso` | El servidor confirmó el registro | SnackBar verde |
| `guardadoComoBorrador` | No hay conexión, o la petición falló por un problema de red/timeout (no por una regla de negocio) | SnackBar naranja: "se guardó como borrador" |
| `rechazado` | El servidor respondió pero **rechazó** la operación (ej. sin stock, sin permiso, cerrado el periodo) | SnackBar rojo con el motivo exacto del backend |

La distinción entre "guardadoComoBorrador" y "rechazado" es clave: solo se guarda como borrador cuando la falla es de **conectividad** (timeout, DNS, sin red) — nunca cuando el propio servidor ya evaluó la operación y dijo que no. Eso evita que un borrador reintente indefinidamente algo que el negocio ya rechazó.

```dart
bool _esFalloDeConexion(String mensaje) {
  return mensaje.startsWith('Error de red') || mensaje.startsWith('Error de conexión');
}
```

### 7.3 Qué se guarda en un borrador

Tabla local `borrador_diesel`: centro de costo, chofer, cantidad, kilometraje, la ruta de la foto y un estado (`pendiente` / `error`, con motivo si aplica).

### 7.4 El problema de la foto y cómo se resolvió

La foto que entrega `image_picker` vive en un directorio de **caché** del sistema operativo — Android puede borrarla sola si el dispositivo necesita espacio, sobre todo en una ventana de varios días offline (justo el escenario típico de un borrador). Si eso pasara, el borrador quedaría con una foto rota e irrecuperable.

Solución: apenas se crea un borrador, la foto se copia a una carpeta **permanente** dentro del directorio de documentos de la app (`path_provider`, `ApplicationDocumentsDirectory/borradores_diesel/`), gestionada por `FotoEvidenciaStorage`. Esa copia se borra recién cuando el borrador se envía con éxito o el usuario lo elimina. Al reintentar, además, se valida que el archivo siga existiendo antes de reintentar el envío — si por alguna razón ya no está, el borrador pasa a estado de error explicando el motivo, en vez de fallar de forma confusa.

### 7.5 Reintento

```dart
Future<RegistrarDieselResultado> reintentarBorrador(BorradorDiesel borrador) async {
  // valida que la foto siga existiendo
  // si no hay conexión: sigue pendiente
  // si hay conexión: vuelve a correr TODAS las validaciones reales en el servidor
  //   (nunca se asume que sigue siendo válido solo porque lo era cuando se creó)
}
```

Importante: reintentar un borrador **no es** simplemente "confirmar lo que ya se guardó" — es volver a mandar la petición completa al backend, que revalida todo de nuevo (stock disponible, accesos, etc.) como si fuera la primera vez.

### 7.6 Clave de idempotencia: por qué reintentar no duplica el registro

Reenviar la petición completa en cada reintento (ver 7.5) trae un riesgo: si el intento anterior en realidad **sí** llegó a procesarse en el servidor, pero la confirmación nunca volvió al celular (ej. se cortó la señal justo después), un reintento ingenuo crearía un segundo Parte de Salida para el mismo evento real.

Para evitarlo, `AbastecimientoDieselRepository` genera una clave (`idempotencyKey`, 128 bits aleatorios) **una sola vez**, en el primer intento de cada registro — y la reutiliza en todos los reintentos de ese mismo borrador:

```dart
// registrar(): se genera UNA vez, antes de decidir si hay conexión o no
final idempotencyKey = _generarIdempotencyKey();
// ...se manda en la petición y, si cae a borrador, se guarda junto con él...

// reintentarBorrador(): reusa la MISMA clave guardada en el borrador
idempotencyKey: borrador.idempotencyKey,
```

El backend (`AbastecimientoDieselRepository.Registrar`, tabla `dbo.AbastecimientoDieselIdempotencia`) revisa esa clave al principio de la transacción: si ya la había visto antes, devuelve el mismo `SalMatCabId` sin insertar nada de nuevo — el cliente recibe un éxito normal, sin tener que saber que fue una repetición. Si es la primera vez, la registra dentro de la misma transacción del registro (si todo hace rollback, la clave queda libre para un reintento real).

### 7.7 Dónde se ve todo esto en la pantalla

`AbastecimientoDieselScreen` tiene 3 pestañas: **Mis salidas**, **Borradores** (con badge del total pendiente) y **Anulados** — las tres con su propio contador junto al nombre.

El aviso de reconexión con borradores pendientes existe en **dos niveles**:
- **Dentro de la pantalla de Diesel** (si está abierta en ese momento): banner inmediato con botón para enviar todos los pendientes de una vez.
- **A nivel de toda la app** (`_AppLifecycleObserverState` en `lib/app.dart`): un listener de conectividad separado, activo sin importar en qué pantalla esté el usuario, que muestra un SnackBar global (vía `scaffoldMessengerKey`) con un botón "Ver" que navega a la pestaña de Borradores. Una bandera simple (`dieselScreenAbierta`, en `abastecimiento_diesel_screen.dart`) evita que ambos avisos aparezcan duplicados cuando la pantalla ya está abierta.

---

## 8. Almacenamiento local: resumen de piezas

| Mecanismo | Para qué se usa | Dónde |
|---|---|---|
| `flutter_secure_storage` | Token JWT, refresh token, datos del usuario (cifrado) | `AuthService` |
| `shared_preferences` | Valores simples: caché del menú, marcas de tiempo de sincronización (catálogos, historial, anulados) | `AuthService`, `AbastecimientoDieselRepository` |
| SQLite (`sqflite`, con `sqflite_common_ffi` para pruebas de escritorio en Windows/Linux) | Datos tabulares: catálogos completos, historial de salidas (con y sin anular), borradores pendientes | `LocalDatabase` (`lib/core/services/local_database.dart`) |
| Carpeta de documentos de la app (`path_provider`) | Copias permanentes de fotos de evidencia mientras un borrador está pendiente, y copias en caché de las fotos ya descargadas de partes registrados | `FotoEvidenciaStorage` |

### 8.1 Tablas SQLite (`LocalDatabase`)

| Tabla | Contenido |
|---|---|
| `cache_salida_diesel` | Espejo de "Mis salidas" y "Anulados" (distinguidos por la columna `anulado`) |
| `cache_centro_costo` | Espejo completo del catálogo de Centro de Costo |
| `cache_jefatura` | Espejo completo del catálogo de Jefatura |
| `cache_chofer` | Espejo completo del catálogo de Chofer (+9,000 filas) |
| `borrador_diesel` | Outbox: registros pendientes de enviar, con su foto, estado y clave de idempotencia |

---

## 9. Capa que decide "¿online o local?": el Repository

Cada módulo con soporte offline tiene un `Repository` (ej. `AbastecimientoDieselRepository`) que es la única pieza que sabe si conviene usar la red o la copia local. Las pantallas y widgets **nunca** llaman directo a `ApiService` para datos con soporte offline — siempre pasan por el repository, así no tienen que preocuparse por conectividad, cachés, ni por si el resultado vino de SQLite o del servidor.

```
Pantalla / Widget
      │
      ▼
Repository   ← decide: ¿hay conexión? ¿toca resincronizar? ¿cae a lo local?
   │      │
   ▼      ▼
Service   LocalStore
(API)     (SQLite / shared_preferences)
```

---

## 10. Resumen de archivos clave (Flutter)

| Archivo | Responsabilidad |
|---|---|
| `lib/core/services/connectivity_service.dart` | Detecta si hay red activa |
| `lib/core/services/local_database.dart` | Esquema y apertura de la base SQLite local |
| `lib/core/services/auth_service.dart` | Login, sesión persistente, refresh de token, caché del menú, logout |
| `lib/core/services/api_service.dart` | Cliente HTTP, refresh reactivo/proactivo del token, invalidación remota |
| `lib/app.dart` | Dispara refresco de sesión/menú cuando la app vuelve a primer plano |
| `lib/modules/abastecimiento_diesel/services/abastecimiento_diesel_service.dart` | Llamadas puras al API (sin lógica de caché) |
| `lib/modules/abastecimiento_diesel/services/abastecimiento_diesel_local_store.dart` | Lectura/escritura de la copia local (SQLite) |
| `lib/modules/abastecimiento_diesel/services/abastecimiento_diesel_repository.dart` | Decide red vs. local, maneja borradores y sincronización de catálogos |
| `lib/modules/abastecimiento_diesel/services/foto_evidencia_storage.dart` | Copia permanente de fotos para borradores, y caché en disco de fotos ya descargadas de partes registrados |
| `lib/modules/abastecimiento_diesel/models/borrador_diesel.dart` | Modelo del borrador (outbox) |
| `lib/modules/abastecimiento_diesel/abastecimiento_diesel_screen.dart` | Pantalla con las 3 pestañas (Mis salidas / Borradores / Anulados) |
| `lib/modules/abastecimiento_diesel/abastecimiento_diesel_form_screen.dart` | Formulario de registro, dispara `registrar()` del repository |

## 11. Resumen de piezas clave (Backend, ASP.NET Core)

| Pieza | Responsabilidad |
|---|---|
| `LoginSigerpService` | Emite JWT + refresh token, duraciones extendidas para "recordarme" (24h / 60 días), logout con invalidación en Redis |
| `IValidacionAccesoService` / `ValidacionAccesoRepository` | Revalida un acceso puntual (`AccNombre`) contra `RolAcceso`/`UsuarioAcceso` en cada acción sensible, más allá de lo que diga el JWT |
| `AbastecimientoDieselController` | `Registrar`, `Listar`, `ListarAnulados`, `Foto` — cada acción sensible revalida acceso mobile antes de ejecutar |
| SPs `Usp_Get_TodasLasJefaturas_Flutter` / `Usp_Get_TodosLosTrabajadores_Flutter` | Traen el catálogo **completo** (sin filtro/`TOP`) para el espejo local, en vez de depender de búsquedas puntuales limitadas |
| Tabla `dbo.AbastecimientoDieselIdempotencia` | Guarda `IdempotencyKey → SalMatCabId`; `Registrar` la revisa al inicio de la transacción para no duplicar un reintento que ya se había procesado |

---

## 12. Preguntas frecuentes

**¿Qué pasa si el usuario cierra la app con borradores pendientes?**
Nada se pierde — los borradores viven en SQLite, no en memoria. Al volver a abrir la app siguen ahí, en la pestaña "Borradores".

**¿Un borrador puede duplicar un registro?**
No: cada reintento es una petición nueva y completa al backend, que aplica sus propias reglas de negocio (ej. validación de stock) igual que si fuera la primera vez — pero viaja con la misma clave de idempotencia del intento original (ver 7.6). Si ese intento anterior en realidad ya se había procesado (ej. se guardó como borrador por un timeout, pero el servidor sí lo había hecho), el backend reconoce la clave y devuelve el mismo resultado sin insertar un segundo Parte de Salida.

**¿Por qué los catálogos son un espejo completo y no algo más "inteligente" (incremental/delta)?**
Porque el volumen total es chico (unas pocas MB incluso con +9,000 choferes) y cambian poco de un día a otro. La complejidad de un sync incremental no se justifica frente al beneficio real.

**¿Qué pasa si el menú cacheado dice que el usuario SÍ tiene acceso, pero se lo revocaron hace una hora y no hay señal para refrescarlo?**
Va a ver el botón/pestaña (falso positivo visual), pero en cuanto intente `Registrar` o `Listar` de verdad, el backend va a revalidar el acceso puntual y rechazar la operación con 403. El menú cacheado nunca es la última palabra.
