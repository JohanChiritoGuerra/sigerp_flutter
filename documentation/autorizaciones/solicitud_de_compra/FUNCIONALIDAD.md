# 🛒 Solicitud de Compra - Funcionalidad

---

## 🔌 Endpoints de la API

### 1. Obtener Lista de Solicitudes de Compra

```http
GET /api/SolicitudCompra/ObtenerListaAutorizar
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
  "trabId": "string",         // ID del trabajador
  "empresaId": "string",      // ID de la empresa
  "estado": "string",         // "PENDIENTE" | "AUTORIZADO" | "OBSERVADO"
  "urgencia": "string",       // "URGENTE" | "NORMAL" | "TODOS"
  "proveedorId": "string",    // Filtro por proveedor (opcional)
  "montoMin": "decimal",      // Filtro monto mínimo (opcional)
  "montoMax": "decimal",      // Filtro monto máximo (opcional)
  "fechaInicio": "date",      // Filtro fecha inicio (opcional)
  "fechaFin": "date",         // Filtro fecha fin (opcional)
  "pagina": "int",            // Número de página (paginación)
  "tamanoPagina": "int"       // Registros por página (default: 20)
}
```

**Response:**
```json
{
  "success": true,
  "message": "Lista obtenida correctamente",
  "data": {
    "solicitudes": [
      {
        "solicitudId": "string",
        "codigo": "SC-2024-089",
        "urgencia": "URGENTE",
        "solicitante": {
          "trabId": "string",
          "nombreCompleto": "Pedro Sánchez",
          "area": "Compras"
        },
        "proveedor": {
          "proveedorId": "string",
          "razonSocial": "Tech Solutions SAC",
          "ruc": "20123456789"
        },
        "montoTotal": 13098.00,
        "subtotal": 11100.00,
        "igv": 1998.00,
        "fechaSolicitud": "2026-01-09T14:30:00",
        "descripcion": "Adquisición de equipos de cómputo para área administrativa",
        "estadoActual": "PENDIENTE",
        "nivelAutorizacionActual": 2,
        "esmiTurno": true
      }
    ],
    "totalRegistros": 15,
    "paginaActual": 1,
    "totalPaginas": 1
  }
}
```

---

### 2. Obtener Detalle de Solicitud de Compra

```http
GET /api/SolicitudCompra/ObtenerDetalle
```

**Query Parameters:**
```json
{
  "solicitudId": "string",
  "trabId": "string",
  "empresaId": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Detalle obtenido correctamente",
  "data": {
    "solicitudId": "string",
    "codigo": "SC-2024-089",
    "urgencia": "URGENTE",
    "solicitante": {
      "trabId": "string",
      "nombreCompleto": "Pedro Sánchez",
      "area": "Compras",
      "cargo": "Jefe de Compras"
    },
    "proveedor": {
      "proveedorId": "string",
      "razonSocial": "Tech Solutions SAC",
      "ruc": "20123456789",
      "direccion": "Av. Principal 123, Lima",
      "telefono": "01-2345678",
      "contacto": "Juan Pérez"
    },
    "fechaSolicitud": "2026-01-09T14:30:00",
    "descripcion": "Adquisición de equipos de cómputo para área administrativa según requerimiento adjunto",
    "items": [
      {
        "itemId": "string",
        "descripcion": "Laptop HP Core i7",
        "cantidad": 10,
        "precioUnitario": 800.00,
        "subtotal": 8000.00
      },
      {
        "itemId": "string",
        "descripcion": "Mouse inalámbrico",
        "cantidad": 10,
        "precioUnitario": 15.00,
        "subtotal": 150.00
      },
      {
        "itemId": "string",
        "descripcion": "Teclado mecánico",
        "cantidad": 10,
        "precioUnitario": 45.00,
        "subtotal": 450.00
      },
      {
        "itemId": "string",
        "descripcion": "Monitor 24 pulgadas",
        "cantidad": 10,
        "precioUnitario": 250.00,
        "subtotal": 2500.00
      }
    ],
    "subtotal": 11100.00,
    "igv": 1998.00,
    "montoTotal": 13098.00,
    "historialAutorizaciones": [
      {
        "nivel": 1,
        "nombreNivel": "Jefe de Área",
        "autorizador": {
          "trabId": "string",
          "nombreCompleto": "Carlos López",
          "cargo": "Jefe de Área"
        },
        "estado": "AUTORIZADO",
        "fechaAccion": "2026-01-09T14:45:00",
        "observacion": null
      },
      {
        "nivel": 2,
        "nombreNivel": "Gerente de Área",
        "autorizador": {
          "trabId": "string",
          "nombreCompleto": "Ana María Torres",
          "cargo": "Gerente de Área"
        },
        "estado": "PENDIENTE",
        "fechaAccion": null,
        "observacion": null
      },
      {
        "nivel": 3,
        "nombreNivel": "Gerencia General",
        "autorizador": null,
        "estado": "EN_COLA",
        "fechaAccion": null,
        "observacion": null
      }
    ],
    "estadoActual": "EN_PROCESO",
    "nivelActual": 2,
    "documentosAdjuntos": [
      {
        "documentoId": "string",
        "nombre": "Cotización_Tech_Solutions.pdf",
        "url": "https://...",
        "tipo": "PDF",
        "tamanio": 524288
      }
    ]
  }
}
```

