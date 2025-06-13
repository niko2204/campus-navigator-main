import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteService {
  // Method to get the route between two locations from OpenRouteService
  Future<Map<String, dynamic>> getRoute(
      LatLng from, LatLng to, String method) async {
    try {
      final String apiKey = dotenv.env['OPENROUTE_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('OpenRoute API key is not set in .env file');
      }

      // 좌표 유효성 검사
      if (from.latitude < -90 || from.latitude > 90 || 
          from.longitude < -180 || from.longitude > 180 ||
          to.latitude < -90 || to.latitude > 90 || 
          to.longitude < -180 || to.longitude > 180) {
        throw Exception('Invalid coordinates');
      }

      final String url =
          'https://api.openrouteservice.org/v2/directions/$method?api_key=$apiKey&start=${from.longitude},${from.latitude}&end=${to.longitude},${to.latitude}';

      debugPrint('Requesting route from OpenRouteService...');
      debugPrint('URL: $url');
      
      final response = await http.get(Uri.parse(url));
      debugPrint('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 응답 데이터 유효성 검사
        if (data == null) {
          throw Exception('Empty response from API');
        }
        
        if (data['features'] == null || data['features'].isEmpty) {
          throw Exception('No route found in the response');
        }

        if (data['features'][0]['geometry'] == null || 
            data['features'][0]['geometry']['coordinates'] == null) {
          throw Exception('Invalid route data format');
        }

        final coordinates = (data['features'][0]['geometry']['coordinates'] as List)
            .map((c) {
              if (c is! List || c.length < 2) {
                throw Exception('Invalid coordinate format');
              }
              return LatLng(c[1], c[0]);
            })
            .toList();

        if (coordinates.isEmpty) {
          throw Exception('No coordinates in route');
        }

        return {
          'coordinates': coordinates,
          'distance': data['features'][0]['properties']['segments'][0]['distance'] ?? 0,
          'duration': data['features'][0]['properties']['segments'][0]['duration'] ?? 0,
        };
      } else if (response.statusCode == 403) {
        throw Exception('API key is invalid or expired');
      } else if (response.statusCode == 429) {
        throw Exception('API request limit exceeded');
      } else {
        throw Exception('Failed to load route: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getRoute: $e');
      throw Exception('Failed to calculate route: $e');
    }
  }

  // Method to generate a polyline for the route from a list of LatLng coordinates
  Polyline getPolyline(List<LatLng> route) {
    return Polyline(
      polylineId: PolylineId('route'),
      points: route,
      width: 5,
      color: Colors.blue,
      patterns: [PatternItem.dash(20.0), PatternItem.gap(10.0)],
    );
  }
}
