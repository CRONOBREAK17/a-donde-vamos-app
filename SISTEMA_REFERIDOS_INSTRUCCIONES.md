# 🎁 Sistema de Referidos - Instrucciones de Implementación

## 📋 Resumen

Se ha implementado un **sistema completo de referidos** que recompensa:
- **40 puntos** al usuario que invita por cada amigo que se una
- **20 puntos** al nuevo usuario que usa un código de referido
- **Campo opcional en el registro** para ingresar código directamente

---

## ✅ Componentes Implementados

### 1. **Base de datos (Supabase)**
   - ✅ Tabla `referrals` para tracking de referidos
   - ✅ Campos agregados a `users`: `referral_code`, `referred_by`, `referral_points_earned`
   - ✅ Función SQL `apply_referral_code()` para validar y aplicar códigos
   - ✅ Función SQL `get_referral_stats()` para obtener estadísticas
   - ✅ Trigger automático para generar códigos únicos al registrar usuarios
   - ✅ RLS (Row Level Security) configurado

### 2. **Servicio de Referidos (Flutter)**
   - ✅ `ReferralService` con métodos para:
     - Obtener código de referido del usuario
     - Aplicar código de referido
     - Obtener estadísticas (total de referidos y puntos)
     - Obtener lista de usuarios referidos
     - Verificar si el usuario fue referido
     - Generar mensaje para compartir

### 3. **Pantallas**
   - ✅ **ReferralScreen**: Pantalla principal de referidos
     - Muestra código único del usuario
     - Estadísticas (referidos y puntos ganados)
     - Lista de amigos referidos
     - Botones para copiar y compartir código
     - Sección "¿Cómo funciona?"
   
   - ✅ **ReferralInputScreen**: Para nuevos usuarios
     - Campo de entrada para código de referido
     - Validación en tiempo real
     - Opción de omitir
     - Mensajes de éxito/error

   - ✅ **Botón en ProfileScreen**: Acceso rápido a referidos

### 4. **Rutas y Navegación**
   - ✅ Rutas agregadas: `/referral` y `/referral-input`
   - ✅ Imports configurados en `main.dart`

### 5. **Dependencias**
   - ✅ `share_plus: ^10.1.2` agregado a `pubspec.yaml`

---

## 🚀 Pasos para Completar la Implementación

### **Paso 1: Ejecutar SQL en Supabase**

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Navega a **SQL Editor**
3. Copia y pega el contenido de: `supabase_migrations/create_referral_system.sql`
4. Ejecuta el script (Run)

**Importante:** Este script creará:
- Nuevos campos en la tabla `users`
- Tabla `referrals`
- Funciones SQL para lógica de negocio
- Triggers automáticos
- Políticas de seguridad (RLS)

---

### **Paso 2: Instalar Dependencias**

En la terminal, dentro de la carpeta del proyecto Flutter:

```bash
cd a_donde_vamos
flutter pub get
```

Esto instalará el paquete `share_plus` para compartir el código de referido.

---

### **Paso 3: ✅ Integrado en el Registro**

El sistema ya está integrado en la pantalla de registro (`auth_screen.dart`):
- Campo opcional "Código de referido" visible durante el registro
- Se procesa automáticamente al crear la cuenta
- No requiere pasos adicionales del usuario

**El código se aplica automáticamente en segundo plano cuando el usuario se registra.**

---

### **Paso 4: Verificar Código Existente**

Busca usuarios existentes en tu base de datos. El trigger automático solo funciona para **nuevos usuarios**. Para usuarios existentes, ejecuta este SQL en Supabase:

```sql
-- Generar códigos de referido para usuarios existentes
UPDATE users 
SET referral_code = (
  SELECT substr(md5(random()::text || id::text), 1, 8)
)
WHERE referral_code IS NULL;
```

---

## 🎨 Características del Sistema

### **Para el Usuario que Invita:**
- 🎁 Recibe **40 puntos** por cada amigo que use su código
- 📊 Ve estadísticas de cuántos amigos ha referido
- 👥 Lista de todos sus referidos con fechas
- 📋 Puede copiar su código con un tap
- 📤 Puede compartir su código por WhatsApp, Telegram, etc.

### **Para el Usuario Nuevo:**
- ✨ Puede ingresar un código de referido directamente en el registro
- 🎁 Recibe **20 puntos de bonificación** al usar un código válido
- 🎉 Su amigo también gana 40 puntos
- ⏭️ El campo es opcional, puede dejarlo vacío

### **Validaciones Automáticas:**
- ✅ Código único y válido
- ✅ No puede usar su propio código
- ✅ Solo puede usar un código (una vez por usuario)
- ✅ Código case-insensitive (ABC123 = abc123)

