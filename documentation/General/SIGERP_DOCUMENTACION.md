# 📱 SIGERP - Sistema de Gestión Empresarial
## Documentación del Proyecto Flutter

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── models/
│   │   ├── usuario.dart
│   │   ├── login_response.dart
│   │   ├── base_response.dart
│   │   └── perfil_trabajador.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── auth_service. dart
│   └── utils/
│       └── constants.dart
└── modules/
    ├── auth/
    │   └── login_screen. dart
    └── home/
        ├── home_screen.dart
        └── widgets/
            └── module_card.dart
```

---

## 🎨 Diseño de Pantallas

### PANTALLA 1: SPLASH SCREEN
- Logo de Andahuasi (color)
- Texto "SIGERP"
- Subtítulo "Sistema de Gestión Empresarial"
- Indicador de carga

### PANTALLA 2: LOGIN
- Campo Usuario
- Campo Contraseña
- Campo Empresa ID (valor por defecto:  02)
- Checkbox "Recordarme"
- Botón "Iniciar Sesión"

### PANTALLA 3: HOME (Usuario con ambos permisos)
```
┌─────────────────────────────────────┐
│ [≡]   👋 HOLA, JORGE      🔔³  👤  │
├─────────────────────────────────────┤
│ ⚠️  Tienes 8 autorizaciones         │
│     pendientes                      │
├─────────────────────────────────────┤
│ ────────────────── AUTORIZAR        │
│ ┌─────────────┬─────────────┐       │
│ │ 🚨          │ 🛒          │       │
│ │ Presupuesto │ Solicitud   │       │
│ │ Emergencia  │ Compra      │       │
│ │ 3 pendiente │ 5 pendiente │       │
│ │ (Naranja)   │ (Azul)      │       │
│ └─────────────┴─────────────┘       │
│ ────────────────────────────        │
├─────────────────────────────────────┤
│ ────────────────── CONSULTAS        │
│ ┌─────────────┬─────────────┐       │
│ │ Ver         │ Ver         │       │
│ │ Presupuesto │ Solicitud   │       │
│ │ Emergencia  │ Compra      │       │
│ │ Ver (5)     │ Ver (3)     │       │
│ │ (Morado)    │ (Verde)     │       │
│ └─────────────┴─────────────┘       │
│ ────────────────────────────        │
├─────────────────────────────────────┤
│ 🔄 Última actualización: Ahora      │
└─────────────────────────────────────┘

CARACTERÍSTICAS DEL DISEÑO HOME:
- AppBar: Saludo centrado "👋 HOLA, [NOMBRE]" (16px)
- Card de autorizaciones: Fondo blanco, icono warning naranja, número en rojo
- Franjas: Fondo gris claro (grey[50])
- Separadores: Líneas con degradado gris arriba y abajo
- Títulos de franjas: Alineados a la derecha (16px, negrita)
- Espacio entre franjas: 16px
```

### PANTALLA 3B: HOME (Usuario con 1 permiso)
- En AUTORIZAR solo aparece el módulo que tiene permiso
- En CONSULTAS siempre aparecen ambos

### PANTALLA 3C: HOME (Usuario sin permisos)
- No aparece sección AUTORIZAR
- Solo CONSULTAS
- Mensaje: "Solo tienes acceso a consultar tus solicitudes"

### PANTALLA 4: DRAWER (Menú Lateral)
```
┌─────────────────────────────────────┐
│ 👤 JR  Jorge Ramírez               │
│    (Avatar + Nombre Horizontal)     │
├─────────────────────────────────────┤
│ 🏠 Inicio                           │
├─────────────────────────────────────┤
│ AUTORIZAR                           │
│ ───────────                         │
│ 🚨 Autorizar Presupuesto            │
│    de Emergencia (Naranja)          │
│ 🛒 Autorizar Solicitud              │
│    de Compra (Azul)                 │
├─────────────────────────────────────┤
│ CONSULTAS                           │
│ ─────────                           │
│ 📋 Ver Presupuestos de Emergencia   │
│    (Morado)                         │
│ 📋 Ver Solicitudes de Compra        │
│    (Verde)                          │
├─────────────────────────────────────┤
│ 🚪 Cerrar Sesión                    │
├─────────────────────────────────────┤
│ v1.0.0 • Build 23                   │
└─────────────────────────────────────┘
```

CARACTERÍSTICAS DEL DISEÑO DRAWER:
- Header: Avatar + Nombre horizontal (sin email ni cargo)
- Secciones: Título en negrita + línea inferior gris
- Sin cards ni marcos en las secciones
- Iconos con colores correspondientes
- Fondo azul en header

### PANTALLA 4B: DRAWER (Sin permisos de autorización)
- NO aparece sección AUTORIZAR
- Solo CONSULTAS

### PANTALLA 5: LISTA DE PRESUPUESTOS (Para Autorizar)
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
│ 🏢 Sección:  Mantenimiento           │
│ 💰 $5,250.00                        │
│ 📅 Hace 15 minutos                  │
│ ⏳ Esperando tu autorización        │
├─────────────────────────────────────┤
│ 🟡 URGENTE                          │
│ Presupuesto #2024-0155              │
│ 👤 María López                      │
│ 🏢 Sección:  Logística               │
│ 💰 $1,800.00                        │
│ 📅 Hace 2 horas                     │
├─────────────────────────────────────┤
│ 🟢 NORMAL                           │
│ Presupuesto #2024-0154              │
│ ...                                  │
└─────────────────────────────────────┘
```

