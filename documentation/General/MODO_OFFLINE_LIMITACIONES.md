# SIGERP Mobile — Modo Offline: Limitaciones y Alcance

> Complemento de [`MODO_OFFLINE.md`](MODO_OFFLINE.md). Ese documento explica **cómo funciona** el modo offline; este documento explica **dónde se queda corto hoy** — qué casos NO están cubiertos, con ejemplos concretos, para que quede claro qué esperar y qué no antes de prometerle algo al usuario final o de reportar un "bug" que en realidad es una limitación conocida.

---

## 1. Limitaciones dentro de lo implementado

Estas son cosas que el modo offline sí intenta resolver, pero con un límite conocido y aceptado (no son errores — son decisiones de costo/beneficio).

### 1.1 ✅ Resuelto — Las fotos de partes ya registrados ahora se guardan en disco

~~Solo la foto de un borrador pendiente vivía guardada en el teléfono; la de un parte ya registrado solo se guardaba en memoria y se perdía al cerrar la app.~~ `AbastecimientoDieselRepository.obtenerFoto()` ahora guarda en disco (vía `FotoEvidenciaStorage.guardarFotoHistorial`, carpeta `fotos_historial_diesel/`) la primera vez que se descarga cada foto, y desde ahí la lee directo en cualquier apertura futura, con o sin conexión — una foto de evidencia ya registrada no cambia, así que no hace falta re-descargarla. El guardado es lazy (solo lo que el usuario realmente abrió), así el espacio usado crece con el uso real. Ver `MODO_OFFLINE.md §6.2`.

### 1.2 El Stock disponible y la descripción/unidad del ítem no se cachean

El formulario de registro pide el stock actual (`Stock`) y los datos del ítem de almacén (`ItemAlmacen/ObtenerPorCodigo`) siempre en vivo, sin caer a ninguna copia local. Sin conexión, esos campos simplemente no aparecen (no bloquean el formulario, pero el usuario pierde esa referencia).

> **Ejemplo:** sin señal, el formulario deja registrar el borrador igual, pero no muestra "Stock: 1,250 GAL" ni la descripción del ítem — el chofer no tiene forma de saber, desde el celular, si probablemente hay stock suficiente. Recién se sabe cuando el borrador se reintenta con conexión y el backend lo acepta o lo rechaza por falta de stock.

### 1.3 Catálogos con hasta 24 horas de desfase

Centro de Costo, Jefatura y Chofer se sincronizan como máximo una vez al día (ver `MODO_OFFLINE.md §5.2`). Un cambio hecho en el sistema hoy no aparece en el celular hasta la próxima sincronización exitosa.

> **Ejemplo:** se contrata un chofer nuevo y se le da de alta en `Trabajador` a las 9 a.m. Un usuario que ya sincronizó catálogos a las 8 a.m. no lo va a encontrar en el buscador de Chofer (online ni offline) hasta que pase el throttle de 24h — aunque tenga señal perfecta, porque la sincronización no se dispara "porque sí" en cada apertura del módulo.

### 1.4 El menú de accesos cacheado puede mostrar botones que el backend va a rechazar

Si el acceso de un usuario se revoca mientras el celular está sin señal, el menú cacheado (`shared_preferences`) sigue mostrando el botón "Registrar" o la pestaña "Consultar". La operación real sí se bloquea (403) porque el backend revalida el acceso puntual en cada llamada — pero la experiencia es confusa: el botón está ahí, y al usarlo aparece un error.

> **Ejemplo:** a un chofer se le retira el acceso de "Registrar - abastecimiento diesel" el lunes. El celular del chofer no tuvo señal desde el domingo. El lunes en el campo sigue viendo el botón "+", completa todo el formulario, toma la foto, y recién al intentar enviarlo (con señal) le sale "No tienes permiso para registrar Abastecimiento de Diesel" — después de haber hecho todo el trabajo de cargar el formulario.

### 1.5 "¿Hay conexión?" es una aproximación, no una garantía

`ConnectivityService.isOnline()` solo confirma que hay una interfaz de red activa (wifi/datos), no que el servidor realmente responda. Si hay wifi conectado a un router sin Internet real, o el servidor está caído, la app va a **intentar** la llamada en vivo igual, esperar el timeout, y recién ahí caer al borrador o a la copia local — con un retraso perceptible en vez de un salto directo a modo offline.

> **Ejemplo:** el chofer está conectado a un wifi de oficina que no tiene salida a Internet en ese momento. Al guardar el registro, la app no detecta "sin conexión" de entrada — intenta la petición, espera varios segundos hasta que el request falla por timeout, y recién ahí lo guarda como borrador. El resultado final es correcto, pero el usuario espera más de lo que esperaría si la app hubiera sabido de entrada que no había Internet real.

### 1.6 ✅ Resuelto — El aviso de reconexión ahora funciona en toda la app, no solo con la pantalla de Diesel abierta

