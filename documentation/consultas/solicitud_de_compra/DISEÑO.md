# 🔍 Consulta de Solicitudes de Compra - Diseño de Pantallas

---

## 📱 PANTALLA: Lista de Solicitudes (Consulta)

### Diseño Visual
```
┌─────────────────────────────────────┐
│ ← Consulta de Solicitudes     🔽   │
│                                     │
├─────────────────────────────────────┤
│ 🔍 Buscar por código, descripción...│
├─────────────────────────────────────┤
│ [Todos⁷][Pendientes²][Autorizados⁴][Observados¹]│
├─────────────────────────────────────┤
│ 🔵┃ 📦 COMPRA DE MATERIALES         │
│   ┃    SISTEMAS                     │
│   ┃                                 │
│   ┃ SC-2026-00145    29/01/2026    │
│   ┃                                 │
│   ┃        S/ 12,500.00  PENDIENTE │
├─────────────────────────────────────┤
│ 🟠┃ 🏭 COMPRA DE ACTIVO FIJO        │
│   ┃    ENERGÍA                      │
│   ┃                                 │
│   ┃ SC-2026-00142    28/01/2026    │
│   ┃                                 │
│   ┃        S/ 45,800.00 AUTORIZADO │
├─────────────────────────────────────┤
│ 🟢┃ 👷 SERVICIO DE TERCERO          │
│   ┃    RECURSOS HUMANOS             │
│   ┃                                 │
│   ┃ SC-2026-00140    27/01/2026    │
│   ┃                                 │
│   ┃         S/ 8,200.00  OBSERVADO │
├─────────────────────────────────────┤
│ 🟣┃ 📁 CARGA DIVERSA DE GESTIÓN     │
│   ┃    ADMINISTRACIÓN               │
│   ┃                                 │
│   ┃ SC-2026-00138    26/01/2026    │
│   ┃                                 │
│   ┃         S/ 3,500.00 AUTORIZADO │
└─────────────────────────────────────┘
```

### Elementos de la UI

#### 1. AppBar
- **Título**: "Consulta de Solicitudes"
- **Leading**: Botón de retroceso
- **Actions**: Icono de filtros avanzados (🔽)
- **Color**: Success Color (#4CAF50)

#### 2. Barra de Búsqueda
- Campo de texto con fondo semitransparente
- Placeholder: "Buscar por código, descripción..."
- Icono de búsqueda a la izquierda
- Botón X para limpiar cuando hay texto

#### 3. Tabs
- **Todos**: Muestra todas las solicitudes (badge con total)
- **Pendientes**: Solicitudes pendientes y en proceso
- **Autorizados**: Solicitudes completamente autorizadas
- **Observados**: Solicitudes rechazadas/observadas
- Cada tab tiene badge con contador

#### 4. Card de Solicitud (Modo Consulta)
- Borde izquierdo con color del tipo
- Icono del tipo de solicitud
- Nombre del tipo en color destacado
- Área solicitante
- Código y fecha
- Monto total
- **Badge de estado** (PENDIENTE/AUTORIZADO/OBSERVADO)

---

## 🔽 MODAL: Filtros de Búsqueda

### Diseño Visual
```
┌─────────────────────────────────────┐
│          ═══════                    │
│                                     │
│ Filtros de búsqueda                 │
│                                     │
│ Tipo de Solicitud                   │
│ ┌──────┐ ┌────────────┐ ┌─────────┐│
│ │Todos │ │🔵Materiales│ │🟠Act.Fijo││
│ └──────┘ └────────────┘ └─────────┘│
│ ┌─────────┐ ┌─────────────┐        │
│ │🟢Servicio│ │🟣Carga Div. │        │
│ └─────────┘ └─────────────┘        │
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

#### 2. Filtro de Tipo de Solicitud
- Chips seleccionables
- Colores según tipo:
  - Compra de Materiales: Azul (#1565C0)
  - Compra de Activo Fijo: Naranja (#E65100)
  - Servicio de Tercero: Verde (#2E7D32)
  - Carga Diversa de Gestión: Púrpura (#5E35B1)
  - Todos: Primary Color

#### 3. Filtro de Fechas
- Selector de rango de fechas
- Muestra fechas seleccionadas o placeholder
- Botón X para limpiar selección

#### 4. Botones de Acción
- **Limpiar**: Restablece todos los filtros
- **Aplicar**: Cierra el modal y aplica filtros

---

## 📋 MODAL: Detalle de Solicitud (Solo Lectura)

### Diseño Visual
```
┌─────────────────────────────────────┐
│          ═══════                    │
│                                     │
│ 🔵 COMPRA DE MATERIALES             │
│                                     │
│ Solicitud SC-2026-00145             │
│                                     │
├─────────────────────────────────────┤
│ 📋 INFORMACIÓN                      │
├─────────────────────────────────────┤
│ Área Solicitante                    │
│ SISTEMAS                            │
│                                     │
│ Solicitante                         │
│ Juan Pérez García                   │
│                                     │
│ Fecha de Solicitud                  │
│ 29/01/2026                          │
│                                     │
│ Monto Total                         │
│ S/ 12,500.00                        │
├─────────────────────────────────────┤
│ 📝 SUSTENTO                         │
├─────────────────────────────────────┤
│ Requerimiento urgente para          │
│ renovación de equipos del área      │
│ de desarrollo.                      │
├─────────────────────────────────────┤
│ 📦 ITEMS (2)                        │
├─────────────────────────────────────┤
│ 01020304                            │
│ Laptop HP Core i7 16GB RAM          │
│ 5 UND × S/ 1,800.00 = S/ 9,000.00   │
│                                     │
│ 01020512                            │
│ Monitor 27" LG UltraWide            │
│ 5 UND × S/ 700.00 = S/ 3,500.00     │
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
2. **Solo botón "Cerrar"** al final
3. **Sin indicador de estado** en el footer

---

## 🎨 Colores por Tipo de Solicitud

| Tipo | Color Principal | Color Oscuro | Icono |
|------|-----------------|--------------|-------|
| Compra de Materiales | #1565C0 | #0D47A1 | 📦 inventory_2 |
| Compra de Activo Fijo | #E65100 | #BF360C | 🏭 precision_manufacturing |
| Servicio de Tercero | #2E7D32 | #1B5E20 | 👷 engineering |
| Carga Diversa de Gestión | #5E35B1 | #311B92 | 📁 category |

---

## 🎨 Colores de Estado

| Estado | Color | Fondo | 
|--------|-------|-------|
| Pendiente | #FF9800 | #FFF3E0 |
| En Proceso | #2196F3 | #E3F2FD |
| Autorizado | #4CAF50 | #E8F5E9 |
| Observado | #F44336 | #FFEBEE |

---

## 📐 Especificaciones Técnicas

### Pantalla Principal
- `Scaffold` con `AppBar` color verde (Success)
- `TabController` con 4 tabs
- `ListView.builder` para la lista
- `RefreshIndicator` para pull-to-refresh

### Cards
- `Card` con `elevation: 0`
- Borde izquierdo de 4px con color del tipo
- `Gradient` suave de fondo
- Badge de estado en esquina inferior derecha

### Modal de Filtros
- `showModalBottomSheet`
- `StatefulBuilder` para estado interno
- `FilterChip` para opciones de tipo
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
- Busca en: código, sustento, solicitante, área

### Tap en Card
- Abre modal de detalle en modo solo lectura

### Filtros
- Se aplican al cerrar el modal
- Se combinan con la búsqueda y tab activo
