# 🚀 Pasos para Probar las Nuevas Funcionalidades

## 1️⃣ Crear Tabla de Reseñas en Supabase

1. Abre [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto `aukzmohxmqvgqrfporwg`
3. Ve a **SQL Editor** (ícono de base de datos en el menú)
4. Crea una nueva query
5. Copia y pega TODO el contenido del archivo:
   ```
   database/place_reviews.sql
   ```
6. Presiona **Run** o **F5**
7. Deberías ver: ✅ Success. No rows returned

## 2️⃣ Recompilar la App

En tu máquina local (Windows), abre la terminal y ejecuta:

```bash
cd a_donde_vamos
flutter clean
flutter pub get
flutter run
```

## 3️⃣ Probar Funcionalidades

### ❤️ Favoritos
1. Abre un lugar desde el dashboard
2. Presiona el ícono de corazón en la parte superior
3. Debería aparecer una alerta neon: "Agregado a favoritos"
4. Cierra la app y vuelve a abrirla
5. Abre el mismo lugar
6. El corazón debería estar rojo (mantiene el estado)

### ✅ Lugares Visitados
1. En la pantalla de detalles, presiona "Ya visité"
2. Alerta neon: "¡Lugar visitado!"
3. El botón cambia de color/estado

### 🚫 Bloquear Lugares
1. Presiona "No recomendar más"
2. Alerta neon: "Lugar bloqueado"
3. En futuras búsquedas, este lugar NO debería aparecer

### ⭐ Reseñas
1. Baja al final de la pantalla de detalles
2. Presiona "Opinar"
3. Selecciona estrellas (1-5)
4. Escribe tu comentario
5. Presiona "Publicar"
6. Alerta neon: "¡Gracias!"
7. Tu reseña aparece en la lista inmediatamente

## 4️⃣ Solucionar Mapa en Blanco

Si el mapa sigue en blanco, ve a **Google Cloud Console**:

### Opción A: Verificar Facturación
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a **Billing**
4. Asegúrate de tener una tarjeta registrada
5. **Google da $200 USD gratis cada mes**

### Opción B: Verificar APIs Habilitadas
1. Ve a **APIs & Services** > **Library**
2. Busca y habilita:
   - ✅ Maps SDK for Android
   - ✅ Places API
   - ✅ Geocoding API

### Opción C: Revisar API Key
1. Ve a **APIs & Services** > **Credentials**
2. Encuentra tu key: `AIzaSyB8qeOmj_KuX_OMtJ__MDtC-PL9hk6voDM`
3. En **Application restrictions**: ponla en "None"
4. En **API restrictions**: "Don't restrict key"

Más detalles en `GOOGLE_MAPS_FIX.md`

## 5️⃣ Ver Logs en Caso de Error

```bash
# Ver todos los logs
flutter logs

# O específicamente de Google Maps
adb logcat | grep -i "maps\|google"
```

Busca errores como:
- ❌ "Authorization failure" → Problema con API Key
- ❌ "Billing not enabled" → Necesitas habilitar facturación
- ❌ "API not enabled" → Habilita Maps SDK for Android

## ✅ Checklist de Verificación

- [ ] Script SQL ejecutado en Supabase
- [ ] `flutter clean` ejecutado
- [ ] `flutter pub get` ejecutado
- [ ] App recompilada y ejecutándose
- [ ] Usuario autenticado en la app
- [ ] Favoritos funcionando y persistiendo
- [ ] "Ya visité" guardando en BD
- [ ] "No recomendar" bloqueando lugares
- [ ] Reseñas visibles
- [ ] Modal de nueva reseña funcionando
- [ ] Alertas neon mostrándose correctamente
- [ ] Mapa mostrando tiles (no en blanco)

## 🎯 Qué Esperar

### Alertas Neon
Cada acción muestra un diálogo con:
- 🎨 Borde con gradiente cyan-pink
- ✨ Efecto de brillo (glow)
- 💫 Ícono con anillo neon
- ✅ Mensaje de confirmación

### Reseñas
- 👁️ Ver reseñas de otros usuarios
- 👤 Avatar con inicial del nombre
- ⭐ Rating visual con estrellas
- 📅 Fecha relativa ("Hace 2 días")
- ➕ Botón para agregar tu reseña

### Persistencia
TODO se guarda en Supabase:
- Favoritos persisten entre sesiones
- Visitados tienen timestamp
- Bloqueados no aparecen en búsquedas
- Reseñas visibles para todos

## 🆘 ¿Algo no Funciona?

1. **Alertas no aparecen**: Verifica que no haya errores en `flutter logs`
2. **No guarda en BD**: Revisa tu conexión a internet
3. **Mapa en blanco**: 99% es facturación de Google Cloud
4. **Reseñas no aparecen**: Verifica que ejecutaste el script SQL
5. **App crashea**: Ejecuta `flutter clean` y recompila

## 📚 Documentación

- `FEATURES.md` - Guía completa de funcionalidades
- `GOOGLE_MAPS_FIX.md` - Solución detallada para mapa
- `IMPLEMENTATION_SUMMARY.md` - Resumen técnico completo
- `database/place_reviews.sql` - Script para crear tabla

## 💡 Tips

- Las alertas se cierran automáticamente o con "Aceptar"
- Puedes deshacer acciones (quitar favorito, desmarcar visitado)
- Las reseñas NO se pueden editar después de publicar (por ahora)
- El rating es obligatorio pero el comentario puede ser corto
- Los lugares bloqueados se pueden desbloquear presionando de nuevo

¡Disfruta las nuevas funcionalidades! 🎉
