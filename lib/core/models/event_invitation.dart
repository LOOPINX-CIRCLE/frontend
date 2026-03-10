import 'package:flutter/foundation.dart';

/// Model representing an event invitation returned from
/// GET /api/events/my-invitations
@immutable
class EventInvitation {
  final int inviteId;
  final int eventId;
  final String eventTitle;
  final DateTime? eventStartTime;
  final String hostName;
  final String status; // pending, accepted, declined, expired
  final String? message;
  final DateTime? createdAt;

  const EventInvitation({
    required this.inviteId,
    required this.eventId,
    required this.eventTitle,
    required this.hostName,
    required this.status,
    this.eventStartTime,
    this.message,
    this.createdAt,
  });

  factory EventInvitation.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return EventInvitation(
      inviteId: json['invite_id'] is int
          ? json['invite_id'] as int
          : int.tryParse(json['invite_id']?.toString() ?? '') ?? 0,
      eventId: json['event_id'] is int
          ? json['event_id'] as int
          : int.tryParse(json['event_id']?.toString() ?? '') ?? 0,
      eventTitle: json['event_title']?.toString() ?? '',
      eventStartTime: _parseDate(json['event_start_time']?.toString()),
      hostName: json['host_name']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? '',
      message: json['message']?.toString(),
      createdAt: _parseDate(json['created_at']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invite_id': inviteId,
      'event_id': eventId,
      'event_title': eventTitle,
      'event_start_time': eventStartTime?.toIso8601String(),
      'host_name': hostName,
      'status': status,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  EventInvitation copyWith({
    int? inviteId,
    int? eventId,
    String? eventTitle,
    DateTime? eventStartTime,
    String? hostName,
    String? status,
    String? message,
    DateTime? createdAt,
  }) {
    return EventInvitation(
      inviteId: inviteId ?? this.inviteId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventStartTime: eventStartTime ?? this.eventStartTime,
      hostName: hostName ?? this.hostName,
      status: (status ?? this.status).toLowerCase(),
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
