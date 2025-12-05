# 🔑 Solución: Error "Invalid API key" en Login

## Problema
```
AuthApiException(message: Invalid API key, statusCode: 401, code: null)
```

## Causa
La API key configurada en `supabase_config.dart` no es válida o está desactualizada.

## ✅ Solución: Obtener las Credenciales Correctas

### Paso 1: Ir a tu Proyecto de Supabase

1. Abre tu navegador y ve a [Supabase Dashboard](https://supabase.com/dashboard)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto: **aukzmohxmqvgqrfporwg**

### Paso 2: Obtener las Credenciales

1. En el menú lateral izquierdo, haz clic en **⚙️ Settings** (Configuración)
2. En el submenú, selecciona **API**
3. Verás dos secciones importantes:

#### Project URL
```
https://aukzmohxmqvgqrfporwg.supabase.co
```
(Esta ya la tienes correcta)

#### Project API keys

Encontrarás dos keys:

**anon / public key** (Esta es la que necesitas):
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**service_role key** (NO uses esta en la app, es solo para backend):
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Paso 3: Actualizar el Archivo de Configuración

1. Copia la **anon/public key** completa
2. Abre el archivo: `lib/config/supabase_config.dart`
3. Reemplaza el valor de `supabaseAnonKey`:

```dart
class SupabaseConfig {
  static String get supabaseUrl => 'https://aukzmohxmqvgqrfporwg.supabase.co';
  
  // ⚠️ REEMPLAZA ESTA KEY CON LA QUE COPIASTE DE SUPABASE DASHBOARD
  static String get supabaseAnonKey =>
      'TU_ANON_KEY_AQUI';  // ← Pega aquí la key completa
      
  // ... resto del código
}
```

### Paso 4: Verificar que el Usuario Existe

1. En Supabase Dashboard, ve a **Authentication** → **Users**
2. Busca tu email: `lsaucedolucas@gmail.com`
3. Si NO existe:
   - Haz clic en **Invite** o **Add user**
   - Ingresa el email
   - Establece una contraseña
   - Guarda

### Paso 5: Verificar las Políticas de Seguridad (RLS)

1. En Supabase Dashboard, ve a **Authentication** → **Policies**
2. Asegúrate de que las políticas permitan el login:
   - Debe haber una política que permita `SELECT` en la tabla `users`
   - Debe estar habilitado Row Level Security (RLS)

Si NO hay políticas o RLS está deshabilitado:

```sql
-- En SQL Editor de Supabase, ejecuta:

-- Habilitar RLS en tabla users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Permitir que los usuarios lean sus propios datos
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Permitir crear usuario al registrarse
CREATE POLICY "Users can insert on signup" ON users
  FOR INSERT WITH CHECK (true);
```

### Paso 6: Limpiar y Reconstruir

Después de actualizar la API key:

```bash
cd a_donde_vamos

# Limpiar caché
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar de nuevo
flutter run
```

## 🔍 Verificar que la API Key es Correcta

La API key debe:
- ✅ Empezar con `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.`
- ✅ Tener 3 partes separadas por puntos (header.payload.signature)
- ✅ Ser muy larga (más de 200 caracteres)
- ✅ NO contener espacios ni saltos de línea
- ✅ NO tener texto extra como "sb_publishable_"

## 🚨 Si el Error Persiste

### Opción 1: Regenerar la API Key

1. En Supabase Dashboard → Settings → API
2. Busca la opción **"Regenerate API keys"** o **"Reset API keys"**
3. Copia la nueva key y actualiza tu archivo

### Opción 2: Crear un Nuevo Usuario de Prueba

1. En Supabase Dashboard → Authentication → Users
2. Crea un nuevo usuario con email y contraseña diferentes
3. Usa esas credenciales para hacer login

### Opción 3: Verificar Estado del Proyecto

1. Verifica que tu proyecto de Supabase esté activo
2. Algunos proyectos se pausan por inactividad
3. Si está pausado, haz clic en **"Resume project"**

## 📝 Checklist de Verificación

- [ ] API key copiada desde Supabase Dashboard (Settings → API)
- [ ] API key pegada en `supabase_config.dart` sin espacios extra
- [ ] Usuario existe en Authentication → Users
- [ ] Proyecto de Supabase está activo (no pausado)
- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] App recompilada con `flutter run`

## 🎯 Confirmación Final

Después de actualizar la API key, deberías ver en los logs:

```
✅ supabase.supabase_flutter: INFO: ***** Supabase init completed *****
```

Y el login debería funcionar sin el error 401.

## 💡 Nota Importante

**NUNCA compartas tu service_role key públicamente**. Solo usa la **anon/public key** en tu aplicación móvil. La service_role key da acceso total a tu base de datos y solo debe usarse en el backend.
