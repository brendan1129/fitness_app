// lib/models/event.dart (or at the top of calendar_screen.dart)

enum EventType { meal, workout }

class FitnessEvent {
  final DateTime date;
  final EventType type;
  final String summary; // We can expand this to more specific fields later

  FitnessEvent({required this.date, required this.type, required this.summary});

  // Convert Event object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      // Store date as ISO 8601 string ( we just use yyyy-mm-dd portion )
      'date': date.toIso8601String(),
      // type.toString() will return EventType.type so split by '.' and take last element
      'type': type.toString().split('.').last,
      // Summary is a simple string list of either
      // 1. Workout ( )
      'summary': summary,
    };
  }

  // Create an Event object from a JSON map
  factory FitnessEvent.fromJson(Map<String, dynamic> json) {
    return FitnessEvent(
      date: DateTime.parse(json['date']),
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      summary: json['summary'],
    );
  }

  // Helper to create a unique ID for the event if needed for editing/deleting
  // For now, we'll just use the summary and date for display.
  String get id => '${date.toIso8601String()}_${summary.hashCode}';
}
