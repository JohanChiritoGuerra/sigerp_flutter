# 🚨 Presupuesto de Emergencia - Funcionalidad

---

## 🔌 Endpoints de la API

### 1. Obtener Lista de Presupuestos

```http
GET /api/PresupuestoEmergencia/ObtenerListaAutorizar
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
  "prioridad": "string",      // "EMERGENCIA" | "URGENTE" | "NORMAL" | "TODOS"
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
    "presupuestos": [
      {
        "presupId": "string",
        "codigo": "2024-0156",
        "prioridad": "EMERGENCIA",
        "solicitante": {
          "trabId": "string",
          "nombreCompleto": "Juan Pérez",
          "seccion": "Mantenimiento"
        },
        "montoTotal": 5250.00,
        "fechaSolicitud": "2026-01-09T10:45:00",
        "descripcion": "Reparación urgente de equipo compresor principal",
        "estadoActual": "PENDIENTE",
        "nivelAutorizacionActual": 2,
        "esmiTurno": true
      }
    ],
    "totalRegistros": 10,
    "paginaActual": 1,
    "totalPaginas": 1
  }
}
```

---

### 2. Obtener Detalle de Presupuesto

```http
GET /api/PresupuestoEmergencia/ObtenerDetalle
```

**Query Parameters:**
```json
{
  "presupId": "string",
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
    "presupId": "string",
    "codigo": "2024-0156",
    "prioridad": "EMERGENCIA",
    "solicitante": {
      "trabId": "string",
      "nombreCompleto": "Juan Pérez",
      "seccion": "Mantenimiento",
      "cargo": "Técnico"
    },
    "fechaSolicitud": "2026-01-09T10:45:00",
    "montoTotal": 5250.00,
    "descripcion": "Reparación urgente de equipo compresor principal que se encuentra fuera de servicio",
    "items": [
      {
        "itemId": "string",
        "descripcion": "Válvula hidráulica",
        "monto": 2500.00
      },
      {
        "itemId": "string",
        "descripcion": "Mano de obra",
        "monto": 1800.00
      },
      {
        "itemId": "string",
        "descripcion": "Repuestos varios",
        "monto": 950.00
      }
    ],
    "historialAutorizaciones": [
      {
        "nivel": 1,
        "nombreNivel": "Jefe Sección",
        "autorizador": {
          "trabId": "string",
          "nombreCompleto": "José Martínez",
          "cargo": "Jefe de Sección"
        },
        "estado": "AUTORIZADO",
        "fechaAccion": "2026-01-09T10:50:00",
        "observacion": null
      },
      {
        "nivel": 2,
        "nombreNivel": "Jefe Departamento",
        "autorizador": {
          "trabId": "string",
          "nombreCompleto": "Carlos Ramírez",
          "cargo": "Jefe de Departamento"
        },
        "estado": "PENDIENTE",
        "fechaAccion": null,
        "observacion": null
      },
      {
        "nivel": 3,
        "nombreNivel": "Gerencia",
        "autorizador": null,
        "estado": "EN_COLA",
        "fechaAccion": null,
        "observacion": null
      }
    ],
    "estadoActual": "EN_PROCESO",
    "nivelActual": 2
  }
}
```

---

### 3. Autorizar Presupuesto

```http
POST /api/PresupuestoEmergencia/Autorizar
```

**Body:**
```json
{
  "presupId": "string",
  "trabId": "string",
  "empresaId": "string",
  "nivelAutorizacion": 2,
  "observacion": "Autorizado conforme",
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
  "message": "Presupuesto autorizado correctamente",
  "data": {
    "presupId": "string",
    "estado": "AUTORIZADO",
    "siguienteNivel": 3,
    "requiereMasAutorizaciones": true,
    "fechaAutorizacion": "2026-01-09T11:00:00"
  }
}
```

---

### 4. Observar Presupuesto

```http
POST /api/PresupuestoEmergencia/Observar
```

**Body:**
```json
{
  "presupId": "string",
  "trabId": "string",
  "empresaId": "string",
  "nivelAutorizacion": 2,
  "motivo": "Falta documentación de sustento",
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
  "message": "Presupuesto observado correctamente",
  "data": {
    "presupId": "string",
    "estado": "OBSERVADO",
    "fechaObservacion": "2026-01-09T11:00:00",
    "notificacionEnviada": true
  }
}
```

---

## 📋 Modelos de Datos (Dart)

