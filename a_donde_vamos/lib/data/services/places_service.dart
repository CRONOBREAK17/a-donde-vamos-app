// lib/data/services/places_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../config/supabase_config.dart';
import '../models/location_model.dart';

class PlacesService {
  final String _apiKey = SupabaseConfig.googleMapsApiKey;
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Buscar lugares cercanos aleatorios
  Future<LocationModel?> findRandomPlace({
    required double latitude,
    required double longitude,
    required String placeType, // 'restaurant', 'cafe', 'bar', 'random'
    required double radiusInKm,
    List<String>? excludedPlaceIds, // IDs de lugares a excluir
  }) async {
    try {
      // Convertir km a metros
      int radiusInMeters = (radiusInKm * 1000).round();

      // Si es búsqueda completamente aleatoria, elegir un tipo aleatorio
      String searchType = placeType;
      if (placeType == 'random') {
        final randomTypes = ['restaurant', 'cafe', 'bar'];
        searchType = randomTypes[Random().nextInt(randomTypes.length)];
      }

      // Construir URL de búsqueda
      final url = Uri.parse(
        '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radiusInMeters&type=$searchType&key=$_apiKey',
      );

      // Hacer petición
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null) {
          List results = data['results'];

          // Filtrar lugares excluidos
          if (excludedPlaceIds != null && excludedPlaceIds.isNotEmpty) {
            results = results
                .where((place) => !excludedPlaceIds.contains(place['place_id']))
                .toList();
          }

          // Si no hay resultados después del filtro
          if (results.isEmpty) {
            return null;
          }

          // Seleccionar un lugar aleatorio
          final random = Random();
          final randomPlace = results[random.nextInt(results.length)];

          // Obtener detalles adicionales del lugar
          return await getPlaceDetails(randomPlace['place_id']);
        } else {
          print('Error en búsqueda: ${data['status']}');
          return null;
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error buscando lugares: $e');
      return null;
    }
  }

  // Obtener detalles completos de un lugar
  Future<LocationModel?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=place_id,name,formatted_address,geometry,rating,price_level,opening_hours,formatted_phone_number,website,photos,types&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];

          return LocationModel(
            id: result['place_id'],
            name: result['name'] ?? 'Sin nombre',
            address: result['formatted_address'] ?? 'Dirección no disponible',
            latitude: result['geometry']['location']['lat'],
            longitude: result['geometry']['location']['lng'],
            rating: (result['rating'] ?? 0.0).toDouble(),
            priceLevel: result['price_level'],
            isOpen: result['opening_hours']?['open_now'],
            phoneNumber: result['formatted_phone_number'],
            website: result['website'],
            photoReference: result['photos']?[0]?['photo_reference'],
            types: List<String>.from(result['types'] ?? []),
          );
        }
      }

      return null;
    } catch (e) {
      print('Error obteniendo detalles: $e');
      return null;
    }
  }

  // Obtener URL de foto del lugar
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  // Buscar lugares con filtros avanzados
  Future<List<LocationModel>> searchPlacesWithFilters({
    required double latitude,
    required double longitude,
    required String placeType,
    required double radiusInKm,
    bool? openNow,
    int? minRating,
    int? priceLevel,
  }) async {
    try {
      int radiusInMeters = (radiusInKm * 1000).round();

      String urlString =
          '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radiusInMeters&type=$placeType&key=$_apiKey';

      if (openNow == true) {
        urlString += '&opennow=true';
      }

      if (minRating != null) {
        urlString += '&minrating=$minRating';
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'] != null) {
          List<LocationModel> places = [];

          for (var place in data['results']) {
            // Filtrar por nivel de precio si se especifica
            if (priceLevel != null &&
                place['price_level'] != null &&
                place['price_level'] != priceLevel) {
              continue;
            }

            final location = LocationModel(
              id: place['place_id'],
              name: place['name'] ?? 'Sin nombre',
              address: place['vicinity'] ?? 'Dirección no disponible',
              latitude: place['geometry']['location']['lat'],
              longitude: place['geometry']['location']['lng'],
              rating: (place['rating'] ?? 0.0).toDouble(),
              priceLevel: place['price_level'],
              isOpen: place['opening_hours']?['open_now'],
              photoReference: place['photos']?[0]?['photo_reference'],
              types: List<String>.from(place['types'] ?? []),
            );

            places.add(location);
          }

          return places;
        }
      }

      return [];
    } catch (e) {
      print('Error buscando con filtros: $e');
      return [];
    }
  }

  // Convertir tipo de lugar para la API de Google
  String convertPlaceType(String type) {
    switch (type) {
      case 'restaurant':
        return 'restaurant';
      case 'cafe':
        return 'cafe';
      case 'bar':
        return 'bar';
      default:
        return 'restaurant';
    }
  }
}
