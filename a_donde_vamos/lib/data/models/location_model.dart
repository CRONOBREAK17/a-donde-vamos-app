// lib/data/models/location_model.dart
class LocationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final String? googleMapsUrl;
  final double? rating; // Cambiado de averageRating a rating
  final int? priceLevel;
  final String? phoneNumber;
  final String? website;
  final List<String>? openingHours;
  final bool? isOpen;
  final double? distance; // En kilómetros
  final String? photoReference; // Para fotos de Google Places
  final List<String>? types; // Tipos de lugar

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.googleMapsUrl,
    this.rating,
    this.priceLevel,
    this.phoneNumber,
    this.website,
    this.openingHours,
    this.isOpen,
    this.distance,
    this.photoReference,
    this.types,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      rating: json['rating'] != null || json['average_rating'] != null
          ? (json['rating'] ?? json['average_rating'] as num).toDouble()
          : null,
      priceLevel: json['price_level'] as int?,
      phoneNumber: json['phone_number'] as String?,
      website: json['website'] as String?,
      openingHours: json['opening_hours'] != null
          ? List<String>.from(json['opening_hours'] as List)
          : null,
      isOpen: json['is_open'] as bool?,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      photoReference: json['photo_reference'] as String?,
      types: json['types'] != null
          ? List<String>.from(json['types'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'google_maps_url': googleMapsUrl,
      'rating': rating,
      'price_level': priceLevel,
      'phone_number': phoneNumber,
      'website': website,
      'opening_hours': openingHours,
      'is_open': isOpen,
      'distance': distance,
      'photo_reference': photoReference,
      'types': types,
    };
  }

  String get priceDisplay {
    if (priceLevel == null) return 'N/A';
    return '\$' * priceLevel!;
  }

  String get distanceDisplay {
    if (distance == null) return 'N/A';
    return '${distance!.toStringAsFixed(2)} km';
  }

  // Método para formatear distancia desde metros
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(2)} km';
    }
  }
}
