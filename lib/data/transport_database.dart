class TransportData {
  static const Map<String, Map<String, double>> carEmissions = {
    'Maruti Suzuki': {
      'Alto': 0.119,
      'Swift': 0.131,
      'Baleno': 0.129,
      'Dzire': 0.132,
      'Wagon R': 0.125,
      'Ertiga': 0.158,
    },
    'Hyundai': {
      'i10': 0.127,
      'i20': 0.134,
      'Venue': 0.142,
      'Creta': 0.158,
      'Verna': 0.145,
      'Tucson': 0.187,
    },
    'Tata': {
      'Tiago': 0.119,
      'Nexon': 0.138,
      'Harrier': 0.168,
      'Safari': 0.175,
      'Altroz': 0.127,
      'Punch': 0.132,
    },
    'Mahindra': {
      'XUV300': 0.142,
      'XUV500': 0.189,
      'XUV700': 0.195,
      'Thar': 0.198,
      'Scorpio': 0.187,
      'Bolero': 0.178,
    },
    'Honda': {
      'City': 0.138,
      'Amaze': 0.129,
      'WR-V': 0.142,
      'Jazz': 0.127,
    },
  };

  static const Map<String, Map<String, double>> publicTransport = {
    'Bus': {
      'City Bus (CNG)': 0.068,
      'City Bus (Diesel)': 0.082,
      'Volvo AC Bus': 0.089,
      'Electric Bus': 0.025,
      'Mini Bus': 0.072,
    },
    'Train': {
      'Local Train (Electric)': 0.041,
      'Metro': 0.035,
      'Suburban Train': 0.042,
      'Inter-city Train (Electric)': 0.038,
      'Inter-city Train (Diesel)': 0.056,
    },
    'Auto Rickshaw': {
      'CNG Auto': 0.064,
      'Electric Auto': 0.022,
      'Petrol Auto': 0.078,
    },
    'Two Wheeler': {
      'Motorcycle (100-125cc)': 0.045,
      'Motorcycle (125-150cc)': 0.052,
      'Motorcycle (150-200cc)': 0.058,
      'Motorcycle (>200cc)': 0.065,
      'Electric Scooter': 0.018,
      'Petrol Scooter': 0.048,
    },
  };

  // Helper method to get all transport categories
  static List<String> get categories => [
        ...carEmissions.keys,
        ...publicTransport.keys,
      ];

  // Helper method to get models for a category
  static List<String> getModels(String category) {
    if (carEmissions.containsKey(category)) {
      return carEmissions[category]!.keys.toList();
    } else if (publicTransport.containsKey(category)) {
      return publicTransport[category]!.keys.toList();
    }
    return [];
  }

  // Helper method to get emission factor
  static double getEmissionFactor(String category, String model) {
    if (carEmissions.containsKey(category)) {
      return carEmissions[category]?[model] ?? 0.2;
    } else if (publicTransport.containsKey(category)) {
      return publicTransport[category]?[model] ?? 0.08;
    }
    return 0.2; // default fallback
  }
} 