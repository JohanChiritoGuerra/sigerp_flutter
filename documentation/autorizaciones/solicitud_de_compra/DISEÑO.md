# 🛒 Solicitud de Compra - Diseño de Pantallas

---

## 📱 PANTALLA: Lista de Solicitudes de Compra (Para Autorizar)

### Diseño Visual
```
┌─────────────────────────────────────┐
│ ← Autorizar Solicitud        🔍    │
│   de Compra                         │
├─────────────────────────────────────┤
│ [Pendientes⁵] [Autorizados]         │
├─────────────────────────────────────┤
│ Filtros: [Todos ▼] [Monto ▼]        │
├─────────────────────────────────────┤
│ 🔴 URGENTE                          │
│ Solicitud Compra #SC-2024-089       │
│ 👤 Pedro Sánchez                    │
│ 🏢 Área: Compras                    │
│ 🏭 Proveedor: Tech Solutions        │
│ 💰 $12,800.00                       │
│ 📅 Hace 1 hora                      │
│ ⏳ Esperando tu autorización        │
├─────────────────────────────────────┤
│ 🟡 NORMAL                           │
│ Solicitud Compra #SC-2024-088       │
│ 👤 María García                     │
│ 🏢 Área: Logística                  │
│ 🏭 Proveedor: Distribuidora SAC     │
│ 💰 $3,500.00                        │
│ 📅 Hace 3 horas                     │
├─────────────────────────────────────┤
│ 🟢 NORMAL                           │
│ Solicitud Compra #SC-2024-087       │
│ ...                                  │
└─────────────────────────────────────┘
```

### Elementos de la UI

#### 1. AppBar
- **Título**: "Autorizar Solicitud de Compra"
- **Leading**: Botón de retroceso
- **Actions**: Icono de búsqueda

#### 2. Tabs
- **Pendientes**: Muestra solicitudes que requieren autorización del usuario
- **Autorizados**: Solicitudes ya autorizadas por el usuario
- Badge con número de pendientes

#### 3. Filtros
- **Por Urgencia**: Todos, Urgente, Normal
- **Por Monto**: Menor a mayor, Mayor a menor
- **Por Fecha**: Hoy, Esta semana, Este mes, Personalizado
- **Por Proveedor**: Lista de proveedores

#### 4. Card de Solicitud
**Elementos:**
- **Badge de urgencia**: 
  - 🔴 URGENTE (Rojo)
  - 🟡 NORMAL (Naranja/Amarillo)
- **Número de solicitud**: #SC-YYYY-NNN
- **Solicitante**: Nombre completo con icono
- **Área**: Departamento/área con icono
- **Proveedor**: Nombre de empresa proveedora con icono
- **Monto**: Formato de moneda con icono
- **Fecha**: Tiempo relativo (hace X minutos/horas)
- **Estado**: Texto descriptivo del estado

**Interacción:**
- Tap: Navega a pantalla de detalle

---

## 📱 PANTALLA: Detalle de Solicitud de Compra

### Diseño Visual
```
┌─────────────────────────────────────┐
│ ← Solicitud #SC-2024-089            │
├─────────────────────────────────────┤
│ 🔴 URGENTE                          │
├─────────────────────────────────────┤
│ 📋 INFORMACIÓN                      │
│ Solicitante: Pedro Sánchez          │
│ Área: Compras                       │
│ Fecha: 09/01/2026 14:30 PM          │
│ Proveedor: Tech Solutions SAC       │
│ RUC: 20123456789                    │
├─────────────────────────────────────┤
│ 📄 DESCRIPCIÓN                      │
│ Adquisición de equipos de cómputo   │
│ para área administrativa...          │
├─────────────────────────────────────┤
│ 📦 ITEMS (4)                        │
│ • Laptop HP Core i7      $800.00    │
│   Cant: 10 × $800.00                │
│ • Mouse inalámbrico       $15.00    │
│   Cant: 10 × $15.00                 │
│ • Teclado mecánico        $45.00    │
│   Cant: 10 × $45.00                 │
│ • Monitor 24"            $250.00    │
│   Cant: 10 × $250.00                │
│                                     │
│ SUBTOTAL:          $11,100.00       │
│ IGV (18%):          $1,998.00       │
│ ────────────────────────────        │
│ TOTAL:             $13,098.00       │
├─────────────────────────────────────┤
│ 📜 HISTORIAL AUTORIZACIONES         │
│ ✅ Jefe Área (Autorizado)           │
│    Carlos López                     │
│    09/01/2026 • 14:45 PM            │
│ ⏳ Gerente de Área                  │
│    (PENDIENTE - Tú)                 │
│ ⏸️ Gerencia General (En cola)       │
├─────────────────────────────────────┤
│ [❌ OBSERVAR]  [✅ AUTORIZAR]       │
└─────────────────────────────────────┘
```

