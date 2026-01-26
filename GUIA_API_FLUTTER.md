# Guía: Cómo construir una app Flutter sin problemas de CORS

## Conceptos Fundamentales

### 1. ¿Qué es CORS y cuándo aplica?

**CORS (Cross-Origin Resource Sharing)** es una política de seguridad de los **navegadores web** que restringe las solicitudes HTTP entre diferentes orígenes (dominios).

**CORS SOLO aplica a:**
- ✅ Flutter Web (cuando la app corre en un navegador)
- ✅ Aplicaciones JavaScript/TypeScript en navegadores

**CORS NO aplica a:**
- ❌ Flutter Mobile (Android/iOS) - Apps nativas
- ❌ Flutter Desktop (Windows/Mac/Linux)
- ❌ Aplicaciones de servidor (Node.js, Python, etc.)

### 2. Por qué Flutter Mobile no tiene problemas de CORS

Las aplicaciones móviles nativas hacen solicitudes HTTP **directamente desde el sistema operativo**, no desde un navegador. Por lo tanto:
- No existe el concepto de "origen" (origin)
- No hay restricciones de dominio cruzado
- Puedes llamar a cualquier API sin configuración CORS

---

## Arquitectura Recomendada

### 1. Estructura de Configuración por Entorno

```dart
enum Environment { development, staging, production }

class AppConfig {
  static Environment _currentEnvironment = Environment.development;
  
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return kIsWeb 
          ? 'https://api.andahuasi.pe/'     // Web usa dominio para CORS
          : 'https://192.168.100.120:7091/'; // Mobile puede usar IP directa
      case Environment.staging:
        return 'https://staging.api.andahuasi.pe/';
      case Environment.production:
        return 'https://api.andahuasi.pe/';
    }
  }
}
```

**Ventajas:**
- Diferencia automáticamente entre Web y Mobile
- Facilita el desarrollo con IPs locales
- Preparado para múltiples entornos

### 2. Service Layer con Interceptores

```dart
class ApiService {
  // Manejo automático de:
  // ✅ Tokens de autenticación
  // ✅ Refresh token automático
  // ✅ Reintentos en caso de error 401
  // ✅ Timeouts configurables
  // ✅ Manejo de errores de red
}
```

---

## Soluciones para Problemas de CORS en Desarrollo Web

### Opción 1: Configurar el Backend (RECOMENDADO)

El backend debe agregar estos headers en la respuesta:

```csharp
// En .NET
builder.Services.AddCors(options => {
    options.AddPolicy("DevelopmentPolicy", policy => {
        policy.WithOrigins(
            "https://trab.andahuasi.pe:7091",  // Desarrollo
            "http://localhost:*",              // Localhost
            "https://*.andahuasi.pe"           // Wildcard para subdominios
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials();
    });
});
```

### Opción 2: Usar archivo hosts + Certificado SSL

**Ventajas:**
- Simula el entorno de producción
- El backend ve las solicitudes desde el dominio correcto
- No requiere cambios en el backend

**Pasos:**

1. **Editar `C:\Windows\System32\drivers\etc\hosts`:**
   ```
   192.168.100.120    trab.andahuasi.pe
   ```

2. **Ejecutar Flutter con HTTPS:**
   ```bash
   flutter run -d chrome \
     --web-port 7091 \
     --web-hostname trab.andahuasi.pe \
     --web-tls-cert-path cert.pem \
     --web-tls-cert-key-path key.pem
   ```

3. **Acceder a:** `https://trab.andahuasi.pe:7091`

### Opción 3: Chrome sin seguridad CORS (Solo desarrollo)

```bash
# Cerrar todas las instancias de Chrome primero
chrome.exe --disable-web-security --user-data-dir="C:/ChromeDevSession"
```

⚠️ **ADVERTENCIA:** Solo para desarrollo, NUNCA en producción.

### Opción 4: Extensión de Chrome

Instalar extensiones como:
- "CORS Unblock"
- "Allow CORS: Access-Control-Allow-Origin"

---

## Implementación de Refresh Token

### 1. Flujo Automático

