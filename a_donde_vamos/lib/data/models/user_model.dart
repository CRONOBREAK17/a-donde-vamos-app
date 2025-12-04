// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? profilePicture;
  final String? description;
  final int activityPoints;
  final bool isPremium;
  final DateTime? premiumUntil;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.profilePicture,
    this.description,
    this.activityPoints = 0,
    this.isPremium = false,
    this.premiumUntil,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      profilePicture: json['profile_picture'] as String?,
      description: json['description'] as String?,
      activityPoints: json['activity_points'] as int? ?? 0,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumUntil: json['premium_until'] != null
          ? DateTime.parse(json['premium_until'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profile_picture': profilePicture,
      'description': description,
      'activity_points': activityPoints,
      'is_premium': isPremium,
      'premium_until': premiumUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? profilePicture,
    String? description,
    int? activityPoints,
    bool? isPremium,
    DateTime? premiumUntil,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      description: description ?? this.description,
      activityPoints: activityPoints ?? this.activityPoints,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
