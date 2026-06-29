import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/app_data.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  PaymentMethodData? _selectedMethod;
  bool _sent = false;

  void _showTransferModal(PaymentMethodData method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TransferModal(
        method: method,
        onSent: () {
          Navigator.of(context).pop();
          setState(() => _sent = true);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _sent = false);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Systems', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Access all global payment rails and transfer methods', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
          const SizedBox(height: 20),

          if (_sent) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                border: Border.all(color: const Color(0xFFbbf7d0)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle, color: AppColors.green, size: 20),
                SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Transfer Initiated Successfully', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Your payment has been queued for processing', style: TextStyle(color: AppColors.green, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
          ],

          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 560 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.55,
              ),
              itemCount: paymentMethods.length,
              itemBuilder: (_, i) => _paymentCard(paymentMethods[i]),
            );
          }),
        ],
      ),
    );
  }

  Widget _paymentCard(PaymentMethodData method) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(method.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(method.desc, style: const TextStyle(fontSize: 11, color: AppColors.textGray), overflow: TextOverflow.ellipsis),
              ],
            )),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4ade80), shape: BoxShape.circle)),
          ]),
          const Spacer(),
          Row(children: [
            const Icon(Icons.bolt, size: 13, color: Color(0xFFf59e0b)),
            const SizedBox(width: 4),
            Text(method.speed, style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
            const Spacer(),
            const Text('Limit: ', style: TextStyle(fontSize: 11, color: AppColors.textGray)),
            Text(method.limit, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: navyGradient, borderRadius: BorderRadius.circular(10)),
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                label: const Text('Initiate Transfer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: () => _showTransferModal(method),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferModal extends StatefulWidget {
  final PaymentMethodData method;
  final VoidCallback onSent;
  const _TransferModal({required this.method, required this.onSent});

  @override
  State<_TransferModal> createState() => _TransferModalState();
}

class _TransferModalState extends State<_TransferModal> {
  String _currency = 'USD';
  final _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AED', 'SGD', 'CHF', 'HKD', 'KWD'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Text(widget.method.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.method.name, style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.method.desc, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
              ]),
            ]),
            const SizedBox(height: 24),
            _field('Recipient Bank / Account', 'Bank name or IBAN / account number'),
            const SizedBox(height: 16),
            _field('Amount', 'Enter amount'),
            const SizedBox(height: 16),
            _label('CURRENCY'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currency,
                  isExpanded: true,
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _currency = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _field('Reference / Purpose', 'Transfer reference'),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textGray,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              )),
              const SizedBox(width: 12),
              Expanded(child: DecoratedBox(
                decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(12)),
                child: TextButton(
                  onPressed: widget.onSent,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Confirm Transfer', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              )),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 1));

  Widget _field(String label, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9ca3af), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.navy, width: 2)),
        ),
      ),
    ]);
  }
}
