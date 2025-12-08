# 🎥 Cómo Agregar Video de Fondo

## 📁 Paso 1: Colocar el archivo de video

1. Guarda tu archivo `.mp4` en la carpeta:
   ```
   assets/videos/background.mp4
   ```

2. El video debe ser:
   - **Formato:** MP4 (H.264)
   - **Tamaño recomendado:** Máximo 5-10 MB
   - **Resolución:** 720p o 1080p
   - **Duración:** 10-30 segundos (se reproduce en loop)

## 🔧 Paso 2: Instalar dependencias

Ejecuta en la terminal:
```bash
cd /workspaces/a-donde-vamos-app/a_donde_vamos
flutter pub get
```

## 💻 Paso 3: Usar el widget VideoBackground

### Ejemplo básico en cualquier pantalla:

```dart
import 'package:flutter/material.dart';
import '../widgets/video_background.dart';

class MiPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoBackground(
        videoPath: 'assets/videos/background.mp4',
        opacity: 0.3, // Opacidad del video (0.0 a 1.0)
        child: // Tu contenido aquí
          Center(
            child: Text('Contenido sobre el video'),
          ),
      ),
    );
  }
}
```

### Ejemplo en ProfileScreen:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background, // Esto se puede quitar
    body: VideoBackground(
      opacity: 0.2, // Video muy tenue
      child: SingleChildScrollView(
        // Todo tu contenido actual aquí...
      ),
    ),
  );
}
```

## ⚙️ Opciones de personalización:

- **`videoPath`**: Ruta al archivo de video
- **`opacity`**: Opacidad del video (0.0 = invisible, 1.0 = completamente visible)
- **`child`**: El contenido que va sobre el video

## 🎨 Recomendaciones:

1. **Opacidad baja:** Usa valores entre 0.2 y 0.4 para no distraer del contenido
2. **Video oscuro:** Los videos oscuros funcionan mejor con texto claro
3. **Loop suave:** Usa videos que inicien y terminen de forma similar para un loop sin cortes
4. **Optimiza el tamaño:** Comprime el video para que la app no sea pesada

## 📱 Notas importantes:

- El video se reproduce automáticamente al cargar la pantalla
- No tiene sonido (está muteado)
- Se reproduce en loop infinito
- Si el video no existe, simplemente no se muestra (sin error)

## 🚀 Dónde usarlo:

Puedes envolver cualquier pantalla con `VideoBackground`:
- Login screen
- Profile screen  
- Dashboard
- Splash screen
- Cualquier pantalla que quieras hacer más dinámica
