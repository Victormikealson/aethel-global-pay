import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Result returned by [DistanceService.getDistanceAndFare].
class DistanceResult {
  /// Straight-line or road distance in kilometres.
  final double distanceKm;

  /// Human-readable distance string e.g. "12.4 km"
  final String distanceText;

  /// Estimated travel duration string e.g. "18 mins" (only from API)
  final String durationText;

  /// Calculated fare in UGX
  final double fareUGX;

  /// Whether the distance came from the real Google API (true)
  /// or the Haversine fallback (false)
  final bool isApiResult;

  const DistanceResult({
    required this.distanceKm,
    required this.distanceText,
    required this.durationText,
    required this.fareUGX,
    required this.isApiResult,
  });
}

/// Service that calculates the road distance between two locations
/// and derives the transport fare from it.
///
/// Flow:
///   1. Try Google Distance Matrix API (requires API key)
///   2. If API fails / no key → fall back to Haversine straight-line formula
///      using geocoded coordinates from the Nominatim (OpenStreetMap) API
///      which is free and requires no key.
///
/// Fare rates per km (UGX):
///   Boda-Boda : 700  UGX/km  (min 3,000)
///   Car        : 1,800 UGX/km (min 8,000)
///   Taxi       : 1,200 UGX/km (min 5,000)
///   Bus        : 400  UGX/km  (min 2,000)
class DistanceService {
  // Singleton
  static final DistanceService _instance = DistanceService._internal();
  factory DistanceService() => _instance;
  DistanceService._internal();

  // ── Fare rates ──────────────────────────────────────────────────────────────

  /// Rate per kilometre in UGX per ride type.
  /// Boda-Boda : 700 UGX/km  (min 3,000)
  /// Car        : 1,800 UGX/km (min 8,000)
  /// Taxi       : 1,200 UGX/km (min 5,000)
  /// Bus        : 400  UGX/km  (min 2,000)
  static const Map<String, double> _ratePerKm = {
    'Car': 1800,
    'Taxi': 1200,
    'Boda-Boda': 700,
    'Bus': 400,
  };

  static const Map<String, double> _minimumFare = {
    'Car': 8000,
    'Taxi': 5000,
    'Boda-Boda': 3000,
    'Bus': 2000,
  };

  final Map<String, Map<String, double>> _geocodeCache = {};

  // ── Google API key ──────────────────────────────────────────────────────────
  // Replace with your actual Google Maps API key.
  // Enable: Distance Matrix API + Geocoding API in Google Cloud Console.
  // Leave empty to always use the free Nominatim fallback.
  static const String _googleApiKey = '';

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Calculate distance between [origin] and [destination] (place name strings)
  /// and return the fare for [rideType].
  Future<DistanceResult> getDistanceAndFare({
    required String origin,
    required String destination,
    required String rideType,
  }) async {
    double distanceKm;
    String distanceText;
    String durationText = '';
    bool isApiResult = false;

    if (_googleApiKey.isNotEmpty) {
      // ── Try Google Distance Matrix API ──────────────────────────────────
      try {
        final result = await _googleDistanceMatrix(origin, destination);
        distanceKm = result['distanceKm'] as double;
        distanceText = result['distanceText'] as String;
        durationText = result['durationText'] as String;
        isApiResult = true;
      } catch (e) {
        debugPrint('Google API failed, using Haversine fallback: $e');
        final fallback = await _haversineFallback(origin, destination);
        distanceKm = fallback['distanceKm'] as double;
        distanceText = fallback['distanceText'] as String;
      }
    } else {
      // ── Use free Nominatim geocoding + Haversine ─────────────────────────
      final fallback = await _haversineFallback(origin, destination);
      distanceKm = fallback['distanceKm'] as double;
      distanceText = fallback['distanceText'] as String;
    }

    final fare = _calculateFare(distanceKm, rideType);

    return DistanceResult(
      distanceKm: distanceKm,
      distanceText: distanceText,
      durationText: durationText,
      fareUGX: fare,
      isApiResult: isApiResult,
    );
  }

