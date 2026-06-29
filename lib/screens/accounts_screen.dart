import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/app_data.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _hideBalances = false;
  String? _expandedNumber;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Accounts', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Moses Byarugaba — Platinum Private Account Holder', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                ],
              )),
              IconButton(
                icon: Icon(_hideBalances ? Icons.visibility : Icons.visibility_off, color: AppColors.textGray),
                onPressed: () => setState(() => _hideBalances = !_hideBalances),
              ),
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12)),
                child: TextButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: AppColors.navy),
                  label: const Text('New Account', style: TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w600)),
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...accounts.map((acc) => _buildAccountTile(acc)),
        ],
      ),
    );
  }

  Widget _buildAccountTile(AccountData acc) {
    final expanded = _expandedNumber == acc.number;
    return GestureDetector(
      onTap: () => setState(() => _expandedNumber = expanded ? null : acc.number),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Text(acc.flag, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(acc.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const SizedBox(height: 3),
                      Text(acc.number, style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      _hideBalances ? '••••••••' : formatBalance(acc.balance, acc.currency),
                      style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.trending_up, size: 12, color: AppColors.green),
                      const SizedBox(width: 4),
                      const Text('Active', style: TextStyle(fontSize: 12, color: AppColors.green)),
                      const SizedBox(width: 8),
                      Text(acc.type, style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
                    ]),
                  ]),
                ],
              ),
            ),
            if (expanded) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 24,
                      runSpacing: 14,
                      children: [
                        _detail('IBAN/Account', acc.iban),
                        _detail('Currency', acc.currency),
                        _detail('Account Type', acc.type),
                        _detail('Opened', acc.opened),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      DecoratedBox(
                        decoration: BoxDecoration(gradient: navyGradient, borderRadius: BorderRadius.circular(10)),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
                          child: const Text('Transfer Funds', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.download, size: 15),
                        label: const Text('Statement', style: TextStyle(fontSize: 13)),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textGray,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return SizedBox(
      width: 160,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      ]),
    );
  }
}
