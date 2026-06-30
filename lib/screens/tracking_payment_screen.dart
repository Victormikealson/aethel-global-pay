import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/shipment_model.dart';

/// Tracking & Payment Screen — StatefulWidget
///
/// State variables:
///   [_selectedPaymentMethod]  → which payment method is selected
///   [_isPaying]               → shows spinner while payment processes
///   [_isPaid]                 → hides Pay button after successful payment
///
/// setState() is called in:
///   _selectPaymentMethod()  → updates [_selectedPaymentMethod] so radio rebuilds
///   _pay()                  → sets [_isPaying] true/false and [_isPaid] on success
class TrackingPaymentScreen extends StatefulWidget {
  final Shipment shipment;

  const TrackingPaymentScreen({super.key, required this.shipment});

  @override
  State<TrackingPaymentScreen> createState() => _TrackingPaymentScreenState();
}

class _TrackingPaymentScreenState extends State<TrackingPaymentScreen> {
  // ─── State variables ───────────────────────────────────────────────────────
  String _selectedPaymentMethod = 'Mobile Money (MTN)';
  bool _isPaying = false;
  bool _isPaid = false;

  final List<String> _paymentMethods = [
    'Mobile Money (MTN)',
    'Mobile Money (Airtel)',
    'Visa Card',
    'Credit Card',
  ];

  /// Select a payment method.
  /// setState() updates [_selectedPaymentMethod] so the radio buttons rebuild.
  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  /// Process payment by deducting from wallet.
  /// setState() sets [_isPaying] true → spinner, then [_isPaid] on success.
  Future<void> _pay() async {
    setState(() => _isPaying = true);

    final appState = AppStateProvider.of(context);
    final success =
        await appState.deductBalance(widget.shipment.estimatedCost);

    if (success) {
      // Mark shipment as delivered after payment
      await appState.updateShipmentStatus(widget.shipment.id, 'Delivered');
      setState(() {
        _isPaying = false;
        _isPaid = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Payment of UGX ${widget.shipment.estimatedCost.toStringAsFixed(0)} successful!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() => _isPaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient wallet balance. Please top up.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─── Tracking steps based on status ───────────────────────────────────────

  List<_TrackingStep> _buildSteps() {
    final status = widget.shipment.status;
    return [
      const _TrackingStep(
        label: 'Order Placed',
        isDone: true,
        icon: Icons.check_circle,
      ),
      _TrackingStep(
        label: 'Processing',
        isDone: status == 'In Transit' || status == 'Delivered',
        icon: status == 'Processing' ? Icons.pending : Icons.check_circle,
      ),
      _TrackingStep(
        label: 'In Transit',
        isDone: status == 'Delivered',
        icon: status == 'In Transit'
            ? Icons.local_shipping
            : (status == 'Delivered'
                ? Icons.check_circle
                : Icons.schedule),
      ),
      _TrackingStep(
        label: 'Delivered',
        isDone: status == 'Delivered',
        icon: status == 'Delivered' ? Icons.check_circle : Icons.schedule,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Tracking'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Order info card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${shipment.trackingNumber}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(shipment.description,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.storefront,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        const Text('Platform: ',
                            style: TextStyle(color: Colors.grey)),
                        Text(shipment.platform,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tracking timeline
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tracking Status',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._buildSteps().map((step) => _TrackingStepRow(step: step)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment section — hidden after payment
            if (!_isPaid)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Summary',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _payRow('Shipping fee:',
                          'UGX ${(shipment.estimatedCost * 0.67).toStringAsFixed(0)}'),
                      _payRow('Import tax:',
                          'UGX ${(shipment.estimatedCost * 0.25).toStringAsFixed(0)}'),
                      _payRow('Service fee:',
                          'UGX ${(shipment.estimatedCost * 0.08).toStringAsFixed(0)}'),
                      const Divider(height: 16),
                      _payRow(
                          'TOTAL:',
                          'UGX ${shipment.estimatedCost.toStringAsFixed(0)}',
                          isTotal: true),
                      const SizedBox(height: 16),

                      // Payment method selection
                      // Rebuilds when _selectPaymentMethod() calls setState()
                      const Text('Payment Method:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ..._paymentMethods.map(
                        (method) => RadioListTile<String>(
                          value: method,
                          groupValue: _selectedPaymentMethod,
                          title: Text(method,
                              style: const TextStyle(fontSize: 14)),
                          activeColor: Colors.green[700],
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => _selectPaymentMethod(v!),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Pay button — shows spinner when [_isPaying] is true
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPaying ? null : _pay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isPaying
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'PAY UGX ${shipment.estimatedCost.toStringAsFixed(0)}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Success message after payment
            if (_isPaid)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[700], size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Payment complete! Your shipment is marked as Delivered.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _payRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                      isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 15 : 14)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 15 : 14,
                  color: isTotal ? Colors.green[800] : Colors.black87)),
        ],
      ),
    );
  }
}

// ─── Tracking step model & widget ────────────────────────────────────────────

class _TrackingStep {
  final String label;
  final bool isDone;
  final IconData icon;
  const _TrackingStep(
      {required this.label, required this.isDone, required this.icon});
}

class _TrackingStepRow extends StatelessWidget {
  final _TrackingStep step;
  const _TrackingStepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            step.icon,
            color: step.isDone ? Colors.green[600] : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            step.label,
            style: TextStyle(
              color: step.isDone ? Colors.black87 : Colors.grey,
              fontWeight:
                  step.isDone ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
