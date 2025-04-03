class FoodItem {
  final String name;
  final String category;
  final double carbonFootprint; // kg CO2e per serving
  final Map<String, double> nutrients;
  final String servingSize;
  final String? imageUrl;

  FoodItem({
    required this.name,
    required this.category,
    required this.carbonFootprint,
    required this.nutrients,
    required this.servingSize,
    this.imageUrl,
  });
}

class FoodDatabase {
  static final Map<String, List<FoodItem>> indianFoods = {
    'Rice Dishes': [
      FoodItem(
        name: 'Plain Rice',
        category: 'Rice Dishes',
        carbonFootprint: 0.16,
        servingSize: '100g',
        nutrients: {
          'calories': 130,
          'protein': 2.7,
          'carbs': 28,
          'fat': 0.3,
        },
      ),
      FoodItem(
        name: 'Biryani',
        category: 'Rice Dishes',
        carbonFootprint: 0.68,
        servingSize: '250g',
        nutrients: {
          'calories': 292,
          'protein': 15,
          'carbs': 45,
          'fat': 8,
        },
      ),
    ],
    'Breads': [
      FoodItem(
        name: 'Roti',
        category: 'Breads',
        carbonFootprint: 0.13,
        servingSize: '30g',
        nutrients: {
          'calories': 85,
          'protein': 3,
          'carbs': 18,
          'fat': 0.5,
        },
      ),
      FoodItem(
        name: 'Naan',
        category: 'Breads',
        carbonFootprint: 0.25,
        servingSize: '60g',
        nutrients: {
          'calories': 165,
          'protein': 5.5,
          'carbs': 33,
          'fat': 1.2,
        },
      ),
    ],
    'Lentils': [
      FoodItem(
        name: 'Dal',
        category: 'Lentils',
        carbonFootprint: 0.11,
        servingSize: '150g',
        nutrients: {
          'calories': 150,
          'protein': 9,
          'carbs': 28,
          'fat': 0.8,
        },
      ),
    ],
    'Vegetables': [
      FoodItem(
        name: 'Palak Paneer',
        category: 'Vegetables',
        carbonFootprint: 0.45,
        servingSize: '200g',
        nutrients: {
          'calories': 340,
          'protein': 14,
          'carbs': 12,
          'fat': 28,
        },
      ),
    ],
  };

  static List<String> get categories => indianFoods.keys.toList();

  static List<FoodItem> getFoodsByCategory(String category) {
    return indianFoods[category] ?? [];
  }

  static List<FoodItem> searchFoods(String query) {
    query = query.toLowerCase();
    List<FoodItem> results = [];
    
    for (var foods in indianFoods.values) {
      results.addAll(
        foods.where((food) => 
          food.name.toLowerCase().contains(query) ||
          food.category.toLowerCase().contains(query)
        ),
      );
    }
    
    return results;
  }

  static double calculateMealFootprint(List<FoodItem> items) {
    return items.fold(0, (sum, item) => sum + item.carbonFootprint);
  }

  // Helper method to get eco-friendly alternatives
  static List<FoodItem> getEcoFriendlyAlternatives(FoodItem food) {
    List<FoodItem> alternatives = [];
    
    for (var foods in indianFoods.values) {
      alternatives.addAll(
        foods.where((item) => 
          item.category == food.category &&
          item.carbonFootprint < food.carbonFootprint
        ),
      );
    }
    
    alternatives.sort((a, b) => 
      a.carbonFootprint.compareTo(b.carbonFootprint)
    );
    
    return alternatives.take(3).toList();
  }
} 