```
┌─────────────┐
│   Request   │
└──────┬──────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│  API Call   │─401─▶│ Token        │
└──────┬──────┘      │ Expirado?    │
       │             └──────┬───────┘
       │                    │
       │             ┌──────▼───────┐
       │             │ Refresh      │
       │             │ Token Call   │
       │             └──────┬───────┘
       │                    │
       │             ┌──────▼───────┐
       │             │ Nuevo Token? │
       │             └──────┬───────┘
       │                    │
       │              ┌─────▼──────┐
       │              │   Retry    │
       │              │  Original  │
       │              │  Request   │
       │              └─────┬──────┘
       │                    │
       ▼                    ▼
┌─────────────┐      ┌──────────────┐
│   Success   │      │   Response   │
└─────────────┘      └──────────────┘
```

### 2. Implementación

```dart
// El ApiService maneja esto automáticamente:
final response = await apiService.get('api/usuarios');
// Si el token expiró (401), automáticamente:
// 1. Llama al endpoint de refresh token
// 2. Obtiene un nuevo token
// 3. Reintenta la petición original
// 4. Si el refresh falla, cierra la sesión
```

### 3. Configuración en AuthService

```dart
// Configurar callbacks para eventos de token
_apiService.onTokenExpired = () async {
  await logout(); // Cerrar sesión automáticamente
};

_apiService.onTokenRefreshed = (newToken) {
  // Actualizar usuario con el nuevo token
  _usuario = _usuario!.copyWith(token: newToken);
  _saveUserData();
};
```

---

## Mejores Prácticas

### ✅ DO (Hacer)

1. **Usar diferentes URLs para Web y Mobile en desarrollo**
   ```dart
   return kIsWeb ? domainUrl : localIpUrl;
   ```

2. **Implementar refresh token automático**
   - Mejora la experiencia del usuario
   - Evita cierres de sesión inesperados

3. **Manejar timeouts**
   ```dart
   .timeout(Duration(seconds: 30))
   ```

4. **Almacenar tokens de forma segura**
   ```dart
   FlutterSecureStorage() // Encriptado en el dispositivo
   ```

5. **Diferenciar errores de red vs errores de API**
   ```dart
   on http.ClientException catch (e) {
     // Error de red/CORS
   } catch (e) {
     // Otros errores
   }
   ```

### ❌ DON'T (No Hacer)

1. ❌ **No deshabilitar CORS en producción**
2. ❌ **No guardar tokens en SharedPreferences sin encriptar**
3. ❌ **No hardcodear URLs de API**
4. ❌ **No ignorar errores 401 sin manejo de refresh**
5. ❌ **No usar `http://` en producción**

---

## Testing

### Probar CORS localmente

1. **Abrir consola del navegador (F12)**
2. **Buscar errores CORS:**
   ```
   Access to fetch at 'https://api.example.com' from origin 
   'http://localhost:8080' has been blocked by CORS policy
   ```

3. **Verificar headers en Network tab:**
   - Request Headers: `Origin: http://localhost:8080`
   - Response Headers: `Access-Control-Allow-Origin: *`

### Probar en diferentes plataformas

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows
```

---

## Troubleshooting

### Problema: "Error de red" en Flutter Web

**Causa:** CORS bloqueando la petición

**Soluciones:**
1. Verificar que el backend tenga CORS configurado
2. Usar archivo hosts + certificado SSL
3. Ejecutar Chrome sin seguridad (solo dev)

### Problema: Token expirado constantemente

**Causa:** No se está guardando/usando el refresh token

**Solución:**
- Verificar que la API devuelva `refreshToken`
- Guardar en storage: `_storage.write(key: 'refresh_token')`
- Configurar en ApiService: `setRefreshToken(token)`

### Problema: 401 en cada petición

**Causa:** Token no se está enviando en headers

**Solución:**
- Verificar header: `Authorization: Bearer <token>`
- Confirmar que el token sea válido
- Verificar formato esperado por la API

---

## Recursos Adicionales

- [Flutter Web Security](https://flutter.dev/docs/development/platform-integration/web)
- [HTTP Package Documentation](https://pub.dev/packages/http)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [CORS MDN Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

---

## Resumen

### Para Flutter Mobile/Desktop
- ✅ No hay problemas de CORS
- ✅ Puede usar IPs directamente
- ✅ Configuración simple y directa

### Para Flutter Web
- ⚠️ Requiere configuración CORS en backend
- ⚠️ Debe usar dominios (no IPs locales)
- ⚠️ Necesita HTTPS en producción
- ✅ Archivo hosts + SSL para desarrollo

### Implementación de Tokens
- ✅ Guardar de forma segura con `FlutterSecureStorage`
- ✅ Implementar refresh token automático
- ✅ Manejar expiración gracefully
- ✅ Cerrar sesión automáticamente si refresh falla
