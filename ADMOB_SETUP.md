# 🎯 Configuración de AdMob - Guía Paso a Paso

## 📱 Paso 1: Crear cuenta y app en AdMob

1. Ve a **https://admob.google.com**
2. Inicia sesión con tu cuenta de Google
3. Haz clic en "Empezar" o "Agregar aplicación"
4. Selecciona "Android"
5. Ingresa el nombre de tu app: **"¿A Dónde Vamos?"**
6. Te darán un **App ID** como: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`

## 📝 Paso 2: Crear Ad Units (Unidades de Anuncios)

Necesitas crear 3 tipos de anuncios:

### 1. Banner Ad (Banner inferior)
- En AdMob, ve a "Ad units" → "Add ad unit"
- Selecciona "Banner"
- Nombre: "Dashboard Banner"
- Copia el **Ad Unit ID**: `ca-app-pub-XXXXXXXXXXXXXXXX/1111111111`

### 2. Interstitial Ad (Pantalla completa)
- Ve a "Ad units" → "Add ad unit"
- Selecciona "Interstitial"
- Nombre: "Search Interstitial"
- Copia el **Ad Unit ID**: `ca-app-pub-XXXXXXXXXXXXXXXX/2222222222`

### 3. Rewarded Ad (Con recompensa - opcional)
- Ve a "Ad units" → "Add ad unit"
- Selecciona "Rewarded"
- Nombre: "Reward Points"
- Copia el **Ad Unit ID**: `ca-app-pub-XXXXXXXXXXXXXXXX/3333333333`

## 🔧 Paso 3: Configurar Android

### A) Editar `android/app/src/main/AndroidManifest.xml`

Agrega dentro de la etiqueta `<application>`:

```xml
<application>
    <!-- Otros contenidos... -->
    
    <!-- AdMob App ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
</application>
```

### B) Editar `lib/data/services/ad_service.dart`

Reemplaza los IDs de prueba con tus IDs reales:

```dart
// Banner Ad Test ID
static const String _bannerAdUnitId = kReleaseMode
    ? 'ca-app-pub-XXXXXXXXXXXXXXXX/1111111111' // ← TU ID AQUÍ
    : 'ca-app-pub-3940256099942544/6300978111';

// Interstitial Ad Test ID
static const String _interstitialAdUnitId = kReleaseMode
    ? 'ca-app-pub-XXXXXXXXXXXXXXXX/2222222222' // ← TU ID AQUÍ
    : 'ca-app-pub-3940256099942544/1033173712';

// Rewarded Ad Test ID
static const String _rewardedAdUnitId = kReleaseMode
    ? 'ca-app-pub-XXXXXXXXXXXXXXXX/3333333333' // ← TU ID AQUÍ
    : 'ca-app-pub-3940256099942544/5224354917';
```

## ✅ Paso 4: Probar los anuncios

### Modo Debug (IDs de prueba)
```bash
flutter run
```
- Verás anuncios de PRUEBA de Google
- Son solo para testing, NO generan ingresos

### Modo Release (IDs reales)
```bash
flutter build apk --release
```
- Usará tus IDs reales de AdMob
- Generará ingresos reales

## 🎮 Comportamiento implementado

### 1. **Banner Ad**
- ✅ Se muestra en la parte inferior del Dashboard
- ✅ Solo aparece si el usuario NO es premium
- ✅ Tamaño: 320x50 (banner estándar)

### 2. **Interstitial Ad**
- ✅ Aparece cada 3 búsquedas de lugares
- ✅ Pantalla completa entre búsquedas
- ✅ Solo si el usuario NO es premium

### 3. **Premium Experience**
- ✅ Si `is_premium = true` en la BD, NO se muestran anuncios
- ✅ Botón "Hazte Premium" en el perfil
- ✅ Pantalla con beneficios premium

## 💳 Próximos pasos: Google Play Billing

Para implementar pagos reales necesitarás:

1. **Crear app en Google Play Console**
2. **Configurar producto de suscripción**:
   - ID: `premium_monthly`
   - Precio: $4.99/mes
3. **Instalar package**: `in_app_purchase: ^3.2.0`
4. **Implementar flujo de compra**

## 📊 Verificar ingresos

1. Ve a **AdMob Dashboard**
2. Sección "Informes"
3. Verás métricas en tiempo real:
   - Impresiones
   - Clics
   - CTR (Click-Through Rate)
   - Ingresos estimados

## ⚠️ Notas importantes

1. **Los anuncios de prueba NO generan ingresos**
2. **NO hagas clic en tus propios anuncios** (Google puede banear tu cuenta)
3. **Espera 24-48 horas** para ver datos en AdMob después de publicar
4. **Cumple con las políticas** de AdMob y Google Play

## 🚀 Estado actual

- ✅ AdMob SDK integrado
- ✅ Banner ads funcionando (IDs de prueba)
- ✅ Interstitial ads funcionando (IDs de prueba)
- ✅ Sistema de verificación premium
- ✅ Pantalla premium con beneficios
- 🔜 Google Play Billing (siguiente paso)

---

**¿Necesitas ayuda?** Avísame cuando tengas tus IDs de AdMob y te ayudo a configurarlos.