  /// Calculate distance using raw GPS coordinates for the origin
  /// (avoids reverse-geocode CORS issues on web) and a place name
  /// for the destination.
  Future<DistanceResult> getDistanceAndFareFromCoords({
    required double originLat,
    required double originLon,
    required String originLabel,
    required String destination,
    required String rideType,
  }) async {
    double distanceKm;
    String distanceText;
    String durationText = '';
    bool isApiResult = false;

    if (_googleApiKey.isNotEmpty) {
      // Use "lat,lon" string as origin for Google API
      final originStr = '$originLat,$originLon';
      try {
        final result = await _googleDistanceMatrix(originStr, destination);
        distanceKm = result['distanceKm'] as double;
        distanceText = result['distanceText'] as String;
        durationText = result['durationText'] as String;
        isApiResult = true;
      } catch (e) {
        debugPrint('Google API failed: $e');
        final destCoords = await _geocode(destination);
        distanceKm = _haversine(
            originLat, originLon, destCoords['lat']!, destCoords['lon']!) *
            1.3;
        distanceText = '${distanceKm.toStringAsFixed(1)} km (est.)';
      }
    } else {
      // Geocode only the destination if needed; origin is already coordinates.
      final destCoords = await _geocode(destination);
      distanceKm = _haversine(
          originLat, originLon, destCoords['lat']!, destCoords['lon']!) *
          1.3;
      distanceText = '${distanceKm.toStringAsFixed(1)} km (est.)';
    }

    final fare = _calculateFare(distanceKm, rideType);
    return DistanceResult(
      distanceKm: distanceKm,
      distanceText: distanceText,
      durationText: durationText,
      fareUGX: fare,
      isApiResult: isApiResult,
    );
  }

  /// Calculate distance when both origin and destination are already
  /// available as coordinates.
  Future<DistanceResult> getDistanceAndFareFromCoordsToCoords({
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
    required String rideType,
  }) async {
    double distanceKm;
    String distanceText;
    String durationText = '';
    bool isApiResult = false;

    if (_googleApiKey.isNotEmpty) {
      try {
        final originStr = '$originLat,$originLon';
        final destinationStr = '$destinationLat,$destinationLon';
        final result = await _googleDistanceMatrix(originStr, destinationStr);
        distanceKm = result['distanceKm'] as double;
        distanceText = result['distanceText'] as String;
        durationText = result['durationText'] as String;
        isApiResult = true;
      } catch (e) {
        debugPrint('Google API failed: $e');
        distanceKm = _haversine(originLat, originLon, destinationLat, destinationLon) *
            1.3;
        distanceText = '${distanceKm.toStringAsFixed(1)} km (est.)';
      }
    } else {
      distanceKm = _haversine(originLat, originLon, destinationLat, destinationLon) *
          1.3;
      distanceText = '${distanceKm.toStringAsFixed(1)} km (est.)';
    }

    final fare = _calculateFare(distanceKm, rideType);
    return DistanceResult(
      distanceKm: distanceKm,
      distanceText: distanceText,
      durationText: durationText,
      fareUGX: fare,
      isApiResult: isApiResult,
    );
  }

  /// Get the device's current GPS position.
  /// Returns a [GpsPosition] with lat, lon and a display label.
  /// Works on Android, iOS and Chrome (browser Geolocation API).
  Future<GpsPosition?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Try reverse geocode for a readable label; fall back gracefully
      String label = 'My Location';
      try {
        label = await _reverseGeocode(position.latitude, position.longitude);
      } catch (_) {
        // On web, Nominatim may be blocked by CORS — use coordinates as label
        label =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }

      return GpsPosition(
        lat: position.latitude,
        lon: position.longitude,
        label: label,
      );
    } catch (e) {
      debugPrint('GPS error: $e');
      return null;
    }
  }

  /// Legacy helper kept for backward compatibility.
  Future<String?> getCurrentLocationName() async {
    final pos = await getCurrentPosition();
    return pos?.label;
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Call Google Distance Matrix API to get road distance and duration.
  Future<Map<String, dynamic>> _googleDistanceMatrix(
      String origin, String destination) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/distancematrix/json',
      {
        'origins': origin,
        'destinations': destination,
        'units': 'metric',
        'key': _googleApiKey,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Google API HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') {
      throw Exception('Google API status: ${data['status']}');
    }

    final element =
        (data['rows'] as List).first['elements'] as List;
    final el = element.first as Map<String, dynamic>;

    if (el['status'] != 'OK') {
      throw Exception('Element status: ${el['status']}');
    }

    final distanceM =
        (el['distance']['value'] as num).toDouble(); // metres
    final distanceKm = distanceM / 1000;
    final distanceText = el['distance']['text'] as String;
    final durationText = el['duration']['text'] as String;

    return {
      'distanceKm': distanceKm,
      'distanceText': distanceText,
      'durationText': durationText,
    };
  }

  /// Geocode a place name using Nominatim (OpenStreetMap) — free, no key.
  Future<Map<String, double>> _geocode(String placeName) async {
    // Append Uganda to improve local result accuracy
    final cacheKey = placeName.toLowerCase();
    if (_geocodeCache.containsKey(cacheKey)) {
      return _geocodeCache[cacheKey]!;
    }

    final query = placeName.toLowerCase().contains('uganda')
        ? placeName
        : '$placeName, Uganda';

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {'q': query, 'format': 'json', 'limit': '1'},
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'HermusGlobalHauls/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Nominatim HTTP ${response.statusCode}');
    }

    final results = jsonDecode(response.body) as List;
    if (results.isEmpty) {
      throw Exception('Location not found: $placeName');
    }

    final first = results.first as Map<String, dynamic>;
    final coords = {
      'lat': double.parse(first['lat'] as String),
      'lon': double.parse(first['lon'] as String),
    };
    _geocodeCache[cacheKey] = coords;
    return coords;
  }

  /// Reverse geocode coordinates to a place name using Nominatim.
  Future<String> _reverseGeocode(double lat, double lon) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
      },
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'HermusGlobalHauls/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return 'Current Location';

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;
    if (address == null) return 'Current Location';

    // Build a short readable name: suburb/city
    final parts = <String>[];
    for (final key in ['suburb', 'city_district', 'town', 'city', 'county']) {
      if (address.containsKey(key)) {
        parts.add(address[key] as String);
        if (parts.length == 2) break;
      }
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  /// Haversine formula: straight-line distance between two lat/lon points.
  /// Used as fallback when Google API is unavailable.
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  /// Geocode both locations then compute Haversine distance.
  Future<Map<String, dynamic>> _haversineFallback(
      String origin, String destination) async {
    final originCoords = await _geocode(origin);
    final destCoords = await _geocode(destination);

    final distanceKm = _haversine(
      originCoords['lat']!,
      originCoords['lon']!,
      destCoords['lat']!,
      destCoords['lon']!,
    );

    // Road distance is typically ~30% longer than straight-line
    final roadEstimate = distanceKm * 1.3;

    return {
      'distanceKm': roadEstimate,
      'distanceText': '${roadEstimate.toStringAsFixed(1)} km (est.)',
    };
  }

  /// Calculate fare from distance and ride type.
  /// Formula: distance (km) × rate (UGX/km), rounded to nearest 500 UGX.
  double _calculateFare(double distanceKm, String rideType) {
    final rate = _ratePerKm[rideType] ?? 1000;
    final minimum = _minimumFare[rideType] ?? 3000;
    final calculated = distanceKm * rate;
    // Round up to nearest 500 UGX for clean pricing
    final rounded = (calculated / 500).ceil() * 500.0;
    return rounded < minimum ? minimum : rounded;
  }
}

// ── GPS position data class ───────────────────────────────────────────────────

/// Holds a GPS fix with coordinates and a human-readable label.
class GpsPosition {
  final double lat;
  final double lon;
  final String label;
  const GpsPosition({
    required this.lat,
    required this.lon,
    required this.label,
  });
}