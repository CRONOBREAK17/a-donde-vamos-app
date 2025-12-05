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
        throw Exception('El servicio de ubicación está deshabilitado');
      }

      // Verificar permisos
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
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

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
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
