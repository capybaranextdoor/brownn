import 'package:flutter/material.dart';
import '../services/uber_service.dart';

class UberTripsScreen extends StatefulWidget {
  const UberTripsScreen({super.key});

  @override
  State<UberTripsScreen> createState() => _UberTripsScreenState();
}

class _UberTripsScreenState extends State<UberTripsScreen> {
  final UberService _uberService = UberService();
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = false;
  double _totalEmissions = 0;

  @override
  void initState() {
    super.initState();
    _connectUber();
  }

  Future<void> _connectUber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _uberService.authorize();
      await _loadTrips();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to Uber: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTrips() async {
    try {
      // Get the access token first
      String? accessToken = await _uberService.getAccessToken();
      
      if (accessToken != null) {
        final trips = await _uberService.getTripHistory(accessToken); // Pass the access token
        double totalEmissions = 0;

        // Cast trips to List<Map<String, dynamic>>
        if (trips != null) {
          List<Map<String, dynamic>> tripList = List<Map<String, dynamic>>.from(trips);

          for (var trip in tripList) {
            final emissions = await _uberService.getTripEmissions(trip['trip_id']);
            totalEmissions += emissions['emissions'];
            trip['emissions'] = emissions;
          }

          setState(() {
            _trips = tripList;  // Update _trips with the casted list
            _totalEmissions = totalEmissions;
          });
        }
      } else {
        print('Failed to retrieve access token.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading trips: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uber Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildEmissionsSummary(),
                Expanded(child: _buildTripsList()),
              ],
            ),
    );
  }

  Widget _buildEmissionsSummary() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Total Emissions from Uber Trips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_totalEmissions.toStringAsFixed(2)} kg CO₂',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    return ListView.builder(
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final trip = _trips[index];
        final emissions = trip['emissions'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              Icons.directions_car,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Trip on ${trip['request_time']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Distance: ${emissions['distance']} miles'),
                Text('Vehicle: ${emissions['vehicleType']}'),
                Text(
                  'Emissions: ${emissions['emissions'].toStringAsFixed(2)} kg CO₂',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            onTap: () {
              // Show detailed trip information
              _showTripDetails(trip);
            },
          ),
        );
      },
    );
  }

  void _showTripDetails(Map<String, dynamic> trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trip Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Date: ${trip['request_time']}'),
            Text('Distance: ${trip['emissions']['distance']} miles'),
            Text('Vehicle: ${trip['emissions']['vehicleType']}'),
            Text(
              'Emissions: ${trip['emissions']['emissions'].toStringAsFixed(2)} kg CO₂',
            ),
            Text('Start: ${trip['start_city']['display_name']}'),
            Text('End: ${trip['end_city']['display_name']}'),
          ],
        ),
      ),
    );
  }
} 