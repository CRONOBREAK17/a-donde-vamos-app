# 🚀 INSTRUCCIONES RÁPIDAS - Sistema Premium V2

## ⚡ Pasos Inmediatos

### 1️⃣ Ejecutar SQL en Supabase (OBLIGATORIO)

1. Ir a **Supabase Dashboard** → **SQL Editor**
2. Copiar COMPLETO el archivo: `database/migration_premium_v2.sql`
3. Pegar y ejecutar
4. Verificar que salió exitoso ✅

### 2️⃣ Probar la App

```bash
# Hot restart (recomendado)
flutter run
```

O simplemente **reiniciar la app** en el emulador

---

## 🎯 ¿Qué Cambió?

### Antes ❌
- Límite de 3 búsquedas **con filtros** por día
- Después del límite: búsquedas aleatorias sin filtros
- Precio fijo: $4.99 USD

### Ahora ✅
- Límite de 3 búsquedas **TOTALES** por día  
- Después del límite: botón deshabilitado + modal premium
- Precio dinámico según país ($30 MXN en México, etc.)
- Temporizador mostrando próximo reseteo

---

## 🧪 Cómo Probar

### Test 1: Usuario Gratuito
1. Abrir app (NO ser premium)
2. Hacer búsqueda → Contador: `2/3 búsquedas` ✅
3. Hacer búsqueda → Contador: `1/3 búsquedas` ✅
4. Hacer búsqueda → Contador: `0/3 búsquedas` ✅
5. Intentar 4ta búsqueda → Modal Premium aparece ✅
6. Botón debe decir: "🔒 Sin búsquedas disponibles" ✅

### Test 2: Temporizador
1. Alcanzar límite de búsquedas
2. Verificar que aparece: "⏰ Próximo reseteo en Xh Xm" ✅
3. El tiempo debe ser dinámico (contar hacia abajo)

### Test 3: Moneda Local
1. Ir a pantalla Premium (`/premium`)
2. Verificar que el precio se muestra en tu moneda local
   - México: `$30 MXN`
   - USA: `$1.67 USD`
   - Argentina: `$585 ARS`
   - etc.

### Test 4: Usuario Premium
1. Cambiar `is_premium = true` en Supabase
2. Hot restart
3. Verificar insignia dorada "PREMIUM" ✅
4. Hacer 10+ búsquedas → Sin límite ✅

---

## 🔧 Solución de Problemas

### Problema: "Columna no existe"
**Solución**: Ejecutar el SQL de migración en Supabase

### Problema: Precio no se actualiza
**Solución**: 
```bash
flutter clean
flutter run
```

### Problema: Contador no resetea
**Solución**: Verificar que el SQL creó la función `reset_daily_searches()` correctamente

### Problema: Botón no se deshabilita
**Solución**: 
1. Verificar que `daily_searches_used >= 3`
2. Hot restart completo
3. Revisar logs en consola

---

## 📊 Monitoreo en Supabase

### Ver estado de usuarios:
```sql
SELECT 
    username,
    is_premium,
    daily_searches_used,
    last_search_reset
FROM users
ORDER BY daily_searches_used DESC;
```

### Resetear un usuario manualmente:
```sql
UPDATE users 
SET daily_searches_used = 0, last_search_reset = NOW()
WHERE id = 'USUARIO_ID_AQUI';
```

---

## ✅ Checklist Final

- [ ] SQL ejecutado en Supabase
- [ ] Columnas `daily_searches_used` y `last_search_reset` existen
- [ ] App reiniciada (hot restart)
- [ ] Contador "X/3 búsquedas" visible
- [ ] Botón se deshabilita al alcanzar límite
- [ ] Modal premium aparece al intentar buscar sin créditos
- [ ] Temporizador se muestra correctamente
- [ ] Precio en moneda local correcto

---

## 🎉 Todo Listo!

Si todos los tests pasan, el sistema está funcionando correctamente.

**Documentación completa**: Ver `PREMIUM_SYSTEM_V2.md`
