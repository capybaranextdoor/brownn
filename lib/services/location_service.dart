import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static final directions = GoogleMapsDirections(
    apiKey: 'YOUR_GOOGLE_MAPS_API_KEY', // Replace with your API key
  );

  // Request location permission
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    if (await requestPermission()) {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
    return null;
  }

  // Calculate distance between two points
  static Future<double?> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final response = await directions.directionsWithLocation(
        Location(lat: startLat, lng: startLng),
        Location(lat: endLat, lng: endLng),
        travelMode: TravelMode.driving,
      );

      if (response.status == 'OK') {
        // Distance in meters, convert to kilometers
        return response.routes.first.legs.first.distance.value / 1000;
      }
    } catch (e) {
      print('Error calculating distance: $e');
    }
    return null;
  }

  // Track journey
  static Stream<Position> trackJourney() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  static Stream<Position> trackJourneyWithSpeed() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: null,    // No time limit
      ),
    ).map((position) {
      // Calculate speed in km/h
      double speed = position.speed * 3.6; // Convert m/s to km/h
      print('Current speed: ${speed.toStringAsFixed(1)} km/h');
      return position;
    });
  }

  static double calculateRouteDistance(List<LatLng> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance / 1000; // Convert to kilometers
  }

  static LatLngBounds getBoundsForRoute(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
} 