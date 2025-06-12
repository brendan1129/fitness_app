import 'package:fitness_app/model/workout.dart';

class CardioWorkout extends Workout {
  String distanceMetric;
  double distanceValue;
  String duration;

  CardioWorkout({
    required super.id,
    required super.name,
    required this.duration,
    required this.distanceMetric,
    required this.distanceValue,
    super.isComplete,
    super.notes,
  }) : super(workoutType: WorkoutType.cardio);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'cardioWorkout', // Important for polymorphic deserialization
      'name': name,
      'notes': super.notes,
      'isComplete': isComplete,
      'duration': duration,
      'distanceMetric': distanceMetric,
      'distanceValue': distanceValue,
    };
  }

  factory CardioWorkout.fromJson(Map<String, dynamic> json) {
    return CardioWorkout(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] ?? '',
      isComplete: json['isComplete'] as bool,
      duration: json['duration'] as String,
      distanceMetric: json['distanceMetric'] as String,
      distanceValue: (json['distanceValue'] as num).toDouble(),
    );
  }
}
