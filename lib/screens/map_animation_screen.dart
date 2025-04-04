import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MapAnimationScreen extends StatefulWidget {
  @override
  _MapAnimationScreenState createState() => _MapAnimationScreenState();
}

class _MapAnimationScreenState extends State<MapAnimationScreen> {
  late GoogleMapController mapController;
  List<LatLng> routeCoordinates = [
    LatLng(40.785091, -73.968285), // Central Park
    LatLng(40.7580, -73.9855), // Times Square
  ];
  int currentIndex = 0;
  late Timer timer;
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalDistance();
    _startAnimation();
  }

  void _calculateTotalDistance() {
    // Simple distance calculation (in km) between points
    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      totalDistance += _calculateDistance(routeCoordinates[i], routeCoordinates[i + 1]);
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Radius of the Earth in km
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLon = _degreesToRadians(end.longitude - start.longitude);
    double a = 
      (sin(dLat / 2) * sin(dLat / 2)) +
      (cos(_degreesToRadians(start.latitude)) * cos(_degreesToRadians(end.latitude)) *
      sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in km
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793238 / 180);
  }

  void _startAnimation() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (currentIndex < routeCoordinates.length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        timer.cancel(); // Stop the timer when the end of the route is reached
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newLatLng(routeCoordinates[0]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Animation on Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: routeCoordinates[0],
          zoom: 14.0,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: routeCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
        markers: {
          Marker(
            markerId: MarkerId('car'),
            position: routeCoordinates[currentIndex],
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          double emissions = _calculateEmissions(totalDistance);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Carbon Emissions'),
              content: Text('Estimated emissions for this trip: ${emissions.toStringAsFixed(2)} kg CO₂'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.calculate),
      ),
    );
  }

  double _calculateEmissions(double distance) {
    const double emissionsFactor = 0.2; // kg CO₂ per km for a petrol car
    return distance * emissionsFactor;
  }
} 