# 🔍 Consulta de Presupuestos de Emergencia - Funcionalidad

---

## 🎯 Objetivo

Proporcionar una vista de solo lectura para consultar el historial de todos los presupuestos de emergencia, permitiendo filtrar por estado, prioridad, fechas y realizar búsquedas.

---

## 🔌 Endpoints de la API

### 1. Obtener Todos los Presupuestos (Consulta)

```http
GET /api/PresupuestoEmergencia/ObtenerTodos
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
  "prioridad": "string",        // "TODOS" | "EMERGENCIA" | "URGENTE" | "NORMAL"
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
    "presupuestos": [
      {
        "presupId": "string",
        "codigo": "PE-2026-0156",
        "prioridad": "EMERGENCIA",
        "solicitante": {
          "trabId": "string",
          "nombreCompleto": "Juan Pérez García",
          "seccion": "Mantenimiento",
          "cargo": "Técnico Senior"
        },
        "montoTotal": 5250.00,
        "fechaSolicitud": "2026-01-30T10:45:00",
        "descripcion": "Reparación urgente de equipo compresor principal",
        "estadoActual": "PENDIENTE",
        "nivelAutorizacionActual": 2,
        "items": [...],
        "historialAutorizaciones": [...]
      }
    ],
    "totalRegistros": 50,
    "paginaActual": 1,
    "totalPaginas": 3,
    "contadores": {
      "todos": 50,
      "pendientes": 15,
      "autorizados": 30,
      "observados": 5
    }
  }
}
```

### 2. Obtener Detalle (Mismo endpoint que autorización)

```http
GET /api/PresupuestoEmergencia/ObtenerDetalle
```

---

## 📋 Modelos de Datos

Los modelos son los mismos que se usan en el módulo de autorización:

- `PresupuestoEmergencia`
- `PrioridadPresupuesto` (enum)
- `EstadoPresupuesto` (enum)
- `Solicitante`
- `ItemPresupuesto`
- `AutorizacionHistorial`

---

## 🔄 Flujo de la Aplicación

```
1. Usuario ingresa a "Ver Presupuesto Emergencia"
   ↓
2. Se carga lista de TODOS los presupuestos
   ↓
3. Usuario puede:
   ├─ Cambiar de tab (Todos/Pendientes/Autorizados/Observados)
   ├─ Buscar por texto
   ├─ Aplicar filtros (prioridad, fechas)
   └─ Ver detalle de un presupuesto
   ↓
4. Al tocar un presupuesto → Modal de detalle (solo lectura)
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

### Filtro por Prioridad
- Todos
- Emergencia
- Urgente
- Normal

### Filtro por Fechas
- Rango de fechas (desde - hasta)
- Aplica sobre `fechaSolicitud`

### Búsqueda de Texto
Campos donde busca:
- `codigo`
- `descripcion`
- `solicitante.nombreCompleto`
- `solicitante.seccion`

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
- Chips para seleccionar prioridad
- DateRangePicker para fechas
- Botones Limpiar/Aplicar

### 4. Lista con Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: _cargarPresupuestos,
  child: ListView.builder(...),
)
```

### 5. Card con Badge de Estado
- Muestra el estado actual del presupuesto
- Colores diferenciados por estado
- Sin indicador "Esperando tu autorización"

---

## 🔐 Permisos

### Acceso a Consulta
- Cualquier usuario autenticado puede consultar
- No requiere permisos especiales de autorización
- Vista de solo lectura

### Datos Visibles
- Todos los presupuestos de la empresa
- Historial completo de autorizaciones
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
   - Filtrar por prioridad Emergencia
   - Filtrar por rango de fechas
   - Combinar prioridad + fechas

5. **Ver detalle**
   - Tocar card → abrir modal
   - Verificar que NO muestra botones de autorizar
   - Verificar historial completo

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
| Filtros avanzados | Básicos | Completos (prioridad + fechas) |
| Badge en card | "Esperando tu autorización" | Estado actual |
| Modal detalle | Con botones Autorizar/Observar | Solo lectura |
| Datos | Solo pendientes del usuario | Todos los presupuestos |
| Color AppBar | Warning (naranja) | Primary (azul) |
