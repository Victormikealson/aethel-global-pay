import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_state.dart';
import '../services/firebase_service.dart';
import 'ride_booking_screen.dart';
import 'shipments_screen.dart';
import 'tracking_payment_screen.dart';
import 'wallet_activity_screen.dart';
import 'auth_screen.dart';

/// Dashboard — the app's home screen.
///
/// Converted to StatefulWidget to support:
///   [_userName]   → loaded from SharedPreferences, triggers setState() on load
///   [_isLoading]  → shows spinner while AppState loads persisted data
///
/// setState() is called in:
///   _loadUserName()  → updates [_userName] after reading SharedPreferences
///   initState()      → triggers AppState.loadData() which calls notifyListeners()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ─── State variables ───────────────────────────────────────────────────────
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // Load persisted data into AppState; notifyListeners() will rebuild
    // any widgets that depend on AppState (wallet balance, shipments, etc.)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppStateProvider.of(context).loadData();
    });
  }

  /// Load the logged-in user's name from SharedPreferences.
  /// setState() updates [_userName] so the welcome text rebuilds.
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    setState(() {
      _userName = name;
    });
  }

  /// Log out: clear session and navigate back to AuthScreen.
  Future<void> _logout() async {
    await FirebaseService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppState is read here; any notifyListeners() call will rebuild this widget
    final appState = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hermus Global Hauls'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          // Dark / light mode toggle
          // setState: calls appState.toggleTheme() → notifyListeners()
          // → _AppRoot rebuilds → themeMode switches instantly
          IconButton(
            icon: Icon(
              appState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: appState.isDarkMode ? 'Light mode' : 'Dark mode',
            onPressed: () => appState.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section — rebuilds when _userName changes via setState()
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Welcome, $_userName!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Wallet balance summary card
                  // Rebuilds when appState.walletBalance changes (notifyListeners)
                  Card(
                    color: Colors.green[50],
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet,
                              color: Colors.green[700], size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Wallet Balance',
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                'UGX ${appState.walletBalance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Services section
                  const Text(
                    'Services',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ServiceCard(
                          title: 'Get a Ride',
                          icon: Icons.directions_car,
                          color: Colors.green[600]!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const RideBookingScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ServiceCard(
                          title: 'Shop & Ship',
                          icon: Icons.shopping_cart,
                          color: Colors.green[600]!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ShipmentsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ServiceCard(
                      title: 'My Wallet',
                      icon: Icons.wallet,
                      color: Colors.green[600]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const WalletActivityScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active shipments — rebuilds when appState.shipments changes
                  const Text(
                    'My Active Shipments',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Show only non-delivered shipments on dashboard
                  ...appState.shipments
                      .where((s) => s.status != 'Delivered')
                      .take(3)
                      .map(
                        (shipment) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ShipmentItem(
                            platform: shipment.platform,
                            status: shipment.status,
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
                        ),
                      ),

                  // Fallback when all shipments are delivered
                  if (appState.shipments
                      .where((s) => s.status != 'Delivered')
                      .isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'No active shipments',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

// ─── Reusable widgets ────────────────────────────────────────────────────────

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 42, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShipmentItem extends StatelessWidget {
  final String platform;
  final String status;
  final VoidCallback onTap;

  const ShipmentItem({
    super.key,
    required this.platform,
    required this.status,
    required this.onTap,
  });

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
        title: Text(platform,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(status),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
