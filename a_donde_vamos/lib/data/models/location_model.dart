// lib/data/models/location_model.dart
class LocationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final String? googleMapsUrl;
  final double? averageRating;
  final int? priceLevel;
  final String? phoneNumber;
  final String? website;
  final List<String>? openingHours;
  final bool? isOpen;
  final double? distance; // En kilómetros

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.googleMapsUrl,
    this.averageRating,
    this.priceLevel,
    this.phoneNumber,
    this.website,
    this.openingHours,
    this.isOpen,
    this.distance,
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
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
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
      'average_rating': averageRating,
      'price_level': priceLevel,
      'phone_number': phoneNumber,
      'website': website,
      'opening_hours': openingHours,
      'is_open': isOpen,
      'distance': distance,
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
}
