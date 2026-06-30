import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shipment_model.dart';
import '../models/ride_model.dart';

/// Handles all Firebase Auth and Firestore operations.
/// Every method has try/catch so the app never crashes if Firebase fails.
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth ────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'walletBalance': 125000.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {'status': 'success', 'uid': uid, 'name': name, 'email': email};
    } on FirebaseAuthException catch (e) {
      return {'status': 'error', 'message': _authError(e.code)};
    } catch (e) {
      return {'status': 'error', 'message': 'Registration failed. Check connection.'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      return {
        'status': 'success',
        'uid': uid,
        'name': data['name'] ?? '',
        'email': email,
        'walletBalance': (data['walletBalance'] as num?)?.toDouble() ?? 125000.0,
      };
    } on FirebaseAuthException catch (e) {
      return {'status': 'error', 'message': _authError(e.code)};
    } catch (e) {
      return {'status': 'error', 'message': 'Login failed. Check connection.'};
    }
  }

  static Future<void> logout() async {
    try { await _auth.signOut(); } catch (_) {}
  }

  static String? get currentUid => _auth.currentUser?.uid;

  // ── Wallet ──────────────────────────────────────────────────────────────────

  static Future<double> getWalletBalance() async {
    try {
      final uid = currentUid;
      if (uid == null) return 125000.0;
      final doc = await _db.collection('users').doc(uid).get();
      return (doc.data()?['walletBalance'] as num?)?.toDouble() ?? 125000.0;
    } catch (_) {
      return 125000.0;
    }
  }

  static Future<void> updateWalletBalance(double newBalance) async {
    try {
      final uid = currentUid;
      if (uid == null) return;
      await _db.collection('users').doc(uid).update({'walletBalance': newBalance});
    } catch (_) {}
  }

  // ── Rides ───────────────────────────────────────────────────────────────────

  static Future<List<RideBooking>> getRides() async {
    try {
      final uid = currentUid;
      if (uid == null) return [];
      final snapshot = await _db
          .collection('users').doc(uid).collection('rides')
          .orderBy('bookedAt', descending: true)
          .get();
      return snapshot.docs.map((d) => RideBooking.fromMap(d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRide(RideBooking ride) async {
    try {
      final uid = currentUid;
      if (uid == null) return;
      await _db.collection('users').doc(uid)
          .collection('rides').doc(ride.id).set(ride.toMap());
    } catch (_) {}
  }

  // ── Shipments ───────────────────────────────────────────────────────────────

  static Future<List<Shipment>> getShipments() async {
    try {
      final uid = currentUid;
      if (uid == null) return [];
      final snapshot = await _db
          .collection('users').doc(uid).collection('shipments')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((d) => Shipment.fromMap(d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveShipment(Shipment shipment) async {
    try {
      final uid = currentUid;
      if (uid == null) return;
      await _db.collection('users').doc(uid)
          .collection('shipments').doc(shipment.id).set(shipment.toMap());
    } catch (_) {}
  }

  static Future<void> updateShipmentStatus(String id, String status) async {
    try {
      final uid = currentUid;
      if (uid == null) return;
      await _db.collection('users').doc(uid)
          .collection('shipments').doc(id).update({'status': status});
    } catch (_) {}
  }

  // ── Error messages ──────────────────────────────────────────────────────────

  static String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':   return 'Email already registered.';
      case 'invalid-email':          return 'Invalid email address.';
      case 'weak-password':          return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':     return 'Invalid email or password.';
      case 'too-many-requests':      return 'Too many attempts. Try again later.';
      default:                       return 'Authentication failed. Try again.';
    }
  }
}
