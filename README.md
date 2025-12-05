# A Donde Vamos - Aplicación Android 🚀

Aplicación móvil Android nativa para descubrir lugares aleatorios cerca de ti (restaurantes, cafés, bares).

## 🚨 ERROR COMÚN: "Invalid API key" en Login

Si ves el error **"AuthApiException: Invalid API key, statusCode: 401"**:

➡️ **Solución completa en**: [`FIX_INVALID_API_KEY.md`](FIX_INVALID_API_KEY.md)

**Resumen**: Necesitas copiar la API key correcta desde tu [Supabase Dashboard](https://supabase.com/dashboard) → Settings → API → **anon/public key** y pegarla en `lib/config/supabase_config.dart`.

## 🎉 Nuevas Funcionalidades Implementadas

**Ver**: [`QUICK_START.md`](QUICK_START.md) para instrucciones de uso inmediatas

✅ **Sistema de Favoritos** - Guarda tus lugares preferidos  
✅ **Lugares Visitados** - Marca los lugares que ya visitaste  
✅ **Bloquear Lugares** - No volver a ver lugares que no te gustaron  
✅ **Sistema de Reseñas** - Lee y escribe opiniones con calificaciones  
✅ **Alertas Neon** - Feedback visual personalizado con diseño neon  

**Documentación completa**:
- 📖 [`FEATURES.md`](FEATURES.md) - Guía de funcionalidades
- 🗺️ [`GOOGLE_MAPS_FIX.md`](GOOGLE_MAPS_FIX.md) - Solución para mapa en blanco
- 📋 [`IMPLEMENTATION_SUMMARY.md`](IMPLEMENTATION_SUMMARY.md) - Resumen técnico

## 🛠️ **Stack Tecnológico Recomendado**

### **Opción 1: Desarrollo Nativo (Kotlin)**
```
- Lenguaje: Kotlin
- IDE: Android Studio
- UI: Jetpack Compose (moderno) o XML Views
- Arquitectura: MVVM con Clean Architecture
```

### **Opción 2: Flutter (Multiplataforma)**
```
- Lenguaje: Dart
- Framework: Flutter
- Ventaja: Mismo código para Android e iOS
```

### **Opción 3: React Native (Si ya sabes React)**
```
- Lenguaje: JavaScript/TypeScript
- Ventaja: Reutilizar lógica de la web
```

---

## 📦 **Dependencias/Librerías Necesarias**

### **Para Kotlin/Android Nativo:**

```gradle
// build.gradle.kts (Module: app)

dependencies {
    // ✅ 1. GEOLOCALIZACIÓN Y MAPAS
    implementation("com.google.android.gms:play-services-maps:18.2.0")
    implementation("com.google.android.gms:play-services-location:21.1.0")
    implementation("com.google.maps.android:android-maps-utils:3.8.2")
    
    // ✅ 2. SUPABASE (Backend)
    implementation("io.github.jan-tennert.supabase:postgrest-kt:2.0.0")
    implementation("io.github.jan-tennert.supabase:realtime-kt:2.0.0")
    implementation("io.github.jan-tennert.supabase:gotrue-kt:2.0.0") // Auth
    implementation("io.github.jan-tennert.supabase:storage-kt:2.0.0")
    implementation("io.ktor:ktor-client-android:2.3.7")
    
    // ✅ 3. RED Y API CALLS
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    
    // ✅ 4. IMÁGENES
    implementation("io.coil-kt:coil-compose:2.5.0") // Para Compose
    // O: implementation("com.github.bumptech.glide:glide:4.16.0") // Para Views
    
    // ✅ 5. JETPACK COMPOSE (UI Moderna)
    implementation("androidx.compose.ui:ui:1.6.0")
    implementation("androidx.compose.material3:material3:1.2.0")
    implementation("androidx.compose.ui:ui-tooling-preview:1.6.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.navigation:navigation-compose:2.7.6")
    
    // ✅ 6. VIEWMODEL Y LIFECYCLE
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")
    
    // ✅ 7. PAGOS STRIPE
    implementation("com.stripe:stripe-android:20.37.0")
    
    // ✅ 8. PERMISOS
    implementation("com.google.accompanist:accompanist-permissions:0.34.0")
    
    // ✅ 9. LOCAL DATABASE (OPCIONAL)
    implementation("androidx.room:room-runtime:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    
    // ✅ 10. HILT (Inyección de Dependencias)
    implementation("com.google.dagger:hilt-android:2.50")
    kapt("com.google.dagger:hilt-compiler:2.50")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")
}
```

---

## 🗂️ **Estructura de Carpetas (Kotlin + Compose)**

```
app/
├── manifests/
│   └── AndroidManifest.xml        # Permisos (GPS, Internet, etc.)
├── java/com/tuapp/adondevamos/
│   ├── MainActivity.kt            # Punto de entrada
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── DashboardScreen.kt    # Pantalla principal
│   │   │   ├── HistoryScreen.kt      # Historial
│   │   │   ├── FavoritesScreen.kt    # Favoritos
│   │   │   ├── ProfileScreen.kt      # Perfil
│   │   │   ├── AuthScreen.kt         # Login/Registro
│   │   │   └── MapScreen.kt          # Mapa
│   │   ├── components/              # Botones, cards, etc.
│   │   └── theme/                   # Colores, tipografía
│   ├── data/
│   │   ├── remote/                  # API calls (Supabase, Google Places)
│   │   ├── repository/              # Lógica de datos
│   │   └── model/                   # Clases de datos (Location, User, etc.)
│   ├── domain/
│   │   ├── usecase/                 # Casos de uso (GetRandomPlace, MarkAsVisited)
│   │   └── repository/              # Interfaces
│   ├── utils/
│   │   ├── LocationHelper.kt        # GPS utils
│   │   ├── DistanceCalculator.kt    # Haversine
│   │   └── Constants.kt             # API Keys
│   └── di/                          # Módulos de Hilt
└── res/
    ├── drawable/                    # Iconos, imágenes
    ├── values/
    │   ├── strings.xml
    │   ├── colors.xml
    │   └── themes.xml
    └── xml/
        └── network_security_config.xml # HTTPS config
```

---

## 🔑 **Configuración Necesaria**

### **1. AndroidManifest.xml (Permisos)**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permisos de ubicación -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Google Maps API Key -->
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="TU_GOOGLE_MAPS_API_KEY"/>
        
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### **2. local.properties (API Keys - NO SUBIR A GIT)**
```properties
GOOGLE_MAPS_API_KEY=TU_KEY_AQUI
SUPABASE_URL=https://tuproyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxx
```

### **3. build.gradle.kts (Cargar Keys Seguras)**
```kotlin
android {
    defaultConfig {
        // Cargar desde local.properties
        val properties = Properties()
        properties.load(project.rootProject.file("local.properties").inputStream())
        
        buildConfigField("String", "GOOGLE_MAPS_API_KEY", 
            "\"${properties.getProperty("GOOGLE_MAPS_API_KEY")}\"")
        buildConfigField("String", "SUPABASE_URL", 
            "\"${properties.getProperty("SUPABASE_URL")}\"")
        buildConfigField("String", "SUPABASE_ANON_KEY", 
            "\"${properties.getProperty("SUPABASE_ANON_KEY")}\"")
    }
    
    buildFeatures {
        buildConfig = true
        compose = true
    }
}
```

---

## 🎨 **Características a Implementar (Paridad con Web)**

### **Core Features:**
- ✅ Geolocalización con GPS
- ✅ Búsqueda de lugares random cercanos (Google Places API)
- ✅ Filtros (tipo, radio, precio, contexto, horario)
- ✅ Mapa interactivo con marcadores
- ✅ Marcado de lugares visitados/pendientes
- ✅ Bloqueo de lugares (no recomendar)
- ✅ Historial (visitados + pendientes)
- ✅ Sistema de favoritos con listas
- ✅ Reseñas y votos
- ✅ Sistema de insignias/logros
- ✅ Perfil de usuario (puntos, nivel, foto)
- ✅ Ranking de usuarios
- ✅ Sistema de amigos
- ✅ Autenticación (Email + Google OAuth)
- ✅ Modo invitado
- ✅ Suscripción Premium (Stripe)

### **Extras Mobile:**
- 🔔 Notificaciones push (recordatorios de lugares pendientes)
- 📍 Widget de "lugar del día"
- 🌙 Modo oscuro/claro
- 🗺️ Integración directa con Waze/Google Maps
- 📸 Cámara para fotos en reseñas
- 🔄 Sincronización offline

---

## 🚀 **Pasos para Empezar**

### **Si eliges Kotlin Nativo:**
1. **Instalar Android Studio** (última versión)
2. **Crear proyecto:**
   - File → New → New Project → Empty Activity (Compose)
   - Package name: `com.tuapp.adondevamos`
3. **Configurar dependencias** (copiar el gradle arriba)
4. **Configurar API Keys** (Google Maps + Supabase)
5. **Implementar navegación** (Navigation Compose)
6. **Implementar geolocalización** primero
7. **Integrar Google Places API**
8. **Conectar con Supabase**

### **Si eliges Flutter:**
```bash
flutter create a_donde_vamos_app
cd a_donde_vamos_app
flutter pub add google_maps_flutter supabase_flutter geolocator
```

### **Si eliges React Native:**
```bash
npx react-native init ADondeVamosApp
cd ADondeVamosApp
npm install react-native-maps @supabase/supabase-js react-native-geolocation-service
```

---

## 📚 **Recursos Útiles**

- [Google Maps Android SDK](https://developers.google.com/maps/documentation/android-sdk)
- [Supabase Kotlin Client](https://supabase.com/docs/reference/kotlin/introduction)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Stripe Android SDK](https://stripe.com/docs/mobile/android)

---

## 🆘 **Siguiente Paso**
¿Qué tecnología prefieres usar? 
1. **Kotlin Nativo** (recomendado para Android puro)
2. **Flutter** (si quieres Android + iOS)
3. **React Native** (si ya sabes React)

Dime y creo la estructura inicial del proyecto 🚀
