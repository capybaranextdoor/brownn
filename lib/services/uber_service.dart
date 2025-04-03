import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class UberService {
  // Replace these with your actual Uber API credentials
  static const String _clientId = 'YOUR_UBER_CLIENT_ID';
  static const String _clientSecret = 'YOUR_UBER_CLIENT_SECRET';
  static const String _redirectUri = 'carbontracker://oauth/callback';
  static const String _tokenUrl = 'https://sandbox-login.uber.com/oauth/v2/token';

  static const String _baseUrl = 'https://api.uber.com/v1.2';
  String? _accessToken;

  Future<void> authorize() async {
    final Uri authUrl = Uri.parse(
      'https://login.uber.com/oauth/v2/authorize'
      '?client_id=$_clientId'
      '&response_type=code'
      '&redirect_uri=$_redirectUri'
      '&scope=history profile:read',
    );

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Uber authorization';
    }
  }

  Future<void> handleAuthCallback(String code) async {
    final response = await http.post(
      Uri.parse('https://login.uber.com/oauth/v2/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to get access token');
    }
  }

  Future<List<dynamic>?> getTripHistory(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.uber.com/v1.2/history'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['history'];
    } else {
      print('Failed to get trip history: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>> getTripEmissions(String tripId) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/trips/$tripId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Calculate emissions based on distance and vehicle type
      double distance = data['distance']; // in miles
      String vehicleType = data['vehicle']['type'];

      // Approximate CO2 emissions (kg) based on vehicle type
      double emissionsFactor = _getEmissionsFactor(vehicleType);
      double emissions = distance * emissionsFactor;

      return {
        'distance': distance,
        'vehicleType': vehicleType,
        'emissions': emissions,
        'tripDetails': data,
      };
    } else {
      throw Exception('Failed to get trip details');
    }
  }

  double _getEmissionsFactor(String vehicleType) {
    // Approximate CO2 emissions factors (kg/mile)
    switch (vehicleType.toLowerCase()) {
      case 'uberx':
        return 0.29;
      case 'uberxl':
        return 0.35;
      case 'uber black':
        return 0.38;
      case 'uber suv':
        return 0.45;
      default:
        return 0.32; // default factor
    }
  }

  Future<String?> getAccessToken() async {
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'client_credentials',
        'scope': 'history profile:read',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      print('Failed to get access token: ${response.body}');
      return null;
    }
  }
}
