class AccountData {
  final String name;
  final String number;
  final String currency;
  final double balance;
  final String type;
  final String flag;
  final String iban;
  final String opened;
  final String change;

  const AccountData({
    required this.name,
    required this.number,
    required this.currency,
    required this.balance,
    required this.type,
    required this.flag,
    required this.iban,
    required this.opened,
    required this.change,
  });
}

class TransactionData {
  final String from;
  final String to;
  final String amount;
  final String type;
  final String status;
  final String date;
  final String ref;

  const TransactionData({
    required this.from,
    required this.to,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    this.ref = '',
  });
}

class BankData {
  final String name;
  final String country;
  final String region;
  final String flag;
  final String type;
  final String swift;

  const BankData({
    required this.name,
    required this.country,
    required this.region,
    required this.flag,
    required this.type,
    required this.swift,
  });
}

class PaymentMethodData {
  final String name;
  final String desc;
  final String speed;
  final String limit;
  final String icon;

  const PaymentMethodData({
    required this.name,
    required this.desc,
    required this.speed,
    required this.limit,
    required this.icon,
  });
}

const List<AccountData> accounts = [
  AccountData(name: 'Primary Reserve Account', number: 'PMB-001-2847293', currency: 'USD', balance: 847293847293847, type: 'Reserve', flag: '🇺🇸', iban: 'US84 7293 8472 9384 7293 84', opened: 'Jan 12, 2008', change: '+2.4%'),
  AccountData(name: 'European Holdings', number: 'PMB-EUR-3928472', currency: 'EUR', balance: 392847293000000, type: 'Investment', flag: '🇪🇺', iban: 'EU39 2847 2930 0000 0000 00', opened: 'Mar 05, 2010', change: '+1.8%'),
  AccountData(name: 'Asia-Pacific Trust Fund', number: 'PMB-JPY-9847392', currency: 'JPY', balance: 98473928473920000, type: 'Trust', flag: '🇯🇵', iban: 'JP98 4739 2847 3920 0000 00', opened: 'Jun 18, 2009', change: '+3.2%'),
  AccountData(name: 'China Sovereign Account', number: 'PMB-CNY-4592837', currency: 'CNY', balance: 45928374920384000, type: 'Sovereign', flag: '🇨🇳', iban: 'CN45 9283 7492 0384 0000 00', opened: 'Nov 22, 2011', change: '+4.1%'),
  AccountData(name: 'UAE Royal Reserve', number: 'PMB-AED-1284729', currency: 'AED', balance: 12847293847293000, type: 'Reserve', flag: '🇦🇪', iban: 'AE12 8472 9384 7293 0000 00', opened: 'Feb 14, 2013', change: '+2.9%'),
  AccountData(name: 'Singapore Digital Asset', number: 'PMB-SGD-8293847', currency: 'SGD', balance: 8293847293847000, type: 'Digital', flag: '🇸🇬', iban: 'SG82 9384 7293 8470 0000 00', opened: 'Sep 08, 2015', change: '+5.3%'),
  AccountData(name: 'UK Treasury Bond', number: 'PMB-GBP-2938472', currency: 'GBP', balance: 293847293847293, type: 'Bond', flag: '🇬🇧', iban: 'GB29 3847 2938 4729 3847 29', opened: 'Apr 30, 2007', change: '+1.1%'),
  AccountData(name: 'Swiss Vault Reserve', number: 'PMB-CHF-1847392', currency: 'CHF', balance: 184739283740000, type: 'Vault', flag: '🇨🇭', iban: 'CH18 4739 2837 4000 0000 0', opened: 'Jul 11, 2006', change: '+0.8%'),
];

