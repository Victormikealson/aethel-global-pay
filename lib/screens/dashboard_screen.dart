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

  double get totalUSD {
    return 847293847293847 +
        392847293000000 * 1.08 +
        98473928473920000 / 155 +
        45928374920384000 / 7.2;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildNetWorthCard(),
          const SizedBox(height: 28),
          _buildAccountsGrid(),
          const SizedBox(height: 28),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Moses Byarugaba', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Platinum Private Account · Last login: Today 09:42 AM', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
            ],
          ),
        ),
        Row(children: [
          OutlinedButton.icon(
            icon: Icon(_hideBalances ? Icons.visibility : Icons.visibility_off, size: 16),
            label: Text(_hideBalances ? 'Show' : 'Hide', style: const TextStyle(fontSize: 13)),
            onPressed: () => setState(() => _hideBalances = !_hideBalances),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textGray,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(gradient: navyGradient, borderRadius: BorderRadius.circular(12)),
            child: TextButton.icon(
              icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
              label: const Text('Refresh', style: TextStyle(color: Colors.white, fontSize: 13)),
              onPressed: () {},
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildNetWorthCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0a1628), Color(0xFF1a3a6b), Color(0xFF0d2d5e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.gold.withOpacity(0.15), Colors.transparent]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.public, color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                Text('Total Portfolio Net Worth', style: TextStyle(color: Colors.blue[200], fontSize: 13)),
              ]),
              const SizedBox(height: 10),
              Text(
                _hideBalances ? '••••••••' : 'USD ${(totalUSD / 1e12).toStringAsFixed(3)} Trillion',
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.trending_up, color: Color(0xFF4ade80), size: 16),
                const SizedBox(width: 6),
                const Text('+3.47% this month', style: TextStyle(color: Color(0xFF4ade80), fontSize: 13)),
                const SizedBox(width: 16),
                Text('Across 8 currencies · 114 banks', style: TextStyle(color: Colors.blue[300], fontSize: 12)),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                for (final s in ['SWIFT', 'RTGS', 'SEPA']) ...[
                  Column(children: [
                    Text(s, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
                    const Text('Active', style: TextStyle(color: Color(0xFF4ade80), fontSize: 11)),
                  ]),
                  const SizedBox(width: 28),
                ],
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Balances', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 560 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.8,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(acc.flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(acc.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.5)),
                  Text(acc.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark), overflow: TextOverflow.ellipsis),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFf0fdf4), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.trending_up, size: 11, color: AppColors.green),
                  const SizedBox(width: 3),
                  Text(acc.change, style: const TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600)),
                ]),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _hideBalances ? '••••••••' : formatBalance(acc.balance, acc.currency),
            style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          if (!_hideBalances)
            Text(formatBalanceFull(acc.balance, acc.currency), style: const TextStyle(fontSize: 10, color: AppColors.textGray), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Account Active', style: TextStyle(fontSize: 11, color: AppColors.textGray)),
              const Spacer(),
              GestureDetector(
                child: Row(children: [
                  Text('View', style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_outward, size: 11, color: AppColors.gold),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: const Row(children: [
                  Expanded(flex: 3, child: Text('FROM / TO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                  Expanded(flex: 2, child: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                  Expanded(flex: 1, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                  Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                ]),
              ),
              ...recentTransactions.map((tx) => _txRow(tx)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _txRow(TransactionData tx) {
    final isCompleted = tx.status == 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFf9fafb)))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tx.from, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
              Row(children: [
                const Text('→ ', style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                Text(tx.to, style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
              ]),
            ],
          )),
          Expanded(flex: 2, child: Text(
            _hideBalances ? '••••' : tx.amount,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy),
          )),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.blueBg, borderRadius: BorderRadius.circular(20)),
            child: Text(tx.type, style: const TextStyle(fontSize: 11, color: AppColors.blueText), overflow: TextOverflow.ellipsis),
          )),
          Expanded(flex: 2, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.greenBg : AppColors.yellowBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(tx.status, style: TextStyle(fontSize: 11, color: isCompleted ? AppColors.green : AppColors.yellowText, fontWeight: FontWeight.w600)),
          )),
        ],
      ),
    );
  }
}