---

### 3. Autorizar Solicitud de Compra

```http
POST /api/SolicitudCompra/Autorizar
```

**Body:**
```json
{
  "solicitudId": "string",
  "trabId": "string",
  "empresaId": "string",
  "nivelAutorizacion": 2,
  "observacion": "Autorizado conforme a presupuesto",
  "deviceInfo": {
    "deviceId": "string",
    "deviceType": "MOBILE",
    "ipAddress": "string",
    "userAgent": "string"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Solicitud de compra autorizada correctamente",
  "data": {
    "solicitudId": "string",
    "estado": "AUTORIZADO",
    "siguienteNivel": 3,
    "requiereMasAutorizaciones": true,
    "fechaAutorizacion": "2026-01-09T15:00:00"
  }
}
```

---

### 4. Observar Solicitud de Compra

```http
POST /api/SolicitudCompra/Observar
```

**Body:**
```json
{
  "solicitudId": "string",
  "trabId": "string",
  "empresaId": "string",
  "nivelAutorizacion": 2,
  "motivo": "Falta cotización comparativa de al menos 3 proveedores",
  "deviceInfo": {
    "deviceId": "string",
    "deviceType": "MOBILE",
    "ipAddress": "string",
    "userAgent": "string"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Solicitud de compra observada correctamente",
  "data": {
    "solicitudId": "string",
    "estado": "OBSERVADO",
    "fechaObservacion": "2026-01-09T15:00:00",
    "notificacionEnviada": true
  }
}
```

---

### 5. Obtener Lista de Proveedores

```http
GET /api/Proveedor/ObtenerLista
```

**Query Parameters:**
```json
{
  "empresaId": "string",
  "activo": true,
  "busqueda": "string"  // Buscar por RUC o razón social
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "proveedorId": "string",
      "razonSocial": "Tech Solutions SAC",
      "ruc": "20123456789"
    }
  ]
}
```

---

## 📋 Modelos de Datos (Dart)