~~El listener de reconexión solo existía mientras `AbastecimientoDieselScreen` estaba montada.~~ Ahora `_AppLifecycleObserverState` (`lib/app.dart`) tiene su propio listener de conectividad, activo mientras la app esté abierta sin importar la pantalla en la que esté el usuario: al detectar offline→online con borradores pendientes, muestra un SnackBar global (`scaffoldMessengerKey`) con un botón "Ver" que navega directo a la pestaña de Borradores. Si la pantalla de Diesel ya está abierta en ese momento, sigue mostrando su propio aviso en el sitio (más inmediato) y el global se omite (bandera `dieselScreenAbierta`) para no duplicarlo. Ver `MODO_OFFLINE.md §7.7`.
>
> Sigue sin existir un recordatorio si el usuario cierra la app por completo con borradores pendientes (ver §2.5 — eso sigue fuera de alcance, requeriría notificaciones push/locales).

### 1.7 ✅ Resuelto — El historial ahora se pide por mes, no completo

~~`Listar`/`ListarAnulados` devolvían TODOS los registros del usuario, sin `TOP` ni rango de fechas, y el filtro de fechas de la pantalla era puramente visual sobre lo ya descargado.~~ Ahora ambos endpoints reciben `anio`/`mes` (por defecto, el mes actual si no se envían) y acotan la consulta con un rango de fechas sargable (`SalMatCabFecEnt >= @Desde AND < @Hasta`). La pantalla reemplazó el filtro "Desde/Hasta" por un **selector de mes** (flechas ‹mes› + un picker de mes/año) en cada una de las pestañas "Mis salidas" y "Anulados", cada una con su propio mes seleccionado de forma independiente.
>
> La copia local dejó de ser un mirror completo del historial y pasó a **acumular por mes**: cada sincronización solo reemplaza el mes consultado (`reemplazarSalidasDelMes`), sin tocar los demás meses ya guardados — el mismo principio que el caché de fotos (§6.2). Esto trae un matiz nuevo: **sin conexión, solo se puede ver un mes si ya se visitó alguna vez con conexión** — si nunca se sincronizó, la pantalla lo distingue claramente ("Sin conexión — no tienes este mes descargado") de un mes que genuinamente no tiene registros. Ver `MODO_OFFLINE.md §6.1`.

### 1.8 Sin respaldo en la nube de lo que vive solo en el celular

Borradores pendientes, sus fotos, y las copias locales de catálogos/historial existen **únicamente** en el almacenamiento del dispositivo (SQLite + carpeta de documentos + `shared_preferences`). No hay backup automático a la nube de esta información específica.

> **Ejemplo:** un chofer tiene 2 borradores pendientes (con sus fotos) porque estuvo 3 días sin señal. Se le pierde el celular, o el celular se malogra y hay que resetearlo de fábrica. Esos 2 registros —y sus fotos de evidencia— se pierden por completo; no hay forma de recuperarlos desde otro dispositivo ni desde el servidor, porque nunca llegaron a enviarse.

### 1.9 ✅ Resuelto — Ahora hay clave de idempotencia, no debería poder duplicar un registro

~~Si una petición de `Registrar` sí llegaba a procesarse en el servidor pero la respuesta nunca volvía al celular, un reintento posterior podía crear un segundo registro para la misma operación.~~ Ahora `AbastecimientoDieselRepository` (Flutter) genera una clave aleatoria (`idempotencyKey`, 128 bits) una sola vez por registro y la reutiliza en todos sus reintentos (incluida la que queda guardada junto con el borrador). El backend (tabla `dbo.AbastecimientoDieselIdempotencia`) revisa esa clave al principio de la transacción de `Registrar`: si ya la había visto, devuelve el mismo `SalMatCabId` sin insertar nada de nuevo. Ver `MODO_OFFLINE.md §7.6`.
>
> Queda un margen teórico muy pequeño: dos reintentos del mismo borrador disparados *exactamente* al mismo instante (ej. doble tap accidental) podrían chocar contra la clave primaria de la tabla de idempotencia antes de que el primero termine de insertarla — resultaría en un error de reintento, no en un duplicado. No se blindó contra ese caso puntual (requeriría un retry-loop) porque el flujo real es un botón que el usuario toca una vez.

### 1.10 Sin sincronización entre dispositivos

Todo el estado offline (borradores, catálogos, historial cacheado) es local a **un** dispositivo. Si el mismo usuario inicia sesión en otro celular, no ve los borradores pendientes que dejó en el primero.

> **Ejemplo:** un supervisor usa su celular personal para registrar un abastecimiento sin señal (queda como borrador ahí). Luego usa la tablet de la oficina con el mismo usuario para revisar "Borradores" — la tablet no muestra nada, porque ese borrador solo existe en el celular donde se creó.

### 1.11 Los borradores con error no se limpian solos

Un borrador que pasa a estado `error` (ej. rechazado por el backend, o con la foto perdida) se queda ahí indefinidamente hasta que el usuario lo elimina a mano. No hay expiración automática ni límite de cuántos se pueden acumular.