### PANTALLA 6: DETALLE DE PRESUPUESTO (Pendiente)
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

### PANTALLA 8: LISTA DE SOLICITUDES DE COMPRA (Para Autorizar)
```
┌─────────────────────────────────────┐
│ ← Autorizar Solicitud        🔍    │
│   de Compra                         │
├─────────────────────────────────────┤
│ [Pendientes⁵] [Autorizados]         │
├─────────────────────────────────────┤
│ Filtros:  [Todos ▼] [Monto ▼]        │
├─────────────────────────────────────┤
│ 🔴 URGENTE                          │
│ Solicitud Compra #SC-2024-089       │
│ 👤 Pedro Sánchez                    │
│ 🏢 Área: Compras                    │
│ 🏭 Proveedor: Tech Solutions        │
│ 💰 $12,800.00                       │
│ 📅 Hace 1 hora                      │
│ ⏳ Esperando tu autorización        │
└─────────────────────────────────────┘
```

### PANTALLA 9: DETALLE DE SOLICITUD DE COMPRA
- Similar a Presupuesto pero incluye: 
  - Proveedor + RUC
  - Items con Cantidad × Precio c/u = Subtotal
  - SUBTOTAL + IGV (18%) + TOTAL

### PANTALLA 10A: VER MIS PRESUPUESTOS (Consulta)
- Tabs:  [Pendientes] [Autorizados]
- Cards con estado: EN PROCESO, Nivel 2/3
- Tap → BottomSheet (readonly, sin botones)

### PANTALLA 10B:  VER MIS SOLICITUDES DE COMPRA (Consulta)
- Similar a 10A pero con Proveedor

### PANTALLA 10C:  BOTTOM SHEET (Detalle Readonly)
- Fondo semi-transparente
- Scrollable
- SIN botones de acción
- Cierra con:  Swipe down, Tap [X], Tap fuera

### PANTALLA 11: CENTRO DE NOTIFICACIONES
```
┌─────────────────────────────────────┐
│ ← Notificaciones                    │
├─────────────────────────────────────┤
│ [No leídas³] [Todas]                │
├─────────────────────────────────────┤
│ 🔴 Hace 15 min                      │
│ Autorizar Presupuesto               │
│ Presupuesto #2024-0156              │
│ Sección: Mantenimiento              │
│ Monto: $5,250.00                    │
│ [Ver solicitud →]                   │
├─────────────────────────────────────┤
│ 🔴 Hace 1 hora                      │
│ Autorizar Solicitud de Compra       │
│ Solicitud #SC-2024-089              │
│ Proveedor: Tech Solutions           │
│ Monto: $12,800.00                   │
│ [Ver solicitud →]                   │
└─────────────────────────────────────┘

Tipos de notificaciones:
• 🚨 Autorizar Presupuesto de Emergencia
• 🛒 Autorizar Solicitud de Compra
• ✅ Presupuesto Autorizado
• ✅ Solicitud de Compra Autorizada
• ❌ Presupuesto Observado
• ❌ Solicitud de Compra Observada
```

