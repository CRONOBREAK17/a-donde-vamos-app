# Solución: Mapa de Google Maps en Blanco

## Problema
El widget de Google Maps muestra solo el logo "Google" pero sin tiles (mapa en blanco).

## Posibles Causas y Soluciones

### 1. Verificar API Key en Google Cloud Console

Asegúrate de que tu API key tiene los permisos correctos:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Navega a **APIs & Services > Credentials**
3. Encuentra tu API Key: `AIzaSyB8qeOmj_KuX_OMtJ__MDtC-PL9hk6voDM`
4. Verifica que estén habilitadas estas APIs:
   - ✅ Maps SDK for Android
   - ✅ Places API
   - ✅ Geocoding API

### 2. Verificar Restricciones de la API Key

1. En la configuración de tu API Key
2. **Application restrictions**: Debe ser "Android apps" o "None"
3. Si es "Android apps", agrega tu SHA-1:
   ```bash
   # En el directorio android/ del proyecto
   ./gradlew signingReport
   ```
4. Copia el SHA-1 de la variante debug y agrégalo en la API Key

### 3. Habilitar Facturación en Google Cloud

Google Maps requiere una cuenta con facturación habilitada:

1. Ve a **Billing** en Google Cloud Console
2. Asegúrate de tener una tarjeta de crédito registrada
3. Google ofrece **$200 USD de crédito mensual gratis** para Maps

### 4. Verificar Configuración en AndroidManifest.xml

Ya está configurado correctamente en ambos archivos:
- ✅ `android/app/src/main/AndroidManifest.xml`
- ✅ `android/app/src/debug/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyB8qeOmj_KuX_OMtJ__MDtC-PL9hk6voDM" />
```

### 5. Verificar Ubicación en el Emulador

El emulador necesita una ubicación configurada:

1. Abre el emulador de Android
2. Ve a los **Extended Controls** (3 puntos)
3. Selecciona **Location**
4. Ingresa coordenadas de prueba:
   - Latitude: `4.60971` (Bogotá)
   - Longitude: `-74.08175`
5. Presiona **Send**

### 6. Limpiar y Reconstruir el Proyecto

```bash
cd a_donde_vamos

# Limpiar Flutter
flutter clean

# Limpiar Gradle
cd android
./gradlew clean
cd ..

# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run
```

### 7. Verificar en LogCat

Mira los logs de Android para ver errores específicos:

```bash
# Ver logs en tiempo real
adb logcat | grep -i "maps\|google"
```

Busca mensajes como:
- ❌ "Authorization failure" → Problema con API Key
- ❌ "Billing not enabled" → Necesitas habilitar facturación
- ❌ "API not enabled" → Necesitas habilitar Maps SDK for Android

## Solución Temporal: Mapa Estático

Si el mapa dinámico sigue sin funcionar, puedes usar un mapa estático mientras solucionas:

```dart
// En lugar de GoogleMap widget
Image.network(
  'https://maps.googleapis.com/maps/api/staticmap?'
  'center=${widget.place.location.latitude},${widget.place.location.longitude}'
  '&zoom=15'
  '&size=600x300'
  '&markers=color:red%7C${widget.place.location.latitude},${widget.place.location.longitude}'
  '&key=AIzaSyB8qeOmj_KuX_OMtJ__MDtC-PL9hk6voDM',
  fit: BoxFit.cover,
)
```

## Checklist de Verificación

- [ ] Maps SDK for Android habilitado en Google Cloud
- [ ] Facturación habilitada en Google Cloud
- [ ] API Key sin restricciones o con SHA-1 correcto
- [ ] Ubicación configurada en el emulador
- [ ] `flutter clean` y recompilación completada
- [ ] Logs de Android revisados

## Nota Importante

El problema más común es la **falta de facturación habilitada** en Google Cloud. Aunque Google ofrece $200 USD gratis mensuales, requiere una tarjeta registrada para prevenir abuso.
