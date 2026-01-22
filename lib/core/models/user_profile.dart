import 'package:text_code/core/models/event_interest.dart';

/// Model class for User Profile
/// Represents the complete user profile data from the API
class UserProfile {
  final int id;
  final String name;
  final String phoneNumber;
  final String gender;
  final String? bio;
  final String? location;
  final String birthDate; // Format: YYYY-MM-DD
  final List<EventInterest> eventInterests;
  final List<String> profilePictures;
  final bool isVerified;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    this.bio,
    this.location,
    required this.birthDate,
    required this.eventInterests,
    required this.profilePictures,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      birthDate: json['birth_date'] as String? ?? '',
      eventInterests: (json['event_interests'] as List?)
              ?.map((e) => EventInterest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      profilePictures: (json['profile_pictures'] as List<dynamic>?)
              ?.map((e) {
                String url = e.toString();
                // Sanitize URL: remove trailing "?" and other invalid characters
                url = url.trim();
                // Remove trailing "?" and whitespace
                while (url.endsWith('?') || url.endsWith(' ')) {
                  url = url.substring(0, url.length - 1);
                }
                return url;
              })
              .where((url) => url.isNotEmpty) // Filter out empty URLs
              .toList() ??
          [],
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  /// Converts UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'gender': gender,
      'bio': bio,
      'location': location,
      'birth_date': birthDate,
      'event_interests': eventInterests.map((e) => e.toJson()).toList(),
      'profile_pictures': profilePictures,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Calculate age from birth date
  int? get age {
    if (birthDate.isEmpty) return null;
    try {
      final parts = birthDate.split('-');
      if (parts.length == 3) {
        final birthYear = int.parse(parts[0]);
        final now = DateTime.now();
        int age = now.year - birthYear;
        if (now.month < int.parse(parts[1]) ||
            (now.month == int.parse(parts[1]) && now.day < int.parse(parts[2]))) {
          age--;
        }
        return age;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, phoneNumber: $phoneNumber, gender: $gender)';
  }
}