### PANTALLA 12: PERFIL DE USUARIO
```
┌─────────────────────────────────────┐
│ ← Mi Perfil                         │
├─────────────────────────────────────┤
│        👤 (Avatar)                  │
│     Carlos Ramírez                  │
│     Gerente General                 │
├─────────────────────────────────────┤
│ 📧 INFORMACIÓN                      │
│ Email: carlos.ramirez@...            │
│ Usuario: cramirez                   │
│ Departamento: Gerencia              │
├─────────────────────────────────────┤
│ 📊 ESTADÍSTICAS                     │
│ Autorizadas hoy: 5                  │
│ Autorizadas esta semana: 23         │
│ Observadas esta semana: 2           │
│ Pendientes: 8                       │
├─────────────────────────────────────┤
│ [🚪 CERRAR SESIÓN]                  │
├─────────────────────────────────────┤
│ v1.0.0 • Build 23                   │
└─────────────────────────────────────┘
```

---

## 🔌 Endpoints de la API

### Autenticación
```
POST /api/LoginWeb/login
Body: {
  "usuario": "string",
  "password": "string",
  "empresaId": "string",
  "deviceFingerprint": "string",
  "deviceType": "string",
  "userAgent": "string",
  "ipAddress": "string",
  "rememberMe": boolean
}
```

### Perfil de Trabajador
```
POST /api/PerfilTrabajador/ObtenerPerfilTrabajador
Body: {
  "trabId": "string",
  "empresaId": "string"
}
```

---

## 🎨 Colores de la App

```dart
class AppColors {
  static const int primaryColor = 0xFF1976D2;    // Azul
  static const int secondaryColor = 0xFF757575;  // Gris
  static const int successColor = 0xFF4CAF50;    // Verde
  static const int warningColor = 0xFFFF9800;    // Naranja
  static const int errorColor = 0xFFF44336;      // Rojo
  static const int infoColor = 0xFF2196F3;       // Azul claro
}
```

---

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk:  flutter
  http: ^1.1.0
  provider: ^6.1.1
  flutter_secure_storage:  ^9.0.0
  google_fonts: ^6.1.0
```

---

## 🔐 Lógica de Permisos

| Tipo Usuario | AUTORIZAR Presupuesto | AUTORIZAR Solicitud | CONSULTAS |
|--------------|----------------------|---------------------|-----------|
| Ambos permisos | ✅ | ✅ | ✅ Ambos |
| Solo Presupuesto | ✅ | ❌ | ✅ Ambos |
| Solo Solicitud | ❌ | ✅ | ✅ Ambos |
| Sin permisos | ❌ | ❌ | ✅ Ambos |

---

## 📱 Assets

```
assets/
└── images/
    ├── logo_color.png    (Para Splash)
    └── logo_blanco.png   (Para AppBar/Drawer)
```

---

## ✅ Archivos Creados

1. `lib/main.dart`
2. `lib/app.dart`
3. `lib/core/utils/constants.dart`
4. `lib/core/models/base_response.dart`
5. `lib/core/models/usuario.dart`
6. `lib/core/models/login_response.dart`
7. `lib/core/models/perfil_trabajador. dart`
8. `lib/core/services/api_service.dart`
9. `lib/core/services/auth_service.dart`
10. `lib/modules/auth/login_screen.dart`
11. `lib/modules/home/home_screen. dart`
12. `lib/modules/home/widgets/module_card.dart`

---

## 🚀 Próximos Pasos

- [ ] Actualizar HOME según diseño acordado
- [ ] Actualizar DRAWER según diseño acordado
- [ ] Crear pantalla Lista de Presupuestos
- [ ] Crear pantalla Detalle de Presupuesto
- [ ] Crear pantalla Lista de Solicitudes
- [ ] Crear pantalla Detalle de Solicitud
- [ ] Crear pantalla Consultas (BottomSheet)
- [ ] Crear Centro de Notificaciones
- [ ] Crear Perfil de Usuario
- [ ] Conectar con endpoints reales