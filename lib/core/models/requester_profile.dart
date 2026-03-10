import 'package:text_code/core/models/event_interest.dart';

/// Model for Requester Profile
/// Represents detailed profile information of a user who requested to join an event
class RequesterProfile {
  final int userId;
  final String name;
  final String? phoneNumber;
  final String? bio;
  final String? gender;
  final String? location;
  final List<String> profilePictures;
  final List<EventInterest> eventInterests;
  final bool isVerified;

  RequesterProfile({
    required this.userId,
    required this.name,
    this.phoneNumber,
    this.bio,
    this.gender,
    this.location,
    required this.profilePictures,
    required this.eventInterests,
    required this.isVerified,
  });

  /// Creates a RequesterProfile from JSON
  factory RequesterProfile.fromJson(Map<String, dynamic> json) {
    return RequesterProfile(
      userId: json['user_id'] is int 
          ? json['user_id'] as int 
          : int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      bio: json['bio'] as String?,
      gender: json['gender'] as String?,
      location: json['location'] as String?,
      profilePictures: List<String>.from(
        (json['profile_pictures'] as List<dynamic>?)?.map((pic) => pic.toString()) ?? []
      ),
      eventInterests: (json['event_interests'] as List<dynamic>?)
          ?.map((interest) => EventInterest.fromJson(interest as Map<String, dynamic>))
          .toList() ?? [],
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'bio': bio,
      'gender': gender,
      'location': location,
      'profile_pictures': profilePictures,
      'event_interests': eventInterests.map((e) => e.toJson()).toList(),
      'is_verified': isVerified,
    };
  }

  @override
  String toString() {
    return 'RequesterProfile(userId: $userId, name: $name, isVerified: $isVerified)';
  }
}

/// Model for Event Request (with requester details)
class EventRequestWithDetails {
  final int requestId;
  final int eventId;
  final String eventTitle;
  final String status;
  final String message;
  final String? hostMessage;
  final int seatsRequested;
  final bool canConfirm;
  final String createdAt;
  final String updatedAt;
  final RequesterProfile? requesterProfile;

  EventRequestWithDetails({
    required this.requestId,
    required this.eventId,
    required this.eventTitle,
    required this.status,
    required this.message,
    this.hostMessage,
    required this.seatsRequested,
    required this.canConfirm,
    required this.createdAt,
    required this.updatedAt,
    this.requesterProfile,
  });

  factory EventRequestWithDetails.fromJson(Map<String, dynamic> json) {
    return EventRequestWithDetails(
      requestId: json['request_id'] is int 
          ? json['request_id'] as int 
          : int.tryParse(json['request_id'].toString()) ?? 0,
      eventId: json['event_id'] is int 
          ? json['event_id'] as int 
          : int.tryParse(json['event_id'].toString()) ?? 0,
      eventTitle: json['event_title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
      hostMessage: json['host_message'] as String?,
      seatsRequested: json['seats_requested'] is int 
          ? json['seats_requested'] as int 
          : int.tryParse(json['seats_requested'].toString()) ?? 1,
      canConfirm: json['can_confirm'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      requesterProfile: json['requester_profile'] != null
          ? RequesterProfile.fromJson(json['requester_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'event_id': eventId,
      'event_title': eventTitle,
      'status': status,
      'message': message,
      'host_message': hostMessage,
      'seats_requested': seatsRequested,
      'can_confirm': canConfirm,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'requester_profile': requesterProfile?.toJson(),
    };
  }

  @override
  String toString() {
    return 'EventRequestWithDetails(requestId: $requestId, status: $status)';
  }
}