> **Ejemplo:** un borrador queda en estado de error porque, para cuando se reintentó, ya no había stock. Si nadie lo borra manualmente, se queda para siempre en la lista de "Borradores", sumando al contador del badge, aunque ya no tenga forma de prosperar sin cambiar algo (ej. esperar reposición de stock).

### 1.12 Solo cámara — sin opción de adjuntar una foto ya existente

Se quitó deliberadamente la opción de galería (pedido explícito del usuario): la evidencia siempre se toma en el momento. Esto significa que si la cámara del dispositivo falla o no está disponible en ese momento, no hay forma alternativa de adjuntar una foto para completar el registro (offline u online).

---

## 2. Lo que el modo offline NO cubre (fuera de alcance, no implementado)

Estas no son "limitaciones" de algo que se intentó — son cosas que directamente no existen hoy.

### 2.1 Solo Abastecimiento de Diesel tiene este patrón

**Presupuesto de Emergencia** y **Solicitud de Compra** (autorización y consulta) no tienen ningún soporte offline: sin conexión, sus pantallas van a fallar o mostrarse vacías/con error. Todo lo descrito en `MODO_OFFLINE.md` (Repository, LocalStore, borradores, catálogos cacheados) existe únicamente dentro del módulo de Diesel.

> **Ejemplo:** un usuario sin señal abre "Presupuesto de Emergencia" para autorizar una solicitud pendiente — no hay ninguna copia local que mostrar; la pantalla depende 100% de que la petición al API tenga éxito en ese momento.

### 2.2 No se puede anular un parte desde el celular

La pestaña "Anulados" es **de solo lectura**: muestra los partes que ya fueron anulados (por otro medio, típicamente el sistema de escritorio/backoffice). La app móvil no tiene ninguna función para anular un registro, ni online ni offline.

### 2.3 El primer inicio de sesión siempre necesita conexión

La sesión persistente (`checkSavedSession`) solo puede restaurar una sesión que **ya se guardó** después de un login exitoso con conexión. Un usuario que instala la app por primera vez, o que borró los datos de la app, no puede iniciar sesión sin señal — el login en sí no tiene ningún modo offline.

### 2.4 Sin tareas en segundo plano — nada de sincronización pasa con la app cerrada

No hay ningún `WorkManager` (Android) ni tarea en segundo plano equivalente en iOS. Absolutamente todo lo descrito (sincronizar catálogos, reintentar borradores, refrescar el token) solo ocurre mientras la app está abierta y, en la mayoría de los casos, mientras el usuario está parado en la pantalla correspondiente. Cerrar la app (no solo minimizarla) detiene cualquier proceso en curso.

### 2.5 Sin notificaciones para avisar de borradores pendientes

Más allá del aviso de reconexión (ver §1.6 — ahora funciona en toda la app, pero solo mientras la app sigue **abierta**), no existe ninguna notificación push ni recordatorio periódico que le diga al usuario "tienes borradores esperando desde hace 3 días" si cerró la app por completo. Depende de que el usuario recuerde volver a abrirla y entrar a esa pantalla.

### 2.6 Sin resolución de conflictos entre sesiones/dispositivos

No hay ninguna lógica de "merge" si el mismo usuario termina con datos distintos en dos dispositivos (ver §1.10) — cada instalación de la app es una isla independiente. Esto no ha sido un problema en la práctica porque cada chofer/jefatura usa un único dispositivo asignado, pero conviene tenerlo presente si ese supuesto cambia.

---

## 3. Resumen rápido

| Área | Estado |
|---|---|
| Sesión/login | Persistente, con renovación silenciosa — pero el **primer** login siempre necesita señal |
| Accesos (menú) | Cacheado para mostrar/ocultar UI — el backend siempre revalida el permiso real |
| Catálogos (Centro de Costo, Jefatura, Chofer) | Espejo completo, hasta 24h de desfase |
| Historial (Mis salidas / Anulados) | ✅ Se pide y cachea por mes (selector de mes en la pantalla), ya no el historial completo — offline solo ves meses que visitaste antes con conexión. Las fotos ✅ ahora sí se guardan en disco la primera vez que se ven |
| Stock / datos del ítem en el formulario | Solo en vivo, sin caché — degradan de forma visual, no bloquean el registro |
| Registrar sin conexión | Borrador local con foto persistida — reintento **manual**, ✅ con clave de idempotencia (evita duplicados) |
| Aviso de reconexión con pendientes | ✅ A nivel de toda la app (no solo con la pantalla de Diesel abierta) — pero solo mientras la app sigue abierta, sin notificación si se cierra |
| Otros módulos (Presupuesto de Emergencia, Solicitud de Compra) | **Sin soporte offline** |
| Anular un parte | No existe en mobile (ni online ni offline) |
| Sincronización en segundo plano / multi-dispositivo | No implementada |
