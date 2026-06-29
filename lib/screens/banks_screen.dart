import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/app_data.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({super.key});

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  String _search = '';
  String _region = 'All';

  static const _regions = ['All', 'Americas', 'Europe', 'Asia', 'Middle East', 'Africa', 'Pacific'];

  List<BankData> get _filtered => banks.where((b) =>
    (_region == 'All' || b.region == _region) &&
    (b.name.toLowerCase().contains(_search.toLowerCase()) || b.country.toLowerCase().contains(_search.toLowerCase()))
  ).toList();

  Color _typeColor(String type) {
    switch (type) {
      case 'Central': return AppColors.purpleText;
      case 'Investment': return AppColors.blueText;
      case 'Islamic': return AppColors.green;
      default: return AppColors.textGray;
    }
  }

  Color _typeBg(String type) {
    switch (type) {
      case 'Central': return AppColors.purpleBg;
      case 'Investment': return AppColors.blueBg;
      case 'Islamic': return AppColors.greenBg;
      default: return const Color(0xFFf3f4f6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Global Banking Network', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Connected to ${banks.length}+ correspondent banks across 6 regions worldwide', style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
          const SizedBox(height: 20),

          // Stats grid
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 600 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _statCard('🌐', '${banks.length}+', 'Partner Banks'),
                _statCard('🌍', '6', 'Regions'),
                _statCard('💱', '47', 'Currencies'),
                _statCard('⚡', '99.98%', 'Network Uptime'),
              ],
            );
          }),

          const SizedBox(height: 20),

          // Search
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search banks or countries...',
              hintStyle: const TextStyle(color: Color(0xFF9ca3af), fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9ca3af), size: 18),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.navy, width: 2)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Region filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _regions.map((r) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _region = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _region == r ? navyGradient : null,
                      color: _region == r ? null : Colors.white,
                      border: Border.all(color: _region == r ? Colors.transparent : AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(r, style: TextStyle(
                      color: _region == r ? Colors.white : AppColors.textGray,
                      fontSize: 13, fontWeight: FontWeight.w600,
                    )),
                  ),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Banks table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf9fafb),
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Row(children: [
                    Expanded(flex: 4, child: Text('BANK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                    Expanded(flex: 3, child: Text('COUNTRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                    Expanded(flex: 2, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                    Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 0.8))),
                  ]),
                ),
                ...filtered.map((bank) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFf9fafb)))),
                  child: Row(children: [
                    Expanded(flex: 4, child: Row(children: [
                      Text(bank.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(bank.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark), overflow: TextOverflow.ellipsis)),
                    ])),
                    Expanded(flex: 3, child: Text(bank.country, style: const TextStyle(fontSize: 13, color: AppColors.textGray), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 2, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _typeBg(bank.type), borderRadius: BorderRadius.circular(20)),
                      child: Text(bank.type, style: TextStyle(fontSize: 11, color: _typeColor(bank.type), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    )),
                    const Expanded(flex: 2, child: Row(children: [
                      Icon(Icons.check_circle, size: 14, color: AppColors.green),
                      SizedBox(width: 4),
                      Text('Active', style: TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
                    ])),
                  ]),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGray), textAlign: TextAlign.center),
      ]),
    );
  }
}
