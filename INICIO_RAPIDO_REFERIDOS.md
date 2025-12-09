# 🚀 INICIO RÁPIDO - Sistema de Referidos

## ⚡ 3 Pasos para Activar

### 1️⃣ Ejecutar SQL en Supabase (5 min)
```
1. Abre https://app.supabase.com
2. Ve a SQL Editor
3. Copia/pega: supabase_migrations/create_referral_system.sql
4. Click en "Run"
```

### 2️⃣ Instalar Dependencias (2 min)
```bash
cd a_donde_vamos
flutter pub get
```

### 3️⃣ Probar (10 min)
```
1. Registra usuario A
2. Ve a Perfil → "Invita y Gana"
3. Copia el código
4. Registra usuario B
5. Ingresa el código de A
6. Verifica: A recibe +40 puntos
```

---

## 📱 Cómo Usar

### Usuario que Invita:
```
Perfil → 🎁 Invita y Gana → Compartir código
```

### Usuario Nuevo:
```
Registro → Campo "Código de referido (opcional)" → Ingresar código → +20 puntos automáticos
```

---

## 🎯 Recompensas

- **40 puntos** para quien invita por cada amigo
- **20 puntos** para el nuevo usuario que usa el código
- Los puntos se suman automáticamente al registrarse
- Visible en estadísticas de perfil

---

## 📂 Archivos Importantes

```
supabase_migrations/
  └── create_referral_system.sql          ← EJECUTAR EN SUPABASE

lib/data/services/
  └── referral_service.dart               ← Lógica de negocio

lib/presentation/screens/
  ├── referral_screen.dart                ← Pantalla principal
  └── referral_input_screen.dart          ← Ingresar código

SISTEMA_REFERIDOS_INSTRUCCIONES.md        ← Guía completa
SISTEMA_REFERIDOS_RESUMEN.md              ← Resumen ejecutivo
```

---

## ✅ Verificar que Funciona

```sql
-- En Supabase SQL Editor:

-- 1. Ver todos los referidos
SELECT * FROM referrals;

-- 2. Ver códigos de usuarios
SELECT username, referral_code FROM users;

-- 3. Ver puntos por referidos
SELECT 
  username,
  referral_points_earned,
  activity_points
FROM users
WHERE referral_points_earned > 0;
```

---

## 🐛 Si Algo No Funciona

### Error: "Función no existe"
→ No ejecutaste el SQL en Supabase

### Error: "share_plus not found"
→ Ejecuta: `flutter pub get`

### No aparece el código de referido
→ Los usuarios existentes necesitan código. Ejecuta:
```sql
UPDATE users 
SET referral_code = substr(md5(random()::text || id::text), 1, 8)
WHERE referral_code IS NULL;
```

---

## 🎉 ¡Listo!

Tu app ahora tiene sistema de referidos. Los usuarios pueden invitar amigos y ganar 40 puntos por cada uno.

**Documentación completa:** `SISTEMA_REFERIDOS_INSTRUCCIONES.md`
