# 🔍 Consulta de Presupuestos de Emergencia - Diseño de Pantallas

---

## 📱 PANTALLA: Lista de Presupuestos (Consulta)

### Diseño Visual
```
┌─────────────────────────────────────┐
│ ← Consulta de Presupuestos    🔽   │
│                                     │
├─────────────────────────────────────┤
│ 🔍 Buscar por código, descripción...│
├─────────────────────────────────────┤
│ [Todos⁵][Pendientes²][Autorizados²][Observados¹]│
├─────────────────────────────────────┤
│ 🔴 EMERGENCIA          #PE-2026-0156│
│ 👤 Juan Pérez García                │
│ 🏢 Sección: Mantenimiento           │
│ ┌─────────────────┐                 │
│ │💰 S/ 5,250.00   │    Hace 2 horas │
│ └─────────────────┘                 │
│ ┌─────────────────────────────────┐ │
│ │    ⏳ PENDIENTE                 │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ 🟡 URGENTE             #PE-2026-0155│
│ 👤 María López Torres               │
│ 🏢 Sección: Producción              │
│ ┌─────────────────┐                 │
│ │💰 S/ 3,800.00   │    Hace 5 horas │
│ └─────────────────┘                 │
│ ┌─────────────────────────────────┐ │
│ │    ✅ AUTORIZADO                │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ 🟢 NORMAL              #PE-2026-0154│
│ 👤 Pedro Castillo Vega              │
│ 🏢 Sección: Almacén                 │
│ ┌─────────────────┐                 │
│ │💰 S/ 1,200.00   │    Hace 1 día   │
│ └─────────────────┘                 │
│ ┌─────────────────────────────────┐ │
│ │    ❌ OBSERVADO                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Elementos de la UI

#### 1. AppBar
- **Título**: "Consulta de Presupuestos"
- **Leading**: Botón de retroceso
- **Actions**: Icono de filtros avanzados (🔽)
- **Color**: Primary Color (#1565C0)

#### 2. Barra de Búsqueda
- Campo de texto con fondo semitransparente
- Placeholder: "Buscar por código, descripción..."
- Icono de búsqueda a la izquierda
- Botón X para limpiar cuando hay texto

#### 3. Tabs
- **Todos**: Muestra todos los presupuestos (badge con total)
- **Pendientes**: Presupuestos pendientes y en proceso
- **Autorizados**: Presupuestos completamente autorizados
- **Observados**: Presupuestos rechazados/observados
- Cada tab tiene badge con contador

#### 4. Card de Presupuesto (Modo Consulta)
- Badge de prioridad (color según nivel)
- Código del presupuesto
- Información del solicitante
- Sección/Área
- Monto en contenedor destacado
- Tiempo relativo
- **Badge de estado** (diferencia con modo autorización)

---

## 🔽 MODAL: Filtros de Búsqueda

### Diseño Visual
```
┌─────────────────────────────────────┐
│          ═══════                    │
│                                     │
│ Filtros de búsqueda                 │
│                                     │
│ Prioridad                           │
│ ┌──────┐ ┌───────────┐ ┌────────┐  │
│ │Todos │ │🔴Emergencia│ │🟡Urgente│ │
│ └──────┘ └───────────┘ └────────┘  │
│ ┌────────┐                          │
│ │🟢Normal│                          │
│ └────────┘                          │
│                                     │
│ Rango de fechas                     │
│ ┌─────────────────────────────────┐ │
│ │ 📅 Seleccionar rango de fechas  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌──────────┐  ┌──────────────────┐  │
│ │ Limpiar  │  │     Aplicar      │  │
│ └──────────┘  └──────────────────┘  │
└─────────────────────────────────────┘
```

### Elementos del Modal

#### 1. Handle
- Barra gris centrada para indicar que es arrastrable

#### 2. Filtro de Prioridad
- Chips seleccionables
- Colores según prioridad:
  - Emergencia: Rojo (#F44336)
  - Urgente: Naranja (#FF9800)
  - Normal: Verde (#4CAF50)
  - Todos: Primary Color

#### 3. Filtro de Fechas
- Selector de rango de fechas
- Muestra fechas seleccionadas o placeholder
- Botón X para limpiar selección

#### 4. Botones de Acción
- **Limpiar**: Restablece todos los filtros
- **Aplicar**: Cierra el modal y aplica filtros

---

## 📋 MODAL: Detalle del Presupuesto (Solo Lectura)

### Diseño Visual
```
┌─────────────────────────────────────┐
│          ═══════                    │
│                                     │
│ 🔴 EMERGENCIA     ✅ AUTORIZADO    │
│                                     │
│ Presupuesto #PE-2026-0155           │
│                                     │
├─────────────────────────────────────┤
│ 📋 INFORMACIÓN                      │
├─────────────────────────────────────┤
│ Solicitante                         │
│ María López Torres                  │
│                                     │
│ Sección                             │
│ Producción                          │
│                                     │
│ Cargo                               │
│ Supervisora                         │
│                                     │
│ Fecha de Solicitud                  │
│ 30/01/2026 - 10:45                  │
│                                     │
│ Monto Total                         │
│ S/ 3,800.00                         │
├─────────────────────────────────────┤
│ 📝 DESCRIPCIÓN                      │
├─────────────────────────────────────┤
│ Cambio de rodamientos en faja       │
│ transportadora principal            │
├─────────────────────────────────────┤
│ 📦 ITEMS (2)                        │
├─────────────────────────────────────┤
│ • Rodamientos SKF                   │
│   S/ 2,200.00                       │
│ • Instalación y calibración         │
│   S/ 1,600.00                       │
├─────────────────────────────────────┤
│ 📜 HISTORIAL DE AUTORIZACIONES      │
├─────────────────────────────────────┤
│ Nivel 1: Jefe Sección      ✅      │
│ Roberto Sánchez                     │
│ 30/01/2026 10:50                    │
│                                     │
│ Nivel 2: Jefe Departamento ✅      │
│ Carlos Ramírez                      │
│ 30/01/2026 11:15                    │
│ "Aprobado por urgencia operativa"   │
│                                     │
│ Nivel 3: Gerencia          ✅      │
│ Luis García                         │
│ 30/01/2026 11:30                    │
│                                     │
│ ══════════════════════════════════  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │           Cerrar                │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Diferencias con Modal de Autorización