### PresupuestoEmergencia
```dart
class PresupuestoEmergencia {
  final String presupId;
  final String codigo;
  final PrioridadPresupuesto prioridad;
  final Solicitante solicitante;
  final double montoTotal;
  final DateTime fechaSolicitud;
  final String descripcion;
  final EstadoPresupuesto estadoActual;
  final int nivelAutorizacionActual;
  final bool esmiTurno;
  final List<ItemPresupuesto>? items;
  final List<AutorizacionHistorial>? historialAutorizaciones;

  PresupuestoEmergencia({
    required this.presupId,
    required this.codigo,
    required this.prioridad,
    required this.solicitante,
    required this.montoTotal,
    required this.fechaSolicitud,
    required this.descripcion,
    required this.estadoActual,
    required this.nivelAutorizacionActual,
    required this.esmiTurno,
    this.items,
    this.historialAutorizaciones,
  });

  factory PresupuestoEmergencia.fromJson(Map<String, dynamic> json) {
    return PresupuestoEmergencia(
      presupId: json['presupId'],
      codigo: json['codigo'],
      prioridad: PrioridadPresupuesto.fromString(json['prioridad']),
      solicitante: Solicitante.fromJson(json['solicitante']),
      montoTotal: (json['montoTotal'] as num).toDouble(),
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      descripcion: json['descripcion'],
      estadoActual: EstadoPresupuesto.fromString(json['estadoActual']),
      nivelAutorizacionActual: json['nivelAutorizacionActual'],
      esmiTurno: json['esmiTurno'] ?? false,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => ItemPresupuesto.fromJson(i)).toList()
          : null,
      historialAutorizaciones: json['historialAutorizaciones'] != null
          ? (json['historialAutorizaciones'] as List)
              .map((h) => AutorizacionHistorial.fromJson(h))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'presupId': presupId,
      'codigo': codigo,
      'prioridad': prioridad.toString(),
      'solicitante': solicitante.toJson(),
      'montoTotal': montoTotal,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'descripcion': descripcion,
      'estadoActual': estadoActual.toString(),
      'nivelAutorizacionActual': nivelAutorizacionActual,
      'esmiTurno': esmiTurno,
      'items': items?.map((i) => i.toJson()).toList(),
      'historialAutorizaciones': historialAutorizaciones?.map((h) => h.toJson()).toList(),
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

### Enums
```dart
enum PrioridadPresupuesto {
  emergencia,
  urgente,
  normal;

  static PrioridadPresupuesto fromString(String value) {
    switch (value.toUpperCase()) {
      case 'EMERGENCIA':
        return PrioridadPresupuesto.emergencia;
      case 'URGENTE':
        return PrioridadPresupuesto.urgente;
      case 'NORMAL':
        return PrioridadPresupuesto.normal;
      default:
        return PrioridadPresupuesto.normal;
    }
  }

  Color get color {
    switch (this) {
      case PrioridadPresupuesto.emergencia:
        return const Color(0xFFF44336); // Rojo
      case PrioridadPresupuesto.urgente:
        return const Color(0xFFFF9800); // Naranja
      case PrioridadPresupuesto.normal:
        return const Color(0xFF4CAF50); // Verde
    }
  }

  String get label {
    switch (this) {
      case PrioridadPresupuesto.emergencia:
        return 'EMERGENCIA';
      case PrioridadPresupuesto.urgente:
        return 'URGENTE';
      case PrioridadPresupuesto.normal:
        return 'NORMAL';
    }
  }

  IconData get icon {
    switch (this) {
      case PrioridadPresupuesto.emergencia:
        return Icons.error;
      case PrioridadPresupuesto.urgente:
        return Icons.warning;
      case PrioridadPresupuesto.normal:
        return Icons.info;
    }
  }
}

enum EstadoPresupuesto {
  pendiente,
  autorizado,
  observado,
  enProceso;

  static EstadoPresupuesto fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDIENTE':
        return EstadoPresupuesto.pendiente;
      case 'AUTORIZADO':
        return EstadoPresupuesto.autorizado;
      case 'OBSERVADO':
        return EstadoPresupuesto.observado;
      case 'EN_PROCESO':
        return EstadoPresupuesto.enProceso;
      default:
        return EstadoPresupuesto.pendiente;
    }
  }
}
```

---

## 🔄 Flujo de Autorización

```
1. Solicitud creada → Estado: PENDIENTE
   ↓
2. Nivel 1 (Jefe Sección)
   ├─ Autoriza → Pasa a Nivel 2
   └─ Observa → Estado: OBSERVADO (fin)
   ↓
3. Nivel 2 (Jefe Departamento)
   ├─ Autoriza → Pasa a Nivel 3
   └─ Observa → Estado: OBSERVADO (fin)
   ↓
4. Nivel 3 (Gerencia)
   ├─ Autoriza → Estado: AUTORIZADO (fin)
   └─ Observa → Estado: OBSERVADO (fin)
```

---

## 🔔 Sistema de Notificaciones Push

### Cuando se crea un nuevo presupuesto:
```json
{
  "to": "{device_token_nivel_1}",
  "notification": {
    "title": "Nueva autorización pendiente",
    "body": "Presupuesto #2024-0156 - $5,250.00"
  },
  "data": {
    "type": "PRESUPUESTO_NUEVO",
    "presupId": "string",
    "screen": "PresupuestoDetalleScreen"
  }
}
```

### Cuando se autoriza un presupuesto:
- Notificar al siguiente nivel
- Notificar al solicitante del avance

### Cuando se observa un presupuesto:
- Notificar al solicitante
- Incluir motivo de observación

---

## 💾 Almacenamiento Local

### Cache de presupuestos:
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
2. **Cache de imágenes**: Si hay fotos adjuntas
3. **Debounce en búsqueda**: 300ms
4. **Pull to refresh**: Cooldown de 3 segundos
5. **Retry automático**: 3 intentos en caso de error

---

## 🛡️ Validaciones

### Antes de Autorizar:
- Verificar que es el turno del usuario
- Validar que el presupuesto sigue pendiente
- Confirmar conexión a internet

### Antes de Observar:
- Motivo obligatorio (mínimo 10 caracteres)
- Verificar que es el turno del usuario
- Confirmar acción con diálogo

---

## 🧪 Casos de Prueba

1. **Autorizar presupuesto exitosamente**
2. **Observar presupuesto con motivo válido**
3. **Intentar autorizar sin conexión**
4. **Filtrar por prioridad**
5. **Buscar presupuesto por código**
6. **Paginación de lista**
7. **Pull to refresh**
8. **Navegación entre tabs**
9. **Ver detalle y regresar**
10. **Recibir notificación push**
