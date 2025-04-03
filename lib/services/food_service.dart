import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_entry.dart';
import '../data/food_database.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a food entry
  Future<void> addFoodEntry(FoodEntry entry) async {
    await _firestore.collection('food_entries').add(entry.toMap());
  }

  // Get food entries for a specific date
  Stream<List<FoodEntry>> getFoodEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('food_entries')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final foodName = data['foodName'] as String;
            final food = FoodDatabase.searchFoods(foodName).first;
            
            return FoodEntry(
              id: doc.id,
              date: DateTime.parse(data['date']),
              mealType: data['mealType'],
              food: food,
              servings: data['servings'],
            );
          }).toList();
        });
  }

  // Get total carbon footprint for a date range
  Future<double> getTotalCarbonFootprint(DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('food_entries')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .get();

    return snapshot.docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc.data()['carbonFootprint'] as double),
    );
  }
} 