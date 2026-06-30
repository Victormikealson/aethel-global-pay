import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shipment_model.dart';
import '../models/ride_model.dart';

/// Handles all local data persistence using SharedPreferences.
/// Stores shipments, ride bookings, and wallet balance as JSON strings.
class StorageService {
  static const String _shipmentsKey = 'shipments';
  static const String _ridesKey = 'rides';
  static const String _balanceKey = 'wallet_balance';

  // ─── Wallet ────────────────────────────────────────────────────────────────

  /// Persist the current wallet balance
  Future<void> saveBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
  }

  /// Load the stored wallet balance; defaults to 125,000 UGX on first run
  Future<double> loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? 125000.0;
  }

  // ─── Shipments ─────────────────────────────────────────────────────────────

  /// Persist the full list of shipments
  Future<void> saveShipments(List<Shipment> shipments) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(shipments.map((s) => s.toMap()).toList());
    await prefs.setString(_shipmentsKey, encoded);
  }

  /// Load all stored shipments; returns seed data on first run
  Future<List<Shipment>> loadShipments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_shipmentsKey);
    if (raw == null) return _seedShipments();
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Shipment.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Default shipments shown on first launch
  List<Shipment> _seedShipments() {
    return [
      Shipment(
        id: 'seed-1',
        platform: 'Shein',
        trackingNumber: '#XL-4576',
        description: 'Clothing items',
        estimatedCost: 60000,
        status: 'Delivered',
        createdAt: DateTime(2024, 10, 17),
      ),
      Shipment(
        id: 'seed-2',
        platform: 'Amazon',
        trackingNumber: '#AM-8923',
        description: 'Electronics',
        estimatedCost: 45000,
        status: 'In Transit',
        createdAt: DateTime(2024, 10, 20),
      ),
      Shipment(
        id: 'seed-3',
        platform: 'Alibaba',
        trackingNumber: '#AL-1567',
        description: 'Home goods',
        estimatedCost: 35000,
        status: 'Delivered',
        createdAt: DateTime(2024, 9, 28),
      ),
    ];
  }

  // ─── Rides ─────────────────────────────────────────────────────────────────

  /// Persist the full list of ride bookings
  Future<void> saveRides(List<RideBooking> rides) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(rides.map((r) => r.toMap()).toList());
    await prefs.setString(_ridesKey, encoded);
  }

  /// Load all stored ride bookings
  Future<List<RideBooking>> loadRides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ridesKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => RideBooking.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