### SolicitudCompra
```dart
class SolicitudCompra {
  final String solicitudId;
  final String codigo;
  final UrgenciaSolicitud urgencia;
  final Solicitante solicitante;
  final Proveedor proveedor;
  final double montoTotal;
  final double subtotal;
  final double igv;
  final DateTime fechaSolicitud;
  final String descripcion;
  final EstadoSolicitud estadoActual;
  final int nivelAutorizacionActual;
  final bool esmiTurno;
  final List<ItemSolicitud>? items;
  final List<AutorizacionHistorial>? historialAutorizaciones;
  final List<DocumentoAdjunto>? documentosAdjuntos;

  SolicitudCompra({
    required this.solicitudId,
    required this.codigo,
    required this.urgencia,
    required this.solicitante,
    required this.proveedor,
    required this.montoTotal,
    required this.subtotal,
    required this.igv,
    required this.fechaSolicitud,
    required this.descripcion,
    required this.estadoActual,
    required this.nivelAutorizacionActual,
    required this.esmiTurno,
    this.items,
    this.historialAutorizaciones,
    this.documentosAdjuntos,
  });

  factory SolicitudCompra.fromJson(Map<String, dynamic> json) {
    return SolicitudCompra(
      solicitudId: json['solicitudId'],
      codigo: json['codigo'],
      urgencia: UrgenciaSolicitud.fromString(json['urgencia']),
      solicitante: Solicitante.fromJson(json['solicitante']),
      proveedor: Proveedor.fromJson(json['proveedor']),
      montoTotal: (json['montoTotal'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      igv: (json['igv'] as num).toDouble(),
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      descripcion: json['descripcion'],
      estadoActual: EstadoSolicitud.fromString(json['estadoActual']),
      nivelAutorizacionActual: json['nivelAutorizacionActual'],
      esmiTurno: json['esmiTurno'] ?? false,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => ItemSolicitud.fromJson(i)).toList()
          : null,
      historialAutorizaciones: json['historialAutorizaciones'] != null
          ? (json['historialAutorizaciones'] as List)
              .map((h) => AutorizacionHistorial.fromJson(h))
              .toList()
          : null,
      documentosAdjuntos: json['documentosAdjuntos'] != null
          ? (json['documentosAdjuntos'] as List)
              .map((d) => DocumentoAdjunto.fromJson(d))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solicitudId': solicitudId,
      'codigo': codigo,
      'urgencia': urgencia.toString(),
      'solicitante': solicitante.toJson(),
      'proveedor': proveedor.toJson(),
      'montoTotal': montoTotal,
      'subtotal': subtotal,
      'igv': igv,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'descripcion': descripcion,
      'estadoActual': estadoActual.toString(),
      'nivelAutorizacionActual': nivelAutorizacionActual,
      'esmiTurno': esmiTurno,
      'items': items?.map((i) => i.toJson()).toList(),
      'historialAutorizaciones': historialAutorizaciones?.map((h) => h.toJson()).toList(),
      'documentosAdjuntos': documentosAdjuntos?.map((d) => d.toJson()).toList(),
    };
  }

  String get tiempoRelativo {
    final now = DateTime.now();
    final difference = now.difference(fechaSolicitud);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
```

### ItemSolicitud
```dart
class ItemSolicitud {
  final String itemId;
  final String descripcion;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  ItemSolicitud({
    required this.itemId,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory ItemSolicitud.fromJson(Map<String, dynamic> json) {
    return ItemSolicitud(
      itemId: json['itemId'],
      descripcion: json['descripcion'],
      cantidad: json['cantidad'],
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
```

### Proveedor
```dart
class Proveedor {
  final String proveedorId;
  final String razonSocial;
  final String ruc;
  final String? direccion;
  final String? telefono;
  final String? contacto;

  Proveedor({
    required this.proveedorId,
    required this.razonSocial,
    required this.ruc,
    this.direccion,
    this.telefono,
    this.contacto,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      proveedorId: json['proveedorId'],
      razonSocial: json['razonSocial'],
      ruc: json['ruc'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      contacto: json['contacto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proveedorId': proveedorId,
      'razonSocial': razonSocial,
      'ruc': ruc,
      'direccion': direccion,
      'telefono': telefono,
      'contacto': contacto,
    };
  }
}
```

