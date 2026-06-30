import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/shipment_model.dart';
import '../models/ride_model.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

/// Central state management using ChangeNotifier + InheritedWidget.
///
/// Data flow:
///   - Firebase Firestore (cloud, works anywhere, offline-capable)
///   - SharedPreferences (local cache fallback)
///
/// Variables that trigger setState (notifyListeners):
///   [walletBalance]  → addMoney(), deductBalance()
///   [shipments]      → addShipment(), updateShipmentStatus()
///   [rides]          → bookRide()
///   [isLoading]      → loadData()
///   [isDarkMode]     → toggleTheme()
class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  final Uuid _uuid = const Uuid();

  double walletBalance = 0;
  List<Shipment> shipments = [];
  List<RideBooking> rides = [];
  bool isLoading = false;
  bool isDarkMode = false;

  // ── Theme ───────────────────────────────────────────────────────────────────

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDarkMode);
    notifyListeners();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  }

  // ── Load data ───────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    await loadTheme();

    try {
      // Load from Firebase Firestore
      walletBalance = await FirebaseService.getWalletBalance();
      rides = await FirebaseService.getRides();
      shipments = await FirebaseService.getShipments();

      // Cache locally
      await _storage.saveBalance(walletBalance);
      await _storage.saveRides(rides);
      await _storage.saveShipments(shipments);
    } catch (e) {
      // Fallback to local cache if Firebase fails
      debugPrint('Firebase load failed, using local cache: $e');
      walletBalance = await _storage.loadBalance();
      rides = await _storage.loadRides();
      shipments = await _storage.loadShipments();
    }

    isLoading = false;
    notifyListeners();
  }

  // ── Wallet ──────────────────────────────────────────────────────────────────

  Future<void> addMoney(double amount) async {
    walletBalance += amount;
    await FirebaseService.updateWalletBalance(walletBalance);
    await _storage.saveBalance(walletBalance);
    await _notifications.notifyWalletTopUp(amount);
    notifyListeners();
  }

  Future<bool> deductBalance(double amount) async {
    if (walletBalance < amount) return false;
    walletBalance -= amount;
    await FirebaseService.updateWalletBalance(walletBalance);
    await _storage.saveBalance(walletBalance);
    notifyListeners();
    return true;
  }

  // ── Shipments ───────────────────────────────────────────────────────────────

  Future<void> addShipment({
    required String platform,
    required String trackingNumber,
    required String description,
    required double estimatedCost,
  }) async {
    final newShipment = Shipment(
      id: _uuid.v4(),
      platform: platform,
      trackingNumber: trackingNumber,
      description: description,
      estimatedCost: estimatedCost,
      status: 'Processing',
      createdAt: DateTime.now(),
    );
    shipments.insert(0, newShipment);
    await FirebaseService.saveShipment(newShipment);
    await _storage.saveShipments(shipments);
    notifyListeners();
  }

  Future<void> updateShipmentStatus(String id, String newStatus) async {
    final index = shipments.indexWhere((s) => s.id == id);
    if (index == -1) return;
    shipments[index].status = newStatus;
    await FirebaseService.updateShipmentStatus(id, newStatus);
    await _storage.saveShipments(shipments);
    await _notifications.notifyShipmentUpdate(
        shipments[index].platform, newStatus);
    notifyListeners();
  }

  // ── Rides ───────────────────────────────────────────────────────────────────

  Future<bool> bookRide({
    required String rideType,
    required String pickupLocation,
    required String destination,
    required double fare,
    required double distanceKm,
  }) async {
    final success = await deductBalance(fare);
    if (!success) return false;

    final newRide = RideBooking(
      id: _uuid.v4(),
      rideType: rideType,
      pickupLocation: pickupLocation,
      destination: destination,
      status: 'Confirmed',
      fare: fare,
      distanceKm: distanceKm,
      bookedAt: DateTime.now(),
    );
    rides.insert(0, newRide);
    await FirebaseService.saveRide(newRide);
    await _storage.saveRides(rides);
    await _notifications.notifyRideBooked(rideType, destination);
    notifyListeners();
    return true;
  }
}

// ── InheritedWidget wrapper ──────────────────────────────────────────────────

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in widget tree');
    return provider!.notifier!;
  }
}
