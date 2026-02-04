import 'package:text_code/core/models/event_interest.dart';

/// Model class for Event
/// Represents event data from the API
class Event {
  final int id;
  final String uuid;
  final String title;
  final String description;
  final EventHost host;
  final EventLocation location;
  final String startTime;
  final String endTime;
  final int maxCapacity;
  final int goingCount;
  final int requestsCount;
  final bool isPaid;
  final String? ticketPrice;
  final bool allowPlusOne;
  final String? allowedGenders;
  final List<String> coverImages;
  final String status;
  final bool isPublic;
  final bool isActive;
  final List<EventInterest> eventInterests;

  Event({
    required this.id,
    required this.uuid,
    required this.title,
    required this.description,
    required this.host,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.goingCount,
    required this.requestsCount,
    required this.isPaid,
    this.ticketPrice,
    required this.allowPlusOne,
    this.allowedGenders,
    required this.coverImages,
    required this.status,
    required this.isPublic,
    required this.isActive,
    required this.eventInterests,
  });

  /// Creates an Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      host: json['host'] != null
          ? EventHost.fromJson(json['host'] as Map<String, dynamic>)
          : EventHost(id: 0, userId: 0, name: '', phoneNumber: ''),
      location: json['location'] != null
          ? EventLocation.fromJson(json['location'] as Map<String, dynamic>)
          : EventLocation(name: '', address: '', latitude: 0.0, longitude: 0.0),
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      maxCapacity: json['max_capacity'] is int
          ? json['max_capacity'] as int
          : int.tryParse(json['max_capacity'].toString()) ?? 0,
      goingCount: json['going_count'] is int
          ? json['going_count'] as int
          : int.tryParse(json['going_count'].toString()) ?? 0,
      requestsCount: json['requests_count'] is int
          ? json['requests_count'] as int
          : int.tryParse(json['requests_count'].toString()) ?? 0,
      isPaid: json['is_paid'] as bool? ?? false,
      ticketPrice: json['ticket_price']?.toString(),
      allowPlusOne: json['allow_plus_one'] as bool? ?? false,
      allowedGenders: json['allowed_genders']?.toString(),
      coverImages: (json['cover_images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((url) => url.isNotEmpty)
              .toList() ??
          [],
      status: json['status'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      eventInterests: (json['event_interests'] as List?)
              ?.map((e) => EventInterest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts Event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'description': description,
      'host': host.toJson(),
      'location': location.toJson(),
      'start_time': startTime,
      'end_time': endTime,
      'max_capacity': maxCapacity,
      'going_count': goingCount,
      'requests_count': requestsCount,
      'is_paid': isPaid,
      'ticket_price': ticketPrice,
      'allow_plus_one': allowPlusOne,
      'allowed_genders': allowedGenders,
      'cover_images': coverImages,
      'status': status,
      'is_public': isPublic,
      'is_active': isActive,
      'event_interests': eventInterests.map((e) => e.toJson()).toList(),
    };
  }

  /// Check if event has ended based on end_time
  bool get hasEnded {
    if (endTime.isEmpty) return false;
    try {
      final endDateTime = DateTime.parse(endTime);
      return DateTime.now().isAfter(endDateTime);
    } catch (e) {
      return false;
    }
  }

  /// Get formatted date string
  String get formattedDate {
    if (startTime.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(startTime);
      return '${dateTime.day} ${_getMonthAbbreviation(dateTime.month)} ${dateTime.year.toString().substring(2)}';
    } catch (e) {
      return '';
    }
  }

  /// Get formatted time string
  String get formattedTime {
    if (startTime.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(startTime);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, status: $status)';
  }
}

/// Model for Event Host
class EventHost {
  final int id;
  final int userId; // Add user_id field
  final String name;
  final String phoneNumber;
  final String? profileImage;

  EventHost({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.profileImage,
  });

  factory EventHost.fromJson(Map<String, dynamic> json) {
    return EventHost(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] as int : int.parse(json['user_id'].toString()),
      name: json['name'] as String? ?? '',
      phoneNumber: json['username'] as String? ?? '', // API uses 'username' for phone number
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'username': phoneNumber, // API expects 'username' for phone number
      'profile_image': profileImage,
    };
  }
}

/// Model for Event Location
class EventLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  EventLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    // Prioritize venue_name if available, otherwise use name
    final venueName = json['venue_name'] as String? ?? 
                     json['name'] as String? ?? '';
    return EventLocation(
      name: venueName,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

