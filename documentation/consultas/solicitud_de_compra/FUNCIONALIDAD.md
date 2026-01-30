# 🔍 Consulta de Solicitudes de Compra - Funcionalidad

---

## 🎯 Objetivo

Proporcionar una vista de solo lectura para consultar el historial de todas las solicitudes de compra, permitiendo filtrar por estado, tipo, fechas y realizar búsquedas.

---

## 🔌 Endpoints de la API

### 1. Obtener Todas las Solicitudes (Consulta)

```http
GET /api/SolicitudCompra/ObtenerTodas
```

**Headers:**
```json
{
  "Authorization": "Bearer {token}",
  "Content-Type": "application/json"
}
```

**Query Parameters:**
```json
{
  "trabId": "string",
  "empresaId": "string",
  "estado": "string",           // "TODOS" | "PENDIENTE" | "AUTORIZADO" | "OBSERVADO" | "EN_PROCESO"
  "tipoSolicitud": "string",    // "TODOS" | "CM" | "AF" | "ST" | "CD"
  "busqueda": "string",         // Texto libre para buscar
  "fechaInicio": "date",
  "fechaFin": "date",
  "pagina": "int",
  "tamanoPagina": "int"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Consulta realizada correctamente",
  "data": {
    "solicitudes": [
      {
        "solicitudId": "string",
        "codigo": "SC-2026-00145",
        "tipoSolicitud": "CM",
        "areaSolicitante": "SISTEMAS",
        "solicitante": {
          "trabId": "string",
          "nombreCompleto": "Juan Pérez García"
        },
        "fechaSolicitud": "2026-01-29T10:00:00",
        "montoTotal": 12500.00,
        "sustento": "Requerimiento urgente para renovación de equipos",
        "estado": "PENDIENTE",
        "items": [...]
      }
    ],
    "totalRegistros": 50,
    "paginaActual": 1,
    "totalPaginas": 3,
    "contadores": {
      "todos": 50,
      "pendientes": 10,
      "autorizados": 35,
      "observados": 5
    }
  }
}
```

### 2. Obtener Detalle (Mismo endpoint que autorización)

```http
GET /api/SolicitudCompra/ObtenerDetalle
```

---

## 📋 Modelos de Datos

Los modelos son los mismos que se usan en el módulo de autorización:

- `SolicitudCompra`
- `TipoSolicitudCompra` (enum)
- `EstadoSolicitud` (enum)
- `ItemSolicitud`

### Tipos de Solicitud
| Código | Nombre | Color |
|--------|--------|-------|
| CM | Compra de Materiales | #1565C0 |
| AF | Compra de Activo Fijo | #E65100 |
| ST | Servicio de Tercero | #2E7D32 |
| CD | Carga Diversa de Gestión | #5E35B1 |

---

## 🔄 Flujo de la Aplicación

```
1. Usuario ingresa a "Ver Solicitud Compra"
   ↓
2. Se carga lista de TODAS las solicitudes
   ↓
3. Usuario puede:
   ├─ Cambiar de tab (Todos/Pendientes/Autorizados/Observados)
   ├─ Buscar por texto
   ├─ Aplicar filtros (tipo, fechas)
   └─ Ver detalle de una solicitud
   ↓
4. Al tocar una solicitud → Modal de detalle (solo lectura)
   ↓
5. Usuario solo puede ver información, no autorizar/observar
```

---

## 🔍 Sistema de Filtros

### Filtro por Tab (Estado)
| Tab | Estados incluidos |
|-----|-------------------|
| Todos | Todos los estados |
| Pendientes | PENDIENTE, EN_PROCESO |
| Autorizados | AUTORIZADO |
| Observados | OBSERVADO |

### Filtro por Tipo de Solicitud
- Todos
- Compra de Materiales (CM)
- Compra de Activo Fijo (AF)
- Servicio de Tercero (ST)
- Carga Diversa de Gestión (CD)

### Filtro por Fechas
- Rango de fechas (desde - hasta)
- Aplica sobre `fechaSolicitud`

### Búsqueda de Texto
Campos donde busca:
- `codigo`
- `sustento`
- `solicitanteNombre`
- `areaSolicitante`

