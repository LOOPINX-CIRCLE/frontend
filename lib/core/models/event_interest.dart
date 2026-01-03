/// Model class for Event Interest
/// Represents an interest option that users can select during profile completion
class EventInterest {
  final int id;
  final String name;
  final String description;

  EventInterest({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Creates an EventInterest from JSON
  factory EventInterest.fromJson(Map<String, dynamic> json) {
    return EventInterest(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  /// Converts EventInterest to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'EventInterest(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventInterest && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
