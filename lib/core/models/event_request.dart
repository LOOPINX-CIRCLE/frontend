/// Model class for Event Request
/// Represents the user's request status for a specific event
class EventRequest {
  final int requestId;
  final int eventId;
  final String eventTitle;
  final String status; // "pending", "accepted", "declined", "cancelled"
  final String message;
  final String? hostMessage;
  final int seatsRequested;
  final bool canConfirm;
  final String createdAt;
  final String updatedAt;

  EventRequest({
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
  });

  /// Creates an EventRequest from JSON
  factory EventRequest.fromJson(Map<String, dynamic> json) {
    return EventRequest(
      requestId: json['request_id'] as int? ?? 0,
      eventId: json['event_id'] as int? ?? 0,
      eventTitle: json['event_title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
      hostMessage: json['host_message'] as String?,
      seatsRequested: json['seats_requested'] as int? ?? 1,
      canConfirm: json['can_confirm'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  /// Converts EventRequest to JSON
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
    };
  }

  /// Check if request is pending
  bool get isPending => status == 'pending';

  /// Check if request is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if request is declined
  bool get isDeclined => status == 'declined';

  /// Check if request is cancelled
  bool get isCancelled => status == 'cancelled';

  @override
  String toString() {
    return 'EventRequest(id: $requestId, eventId: $eventId, status: $status)';
  }
}