### Enums
```dart
enum UrgenciaSolicitud {
  urgente,
  normal;

  static UrgenciaSolicitud fromString(String value) {
    switch (value.toUpperCase()) {
      case 'URGENTE':
        return UrgenciaSolicitud.urgente;
      case 'NORMAL':
        return UrgenciaSolicitud.normal;
      default:
        return UrgenciaSolicitud.normal;
    }
  }

  Color get color {
    switch (this) {
      case UrgenciaSolicitud.urgente:
        return const Color(0xFFF44336); // Rojo
      case UrgenciaSolicitud.normal:
        return const Color(0xFFFF9800); // Naranja
    }
  }

  String get label {
    switch (this) {
      case UrgenciaSolicitud.urgente:
        return 'URGENTE';
      case UrgenciaSolicitud.normal:
        return 'NORMAL';
    }
  }

  IconData get icon {
    switch (this) {
      case UrgenciaSolicitud.urgente:
        return Icons.priority_high;
      case UrgenciaSolicitud.normal:
        return Icons.shopping_cart;
    }
  }
}

enum EstadoSolicitud {
  pendiente,
  autorizado,
  observado,
  enProceso;

  static EstadoSolicitud fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDIENTE':
        return EstadoSolicitud.pendiente;
      case 'AUTORIZADO':
        return EstadoSolicitud.autorizado;
      case 'OBSERVADO':
        return EstadoSolicitud.observado;
      case 'EN_PROCESO':
        return EstadoSolicitud.enProceso;
      default:
        return EstadoSolicitud.pendiente;
    }
  }
}
```

---

## 🔄 Flujo de Autorización

```
1. Solicitud creada → Estado: PENDIENTE
   ↓
2. Nivel 1 (Jefe de Área)
   ├─ Autoriza → Pasa a Nivel 2
   └─ Observa → Estado: OBSERVADO (fin)
   ↓
3. Nivel 2 (Gerente de Área)
   ├─ Autoriza → Pasa a Nivel 3
   └─ Observa → Estado: OBSERVADO (fin)
   ↓
4. Nivel 3 (Gerencia General)
   ├─ Autoriza → Estado: AUTORIZADO (fin)
   └─ Observa → Estado: OBSERVADO (fin)
```

---

## 🔔 Sistema de Notificaciones Push

### Cuando se crea una nueva solicitud:
```json
{
  "to": "{device_token_nivel_1}",
  "notification": {
    "title": "Nueva autorización pendiente",
    "body": "Solicitud #SC-2024-089 - $13,098.00"
  },
  "data": {
    "type": "SOLICITUD_NUEVA",
    "solicitudId": "string",
    "screen": "SolicitudDetalleScreen"
  }
}
```

### Cuando se autoriza una solicitud:
- Notificar al siguiente nivel
- Notificar al solicitante del avance

### Cuando se observa una solicitud:
- Notificar al solicitante
- Incluir motivo de observación

---

## 💾 Almacenamiento Local

### Cache de solicitudes:
```dart
- Guardar lista en SQLite/Hive para modo offline
- Sincronizar cuando haya conexión
- Marcar items que requieren sincronización
```

### Preferencias:
```dart
- Último filtro aplicado
- Orden de visualización preferido
- Configuración de notificaciones
```

---

## ⚡ Optimizaciones

1. **Paginación**: Cargar 20 items por vez
2. **Cache de documentos**: Para visualización offline
3. **Debounce en búsqueda**: 300ms
4. **Pull to refresh**: Cooldown de 3 segundos
5. **Retry automático**: 3 intentos en caso de error

---

## 🛡️ Validaciones

### Antes de Autorizar:
- Verificar que es el turno del usuario
- Validar que la solicitud sigue pendiente
- Confirmar conexión a internet
- Verificar montos calculados (subtotal + IGV = total)

### Antes de Observar:
- Motivo obligatorio (mínimo 10 caracteres)
- Verificar que es el turno del usuario
- Confirmar acción con diálogo

---

## 🧪 Casos de Prueba

1. **Autorizar solicitud exitosamente**
2. **Observar solicitud con motivo válido**
3. **Intentar autorizar sin conexión**
4. **Filtrar por urgencia**
5. **Filtrar por proveedor**
6. **Buscar solicitud por código**
7. **Verificar cálculo de IGV**
8. **Paginación de lista**
9. **Pull to refresh**
10. **Navegación entre tabs**
11. **Ver detalle y regresar**
12. **Recibir notificación push**
13. **Descargar documento adjunto**