### Secciones de la Pantalla

#### 1. Header con Urgencia
- Badge grande indicando si es urgente o normal
- Color distintivo según urgencia

#### 2. Información General
- **Solicitante**: Nombre completo
- **Área**: Departamento que solicita
- **Fecha de solicitud**: Formato dd/mm/yyyy hh:mm AM/PM
- **Proveedor**: Nombre completo de la empresa
- **RUC**: Número de RUC del proveedor

#### 3. Descripción
- Texto completo de la justificación
- Scrolleable si es muy largo
- Máximo 500 caracteres

#### 4. Lista de Items con Cálculos
- Cada item con:
  - Descripción del producto/servicio
  - Cantidad × Precio unitario = Subtotal
  - Monto alineado a la derecha
- **Cálculos:**
  - SUBTOTAL: Suma de todos los items
  - IGV (18%): Calculado sobre subtotal
  - TOTAL: Subtotal + IGV

#### 5. Historial de Autorizaciones
**Estados posibles:**
- ✅ **Autorizado**: Verde, muestra quién y cuándo
- ❌ **Observado**: Rojo, muestra quién, cuándo y motivo
- ⏳ **Pendiente**: Naranja, indica usuario actual
- ⏸️ **En cola**: Gris, siguiente en la jerarquía

**Jerarquía:**
1. Jefe de Área
2. Gerente de Área
3. Gerencia General

#### 6. Botones de Acción
- **OBSERVAR**: Color rojo, abre diálogo para ingresar motivo
- **AUTORIZAR**: Color verde, abre diálogo de confirmación

---

## 🎨 Colores según Urgencia

```dart
- URGENTE:   #F44336 (Rojo)
- NORMAL:    #FF9800 (Naranja/Amarillo)
```

---

## 📊 Estados de Solicitud

| Estado | Color | Descripción |
|--------|-------|-------------|
| Pendiente | Naranja | Esperando autorización |
| Autorizado | Verde | Aprobado en todos los niveles |
| Observado | Rojo | Rechazado con observaciones |
| En Proceso | Azul | En algún nivel de autorización |

---

## 🔔 Notificaciones

**Eventos que generan notificación:**
1. Nueva solicitud asignada para autorizar
2. Solicitud autorizada por nivel anterior
3. Solicitud observada por nivel anterior
4. Recordatorio de solicitudes pendientes (diario)

---

## 📱 Interacciones

### Tap en Card de Lista
- Navega a pantalla de detalle
- Marca como "visto"

### Botón Autorizar
1. Muestra diálogo de confirmación con resumen
2. Usuario confirma
3. Envía petición al API
4. Muestra mensaje de éxito/error
5. Actualiza lista
6. Envía notificación push al siguiente nivel

### Botón Observar
1. Muestra diálogo con campo de texto
2. Usuario ingresa motivo (obligatorio, min 10 caracteres)
3. Envía petición al API
4. Muestra mensaje de éxito/error
5. Actualiza lista
6. Envía notificación push al solicitante

### Pull to Refresh
- Actualiza la lista de solicitudes
- Muestra indicador de carga

### Búsqueda
- Busca por:
  - Número de solicitud
  - Nombre de solicitante
  - Proveedor
  - Área
- Resultados en tiempo real

---

## 🧮 Cálculos Automáticos

```dart
// Cálculo de totales
double subtotal = items.fold(0, (sum, item) => sum + (item.cantidad * item.precioUnitario));
double igv = subtotal * 0.18;
double total = subtotal + igv;
```

---

## ♿ Accesibilidad

- **Semántica**: Etiquetas descriptivas en todos los elementos
- **Contraste**: Cumple WCAG AA en todos los textos
- **Tamaños**: Botones de al menos 44x44 puntos
- **Lectores de pantalla**: Soporte completo
- **Cálculos legibles**: Formato claro de moneda y cantidades