const List<TransactionData> recentTransactions = [
  TransactionData(ref: 'TXN-2847293', from: 'Bank of China', to: 'PMB Reserve', amount: r'$4,293,847,293,000', type: 'SWIFT', status: 'Completed', date: 'May 21, 2026'),
  TransactionData(ref: 'TXN-2847291', from: 'PMB Reserve', to: 'UAE Central Bank', amount: 'AED 2,847B', type: 'Wire', status: 'Completed', date: 'May 20, 2026'),
  TransactionData(ref: 'TXN-2847289', from: 'Deutsche Bank AG', to: 'PMB Europe', amount: '€893,847B', type: 'SEPA', status: 'Completed', date: 'May 20, 2026'),
  TransactionData(ref: 'TXN-2847285', from: 'PMB Asia Fund', to: 'Sumitomo Bank', amount: '¥28,473T', type: 'SWIFT', status: 'Processing', date: 'May 19, 2026'),
  TransactionData(ref: 'TXN-2847280', from: 'JPMorgan Chase', to: 'PMB Reserve', amount: r'$1,847B', type: 'RTGS', status: 'Completed', date: 'May 19, 2026'),
  TransactionData(ref: 'TXN-2847275', from: 'PMB China (CNY)', to: 'ICBC Beijing', amount: '¥5,928T', type: 'CIPS', status: 'Completed', date: 'May 18, 2026'),
  TransactionData(ref: 'TXN-2847270', from: 'PMB UK (GBP)', to: 'Barclays Bank', amount: '£293,847B', type: 'CHAPS', status: 'Completed', date: 'May 18, 2026'),
];

const List<PaymentMethodData> paymentMethods = [
  PaymentMethodData(name: 'SWIFT Transfer', desc: 'International wire transfers via SWIFT network', speed: '1-3 days', limit: 'Unlimited', icon: '🌐'),
  PaymentMethodData(name: 'RTGS', desc: 'Real-Time Gross Settlement for high-value payments', speed: 'Instant', limit: 'Unlimited', icon: '⚡'),
  PaymentMethodData(name: 'SEPA Transfer', desc: 'Euro area bank transfers via SEPA network', speed: 'Same day', limit: '€999T', icon: '🇪🇺'),
  PaymentMethodData(name: 'ACH Transfer', desc: 'US Automated Clearing House domestic transfers', speed: '1-2 days', limit: r'$500B/day', icon: '🇺🇸'),
  PaymentMethodData(name: 'Fedwire', desc: 'Federal Reserve Wire Network transfers', speed: 'Instant', limit: 'Unlimited', icon: '🏛️'),
  PaymentMethodData(name: 'CHAPS', desc: 'UK same-day sterling high-value payments', speed: 'Same day', limit: '£999T', icon: '🇬🇧'),
  PaymentMethodData(name: 'CHIPS', desc: 'Clearing House Interbank Payments System', speed: 'Same day', limit: 'Unlimited', icon: '🏦'),
  PaymentMethodData(name: 'TARGET2', desc: 'Trans-European Automated Real-time Gross Settlement', speed: 'Instant', limit: 'Unlimited', icon: '🔄'),
  PaymentMethodData(name: 'Blockchain Transfer', desc: 'Distributed ledger asset transfers', speed: 'Minutes', limit: 'Unlimited', icon: '⛓️'),
  PaymentMethodData(name: 'CIPS', desc: 'China Cross-Border Interbank Payment System', speed: 'Same day', limit: '¥999Q', icon: '🇨🇳'),
  PaymentMethodData(name: 'Letter of Credit', desc: 'Documentary credit for trade finance', speed: '3-7 days', limit: 'Unlimited', icon: '📜'),
  PaymentMethodData(name: 'Nostro/Vostro', desc: 'Correspondent banking account transfers', speed: '1-2 days', limit: 'Unlimited', icon: '🔗'),
  PaymentMethodData(name: 'Currency Swap', desc: 'Cross-currency exchange agreements', speed: 'T+2', limit: 'Unlimited', icon: '💱'),
  PaymentMethodData(name: 'Gold Transfer', desc: 'Physical and digital gold asset transfers', speed: 'T+2', limit: 'Unlimited', icon: '🥇'),
  PaymentMethodData(name: 'Bank Guarantee', desc: 'Institutional guarantee instruments', speed: '1-5 days', limit: 'Unlimited', icon: '🛡️'),
  PaymentMethodData(name: 'Documentary Collection', desc: 'Bank-mediated trade document exchange', speed: '5-10 days', limit: 'Unlimited', icon: '📁'),
];

