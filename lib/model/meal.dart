import 'package:fitness_app/model/event_item.dart';

class Meal extends EventItem {
  int calories;
  int carbs;
  int fat;
  int protein;
  Meal({
    required super.id,
    required super.name,
    super.notes = "",
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.protein,
    super.isComplete,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': 'meal', // Important for polymorphic deserialization
      'name': name,
      'notes': super.notes,
      'isComplete': isComplete,
      'calories': calories,
      'carbs': carbs,
      'fat': fat,
      'protein': protein,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] ?? '',
      isComplete: json['isComplete'] as bool,
      calories: json['calories'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      protein: json['protein'] as int,
    );
  }
}