---

## 🎛️ Funcionalidades de la Pantalla

### 1. Tabs con Contadores
```dart
TabBar(
  tabs: [
    Tab(text: 'Todos', badge: totalRegistros),
    Tab(text: 'Pendientes', badge: pendientes),
    Tab(text: 'Autorizados', badge: autorizados),
    Tab(text: 'Observados', badge: observados),
  ],
)
```

### 2. Barra de Búsqueda
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Buscar por código, descripción...',
    prefixIcon: Icon(Icons.search),
    suffixIcon: IconButton(icon: Icon(Icons.clear)),
  ),
  onChanged: (value) => _aplicarFiltros(),
)
```

### 3. Modal de Filtros
- Chips para seleccionar tipo de solicitud
- DateRangePicker para fechas
- Botones Limpiar/Aplicar

### 4. Lista con Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: _cargarSolicitudes,
  child: ListView.builder(...),
)
```

### 5. Card con Badge de Estado
- Muestra el estado actual de la solicitud
- Colores diferenciados por estado
- Posición: esquina inferior derecha del monto

---

## 🔐 Permisos

### Acceso a Consulta
- Cualquier usuario autenticado puede consultar
- No requiere permisos especiales de autorización
- Vista de solo lectura

### Datos Visibles
- Todas las solicitudes de la empresa
- Información completa de items
- Sin opciones de modificación

---

## 💾 Almacenamiento Local

### Cache de Consultas
```dart
- Guardar última consulta en memoria
- Limpiar al cerrar la pantalla
- No persistir en disco (datos siempre frescos)
```

### Preferencias
```dart
- Último tab seleccionado
- Últimos filtros aplicados
- Preferencia de orden
```

---

## ⚡ Optimizaciones

1. **Debounce en búsqueda**: 300ms antes de filtrar
2. **Paginación**: 20 items por carga
3. **Lazy loading**: Cargar más al hacer scroll
4. **Pull to refresh**: Cooldown de 3 segundos
5. **Cache en memoria**: Evitar recargas innecesarias

---

## 🧪 Casos de Prueba

1. **Cargar lista completa**
   - Verificar que carga todos los estados
   - Verificar contadores en tabs

2. **Filtrar por tab**
   - Cambiar a "Pendientes" → solo pendientes
   - Cambiar a "Autorizados" → solo autorizados

3. **Buscar por texto**
   - Buscar por código existente
   - Buscar por nombre de solicitante
   - Buscar texto que no existe

4. **Aplicar filtros**
   - Filtrar por tipo "Compra de Materiales"
   - Filtrar por rango de fechas
   - Combinar tipo + fechas

5. **Ver detalle**
   - Tocar card → abrir modal
   - Verificar que NO muestra botones de autorizar
   - Verificar lista de items completa

6. **Pull to refresh**
   - Deslizar hacia abajo
   - Verificar que recarga datos

7. **Estado vacío**
   - Aplicar filtros sin resultados
   - Mostrar mensaje apropiado

---

## 📱 Diferencias con Módulo de Autorización

| Aspecto | Autorización | Consulta |
|---------|--------------|----------|
| Tabs | 2 (Pendientes/Autorizados) | 4 (Todos/Pendientes/Autorizados/Observados) |
| Barra búsqueda | No | Sí |
| Filtros avanzados | Básicos | Completos (tipo + fechas) |
| Badge en card | No | Sí (estado) |
| Modal detalle | Con botones Autorizar/Observar | Solo lectura |
| Datos | Solo pendientes del usuario | Todas las solicitudes |
| Color AppBar | Info (azul) | Success (verde) |

---

## 🔗 Archivos Relacionados

### Pantalla Principal
```
lib/modules/solicitudes_compra/solicitud_compra_consulta_screen.dart
```

### Widgets Compartidos
```
lib/modules/solicitudes_compra/widgets/solicitud_compra_card.dart
lib/modules/solicitudes_compra/widgets/solicitud_detalle_modal.dart
```

### Modelos
```
lib/modules/solicitudes_compra/models/solicitud_compra.dart
```

### Servicios
```
lib/modules/solicitudes_compra/services/solicitud_compra_service.dart
```
