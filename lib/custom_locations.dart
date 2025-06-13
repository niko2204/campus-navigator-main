import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class CustomLocation {
  final String name;
  final LatLng coordinates;
  final String? indoorMapUrl;

  CustomLocation({
    required this.name, 
    required this.coordinates,
    this.indoorMapUrl,
  });

  bool hasIndoorMap() => indoorMapUrl != null;
}

class LocationRepository {
  static final List<CustomLocation> _locations = [];
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/locations.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 건물 정보 로드
      final List<dynamic> buildings = jsonData['buildings'];
      for (var building in buildings) {
        final baseName = building['baseName'];
        final coordinates = LatLng(
          building['coordinates']['latitude'],
          building['coordinates']['longitude']
        );
        final indoorMapUrl = building['indoorMapUrl'];

        final List<dynamic> rooms = building['rooms'];
        for (var room in rooms) {
          _locations.add(CustomLocation(
            name: "$baseName-${room['number']}호 ${room['name']} 교수님",
            coordinates: coordinates,
            indoorMapUrl: indoorMapUrl,
          ));
        }
      }

      // 특별 위치 로드
      final List<dynamic> specialLocations = jsonData['specialLocations'];
      for (var location in specialLocations) {
        _locations.add(CustomLocation(
          name: location['name'],
          coordinates: LatLng(
            location['coordinates']['latitude'],
            location['coordinates']['longitude']
          ),
          indoorMapUrl: location['indoorMapUrl'],
        ));
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading locations: $e');
      rethrow;
    }
  }

  static List<CustomLocation> get locations {
    if (!_isInitialized) {
      throw Exception('LocationRepository not initialized. Call initialize() first.');
    }
    return _locations;
  }

  static List<CustomLocation> searchLocations(String query) {
    if (!_isInitialized) {
      throw Exception('LocationRepository not initialized. Call initialize() first.');
    }
    return _locations
        .where((location) =>
            location.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static String? getIndoorMapUrl(String buildingName) {
    if (!_isInitialized) {
      throw Exception('LocationRepository not initialized. Call initialize() first.');
    }
    return _locations
        .firstWhere(
          (location) => location.name.startsWith(buildingName),
          orElse: () => CustomLocation(
            name: '',
            coordinates: LatLng(0, 0),
          ),
        )
        .indoorMapUrl;
  }

  static bool hasIndoorMap(String buildingName) {
    if (!_isInitialized) {
      throw Exception('LocationRepository not initialized. Call initialize() first.');
    }
    return _locations
        .any((location) => 
            location.name.startsWith(buildingName) && 
            location.indoorMapUrl != null);
  }
}