---

## 📱 Flujo de Usuario

### **Usuario Existente (Invitar):**
1. Va a su perfil
2. Toca el botón "🎁 Invita y Gana"
3. Ve su código único (ej: `XYZ12345`)
4. Toca "Copiar" o "Compartir"
5. Envía el código a un amigo
6. Cuando su amigo se registra con el código, recibe 40 puntos
7. Ve al amigo en su lista de referidos

### **Usuario Nuevo (Ser Referido):**
1. Se registra en la app
2. Ve el campo opcional "Código de referido"
3. Ingresa el código de su amigo (opcional)
4. Completa el registro
5. Automáticamente recibe 20 puntos
6. Su amigo recibe 40 puntos automáticamente

---

## 🧪 Pruebas

### **Probar el Sistema:**

1. **Crear un usuario de prueba**
   - Regístrate con un email de prueba
   - Ve a tu perfil → "Invita y Gana"
   - Anota tu código de referido

2. **Crear un segundo usuario**
   - Regístrate con otro email
   - Ingresa el código del primer usuario
   - Verifica que se aplique correctamente

3. **Verificar puntos**
   - Cierra sesión del segundo usuario
   - Inicia sesión con el primer usuario
   - Ve a "Invita y Gana"
   - Deberías ver: 1 referido y 40 puntos

4. **Probar compartir**
   - Toca "Compartir" en la pantalla de referidos
   - Verifica que se abra el selector de apps
   - El mensaje debería incluir tu código

---

## 🐛 Troubleshooting

### **"Error al aplicar código"**
- Verifica que ejecutaste el SQL en Supabase
- Revisa los logs en la consola de Flutter
- Asegúrate de que el usuario no haya sido referido antes

### **"Código inválido"**
- El código debe existir en la base de datos
- Verifica que el usuario que invita tenga un `referral_code`
- Ejecuta el SQL para generar códigos a usuarios existentes

### **No aparece el botón "Invita y Gana"**
- Verifica que importaste `referral_screen.dart` en `main.dart`
- Asegúrate de que la ruta `/referral` esté configurada

### **Error al compartir**
- Verifica que `share_plus` esté instalado: `flutter pub get`
- Revisa los permisos de la app en el dispositivo

---

## 📊 Estadísticas y Métricas

Puedes consultar estadísticas globales con estas queries SQL:

```sql
-- Total de referidos en la app
SELECT COUNT(*) as total_referrals FROM referrals;

-- Usuarios que más han referido
SELECT 
  u.username,
  COUNT(r.id) as referral_count,
  SUM(r.points_awarded) as total_points_earned
FROM users u
JOIN referrals r ON r.referrer_id = u.id
GROUP BY u.id, u.username
ORDER BY referral_count DESC
LIMIT 10;

-- Referidos en los últimos 7 días
SELECT COUNT(*) 
FROM referrals 
WHERE created_at > NOW() - INTERVAL '7 days';
```

---

## 🎯 Futuras Mejoras (Opcionales)

- 🏆 **Leaderboard de referidos**: Ranking de usuarios con más referidos
- 🎁 **Recompensas escalonadas**: Más puntos por hitos (10, 50, 100 referidos)
- 📧 **Emails automáticos**: Notificar cuando alguien usa tu código
- 🔗 **Deep linking**: Crear enlaces personalizados con el código incluido
- 💰 **Recompensas premium**: Dar 1 mes gratis después de X referidos
- 📱 **Notificaciones push**: Alertar cuando ganas puntos por referido

---

## ✅ Checklist Final

Antes de lanzar a producción:

- [ ] SQL ejecutado en Supabase
- [ ] `flutter pub get` ejecutado
- [ ] Códigos generados para usuarios existentes
- [ ] Probado con 2+ usuarios de prueba
- [ ] Verificado que se otorgan 40 puntos
- [ ] Probado el botón "Compartir"
- [ ] Verificado que la lista de referidos se muestra correctamente
- [ ] Revisado que no se puede usar el mismo código dos veces
- [ ] Confirmado que no puedes usar tu propio código

---

## 🎉 ¡Listo!

El sistema de referidos está completamente implementado y listo para usar. Los usuarios ahora pueden invitar a sus amigos y ganar puntos por cada uno que se una a la app.

**Beneficios para tu app:**
- 📈 **Crecimiento viral**: Los usuarios invitan a sus amigos
- 🎮 **Gamificación**: Más engagement con el sistema de puntos
- 👥 **Comunidad**: Fomenta la interacción entre usuarios
- 💰 **Monetización**: Usuarios premium pueden tener códigos especiales

¿Preguntas o problemas? Revisa los logs de Flutter y Supabase para más detalles.
