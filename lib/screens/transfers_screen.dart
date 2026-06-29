import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/app_data.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  int _step = 1;
  bool _done = false;

  String _fromAccount = 'Primary Reserve Account — USD 847.29 Trillion';
  String _transferType = 'SWIFT Transfer';
  String _currency = 'USD';

  static const _fromAccounts = [
    'Primary Reserve Account — USD 847.29 Trillion',
    'European Holdings — EUR 392.85 Trillion',
    'Asia-Pacific Trust Fund — JPY 98,473.93 Trillion',
    'China Sovereign Account — CNY 45,928.37 Trillion',
    'UAE Royal Reserve — AED 12,847.29 Trillion',
  ];
  static const _transferTypes = ['SWIFT Transfer', 'RTGS', 'SEPA', 'ACH', 'CHIPS', 'Fedwire', 'CHAPS', 'CIPS', 'Blockchain', 'Currency Swap'];
  static const _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AED', 'SGD', 'CHF'];

  void _handleNext() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      setState(() => _done = true);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() { _done = false; _step = 1; });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('International Transfers', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Send funds across the global PMB network', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
          const SizedBox(height: 24),

          wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: _formCard()),
                  const SizedBox(width: 20),
                  SizedBox(width: 300, child: _historyCard()),
                ])
              : Column(children: [
                  _formCard(),
                  const SizedBox(height: 20),
                  _historyCard(),
                ]),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: _done ? _successView() : _formView(),
    );
  }

  Widget _successView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(color: AppColors.greenBg, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppColors.green, size: 32),
        ),
        const SizedBox(height: 16),
        Text('Transfer Initiated', style: GoogleFonts.playfairDisplay(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Your transfer has been submitted for processing', style: TextStyle(color: AppColors.textGray, fontSize: 14), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepIndicator(),
        const SizedBox(height: 24),
        if (_step == 1) _step1(),
        if (_step == 2) _step2(),
        if (_step == 3) _step3(),
        const SizedBox(height: 24),
        Row(children: [
          if (_step > 1) ...[
            OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textGray,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(child: DecoratedBox(
            decoration: BoxDecoration(gradient: navyGradient, borderRadius: BorderRadius.circular(12)),
            child: TextButton.icon(
              onPressed: _handleNext,
              icon: Icon(_step == 3 ? Icons.send : Icons.arrow_forward, size: 16, color: Colors.white),
              label: Text(_step == 3 ? 'Confirm & Send' : 'Continue', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          )),
        ]),
      ],
    );
  }

  Widget _stepIndicator() {
    final labels = ['Source Account', 'Destination', 'Confirm'];
    return Row(
      children: List.generate(3, (i) {
        final stepNum = i + 1;
        final done = _step > stepNum;
        final active = _step == stepNum;
        return Expanded(child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              gradient: active ? navyGradient : null,
              color: done ? AppColors.green : (active ? null : const Color(0xFFf3f4f6)),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(
              done ? '✓' : '$stepNum',
              style: TextStyle(color: (active || done) ? Colors.white : AppColors.textGray, fontSize: 12, fontWeight: FontWeight.bold),
            )),
          ),
          const SizedBox(width: 6),
          Text(labels[i], style: TextStyle(fontSize: 12, color: active ? AppColors.textDark : AppColors.textGray, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
          if (i < 2) Expanded(child: Container(height: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 6))),
        ]));
      }),
    );
  }

  Widget _step1() => Column(children: [
    _dropdownField('FROM ACCOUNT', _fromAccounts, _fromAccount, (v) => setState(() => _fromAccount = v!)),
    const SizedBox(height: 16),
    _dropdownField('TRANSFER TYPE', _transferTypes, _transferType, (v) => setState(() => _transferType = v!)),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: _inputField('AMOUNT', '0.00')),
      const SizedBox(width: 14),
      Expanded(child: _dropdownField('CURRENCY', _currencies, _currency, (v) => setState(() => _currency = v!))),
    ]),
  ]);

  Widget _step2() => Column(children: [
    _inputField('RECIPIENT BANK', 'Bank name'),
    const SizedBox(height: 16),
    _inputField('SWIFT / BIC CODE', 'e.g. CHASUS33'),
    const SizedBox(height: 16),
    _inputField('ACCOUNT / IBAN NUMBER', 'Recipient account number'),
    const SizedBox(height: 16),
    _inputField('BENEFICIARY NAME', 'Full legal name'),
  ]);

  Widget _step3() {
    final rows = [
      ['Transfer Type', _transferType],
      ['From', _fromAccount.split('—').first.trim()],
      ['Currency', _currency],
      ['Processing Time', '1-3 Business Days'],
      ['Fee', 'Waived — Platinum Account'],
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFf9fafb), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transfer Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
          const SizedBox(height: 14),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r[0], style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
                Flexible(child: Text(r[1], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _historyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.public, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
            Text('Recent Transfers', style: GoogleFonts.playfairDisplay(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          ...recentTransactions.map((tx) {
            final isCompleted = tx.status == 'Completed';
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tx.ref, style: const TextStyle(fontSize: 11, color: AppColors.textGray, fontFamily: 'monospace')),
                    Text(tx.to, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                    Text('${tx.date} · ${tx.type}', style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
                  ])),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(tx.amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.greenBg : AppColors.yellowBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tx.status, style: TextStyle(fontSize: 11, color: isCompleted ? AppColors.green : AppColors.yellowText, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 1)),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9ca3af), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.navy, width: 2)),
        ),
      ),
    ]);
  }

  Widget _dropdownField(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 1)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }
}
