// lib/data/services/location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Verificar si los permisos de ubicación están habilitados
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Verificar el estado de los permisos
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Solicitar permisos de ubicación
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Obtener la ubicación actual del usuario
  Future<Position?> getCurrentLocation() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print(
          '⚠️ Servicio de ubicación deshabilitado, intentando con última ubicación conocida...',
        );
        // Intentar obtener última ubicación conocida
        try {
          Position? lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            print('✅ Usando última ubicación conocida');
            return lastPosition;
          }
        } catch (e) {
          print('❌ No se pudo obtener última ubicación: $e');
        }
        throw Exception(
          'El servicio de ubicación está deshabilitado. Por favor, actívalo en la configuración.',
        );
      }

      // Verificar permisos
      LocationPermission permission = await checkPermission();
      print('📍 Estado de permisos: $permission');

      if (permission == LocationPermission.denied) {
        print('🔐 Solicitando permisos...');
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permisos de ubicación denegados permanentemente. Por favor, habilítalos en la configuración.',
        );
      }

      print('🎯 Obteniendo ubicación actual...');

      // Intentar primero con última ubicación conocida (más rápido)
      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition(
          forceAndroidLocationManager: true,
        );
        if (lastPosition != null) {
          final age = DateTime.now().difference(lastPosition.timestamp);
          // Si la ubicación tiene menos de 5 minutos, usarla
          if (age.inMinutes < 5) {
            print(
              '✅ Usando última ubicación conocida (${age.inSeconds}s de antigüedad)',
            );
            return lastPosition;
          }
        }
      } catch (e) {
        print('⚠️ No hay última ubicación: $e');
      }

      // Obtener ubicación actual con configuración optimizada para emulador
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          forceAndroidLocationManager: true, // Importante para emuladores
          timeLimit: const Duration(seconds: 30), // Timeout más largo
        );
        print(
          '✅ Ubicación obtenida: ${position.latitude}, ${position.longitude}',
        );
        return position;
      } catch (e) {
        print('❌ Error en getCurrentPosition: $e');

        // Último intento: usar cualquier ubicación disponible
        Position? anyPosition = await Geolocator.getLastKnownPosition();
        if (anyPosition != null) {
          print('✅ Usando última ubicación disponible como fallback');
          return anyPosition;
        }

        throw Exception(
          'No se pudo obtener la ubicación después de varios intentos',
        );
      }
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      rethrow;
    }
  }

  // Calcular distancia entre dos coordenadas (en metros)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Formatear distancia para mostrar (convierte a km si es mayor a 1000m)
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(2)} km';
    }
  }

  // Abrir configuración de la app para permisos
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Abrir configuración de ubicación del dispositivo
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
