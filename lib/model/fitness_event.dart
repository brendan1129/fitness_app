// lib/models/event.dart (or at the top of calendar_screen.dart)

import 'package:fitness_app/model/event_item.dart';
import 'package:fitness_app/model/identifiable.dart';

enum EventType { meal, workout }

class FitnessEvent extends Identifiable {
  String? planId; // Nullable if an event doesn't always belong to a plan
  String eventName;
  DateTime eventDate;
  EventType eventType;
  List<EventItem> eventItems;
  bool isComplete; // Can be modified

  FitnessEvent({
    required String id,
    this.planId,
    required this.eventName,
    required this.eventDate,
    required this.eventType,
    required this.eventItems,
    this.isComplete = false,
  }) : super(id);

  // Ideal Methods
  // Method to mark the event as complete
  void markAsComplete() {
    isComplete = true;
  }

  // Method to update completion status of an EventItem
  void updateEventItemCompletion(String itemId, bool isComplete) {
    final itemIndex = eventItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      eventItems[itemIndex].isComplete = isComplete;
    }
  }

  // Method to get a summary string of the event (for display)
  String getSummary() {
    // Example: "Workout on 2025-05-31: Running, Weightlifting"
    // Or "Meal on 2025-05-31: Breakfast, Lunch"
    final itemNames = eventItems.map((item) => item.name).join(', ');
    return '${eventType.name.capitalizeFirstLetter()} on ${eventDate.toLocal().toIso8601String().split('T')[0]}: $itemNames';
  }

  // From/toJson methods for persistence (e.g., shared_preferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'eventType': eventType.name,
      'eventItems': eventItems.map((item) => item.toJson()).toList(),
      'isComplete': isComplete,
    };
  }

  factory FitnessEvent.fromJson(Map<String, dynamic> json) {
    return FitnessEvent(
      id: json['id'] as String,
      planId: json['planId'] as String?,
      eventName: json['eventName'],
      eventDate: DateTime.parse(json['eventDate'] as String),
      eventType: EventType.values.firstWhere(
        (e) => e.name == json['eventType'],
      ),
      eventItems: (json['eventItems'] as List)
          .map(
            (itemJson) => EventItem.fromJson(itemJson as Map<String, dynamic>),
          )
          .toList(),
      isComplete: json['isComplete'] as bool,
    );
  }
}

// Extension to easily capitalize the first letter of an enum name
extension StringCasingExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
