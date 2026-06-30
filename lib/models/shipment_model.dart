import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a shipment order
class Shipment {
  final String id;
  final String platform;
  final String trackingNumber;
  final String description;
  final double estimatedCost;
  String status;
  final DateTime createdAt;

  Shipment({
    required this.id,
    required this.platform,
    required this.trackingNumber,
    required this.description,
    required this.estimatedCost,
    required this.status,
    required this.createdAt,
  });

  /// Convert to a Map for Firestore / SharedPreferences storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform': platform,
      'trackingNumber': trackingNumber,
      'description': description,
      'estimatedCost': estimatedCost,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a Shipment from a stored Map.
  /// Handles both Firestore Timestamp and ISO string for createdAt.
  factory Shipment.fromMap(Map<String, dynamic> map) {
    // Parse createdAt safely — Firestore returns Timestamp, local cache returns String
    DateTime createdAt;
    final raw = map['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String) {
      createdAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Shipment(
      id: (map['id'] ?? '').toString(),
      platform: (map['platform'] ?? '').toString(),
      trackingNumber: (map['trackingNumber'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      estimatedCost: (map['estimatedCost'] as num? ?? 0).toDouble(),
      status: (map['status'] ?? 'Processing').toString(),
      createdAt: createdAt,
    );
  }
}
