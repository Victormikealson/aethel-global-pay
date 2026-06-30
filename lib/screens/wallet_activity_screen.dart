import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_state.dart';

/// Wallet & Activity Screen — StatefulWidget
///
/// State variables:
///   [_isTopping]        → spinner while top-up processes
///   [_selectedMethod]   → chosen payment method in Add Money dialog
///   [_linkedAccounts]   → list of saved payment accounts
///
/// setState() is called in:
///   _topUp()              → sets [_isTopping] true/false
///   _loadLinkedAccounts() → sets [_linkedAccounts] from SharedPreferences
///   _saveLinkedAccounts() → persists and rebuilds [_linkedAccounts]
class WalletActivityScreen extends StatefulWidget {
  const WalletActivityScreen({super.key});

  @override
  State<WalletActivityScreen> createState() => _WalletActivityScreenState();
}

class _WalletActivityScreenState extends State<WalletActivityScreen> {
  // ─── State variables ───────────────────────────────────────────────────────
  bool _isTopping = false;
  String _selectedMethod = '';

  /// Each account: {'type': 'Mobile Money', 'detail': '0771234567', 'icon': 'phone'}
  List<Map<String, String>> _linkedAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadLinkedAccounts();
  }

  // ─── Persistence ───────────────────────────────────────────────────────────

  /// Load saved payment accounts from SharedPreferences.
  /// setState() updates [_linkedAccounts] so the list rebuilds.
  Future<void> _loadLinkedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final types   = prefs.getStringList('account_types') ?? [];
    final details = prefs.getStringList('account_details') ?? [];
    final icons   = prefs.getStringList('account_icons') ?? [];

    final accounts = <Map<String, String>>[];
    for (var i = 0; i < types.length; i++) {
      accounts.add({
        'type':   types[i],
        'detail': i < details.length ? details[i] : '',
        'icon':   i < icons.length   ? icons[i]   : 'card',
      });
    }
    setState(() {
      _linkedAccounts = accounts;
      if (accounts.isNotEmpty) {
        _selectedMethod = accounts.first['type']!;
      }
    });
  }

  /// Save accounts to SharedPreferences and rebuild the list.
  Future<void> _saveLinkedAccounts(List<Map<String, String>> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('account_types',   accounts.map((a) => a['type']!).toList());
    await prefs.setStringList('account_details', accounts.map((a) => a['detail']!).toList());
    await prefs.setStringList('account_icons',   accounts.map((a) => a['icon']!).toList());
    setState(() {
      _linkedAccounts = accounts;
      if (accounts.isNotEmpty && !accounts.any((a) => a['type'] == _selectedMethod)) {
        _selectedMethod = accounts.first['type']!;
      }
    });
  }

  // ─── Add payment account dialog ────────────────────────────────────────────

  void _showAddAccountDialog() {
    String selectedType = 'Mobile Money (MTN)';
    final detailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final accountTypes = [
      {'label': 'Mobile Money (MTN)',   'hint': 'Phone number e.g. 0771234567', 'icon': 'phone'},
      {'label': 'Mobile Money (Airtel)','hint': 'Phone number e.g. 0751234567', 'icon': 'phone'},
      {'label': 'Visa Card',            'hint': 'Card number e.g. 4111111111111111', 'icon': 'card'},
      {'label': 'Credit Card',          'hint': 'Card number e.g. 5500005555555559', 'icon': 'card'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final selected = accountTypes.firstWhere((t) => t['label'] == selectedType);
          return AlertDialog(
            title: const Text('Add Payment Account'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Account type dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Account Type',
                      border: OutlineInputBorder(),
                    ),
                    items: accountTypes
                        .map((t) => DropdownMenuItem(
                              value: t['label'],
                              child: Text(t['label']!),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setDialogState(() {
                        selectedType = v!;
                        detailController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Phone / card number field
                  TextFormField(
                    controller: detailController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selected['label']!.contains('Money')
                          ? 'Phone Number'
                          : 'Card Number',
                      hintText: selected['hint'],
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        selected['icon'] == 'phone'
                            ? Icons.phone_android
                            : Icons.credit_card,
                        color: Colors.green[600],
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter your ${selected['label']!.contains('Money') ? 'phone number' : 'card number'}';
                      }
                      if (selected['icon'] == 'phone' && v.trim().length < 10) {
                        return 'Enter a valid phone number';
                      }
                      if (selected['icon'] == 'card' && v.trim().length < 12) {
                        return 'Enter a valid card number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final raw = detailController.text.trim();
                    // Mask the detail for display: show last 4 digits only
                    final masked = selected['icon'] == 'phone'
                        ? raw.replaceRange(0, raw.length - 4, '*' * (raw.length - 4))
                        : '**** ${raw.substring(raw.length - 4)}';

                    final updated = List<Map<String, String>>.from(_linkedAccounts)
                      ..add({
                        'type':   selectedType,
                        'detail': masked,
                        'icon':   selected['icon']!,
                      });
                    _saveLinkedAccounts(updated);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$selectedType added!'),
                        backgroundColor: Colors.green[600],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Remove account ─────────────────────────────────────────────────────────

  void _removeAccount(int index) {
    final updated = List<Map<String, String>>.from(_linkedAccounts)..removeAt(index);
    _saveLinkedAccounts(updated);
  }

  // ─── Add money dialog ───────────────────────────────────────────────────────

  void _showAddMoneyDialog() {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // If no accounts linked, prompt to add one first
    if (_linkedAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a payment account first.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _showAddAccountDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Add Money to Wallet'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Amount field
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (UGX)',
                      border: OutlineInputBorder(),
                      prefixText: 'UGX ',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter an amount';
                      final parsed = double.tryParse(v.trim());
                      if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Pay from:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  // Linked accounts as selectable tiles
                  ..._linkedAccounts.asMap().entries.map((entry) {
                    final acc = entry.value;
                    final isSelected = _selectedMethod == acc['type'];
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedMethod = acc['type']!),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green[700]!
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected
                              ? Colors.green[50]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              acc['icon'] == 'phone'
                                  ? Icons.phone_android
                                  : Icons.credit_card,
                              color: Colors.green[600],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(acc['type']!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(acc['detail']!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: Colors.green[700], size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isTopping
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          _topUp(double.parse(amountController.text.trim()));
                          Navigator.of(ctx).pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
                child: _isTopping
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Add Money'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Top-up ─────────────────────────────────────────────────────────────────

  /// Add money to the wallet via AppState.
  /// setState() sets [_isTopping] true → spinner, then false → hides it.
  Future<void> _topUp(double amount) async {
    setState(() => _isTopping = true);
    await AppStateProvider.of(context).addMoney(amount);
    setState(() => _isTopping = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('UGX ${amount.toStringAsFixed(0)} added via $_selectedMethod!'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final activities = _buildActivities(appState);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Wallet & Activity'),
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [Tab(text: 'Activity'), Tab(text: 'Wallet')],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Activity Tab ────────────────────────────────────────────────
            activities.isEmpty
                ? const Center(
                    child: Text('No activity yet.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length,
                    itemBuilder: (_, i) => activities[i],
                  ),

            // ── Wallet Tab ──────────────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance card
                  Card(
                    elevation: 4,
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text('Current Balance',
                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 10),
                          Text(
                            'UGX ${appState.walletBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showAddMoneyDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Money'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Linked accounts header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Linked Accounts',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _showAddAccountDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.green[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Linked accounts list
                  if (_linkedAccounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No payment accounts linked yet.\nTap Add to link one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ..._linkedAccounts.asMap().entries.map((entry) {
                      final i   = entry.key;
                      final acc = entry.value;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            acc['icon'] == 'phone'
                                ? Icons.phone_android
                                : Icons.credit_card,
                            color: Colors.green[600],
                          ),
                          title: Text(acc['type']!),
                          subtitle: Text(acc['detail']!),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Remove account',
                            onPressed: () => _removeAccount(i),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActivities(AppState appState) {
    final items = <_ActivityData>[];
    for (final ride in appState.rides) {
      items.add(_ActivityData(
        date: ride.bookedAt,
        label: '${ride.rideType} to ${ride.destination}',
        amount: -ride.fare,
        icon: Icons.directions_car,
      ));
    }
    for (final shipment in appState.shipments) {
      if (shipment.status == 'Delivered') {
        items.add(_ActivityData(
          date: shipment.createdAt,
          label: '${shipment.platform} shipment',
          amount: -shipment.estimatedCost,
          icon: Icons.local_shipping,
        ));
      }
    }
    items.sort((a, b) => b.date.compareTo(a.date));
    return items.map((d) => _ActivityTile(data: d)).toList();
  }
}

// ─── Helper classes ───────────────────────────────────────────────────────────

class _ActivityData {
  final DateTime date;
  final String label;
  final double amount;
  final IconData icon;
  const _ActivityData(
      {required this.date, required this.label,
       required this.amount, required this.icon});
}

class _ActivityTile extends StatelessWidget {
  final _ActivityData data;
  const _ActivityTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final isCredit = data.amount > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(data.icon, color: isCredit ? Colors.green : Colors.red),
        title: Text(data.label),
        subtitle: Text('${data.date.day}/${data.date.month}/${data.date.year}'),
        trailing: Text(
          '${isCredit ? '+' : ''}UGX ${data.amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? Colors.green : Colors.red,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
