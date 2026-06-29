import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/banks_screen.dart';
import '../screens/transfers_screen.dart';
import '../screens/settings_screen.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget screen;
  const NavItem(this.label, this.icon, this.screen);
}

class BankLayout extends StatefulWidget {
  final VoidCallback onLogout;
  const BankLayout({super.key, required this.onLogout});

  @override
  State<BankLayout> createState() => _BankLayoutState();
}

class _BankLayoutState extends State<BankLayout> {
  int _selectedIndex = 0;
  final bool _drawerOpen = false;

  late final List<NavItem> _navItems = [
    const NavItem('Dashboard', Icons.dashboard_outlined, DashboardScreen()),
    const NavItem('Accounts', Icons.credit_card_outlined, AccountsScreen()),
    const NavItem('Payments', Icons.swap_horiz, PaymentsScreen()),
    const NavItem('Global Banks', Icons.account_balance_outlined, BanksScreen()),
    const NavItem('Transfers', Icons.public, TransfersScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Row(
        children: [
          // Persistent sidebar on wide screens
          if (wide) _buildSidebar(context),

          // Main content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, wide),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      ..._navItems.map((n) => n.screen),
                      const SettingsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Drawer for narrow screens
      drawer: wide ? null : Drawer(
        width: 260,
        child: _buildSidebarContent(context),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool wide) {
    final pageLabel = _selectedIndex < _navItems.length
        ? _navItems[_selectedIndex].label
        : 'Settings';

    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (!wide)
            Builder(builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textGray),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            )),
          if (!wide) const SizedBox(width: 8),
          if (wide) ...[
            const Text('Private Monetary Banking System', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
            const SizedBox(width: 8),
            const Text('/', style: TextStyle(color: AppColors.textGray)),
            const SizedBox(width: 8),
            Text(pageLabel, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
          const Spacer(),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textGray), onPressed: () {}),
              Positioned(
                top: 8, right: 8,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(gradient: goldGradient, shape: BoxShape.circle),
            child: const Center(child: Text('MB', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return SizedBox(width: 256, child: _buildSidebarContent(context));
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: sidebarGradient),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.shield, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PMB System', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Private Banking', style: TextStyle(color: Colors.blue[300], fontSize: 11)),
              ]),
            ]),
          ),

          // User info
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(gradient: goldGradient, shape: BoxShape.circle),
                child: const Center(child: Text('MB', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Moses Byarugaba', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text('Platinum Account', style: TextStyle(color: Colors.blue[300], fontSize: 11)),
              ])),
            ]),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                ..._navItems.asMap().entries.map((e) => _navTile(context, e.key, e.value, e.key == _selectedIndex)),
              ],
            ),
          ),

          // Bottom items
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: Column(children: [
              _bottomTile(context, Icons.settings_outlined, 'Settings', () {
                setState(() => _selectedIndex = 5);
                if (MediaQuery.of(context).size.width < 1024) Navigator.of(context).pop();
              }, _selectedIndex == 5),
              const SizedBox(height: 4),
              _bottomTile(context, Icons.logout, 'Sign Out', widget.onLogout, false, isLogout: true),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _navTile(BuildContext context, int index, NavItem item, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (MediaQuery.of(context).size.width < 1024) Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: active ? LinearGradient(colors: [AppColors.gold.withOpacity(0.27), AppColors.goldLight.withOpacity(0.13)]) : null,
          borderRadius: BorderRadius.circular(12),
          border: active ? const Border(left: BorderSide(color: AppColors.gold, width: 3)) : null,
        ),
        child: Row(children: [
          Icon(item.icon, size: 16, color: active ? Colors.white : Colors.blue[300]),
          const SizedBox(width: 12),
          Text(item.label, style: TextStyle(color: active ? Colors.white : Colors.blue[300], fontSize: 14, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }

  Widget _bottomTile(BuildContext context, IconData icon, String label, VoidCallback onTap, bool active, {bool isLogout = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: isLogout ? Colors.red[300] : Colors.blue[300]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isLogout ? Colors.red[300] : Colors.blue[300], fontSize: 14)),
        ]),
      ),
    );
  }
}