const List<BankData> banks = [
  BankData(name: 'JPMorgan Chase', country: 'United States', region: 'Americas', flag: '🇺🇸', type: 'Commercial', swift: 'CHASUS33'),
  BankData(name: 'Bank of America', country: 'United States', region: 'Americas', flag: '🇺🇸', type: 'Commercial', swift: 'BOFAUS3N'),
  BankData(name: 'Citibank N.A.', country: 'United States', region: 'Americas', flag: '🇺🇸', type: 'Commercial', swift: 'CITIUS33'),
  BankData(name: 'Wells Fargo', country: 'United States', region: 'Americas', flag: '🇺🇸', type: 'Commercial', swift: 'WFBIUS6S'),
  BankData(name: 'Goldman Sachs', country: 'United States', region: 'Americas', flag: '🇺🇸', type: 'Investment', swift: 'GOLDUSGIT'),
  BankData(name: 'Morgan Stanley', country: 'United States', region: 'Americas', flag: '🇺🇸', type: 'Investment', swift: 'MSBCUS33'),
  BankData(name: 'Federal Reserve Bank', country: 'United States', region: 'Americas', flag: '🇺🇸', type: 'Central', swift: 'FRNYUS33'),
  BankData(name: 'Royal Bank of Canada', country: 'Canada', region: 'Americas', flag: '🇨🇦', type: 'Commercial', swift: 'ROYCCAT2'),
  BankData(name: 'Banco do Brasil', country: 'Brazil', region: 'Americas', flag: '🇧🇷', type: 'State-Owned', swift: 'BRASBRRJBHE'),
  BankData(name: 'Itaú Unibanco', country: 'Brazil', region: 'Americas', flag: '🇧🇷', type: 'Commercial', swift: 'ITAUBRSP'),
  BankData(name: 'Deutsche Bank AG', country: 'Germany', region: 'Europe', flag: '🇩🇪', type: 'Commercial', swift: 'DEUTDEDB'),
  BankData(name: 'BNP Paribas', country: 'France', region: 'Europe', flag: '🇫🇷', type: 'Commercial', swift: 'BNPAFRPP'),
  BankData(name: 'HSBC Holdings', country: 'United Kingdom', region: 'Europe', flag: '🇬🇧', type: 'Commercial', swift: 'MIDLGB22'),
  BankData(name: 'Barclays Bank', country: 'United Kingdom', region: 'Europe', flag: '🇬🇧', type: 'Commercial', swift: 'BARCGB22'),
  BankData(name: 'UBS Group AG', country: 'Switzerland', region: 'Europe', flag: '🇨🇭', type: 'Investment', swift: 'UBSWCHZH80A'),
  BankData(name: 'Société Générale', country: 'France', region: 'Europe', flag: '🇫🇷', type: 'Commercial', swift: 'SOGEFRPP'),
  BankData(name: 'ING Bank', country: 'Netherlands', region: 'Europe', flag: '🇳🇱', type: 'Commercial', swift: 'INGBNL2A'),
  BankData(name: 'UniCredit', country: 'Italy', region: 'Europe', flag: '🇮🇹', type: 'Commercial', swift: 'UNCRITMM'),
  BankData(name: 'Santander', country: 'Spain', region: 'Europe', flag: '🇪🇸', type: 'Commercial', swift: 'BSCHESMMXXX'),
  BankData(name: 'European Central Bank', country: 'EU', region: 'Europe', flag: '🇪🇺', type: 'Central', swift: 'ECBFDEFFXXX'),
  BankData(name: 'ICBC', country: 'China', region: 'Asia', flag: '🇨🇳', type: 'State-Owned', swift: 'ICBKCNBJ'),
  BankData(name: 'China Construction Bank', country: 'China', region: 'Asia', flag: '🇨🇳', type: 'State-Owned', swift: 'PCBCCNBJ'),
  BankData(name: 'Agricultural Bank of China', country: 'China', region: 'Asia', flag: '🇨🇳', type: 'State-Owned', swift: 'ABOCCNBJ'),
  BankData(name: 'Bank of China', country: 'China', region: 'Asia', flag: '🇨🇳', type: 'State-Owned', swift: 'BKCHCNBJ'),
  BankData(name: 'Mitsubishi UFJ Financial', country: 'Japan', region: 'Asia', flag: '🇯🇵', type: 'Commercial', swift: 'BOTKJPJT'),
  BankData(name: 'Sumitomo Mitsui Banking', country: 'Japan', region: 'Asia', flag: '🇯🇵', type: 'Commercial', swift: 'SMBCJPJT'),
  BankData(name: 'Bank of Japan', country: 'Japan', region: 'Asia', flag: '🇯🇵', type: 'Central', swift: 'BOJPJPJT'),
  BankData(name: 'DBS Bank', country: 'Singapore', region: 'Asia', flag: '🇸🇬', type: 'Commercial', swift: 'DBSSSGSG'),
  BankData(name: 'HDFC Bank', country: 'India', region: 'Asia', flag: '🇮🇳', type: 'Commercial', swift: 'HDFCINBB'),
  BankData(name: 'State Bank of India', country: 'India', region: 'Asia', flag: '🇮🇳', type: 'State-Owned', swift: 'SBININBB'),
  BankData(name: 'Reserve Bank of India', country: 'India', region: 'Asia', flag: '🇮🇳', type: 'Central', swift: 'RBISINBB'),
  BankData(name: 'First Abu Dhabi Bank', country: 'UAE', region: 'Middle East', flag: '🇦🇪', type: 'Commercial', swift: 'NBADAEAA'),
  BankData(name: 'Emirates NBD', country: 'UAE', region: 'Middle East', flag: '🇦🇪', type: 'Commercial', swift: 'EBILAEAD'),
  BankData(name: 'UAE Central Bank', country: 'UAE', region: 'Middle East', flag: '🇦🇪', type: 'Central', swift: 'CBUAAEAD'),
  BankData(name: 'Qatar National Bank', country: 'Qatar', region: 'Middle East', flag: '🇶🇦', type: 'Commercial', swift: 'QNBAQAQA'),
  BankData(name: 'Saudi National Bank', country: 'Saudi Arabia', region: 'Middle East', flag: '🇸🇦', type: 'Commercial', swift: 'NCBKSAJE'),
  BankData(name: 'Al Rajhi Bank', country: 'Saudi Arabia', region: 'Middle East', flag: '🇸🇦', type: 'Islamic', swift: 'RJHISAJE'),
  BankData(name: 'Kuwait Finance House', country: 'Kuwait', region: 'Middle East', flag: '🇰🇼', type: 'Islamic', swift: 'KFHOKWKW'),
  BankData(name: 'Standard Bank Group', country: 'South Africa', region: 'Africa', flag: '🇿🇦', type: 'Commercial', swift: 'SBZAZAJJ'),
  BankData(name: 'Stanbic Bank Uganda', country: 'Uganda', region: 'Africa', flag: '🇺🇬', type: 'Commercial', swift: 'SBICUGKA'),
  BankData(name: 'Centenary Bank Uganda', country: 'Uganda', region: 'Africa', flag: '🇺🇬', type: 'Commercial', swift: 'CENBUGKA'),
  BankData(name: 'Bank of Uganda', country: 'Uganda', region: 'Africa', flag: '🇺🇬', type: 'Central', swift: 'BOUGUGKA'),
  BankData(name: 'Ecobank Group', country: 'Pan-Africa', region: 'Africa', flag: '🌍', type: 'Commercial', swift: 'ECOCGHAC'),
  BankData(name: 'Access Bank', country: 'Nigeria', region: 'Africa', flag: '🇳🇬', type: 'Commercial', swift: 'ABNGNGLA'),
  BankData(name: 'Zenith Bank', country: 'Nigeria', region: 'Africa', flag: '🇳🇬', type: 'Commercial', swift: 'ZEIBNGLA'),
  BankData(name: 'Commonwealth Bank Australia', country: 'Australia', region: 'Pacific', flag: '🇦🇺', type: 'Commercial', swift: 'CTBAAU2S'),
  BankData(name: 'ANZ Banking Group', country: 'Australia', region: 'Pacific', flag: '🇦🇺', type: 'Commercial', swift: 'ANZBAU3M'),
];

String formatBalance(double n, String currency) {
  if (n >= 1e15) return '$currency ${(n / 1e15).toStringAsFixed(2)}Q';
  if (n >= 1e12) return '$currency ${(n / 1e12).toStringAsFixed(2)}T';
  if (n >= 1e9) return '$currency ${(n / 1e9).toStringAsFixed(2)}B';
  return '$currency ${n.toStringAsFixed(0)}';
}

String formatBalanceFull(double n, String currency) {
  if (n >= 1e15) return '$currency ${(n / 1e15).toStringAsFixed(3)} Quadrillion';
  if (n >= 1e12) return '$currency ${(n / 1e12).toStringAsFixed(3)} Trillion';
  if (n >= 1e9) return '$currency ${(n / 1e9).toStringAsFixed(3)} Billion';
  return '$currency ${n.toStringAsFixed(0)}';
}
