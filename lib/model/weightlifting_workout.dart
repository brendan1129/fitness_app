import 'package:fitness_app/model/workout.dart';

class WeightliftingWorkout extends Workout {
  final int reps;
  final String intensity; // Could also be a custom Intensity enum or class

  WeightliftingWorkout({
    required super.id,
    required super.name,
    required this.reps,
    required this.intensity,
    super.isComplete,
  }) : super(workoutType: WorkoutType.weightlifting);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type':
          'weightliftingWorkout', // Important for polymorphic deserialization
      'name': name,
      'isComplete': isComplete,
      'reps': reps,
      'intensity': intensity,
    };
  }

  factory WeightliftingWorkout.fromJson(Map<String, dynamic> json) {
    return WeightliftingWorkout(
      id: json['id'] as String,
      name: json['name'] as String,
      isComplete: json['isComplete'] as bool,
      reps: json['reps'] as int,
      intensity: json['intensity'] as String,
    );
  }
}
