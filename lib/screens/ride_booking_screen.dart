import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/ride_model.dart';
import '../services/distance_service.dart';
import '../widgets/location_search_field.dart';

/// Ride Booking Screen — StatefulWidget
///
/// State variables:
///   [_selectedRideType]  → highlights the chosen ride card
///   [_isBooking]         → spinner while booking is being processed
///
/// setState() is called in:
///   _selectRide()   → updates [_selectedRideType]
///   _bookRide()     → sets [_isBooking] true/false
class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  String? _selectedRideType;
  bool _isBooking = false;

  final Map<String, IconData> _icons = {
    'Boda-Boda': Icons.motorcycle,
    'Car': Icons.directions_car,
    'Taxi': Icons.local_taxi,
    'Bus': Icons.directions_bus,
  };

  void _selectRide(String rideType) {
    setState(() => _selectedRideType = rideType);
    _showBookingDialog(rideType);
  }

  Future<void> _bookRide({
    required String rideType,
    required String pickup,
    required String destination,
    required double fare,
    required double distanceKm,
  }) async {
    setState(() => _isBooking = true);

    final success = await AppStateProvider.of(context).bookRide(
      rideType: rideType,
      pickupLocation: pickup,
      destination: destination,
      fare: fare,
      distanceKm: distanceKm,
    );

    setState(() => _isBooking = false);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '$rideType booked! ${distanceKm.toStringAsFixed(1)} km — '
                'UGX ${fare.toStringAsFixed(0)} deducted.'
            : 'Insufficient wallet balance. Please top up.'),
        backgroundColor: success ? Colors.green[600] : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBookingDialog(String rideType) {
    showDialog(
      context: context,
      builder: (_) => _BookingDialog(
        rideType: rideType,
        icon: _icons[rideType]!,
        isBooking: _isBooking,
        onBook: ({
          required String pickup,
          required String destination,
          required double fare,
          required double distanceKm,
        }) {
          _bookRide(
            rideType: rideType,
            pickup: pickup,
            destination: destination,
            fare: fare,
            distanceKm: distanceKm,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get a Ride'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Ride Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._icons.keys.map(
              (type) => _RideOptionCard(
                title: type,
                icon: _icons[type]!,
                isSelected: _selectedRideType == type,
                color: Colors.green[600]!,
                onTap: () => _selectRide(type),
              ),
            ),
            const SizedBox(height: 24),
            if (appState.rides.isNotEmpty) ...[
              const Text('Recent Rides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...appState.rides.take(5).map((r) => _RideHistoryCard(ride: r)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Booking dialog ────────────────────────────────────────────────────────────
//
// State variables:
//   [_isCalculating]    → spinner while distance API runs
//   [_isGettingLocation]→ spinner while GPS fetches
//   [_result]           → DistanceResult shown in fare card
//   [_errorMsg]         → error text
//   [_gpsPosition]      → raw GPS fix for pickup
//   [_pickupSuggestion] → coordinates from a picked pickup suggestion
//   [_destSuggestion]   → coordinates from a picked destination suggestion
//
// setState() called in:
//   _useCurrentLocation() → sets [_gpsPosition], [_isGettingLocation]
//   _calculateFare()      → sets [_isCalculating], [_result], [_errorMsg]

class _BookingDialog extends StatefulWidget {
  final String rideType;
  final IconData icon;
  final bool isBooking;
  final void Function({
    required String pickup,
    required String destination,
    required double fare,
    required double distanceKm,
  }) onBook;

  const _BookingDialog({
    required this.rideType,
    required this.icon,
    required this.isBooking,
    required this.onBook,
  });

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  bool _isCalculating = false;
  bool _isGettingLocation = false;
  DistanceResult? _result;
  String _errorMsg = '';

  GpsPosition? _gpsPosition;
  PlaceSuggestion? _pickupSuggestion;
  PlaceSuggestion? _destSuggestion;

  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _useCurrentLocation();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _errorMsg = '';
    });
    final pos = await DistanceService().getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _isGettingLocation = false;
      _pickupSuggestion = null;
      if (pos != null) {
        _gpsPosition = pos;
        _pickupController.text = pos.label;
      } else {
        _errorMsg = 'Could not get GPS location. Enter pickup manually.';
      }
    });
  }

  Future<void> _calculateFare() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = null;
      _errorMsg = '';
    });

    try {
      DistanceResult result;
      if (_gpsPosition != null) {
        result = await DistanceService().getDistanceAndFareFromCoords(
          originLat: _gpsPosition!.lat,
          originLon: _gpsPosition!.lon,
          originLabel: _gpsPosition!.label,
          destination: _destController.text.trim(),
          rideType: widget.rideType,
        );
      } else if (_pickupSuggestion != null && _destSuggestion != null) {
        result = await DistanceService().getDistanceAndFareFromCoordsToCoords(
          originLat: _pickupSuggestion!.lat,
          originLon: _pickupSuggestion!.lon,
          destinationLat: _destSuggestion!.lat,
          destinationLon: _destSuggestion!.lon,
          rideType: widget.rideType,
        );
      } else {
        result = await DistanceService().getDistanceAndFare(
          origin: _pickupController.text.trim(),
          destination: _destController.text.trim(),
          rideType: widget.rideType,
        );
      }

      setState(() {
        _result = result;
        _isCalculating = false;
      });
    } catch (_) {
      setState(() {
        _isCalculating = false;
        _errorMsg = 'Could not calculate distance. Check location names.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [
        Icon(widget.icon, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text('Book ${widget.rideType}'),
      ]),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pickup field ──────────────────────────────────────────────
              LocationSearchField(
                controller: _pickupController,
                label: 'Pickup Location',
                prefixIcon:
                    _gpsPosition != null ? Icons.gps_fixed : Icons.my_location,
                hintText: _isGettingLocation
                    ? 'Getting your location...'
                    : 'Type or use GPS',
                suffixIcon: IconButton(
                  icon: _isGettingLocation
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.gps_fixed, color: Colors.green),
                  tooltip: 'Use current GPS location',
                  onPressed: _isGettingLocation ? null : _useCurrentLocation,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter pickup location'
                    : null,
                onChanged: (text) {
                  setState(() {
                    _gpsPosition = null;
                    _pickupSuggestion = null;
                    _result = null;
                  });
                },
                onSelected: (suggestion) {
                  setState(() {
                    _gpsPosition = null;
                    _pickupSuggestion = suggestion;
                    _pickupController.text = suggestion.shortName;
                    _result = null;
                  });
                },
              ),
              if (_gpsPosition != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Row(children: [
                    Icon(Icons.location_on, size: 12, color: Colors.green[700]),
                    const SizedBox(width: 4),
                    Text('Using your current GPS location',
                        style:
                            TextStyle(fontSize: 11, color: Colors.green[700])),
                  ]),
                ),
              const SizedBox(height: 10),

              // ── Destination field ─────────────────────────────────────────
              LocationSearchField(
                controller: _destController,
                label: 'Destination',
                prefixIcon: Icons.location_on,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter destination'
                    : null,
                onChanged: (text) {
                  setState(() {
                    _destSuggestion = null;
                    _result = null;
                  });
                },
                onSelected: (suggestion) {
                  setState(() {
                    _destSuggestion = suggestion;
                    _destController.text = suggestion.shortName;
                    _result = null;
                  });
                },
              ),
              const SizedBox(height: 12),

              // ── Calculate fare button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isCalculating ? null : _calculateFare,
                  icon: _isCalculating
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.calculate_outlined),
                  label: Text(
                      _isCalculating ? 'Calculating...' : 'Calculate Fare'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[700]!),
                  ),
                ),
              ),

              if (_errorMsg.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_errorMsg,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              // ── Fare result card ──────────────────────────────────────────
              if (_result != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.straighten,
                            size: 16, color: Colors.green[700]),
                        const SizedBox(width: 6),
                        Text('Distance: ${_result!.distanceText}',
                            style: const TextStyle(fontSize: 13)),
                      ]),
                      if (_result!.durationText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.green[700]),
                          const SizedBox(width: 6),
                          Text('Est. time: ${_result!.durationText}',
                              style: const TextStyle(fontSize: 13)),
                        ]),
                      ],
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Fare:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            'UGX ${_result!.fareUGX.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800]),
                          ),
                        ],
                      ),
                      if (!_result!.isApiResult)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('* Estimated — actual fare may vary',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600])),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_result == null || widget.isBooking)
              ? null
              : () {
                  widget.onBook(
                    pickup: _pickupController.text.trim(),
                    destination: _destController.text.trim(),
                    fare: _result!.fareUGX,
                    distanceKm: _result!.distanceKm,
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
          child: widget.isBooking
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Book Now'),
        ),
      ],
    );
  }
}

// ── Ride option card ──────────────────────────────────────────────────────────

class _RideOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RideOptionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 5 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: Colors.green[700]!, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(icon, size: 40, color: color),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        subtitle: const Text('Tap to calculate fare & book'),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// ── Ride history card ─────────────────────────────────────────────────────────

class _RideHistoryCard extends StatelessWidget {
  final RideBooking ride;
  const _RideHistoryCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.directions_car, color: Colors.green),
        title: Text('${ride.rideType} → ${ride.destination}'),
        subtitle: Text(
            'From: ${ride.pickupLocation} • ${ride.distanceKm.toStringAsFixed(1)} km'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('UGX ${ride.fare.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 4),
            Text(ride.status,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
