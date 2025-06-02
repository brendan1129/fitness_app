import 'package:fitness_app/model/event_item.dart';

class Meal extends EventItem {
  final int calories;
  final int carbs;
  final int fat;
  final int protein;
  final String? notes; // Nullable

  Meal({
    required super.id,
    required super.name,
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
    this.notes,
    super.isComplete,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'meal', // Important for polymorphic deserialization
      'name': name,
      'isComplete': isComplete,
      'calories': calories,
      'carbs': carbs,
      'fat': fat,
      'protein': protein,
      'notes': notes,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      isComplete: json['isComplete'] as bool,
      calories: json['calories'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      protein: json['protein'] as int,
      notes: json['notes'] as String?,
    );
  }
}
