import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/shipment_model.dart';
import 'tracking_payment_screen.dart';

/// Shipments Screen — StatefulWidget
///
/// State variables:
///   [_isAdding]       → shows spinner while a new shipment is being saved
///   [_filterStatus]   → filters the shipment list by status
///
/// setState() is called in:
///   _addShipment()    → sets [_isAdding] true/false around the async save
///   _setFilter()      → updates [_filterStatus] so the list rebuilds filtered
class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  // ─── State variables ───────────────────────────────────────────────────────
  bool _isAdding = false;
  String _filterStatus = 'All'; // 'All', 'Processing', 'In Transit', 'Delivered'

  final List<String> _filters = ['All', 'Processing', 'In Transit', 'Delivered'];

  /// Update the active filter.
  /// setState() updates [_filterStatus] so the list rebuilds with filtered data.
  void _setFilter(String status) {
    setState(() {
      _filterStatus = status;
    });
  }

  /// Add a new shipment via AppState.
  /// setState() sets [_isAdding] true → shows spinner, then false → hides it.
  Future<void> _addShipment({
    required String platform,
    required String trackingNumber,
    required String description,
    required double estimatedCost,
  }) async {
    setState(() => _isAdding = true);

    await AppStateProvider.of(context).addShipment(
      platform: platform,
      trackingNumber: trackingNumber,
      description: description,
      estimatedCost: estimatedCost,
    );

    setState(() => _isAdding = false);

    if (!mounted) return;
    Navigator.of(context).pop(); // close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$platform shipment added!'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNewShipmentDialog() {
    final platformController = ValueNotifier<String>('Shein');
    final descController = TextEditingController();
    final costController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Platform prefix map for auto-generated tracking numbers
    const prefixes = {
      'Shein': 'SH',
      'Amazon': 'AM',
      'Alibaba': 'AL',
      'Temu': 'TM',
      'AliExpress': 'AE',
    };

    // Generate a tracking number: prefix + 4 random digits
    String generateTracking(String platform) {
      final prefix = prefixes[platform] ?? 'HG';
      final number = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
      return '#$prefix-$number';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Shipment'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Platform dropdown
                  ValueListenableBuilder<String>(
                    valueListenable: platformController,
                    builder: (_, selectedPlatform, __) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Platform',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Shein', 'Amazon', 'Alibaba', 'Temu', 'AliExpress']
                            .map((p) =>
                                DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => platformController.value = v!,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter description'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Cost (UGX)',
                      border: OutlineInputBorder(),
                      prefixText: 'UGX ',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter cost';
                      if (double.tryParse(v) == null) return 'Enter a number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isAdding
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        // Auto-generate tracking number from platform
                        final tracking = generateTracking(platformController.value);
                        _addShipment(
                          platform: platformController.value,
                          trackingNumber: tracking,
                          description: descController.text.trim(),
                          estimatedCost:
                              double.parse(costController.text.trim()),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: _isAdding
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Request Pickup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read shipments from AppState — rebuilds when notifyListeners() fires
    final appState = AppStateProvider.of(context);

    // Apply filter — setState() on _setFilter() causes this to re-evaluate
    final filtered = _filterStatus == 'All'
        ? appState.shipments
        : appState.shipments
            .where((s) => s.status == _filterStatus)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop & Ship'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips — tapping calls _setFilter() → setState()
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: _filterStatus == f,
                          onSelected: (_) => _setFilter(f),
                          selectedColor: Colors.green[200],
                          checkmarkColor: Colors.green[800],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // New shipment button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showNewShipmentDialog,
                icon: const Icon(Icons.add),
                label: const Text('New Shipment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Shipment list — rebuilds when appState.shipments changes
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No shipments found.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final shipment = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShipmentCard(
                          shipment: shipment,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrackingPaymentScreen(
                                    shipment: shipment),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Shipment Card ───────────────────────────────────────────────────────────

class ShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;

  const ShipmentCard({
    super.key,
    required this.shipment,
    required this.onTap,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in transit':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: const Icon(Icons.local_shipping,
            color: Colors.green, size: 36),
        title: Text(shipment.platform,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shipment.trackingNumber,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(shipment.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                shipment.status,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
