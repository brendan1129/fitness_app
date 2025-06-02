import 'package:fitness_app/model/workout.dart';

class CardioWorkout extends Workout {
  final String distanceMetric;
  final double distanceValue;
  final String duration;

  CardioWorkout({
    required super.id,
    required super.name,
    required this.duration,
    required this.distanceMetric,
    required this.distanceValue,
    super.isComplete,
  }) : super(workoutType: WorkoutType.cardio);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'cardioWorkout', // Important for polymorphic deserialization
      'name': name,
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
      isComplete: json['isComplete'] as bool,
      duration: json['duration'] as String,
      distanceMetric: json['distanceMetric'] as String,
      distanceValue: (json['distanceValue'] as num).toDouble(),
    );
  }
}
