import '../data/food_database.dart';

class FoodEntry {
  final String id;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final FoodItem food;
  final int servings;
  final double totalCarbonFootprint;

  FoodEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.food,
    required this.servings,
  }) : totalCarbonFootprint = food.carbonFootprint * servings;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'foodName': food.name,
      'servings': servings,
      'carbonFootprint': totalCarbonFootprint,
    };
  }
} 