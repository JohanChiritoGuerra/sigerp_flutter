# 🚨 Presupuesto de Emergencia - Diseño de Pantallas

---

## 📱 PANTALLA: Lista de Presupuestos (Para Autorizar)

### Diseño Visual
```
┌─────────────────────────────────────┐
│ ← Autorizar Presupuesto      🔍    │
│   de Emergencia                     │
├─────────────────────────────────────┤
│ [Pendientes³] [Autorizados]         │
├─────────────────────────────────────┤
│ Filtros: [Todos ▼] [Fecha ▼]        │
├─────────────────────────────────────┤
│ 🔴 EMERGENCIA                       │
│ Presupuesto #2024-0156              │
│ 👤 Juan Pérez                       │
│ 🏢 Sección: Mantenimiento           │
│ 💰 $5,250.00                        │
│ 📅 Hace 15 minutos                  │
│ ⏳ Esperando tu autorización        │
├─────────────────────────────────────┤
│ 🟡 URGENTE                          │
│ Presupuesto #2024-0155              │
│ 👤 María López                      │
│ 🏢 Sección: Logística               │
│ 💰 $1,800.00                        │
│ 📅 Hace 2 horas                     │
├─────────────────────────────────────┤
│ 🟢 NORMAL                           │
│ Presupuesto #2024-0154              │
│ ...                                  │
└─────────────────────────────────────┘
```

### Elementos de la UI

#### 1. AppBar
- **Título**: "Autorizar Presupuesto de Emergencia"
- **Leading**: Botón de retroceso
- **Actions**: Icono de búsqueda

#### 2. Tabs
- **Pendientes**: Muestra presupuestos que requieren autorización del usuario
- **Autorizados**: Presupuestos ya autorizados por el usuario
- Badge con número de pendientes

#### 3. Filtros
- **Por Estado**: Todos, Emergencia, Urgente, Normal
- **Por Fecha**: Hoy, Esta semana, Este mes, Personalizado

#### 4. Card de Presupuesto
**Elementos:**
- **Badge de prioridad**: 
  - 🔴 EMERGENCIA (Rojo)
  - 🟡 URGENTE (Naranja)
  - 🟢 NORMAL (Verde)
- **Número de presupuesto**: #YYYY-NNNN
- **Solicitante**: Nombre completo con icono
- **Sección**: Departamento/área con icono
- **Monto**: Formato de moneda con icono
- **Fecha**: Tiempo relativo (hace X minutos/horas)
- **Estado**: Texto descriptivo del estado

**Interacción:**
- Tap: Navega a pantalla de detalle

---

## 📱 PANTALLA: Detalle de Presupuesto (Pendiente)

### Diseño Visual
```
┌─────────────────────────────────────┐
│ ← Presupuesto #2024-0156            │
├─────────────────────────────────────┤
│ 🔴 EMERGENCIA                       │
├─────────────────────────────────────┤
│ 📋 INFORMACIÓN                      │
│ Solicitante: Juan Pérez             │
│ Sección: Mantenimiento              │
│ Fecha: 09/01/2026 10:45 AM          │
│ Monto Total: $5,250.00              │
├─────────────────────────────────────┤
│ 📄 DESCRIPCIÓN                      │
│ Reparación urgente de equipo        │
│ compresor principal...               │
├─────────────────────────────────────┤
│ 📦 ITEMS (3)                        │
│ • Válvula hidráulica    $2,500.00   │
│ • Mano de obra          $1,800.00   │
│ • Repuestos varios        $950.00   │
├─────────────────────────────────────┤
│ 📜 HISTORIAL AUTORIZACIONES         │
│ ✅ Jefe Sección (Autorizado)        │
│    José Martínez                    │
│    09/01/2026 • 10:50 AM            │
│ ⏳ Jefe Departamento                │
│    (PENDIENTE - Tú)                 │
│ ⏸️ Gerencia (En cola)               │
├─────────────────────────────────────┤
│ [❌ OBSERVAR]  [✅ AUTORIZAR]       │
└─────────────────────────────────────┘
```

### Secciones de la Pantalla

#### 1. Header con Prioridad
- Badge grande indicando el nivel de prioridad
- Animación sutil para emergencias

#### 2. Información General
- **Solicitante**: Nombre completo
- **Sección/Área**: Departamento que solicita
- **Fecha de solicitud**: Formato dd/mm/yyyy hh:mm AM/PM
- **Monto total**: Suma de todos los items

#### 3. Descripción
- Texto completo de la justificación
- Scrolleable si es muy largo
- Máximo 500 caracteres

#### 4. Lista de Items
- Cada item con:
  - Descripción del item
  - Monto alineado a la derecha
- Total al final (calculado)

#### 5. Historial de Autorizaciones
**Estados posibles:**
- ✅ **Autorizado**: Verde, muestra quién y cuándo
- ❌ **Observado**: Rojo, muestra quién, cuándo y motivo
- ⏳ **Pendiente**: Naranja, indica usuario actual
- ⏸️ **En cola**: Gris, siguiente en la jerarquía

**Jerarquía:**
1. Jefe de Sección
2. Jefe de Departamento
3. Gerencia

#### 6. Botones de Acción
- **OBSERVAR**: Color rojo, abre diálogo para ingresar motivo
- **AUTORIZAR**: Color verde, abre diálogo de confirmación

---

## 🎨 Colores según Prioridad

```dart
- EMERGENCIA:   #F44336 (Rojo)
- URGENTE:      #FF9800 (Naranja)
- NORMAL:       #4CAF50 (Verde)
```

---

## 📊 Estados de Presupuesto

| Estado | Color | Descripción |
|--------|-------|-------------|
| Pendiente | Naranja | Esperando autorización |
| Autorizado | Verde | Aprobado en todos los niveles |
| Observado | Rojo | Rechazado con observaciones |
| En Proceso | Azul | En algún nivel de autorización |

---

## 🔔 Notificaciones

**Eventos que generan notificación:**
1. Nuevo presupuesto asignado para autorizar
2. Presupuesto autorizado por nivel anterior
3. Presupuesto observado por nivel anterior
4. Recordatorio de presupuestos pendientes (diario)

---

## 📱 Interacciones

### Tap en Card de Lista
- Navega a pantalla de detalle
- Marca como "visto"

### Botón Autorizar
1. Muestra diálogo de confirmación
2. Usuario confirma
3. Envía petición al API
4. Muestra mensaje de éxito/error
5. Actualiza lista
6. Envía notificación push al siguiente nivel

### Botón Observar
1. Muestra diálogo con campo de texto
2. Usuario ingresa motivo (obligatorio)
3. Envía petición al API
4. Muestra mensaje de éxito/error
5. Actualiza lista
6. Envía notificación push al solicitante

### Pull to Refresh
- Actualiza la lista de presupuestos
- Muestra indicador de carga

### Búsqueda
- Busca por:
  - Número de presupuesto
  - Nombre de solicitante
  - Sección
- Resultados en tiempo real

---

## ♿ Accesibilidad

- **Semántica**: Etiquetas descriptivas en todos los elementos
- **Contraste**: Cumple WCAG AA en todos los textos
- **Tamaños**: Botones de al menos 44x44 puntos
- **Lectores de pantalla**: Soporte completo
