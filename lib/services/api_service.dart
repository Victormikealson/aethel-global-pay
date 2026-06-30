import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Connects the Flutter app to the live PHP + MySQL backend.
///
/// Base URL is automatically selected:
///   - Chrome (web)   → http://localhost/hermus/api
///   - Android/iOS    → http://172.16.41.213/hermus/api  (PC's local IP)
///
/// If your PC's IP changes, update [_mobileUrl] below.
class ApiService {
  // ── Base URLs ───────────────────────────────────────────────────────────────
  static const String _webUrl    = 'http://localhost/hermus/api';
  static const String _mobileUrl = 'http://172.16.41.213/hermus/api';

  /// Automatically picks the right URL for the current platform.
  static String get baseUrl => kIsWeb ? _webUrl : _mobileUrl;

  // ── Auth endpoints ──────────────────────────────────────────────────────────

  /// Register a new user.
  /// Returns {"status":"success","token":"...","name":"...","email":"..."}
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register.php'),
            headers: _publicHeaders,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
            }),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Register error: $e');
      return {'status': 'error', 'message': 'Network error. Check connection.'};
    }
  }

  /// Log in an existing user.
  /// Returns {"status":"success","token":"...","name":"...","wallet_balance":...}
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: _publicHeaders,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Login error: $e');
      return {'status': 'error', 'message': 'Network error. Check connection.'};
    }
  }

  // ── Wallet endpoints ────────────────────────────────────────────────────────

  /// Get the current wallet balance from the server.
  static Future<Map<String, dynamic>> getWalletBalance(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/wallet.php'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error'};
    }
  }

  /// Update wallet balance on the server.
  /// Pass a positive [amount] to top up, negative to deduct.
  static Future<Map<String, dynamic>> updateWalletBalance(
      String token, double amount) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wallet.php'),
            headers: _authHeaders(token),
            body: jsonEncode({'amount': amount}),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error'};
    }
  }

  // ── Rides endpoints ─────────────────────────────────────────────────────────

  /// Fetch all rides for the logged-in user.
  static Future<Map<String, dynamic>> getRides(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/rides.php'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error'};
    }
  }

  /// Save a new ride booking to the server.
  static Future<Map<String, dynamic>> saveRide(
      String token, Map<String, dynamic> rideData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/rides.php'),
            headers: _authHeaders(token),
            body: jsonEncode(rideData),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error'};
    }
  }

  // ── Shipments endpoints ─────────────────────────────────────────────────────

  /// Fetch all shipments for the logged-in user.
  static Future<Map<String, dynamic>> getShipments(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/shipments.php'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error'};
    }
  }

  /// Save a new shipment to the server.
  static Future<Map<String, dynamic>> saveShipment(
      String token, Map<String, dynamic> shipmentData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/shipments.php'),
            headers: _authHeaders(token),
            body: jsonEncode(shipmentData),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error'};
    }
  }

  /// Update a shipment's status on the server.
  static Future<Map<String, dynamic>> updateShipmentStatus(
      String token, String shipmentId, String newStatus) async {
    try {
      final request = http.Request(
        'PUT',
        Uri.parse('$baseUrl/shipments.php'),
      );
      request.headers.addAll(_authHeaders(token));
      request.body = jsonEncode({'id': shipmentId, 'status': newStatus});

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error'};
    }
  }

  // ── Helper ──────────────────────────────────────────────────────────────────

  /// Build headers with Bearer token for protected endpoints.
  static Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
        'Accept': 'application/json',
      };

  /// Build headers for public endpoints (login/register).
  static Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
        'Accept': 'application/json',
      };
}
