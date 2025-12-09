# Instrucciones para implementar el Ranking de Lugares

## 🎯 Funcionalidad implementada

Se ha agregado un sistema de **ranking de lugares más visitados** en la pantalla de ranking, con dos pestañas:

1. **👥 Usuarios**: Muestra el ranking de usuarios por puntos de actividad (ya existente)
2. **📍 Lugares**: Muestra los lugares más populares según las visitas de todos los usuarios

---

## 📝 Pasos para completar la implementación

### 1. Ejecutar la función SQL en Supabase

Debes ejecutar el archivo SQL en tu proyecto de Supabase para crear la función que obtiene el ranking de lugares:

**Archivo:** `supabase_migrations/create_get_top_places_function.sql`

**Cómo ejecutarlo:**

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Navega a **SQL Editor** en el menú lateral
3. Crea una nueva query
4. Copia y pega el contenido del archivo `create_get_top_places_function.sql`
5. Haz clic en **Run** para ejecutar la función

**¿Qué hace esta función?**

- Cuenta las visitas por lugar desde la tabla `user_places`
- Agrupa los lugares por nombre, dirección y coordenadas
- Devuelve los lugares ordenados por número de visitas (descendente)
- Acepta un parámetro `limit_count` para limitar resultados (por defecto 50)

---

## 🎨 Características del Ranking de Lugares

### Diseño visual:
- 🥇 **Top 3 destacado**: Oro, Plata y Bronce con bordes especiales
- 📍 **Ícono de ubicación**: Cada lugar tiene un ícono circular con el pin de Maps
- 👥 **Contador de visitas**: Muestra cuántas veces fue visitado el lugar
- 📌 **Dirección completa**: Se muestra debajo del nombre del lugar

### Funcionalidad:
- **Tap en lugar**: Abre un diálogo con opciones
- **Botón "Abrir en Maps"**: Lanza Google Maps con las coordenadas exactas
- **Refresh**: Pull-to-refresh para actualizar el ranking
- **Filtros**: Top 10, 25, 50, 100 (mismo que ranking de usuarios)

---

## 🔄 Fallback automático

Si la función SQL no está creada o falla, el código tiene un **fallback** que:

1. Consulta directamente la tabla `user_places`
2. Agrupa manualmente los lugares en el cliente
3. Ordena por visitas y limita resultados
4. Esto evita errores, pero es menos eficiente

**Recomendación:** Ejecuta la función SQL para mejor rendimiento.

---

## 📊 Estructura de datos

La función `get_top_places()` devuelve:

```sql
{
  place_name: TEXT,           -- Nombre del lugar
  place_address: TEXT,        -- Dirección completa
  place_latitude: DOUBLE,     -- Latitud
  place_longitude: DOUBLE,    -- Longitud
  visit_count: BIGINT         -- Número de visitas
}
```

---

## 🧪 Pruebas

Para probar la funcionalidad:

1. Asegúrate de tener datos en `user_places` con `visited = true`
2. Ve a la pantalla de Ranking en la app
3. Cambia a la pestaña **📍 Lugares**
4. Deberías ver los lugares ordenados por popularidad
5. Haz tap en un lugar para ver opciones
6. Prueba el botón "Abrir en Maps"

---

## 🐛 Troubleshooting

### No aparecen lugares:
- Verifica que existan registros en `user_places` con `visited = true`
- Revisa los logs en la consola de Flutter: `debugPrint('Error loading places ranking: ...')`

### Error al cargar ranking:
- Si no ejecutaste la función SQL, el fallback se activará automáticamente
- Revisa los permisos de la tabla `user_places` (debe permitir `SELECT`)

### El botón "Abrir en Maps" no funciona:
- Verifica que el paquete `url_launcher` esté instalado en `pubspec.yaml`
- Asegúrate de tener permisos de internet en Android/iOS

---

## 📦 Dependencias requeridas

Ya están en el proyecto:
- ✅ `supabase_flutter`
- ✅ `url_launcher`
- ✅ `flutter/material.dart`

---

## 🎉 ¡Listo!

Una vez ejecutada la función SQL en Supabase, el ranking de lugares estará completamente funcional. Los usuarios podrán ver qué lugares son los más populares y explorar nuevas opciones basadas en las preferencias de la comunidad.