1. **Sin botones de acción** (Autorizar/Observar)
2. **Muestra estado actual** en el header
3. **Solo botón "Cerrar"** al final
4. **Historial completo visible** sin acciones

---

## 🎨 Colores y Estados

### Badge de Estado
| Estado | Color | Fondo | Icono |
|--------|-------|-------|-------|
| Pendiente | #FF9800 | #FFF3E0 | ⏳ hourglass_empty |
| En Proceso | #2196F3 | #E3F2FD | 🔄 sync |
| Autorizado | #4CAF50 | #E8F5E9 | ✅ check_circle_outline |
| Observado | #F44336 | #FFEBEE | ❌ error_outline |
| En Cola | #9E9E9E | #F5F5F5 | ⏸️ pause_circle_outline |

### Badge de Prioridad
| Prioridad | Color | Fondo Claro | Icono |
|-----------|-------|-------------|-------|
| Emergencia | #F44336 | #FFEBEE | ⚠️ error |
| Urgente | #FF9800 | #FFF3E0 | ⚡ warning_amber |
| Normal | #4CAF50 | #E8F5E9 | ℹ️ info_outline |

---

## 📐 Especificaciones Técnicas

### Pantalla Principal
- `Scaffold` con `AppBar` personalizado
- `TabController` con 4 tabs
- `ListView.builder` para la lista
- `RefreshIndicator` para pull-to-refresh

### Cards
- `Card` con `elevation: 0`
- Borde izquierdo de 4px con color de prioridad
- `Gradient` suave de fondo
- Padding: 14px horizontal, 12px vertical

### Modal de Filtros
- `showModalBottomSheet`
- `StatefulBuilder` para estado interno
- `FilterChip` para opciones
- `showDateRangePicker` para fechas

### Modal de Detalle
- `DraggableScrollableSheet`
- `initialChildSize: 0.85`
- `SingleChildScrollView` para contenido
- Sin botones de autorización

---

## 🔄 Interacciones

### Pull to Refresh
- Deslizar hacia abajo para actualizar
- Cooldown de 3 segundos entre actualizaciones

### Cambio de Tab
- Actualiza la lista filtrada automáticamente
- Mantiene otros filtros activos

### Búsqueda
- Debounce de 300ms
- Busca en: código, descripción, solicitante, sección

### Tap en Card
- Abre modal de detalle en modo solo lectura

### Filtros
- Se aplican al cerrar el modal
- Se combinan con la búsqueda y tab activo
