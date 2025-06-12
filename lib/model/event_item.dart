import 'package:fitness_app/model/cardio_workout.dart';
import 'package:fitness_app/model/identifiable.dart';
import 'package:fitness_app/model/meal.dart';
import 'package:fitness_app/model/weightlifting_workout.dart';

abstract class EventItem extends Identifiable {
  String name; // Common property for all event items
  bool isComplete;
  String notes; // Added for user reflections
  EventItem({
    required String id,
    required this.name,
    this.isComplete = false,
    this.notes = "",
  }) : super(id);

  // Mark this specific item as complete
  void markAsComplete() {
    isComplete = true;
  }

  // Abstract method to convert to JSON for persistence
  Map<String, dynamic> toJson();

  // Factory constructor for deserialization (polymorphic)
  static EventItem fromJson(Map<String, dynamic> json) {
    final type =
        json['type'] as String; // Assuming a 'type' field is added in toJson
    switch (type) {
      case 'cardioWorkout':
        return CardioWorkout.fromJson(json);
      case 'weightliftingWorkout':
        return WeightliftingWorkout.fromJson(json);
      case 'meal':
        return Meal.fromJson(json);
      default:
        throw ArgumentError('Unknown EventItem type: $type');
    }
  }
}
