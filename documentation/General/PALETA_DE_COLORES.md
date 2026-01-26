# 🎨 Paleta de Colores - SIGERP App

Este documento define la paleta de colores oficial de la aplicación SIGERP. Todos los diseños y desarrollos deben seguir estas especificaciones para mantener la consistencia visual de la marca.

---

## 📌 Colores Principales

### Azul Primario (Primary Blue)
El color principal de la marca, usado en elementos destacados, botones principales y la AppBar.

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **Primary** | `#1565C0` | rgb(21, 101, 192) | AppBar, botones principales, iconos activos |
| **Primary Light** | `#1E88E5` | rgb(30, 136, 229) | Hover states, fondos de tarjetas destacadas |
| **Primary Dark** | `#0D47A1` | rgb(13, 71, 161) | Textos importantes, encabezados |

```dart
// Flutter
static const int primaryColor = 0xFF1565C0;
static const int primaryLightColor = 0xFF1E88E5;
static const int primaryDarkColor = 0xFF0D47A1;
```

---

## ⚪ Colores Neutros

### Blancos y Grises
Usados para fondos, textos y elementos de interfaz.

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **White** | `#FFFFFF` | rgb(255, 255, 255) | Fondos principales, textos sobre azul |
| **Background** | `#FAFAFA` | rgb(250, 250, 250) | Fondo general de la app |
| **Surface** | `#F5F5F5` | rgb(245, 245, 245) | Tarjetas, contenedores |
| **Grey Light** | `#E0E0E0` | rgb(224, 224, 224) | Bordes, divisores, líneas de cuadrícula |
| **Grey Medium** | `#9E9E9E` | rgb(158, 158, 158) | Textos secundarios, placeholders |
| **Grey Dark** | `#616161` | rgb(97, 97, 97) | Textos terciarios, subtítulos |

```dart
// Flutter
static const int backgroundColor = 0xFFFAFAFA;
static const int surfaceColor = 0xFFF5F5F5;
static const int greyLightColor = 0xFFE0E0E0;
static const int greyMediumColor = 0xFF9E9E9E;
static const int greyDarkColor = 0xFF616161;
```

---

## 🔵 Colores de Texto

### Tipografía
Colores específicos para la tipografía según jerarquía.

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **Text Primary** | `#0D47A1` | rgb(13, 71, 161) | Títulos principales, encabezados destacados |
| **Text Secondary** | `#1565C0` | rgb(21, 101, 192) | Subtítulos, enlaces |
| **Text Body** | `#424242` | rgb(66, 66, 66) | Texto general del cuerpo |
| **Text Muted** | `#757575` | rgb(117, 117, 117) | Textos secundarios, descripciones |
| **Text on Primary** | `#FFFFFF` | rgb(255, 255, 255) | Texto sobre fondos azules |

```dart
// Flutter
static const int textPrimaryColor = 0xFF0D47A1;
static const int textSecondaryColor = 0xFF1565C0;
static const int textBodyColor = 0xFF424242;
static const int textMutedColor = 0xFF757575;
```

---

## ✅ Colores de Estado

### Estados y Notificaciones
Colores para indicar estados en la aplicación.

| Nombre | Hex | RGB | Uso |
|--------|-----|-----|-----|
| **Success** | `#4CAF50` | rgb(76, 175, 80) | Éxito, aprobado, autorizado |
| **Warning** | `#FF9800` | rgb(255, 152, 0) | Advertencia, pendiente |
| **Error** | `#F44336` | rgb(244, 67, 54) | Error, rechazado, observado |
| **Info** | `#2196F3` | rgb(33, 150, 243) | Información, en proceso |

```dart
// Flutter
static const int successColor = 0xFF4CAF50;
static const int warningColor = 0xFFFF9800;
static const int errorColor = 0xFFF44336;
static const int infoColor = 0xFF2196F3;
```

---

## 🏷️ Estados de Solicitudes

Colores específicos para los estados de las solicitudes en el sistema.

| Estado | Color | Hex | Descripción |
|--------|-------|-----|-------------|
| **Pendiente** | 🟠 Naranja | `#FF9800` | Solicitud en espera de revisión |
| **Autorizado** | 🟢 Verde | `#4CAF50` | Solicitud aprobada |
| **Observado** | 🔴 Rojo | `#F44336` | Solicitud con observaciones/rechazada |
| **En Proceso** | 🔵 Azul | `#2196F3` | Solicitud en trámite |

---

## 🎯 Guía de Uso

### ✅ Hacer
- Usar el **azul primario** (#1565C0) para elementos de acción principales
- Usar **blanco** para fondos de contenido y textos sobre azul
- Usar **grises claros** para fondos secundarios y separadores
- Usar **azul oscuro** (#0D47A1) para títulos y textos importantes
- Mantener suficiente contraste entre texto y fondo

### ❌ Evitar
- No usar colores fuera de esta paleta sin aprobación
- No usar el color de error para elementos decorativos
- No combinar muchos colores en un mismo componente
- No usar grises muy oscuros como fondo principal

---

## 📱 Ejemplos de Aplicación

### AppBar
```dart
AppBarTheme(
  backgroundColor: Color(0xFF1565C0), // Primary
  foregroundColor: Colors.white,
)
```

### Botón Principal
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF1565C0), // Primary
    foregroundColor: Colors.white,
  ),
)
```

### Tarjeta de Módulo
```dart
Card(
  color: Color(0xFFF5F5F5), // Surface
  child: ListTile(
    leading: Icon(icon, color: Color(0xFF1565C0)), // Primary
    title: Text(title, style: TextStyle(color: Color(0xFF0D47A1))), // Text Primary
  ),
)
```

---

## 📅 Historial de Cambios

| Fecha | Versión | Descripción |
|-------|---------|-------------|
| 2026-01-25 | 1.0 | Creación inicial de la paleta de colores basada en identidad visual "La Buena" |

---

> **Nota:** Esta paleta está inspirada en la identidad visual de la marca, con tonos azules que transmiten confianza y profesionalismo, combinados con blancos y grises que aportan limpieza y claridad a la interfaz.
