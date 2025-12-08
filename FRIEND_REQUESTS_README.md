# 🤝 Sistema de Solicitudes de Amistad

## ✅ Implementación Completa

### 📦 Archivos Creados

1. **`lib/data/services/friendship_service.dart`** - Servicio de gestión de amistades
2. **`lib/presentation/screens/friend_requests_screen.dart`** - Pantalla de solicitudes
3. **`database/friend_requests_table.sql`** - Script SQL para crear la tabla

### 🗄️ Base de Datos

**IMPORTANTE:** Ejecuta el script SQL en Supabase:

1. Ve a tu proyecto en Supabase
2. Abre el SQL Editor
3. Copia y pega el contenido de `database/friend_requests_table.sql`
4. Ejecuta el script

Esto creará:
- ✅ Tabla `friend_requests`
- ✅ Índices para optimización
- ✅ Políticas de seguridad RLS
- ✅ Triggers automáticos

### 🎯 Funcionalidades

#### 📤 **Enviar Solicitud**
```dart
final result = await friendshipService.sendFriendRequest(userId);
// Retorna: {'success': bool, 'message': String}
```

#### 📥 **Ver Solicitudes Recibidas**
```dart
final requests = await friendshipService.getIncomingRequests();
// Lista de usuarios que te enviaron solicitud
```

#### 📮 **Ver Solicitudes Enviadas**
```dart
final requests = await friendshipService.getOutgoingRequests();
// Lista de solicitudes que enviaste (pendientes)
```

#### ✅ **Aceptar Solicitud**
```dart
final result = await friendshipService.acceptFriendRequest(requestId);
// Crea la amistad bidireccional automáticamente
```

#### ❌ **Rechazar Solicitud**
```dart
final result = await friendshipService.rejectFriendRequest(requestId);
```

#### 🚫 **Cancelar Solicitud Enviada**
```dart
final result = await friendshipService.cancelFriendRequest(requestId);
```

#### 🔍 **Buscar Usuarios**
```dart
final users = await friendshipService.searchUsers('nombre');
// Excluye al usuario actual
```

#### 📊 **Ver Estado de Amistad**
```dart
final status = await friendshipService.checkFriendshipStatus(userId);
// Retorna: 'self', 'friends', 'request_sent', 'request_received', 'none'
```

### 🎨 Pantallas Actualizadas

#### 1. **FriendsScreen** (Pantalla de Amigos)
**Nuevas funciones:**
- 📩 Botón de solicitudes con badge (contador de pendientes)
- 🔍 Búsqueda de usuarios integrada
- ➕ Enviar solicitudes desde resultados de búsqueda
- 🎨 Cards mejoradas con rangos y colores

**Acciones:**
- Tap en amigo → Ver perfil
- Botón "Solicitudes" → Ver solicitudes entrantes/salientes
- Botón "Buscar" → Buscar y agregar usuarios
- Pull to refresh → Actualizar lista

#### 2. **FriendRequestsScreen** (Nueva)
**2 pestañas:**

**Recibidas:**
- Ver quién te envió solicitud
- Botones: Aceptar / Rechazar
- Tap en usuario → Ver perfil

**Enviadas:**
- Ver tus solicitudes pendientes
- Botón: Cancelar
- Tap en usuario → Ver perfil

**Características:**
- ✨ Contador de solicitudes en cada tab
- 🔄 Pull to refresh
- 🎨 Animaciones suaves
- 📊 Estados vacíos informativos

### 🔐 Seguridad

**Row Level Security (RLS) configurado:**
- ✅ Solo puedes ver tus solicitudes (enviadas/recibidas)
- ✅ Solo puedes enviar solicitudes en tu nombre
- ✅ Solo puedes aceptar/rechazar las que recibes
- ✅ Solo puedes cancelar las que enviaste
- ✅ No puedes enviarte solicitudes a ti mismo
- ✅ No se permiten solicitudes duplicadas

### 📱 Flujo de Usuario

1. **Usuario A busca a Usuario B:**
   ```
   Amigos → Buscar → Escribir nombre → Ver resultados
   ```

2. **Usuario A envía solicitud:**
   ```
   Tap "Agregar" → Solicitud enviada
   ```

3. **Usuario B recibe notificación:**
   ```
   Badge rojo en botón de solicitudes (contador)
   ```

4. **Usuario B revisa y acepta:**
   ```
   Solicitudes → Tab "Recibidas" → Ver Usuario A → Aceptar
   ```

5. **Ambos son amigos:**
   ```
   Aparecen en la lista de amigos mutuamente
   ```

### 🎯 Estados de Solicitud

- **`pending`**: Solicitud enviada, esperando respuesta
- **`accepted`**: Aceptada (se crea amistad automáticamente)
- **`rejected`**: Rechazada

### 🔄 Relaciones

**Tabla `friend_requests`:**
```
sender_id → Usuario que envía la solicitud
receiver_id → Usuario que recibe la solicitud
status → Estado actual
```

**Tabla `user_friends`:**
```
Cuando se acepta una solicitud, se crean 2 registros:
1. user_id: A, friend_id: B
2. user_id: B, friend_id: A
(Relación bidireccional)
```

### 🎨 Mejoras Visuales

- ✨ Badges de notificación en rojo
- 🎨 Colores de rango en avatares
- 📊 Iconos descriptivos
- 🔄 Animaciones suaves
- 📱 Estados vacíos informativos
- ⚡ Pull to refresh

### 🧪 Cómo Probar

1. **Ejecuta el script SQL en Supabase** ⚠️
2. Hot reload de la app
3. Ve a la pantalla de **Amigos** (👥)
4. Toca el botón de **búsqueda** (🔍)
5. Busca un usuario
6. Toca **"Agregar"**
7. Ve a **Solicitudes** (📩)
8. Verás tus solicitudes enviadas
9. Desde otra cuenta, verás solicitudes recibidas

### 📋 Checklist de Implementación

- [x] Servicio de amistad (`FriendshipService`)
- [x] Pantalla de solicitudes (`FriendRequestsScreen`)
- [x] Actualización de `FriendsScreen`
- [x] Script SQL con tabla y políticas
- [x] Búsqueda de usuarios
- [x] Enviar solicitudes
- [x] Aceptar/Rechazar
- [x] Cancelar enviadas
- [x] Badge de notificaciones
- [x] Animaciones y UI
- [ ] **Ejecutar script SQL en Supabase** ⚠️

### 🚀 Próximas Mejoras Sugeridas

1. **Notificaciones push** cuando llega una solicitud
2. **Sugerencias de amigos** basadas en lugares visitados
3. **Historial de solicitudes** rechazadas/canceladas
4. **Bloquear usuarios** que envían spam
5. **Amigos mutuos** en perfil de usuario
6. **Límite de solicitudes** por día (anti-spam)

---

**Nota:** No olvides ejecutar el script SQL antes de probar! 🎯
