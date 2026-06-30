import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/app_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hideBalances = false;

  double get totalUSD =>
      847293847293847 +
      392847293000000 * 1.08 +
      98473928473920000 / 155 +
      45928374920384000 / 7.2;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const SizedBox(height: 20),
          _buildNetWorthCard(isMobile),
          const SizedBox(height: 24),
          _buildAccountsGrid(),
          const SizedBox(height: 24),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Moses Byarugaba',
                  style: GoogleFonts.playfairDisplay(
                      color: AppColors.navy, fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Platinum Private Account', style: TextStyle(color: AppColors.textGray, fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        IconButton(
          icon: Icon(_hideBalances ? Icons.visibility : Icons.visibility_off, color: AppColors.textGray),
          onPressed: () => setState(() => _hideBalances = !_hideBalances),
        ),
      ],
    );
  }

  Widget _buildNetWorthCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0a1628), Color(0xFF1a3a6b), Color(0xFF0d2d5e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.public, color: AppColors.gold, size: 15),
            const SizedBox(width: 8),
            Text('Total Portfolio Net Worth', style: TextStyle(color: Colors.blue[200], fontSize: 12)),
          ]),
          const SizedBox(height: 10),
          Text(
            _hideBalances ? '••••••••' : 'USD ${(totalUSD / 1e12).toStringAsFixed(3)} Trillion',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: isMobile ? 20 : 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 4, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.trending_up, color: Color(0xFF4ade80), size: 14),
              const SizedBox(width: 4),
              const Text('+3.47% this month', style: TextStyle(color: Color(0xFF4ade80), fontSize: 12)),
            ]),
            Text('8 currencies · 114 banks', style: TextStyle(color: Colors.blue[300], fontSize: 11)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            for (final s in ['SWIFT', 'RTGS', 'SEPA']) ...[
              Column(children: [
                Text(s, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 12)),
                const Text('Active', style: TextStyle(color: Color(0xFF4ade80), fontSize: 10)),
              ]),
              const SizedBox(width: 20),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _buildAccountsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Balances',
            style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 560 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.85,
            ),
            itemCount: accounts.length,
            itemBuilder: (_, i) => _accountCard(accounts[i]),
          );
        }),
      ],
    );
  }

  Widget _accountCard(AccountData acc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(acc.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(acc.type.toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.5)),
              Text(acc.name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFf0fdf4), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.trending_up, size: 10, color: AppColors.green),
                const SizedBox(width: 2),
                Text(acc.change, style: const TextStyle(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          const Spacer(),
          Text(
            _hideBalances ? '••••••••' : formatBalance(acc.balance, acc.currency),
            style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (!_hideBalances)
            Text(formatBalanceFull(acc.balance, acc.currency),
                style: const TextStyle(fontSize: 9, color: AppColors.textGray), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Active', style: TextStyle(fontSize: 10, color: AppColors.textGray)),
            const Spacer(),
            Text('View', style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions',
            style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 420),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  child: const Row(children: [
                    SizedBox(width: 130, child: Text('FROM / TO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGray))),
                    SizedBox(width: 110, child: Text('AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGray))),
                    SizedBox(width: 65, child: Text('TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGray))),
                    SizedBox(width: 85, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGray))),
                  ]),
                ),
                ...recentTransactions.map((tx) => _txRow(tx)),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _txRow(TransactionData tx) {
    final done = tx.status == 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFf9fafb)))),
      child: Row(children: [
        SizedBox(width: 130, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.from, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textDark), overflow: TextOverflow.ellipsis),
          Text('→ ${tx.to}', style: const TextStyle(fontSize: 10, color: AppColors.textGray), overflow: TextOverflow.ellipsis),
        ])),
        SizedBox(width: 110, child: Text(_hideBalances ? '••••' : tx.amount,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navy), overflow: TextOverflow.ellipsis)),
        SizedBox(width: 65, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: AppColors.blueBg, borderRadius: BorderRadius.circular(20)),
          child: Text(tx.type, style: const TextStyle(fontSize: 9, color: AppColors.blueText), overflow: TextOverflow.ellipsis),
        )),
        SizedBox(width: 85, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: done ? AppColors.greenBg : AppColors.yellowBg, borderRadius: BorderRadius.circular(20)),
          child: Text(tx.status, style: TextStyle(fontSize: 9, color: done ? AppColors.green : AppColors.yellowText, fontWeight: FontWeight.w600)),
        )),
      ]),
    );
  }
}
