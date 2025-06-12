import 'package:fitness_app/model/event_item.dart';

enum WorkoutType { cardio, weightlifting }

abstract class Workout extends EventItem {
  final WorkoutType workoutType;

  Workout({
    required super.id,
    required super.name,
    required this.workoutType,
    super.isComplete,
    super.notes,
  });
}
