import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service handling both:
///   1. LOCAL notifications  — triggered in-app (ride booked, payment done, etc.)
///   2. PUSH notifications   — received from FCM when app is in background/killed
///
/// FCM push is wired up separately via [PushNotificationService].
/// This class owns the local notification channel and display logic.
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Notification channel definition ────────────────────────────────────────
  // This channel ID must match the one declared in AndroidManifest.xml
  static const String _channelId = 'hermus_channel';
  static const String _channelName = 'Hermus Notifications';
  static const String _channelDesc = 'Ride bookings, shipment updates & wallet alerts';

  // ── Initialise ──────────────────────────────────────────────────────────────

  /// Call once in main() before runApp().
  /// Sets up the local notification plugin for Android and iOS.
  Future<void> init() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      await _createAndroidChannel();
    } catch (e) {
      debugPrint('Notification init failed: $e');
      // App continues without notifications — not a crash
    }
  }

  Future<void> _createAndroidChannel() async {
    try {
      const channel = AndroidNotificationChannel(
        _channelId, _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      debugPrint('Channel creation failed: $e');
    }
  }

  /// Called when the user taps a notification while the app is open.
  void _onNotificationTap(NotificationResponse response) {
    // Navigation logic can be added here if needed
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ── Request runtime permission (Android 13+) ────────────────────────────────

  /// Call this after the user logs in to request POST_NOTIFICATIONS permission.
  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Core show method ────────────────────────────────────────────────────────

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId, _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF2E7D32),
        playSound: true,
        enableVibration: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(
          android: androidDetails, iOS: iosDetails);
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Show notification failed: $e');
    }
  }

  // ── App-specific notification helpers ──────────────────────────────────────

  /// LOCAL: Notify user that their ride has been confirmed.
  Future<void> notifyRideBooked(String rideType, String destination) async {
    await showNotification(
      id: 1,
      title: 'Ride Confirmed 🚗',
      body: '$rideType booked to $destination. Driver is on the way!',
      payload: 'ride',
    );
  }

  /// LOCAL: Notify user of a shipment status change.
  Future<void> notifyShipmentUpdate(String platform, String newStatus) async {
    await showNotification(
      id: 2,
      title: 'Shipment Update 📦',
      body: 'Your $platform order is now: $newStatus',
      payload: 'shipment',
    );
  }

  /// LOCAL: Notify user that money was added to wallet.
  Future<void> notifyWalletTopUp(double amount) async {
    await showNotification(
      id: 3,
      title: 'Wallet Topped Up 💰',
      body: 'UGX ${amount.toStringAsFixed(0)} has been added to your wallet.',
      payload: 'wallet',
    );
  }

  /// LOCAL: Notify user that a payment was successful.
  Future<void> notifyPaymentSuccess(double amount) async {
    await showNotification(
      id: 4,
      title: 'Payment Successful ✅',
      body: 'UGX ${amount.toStringAsFixed(0)} paid successfully.',
      payload: 'payment',
    );
  }
}
