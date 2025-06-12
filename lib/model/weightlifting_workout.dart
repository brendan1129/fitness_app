import 'package:fitness_app/model/workout.dart';

class WeightliftingWorkout extends Workout {
  int sets;
  int reps;
  String intensity; // Could also be a custom Intensity enum or class

  WeightliftingWorkout({
    required super.id,
    required super.name,
    required this.sets,
    required this.reps,
    required this.intensity,
    super.isComplete,
    super.notes = "",
  }) : super(workoutType: WorkoutType.weightlifting);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type':
          'weightliftingWorkout', // Important for polymorphic deserialization
      'name': name,
      'notes': super.notes,
      'isComplete': isComplete,
      'sets': sets,
      'reps': reps,
      'intensity': intensity,
    };
  }

  factory WeightliftingWorkout.fromJson(Map<String, dynamic> json) {
    return WeightliftingWorkout(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] ?? '',
      isComplete: json['isComplete'] as bool,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      intensity: json['intensity'] as String,
    );
  }
}
