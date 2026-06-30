import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a ride booking
class RideBooking {
  final String id;
  final String rideType;
  final String pickupLocation;
  final String destination;
  String status;
  final double fare;
  final double distanceKm;
  final DateTime bookedAt;

  RideBooking({
    required this.id,
    required this.rideType,
    required this.pickupLocation,
    required this.destination,
    required this.status,
    required this.fare,
    this.distanceKm = 0,
    required this.bookedAt,
  });

  /// Convert to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rideType': rideType,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'status': status,
      'fare': fare,
      'distanceKm': distanceKm,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  /// Create a RideBooking from a stored Map.
  /// Handles both Firestore Timestamp and ISO string for bookedAt.
  factory RideBooking.fromMap(Map<String, dynamic> map) {
    // Parse bookedAt safely
    DateTime bookedAt;
    final raw = map['bookedAt'];
    if (raw is Timestamp) {
      bookedAt = raw.toDate();
    } else if (raw is String) {
      bookedAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      bookedAt = DateTime.now();
    }

    return RideBooking(
      id: (map['id'] ?? '').toString(),
      rideType: (map['rideType'] ?? '').toString(),
      pickupLocation: (map['pickupLocation'] ?? '').toString(),
      destination: (map['destination'] ?? '').toString(),
      status: (map['status'] ?? 'Confirmed').toString(),
      fare: (map['fare'] as num? ?? 0).toDouble(),
      distanceKm: (map['distanceKm'] as num? ?? 0).toDouble(),
      bookedAt: bookedAt,
    );
  }
}
