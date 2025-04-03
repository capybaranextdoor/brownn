import 'dart:async';
import 'package:flutter/material.dart';
import '../data/transport_database.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/uber_service.dart';

class CarbonScreen extends StatefulWidget {
  const CarbonScreen({Key? key}) : super(key: key);

  @override
  State<CarbonScreen> createState() => _CarbonScreenState();
}

class _CarbonScreenState extends State<CarbonScreen> {
  final TextEditingController _distanceController = TextEditingController();
  String _mainCategory = 'Maruti Suzuki';
  String? _selectedVehicle;
  double _transportEmissions = 0;
  List<String> _recommendations = [];
  Position? _startPosition;
  Position? _currentPosition;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _routePoints = [];
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = TransportData.getModels(_mainCategory).first;
    _startTracking();
  }

  void _calculateTransportEmissions() {
    double distance = double.tryParse(_distanceController.text) ?? 0;
    double emissionFactor = TransportData.getEmissionFactor(
      _mainCategory,
      _selectedVehicle ?? '',
    );

    setState(() {
      _transportEmissions = distance * emissionFactor;
      _recommendations = _getTransportRecommendations(_transportEmissions);
    });
  }

  List<String> _getTransportRecommendations(double emissions) {
    List<String> recommendations = [];
    
    if (emissions > 20) {
      recommendations.addAll([
        'Consider carpooling or using public transport',
        'Try combining multiple errands into one trip',
        'Look into electric or hybrid vehicle options',
      ]);
    } else if (emissions > 10) {
      recommendations.addAll([
        'Good start! Consider using public transport more often',
        'Try walking or cycling for shorter distances',
      ]);
    } else {
      recommendations.add('Excellent! Your transport emissions are low');
    }
    
    return recommendations;
  }

  void _startTracking() async {
    await LocationService.requestPermission();
    LocationService.trackJourney().listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      print('Current Position: ${position.latitude}, ${position.longitude}');
    });
  }

  void _stopJourneyTracking() {
    _positionStream?.cancel();
    setState(() {
      _isTracking = false;
    });
    _calculateTransportEmissions();
  }

  void _updateDistance() {
    if (_routePoints.length < 2) return;
    
    double totalDistance = 0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude,
      );
    }
    
    // Convert to kilometers
    _distanceController.text = (totalDistance / 1000).toStringAsFixed(2);
  }

  void _fitRouteInMap() {
    if (_mapController != null && _routePoints.length > 1) {
      final bounds = LocationService.getBoundsForRoute(_routePoints);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0), // 50 pixels padding
      );
    }
  }

  void _fetchUberData() async {
    UberService uberService = UberService();
    String? accessToken = await uberService.getAccessToken();
    
    if (accessToken != null) {
      List<dynamic>? tripHistory = await uberService.getTripHistory(accessToken);
      // Handle the trip history data as needed
      print(tripHistory);
    } else {
      print('Failed to retrieve access token.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Carbon Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculate Your Journey Emissions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _distanceController,
                      decoration: const InputDecoration(
                        labelText: 'Distance (km)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.route),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _mainCategory,
                      items: TransportData.categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _mainCategory = value;
                            _selectedVehicle = TransportData.getModels(value).first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicle,
                      items: TransportData.getModels(_mainCategory)
                          .map((vehicle) => DropdownMenuItem(
                                value: vehicle,
                                child: Text(vehicle),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVehicle = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _calculateTransportEmissions,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Emissions'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            if (_transportEmissions > 0) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transport Emissions: ${_transportEmissions.toStringAsFixed(2)} kg CO2',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Recommendations:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.eco, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(rec)),
                          ],
                        ),
                      ))),
                    ],
                  ),
                ),
              ),
            ],
            _buildMapSection(),
            FloatingActionButton(
              onPressed: _isTracking ? _stopJourneyTracking : _startTracking,
              child: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      elevation: 4,
      child: Container(
        height: 200,
        child: _routePoints.isEmpty
            ? const Center(child: Text('Start tracking to see your route'))
            : GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  _fitRouteInMap();
                },
                initialCameraPosition: CameraPosition(
                  target: _routePoints.first,
                  zoom: 15,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: _routePoints,
                    color: Colors.blue,
                    width: 5,
                  ),
                },
                markers: {
                  if (_startPosition != null)
                    Marker(
                      markerId: const MarkerId('start'),
                      position: _routePoints.first,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Start',
                        snippet: 'Journey started here',
                      ),
                    ),
                  if (_currentPosition != null)
                    Marker(
                      markerId: const MarkerId('current'),
                      position: _routePoints.last,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Current',
                        snippet: 'Distance: ${_distanceController.text} km',
                      ),
                    ),
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }
} 