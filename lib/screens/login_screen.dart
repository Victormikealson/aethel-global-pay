import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPass = false;
  bool _loading = false;
  String _error = '';

  Future<void> _handleLogin() async {
    setState(() { _loading = true; _error = ''; });
    await Future.delayed(const Duration(milliseconds: 1200));
    final prefs = await SharedPreferences.getInstance();
    final storedPw = prefs.getString('pmb_password') ?? 'A@arugaba74';
    if (_usernameCtrl.text == 'Moses' && _passwordCtrl.text == storedPw) {
      widget.onLogin();
    } else {
      setState(() { _error = 'Invalid credentials. Please try again.'; _loading = false; });
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navy, AppColors.navyLight, AppColors.navy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Left Panel - decorative, only on wide screens
            if (wide)
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric circles
                    ...List.generate(6, (i) => Container(
                      width: (i + 1) * 120.0,
                      height: (i + 1) * 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold.withOpacity(0.15), width: 1),
                      ),
                    )),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            gradient: goldGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.shield, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Private Monetary\nBanking System',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Secure. Global. Trusted by institutions\nacross 114 banking networks worldwide.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue[200], fontSize: 16, height: 1.6),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _stat('114+', 'Global Banks'),
                            const SizedBox(width: 32),
                            _stat(r'$847T', 'Assets Managed'),
                            const SizedBox(width: 32),
                            _stat('196', 'Countries'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Right Panel - login form
            Container(
              width: wide ? 480 : double.infinity,
              padding: const EdgeInsets.all(40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 20))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!wide) ...[
                          Row(children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(gradient: goldGradient, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.shield, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text('PMB System', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 24),
                        ],
                        Text('Secure Access', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Enter your credentials to access the private banking portal', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                        const SizedBox(height: 32),

                        _label('USERNAME'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameCtrl,
                          decoration: _inputDec('Enter username', const Icon(Icons.person_outline, color: Color(0xFF9ca3af), size: 18)),
                        ),
                        const SizedBox(height: 20),

                        _label('PASSWORD'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: !_showPass,
                          decoration: _inputDec('Enter password', const Icon(Icons.lock_outline, color: Color(0xFF9ca3af), size: 18)).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9ca3af), size: 18),
                              onPressed: () => setState(() => _showPass = !_showPass),
                            ),
                          ),
                          onSubmitted: (_) => _handleLogin(),
                        ),

                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFfef2f2),
                              border: Border.all(color: const Color(0xFFfecaca)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_error, style: const TextStyle(color: Color(0xFFdc2626), fontSize: 13)),
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: navyGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TextButton(
                              onPressed: _loading ? null : _handleLogin,
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('ACCESS ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF9ca3af)),
                            const SizedBox(width: 6),
                            const Text('256-bit SSL Encrypted · ISO 27001 Certified', style: TextStyle(color: Color(0xFF9ca3af), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.blue[300], fontSize: 12)),
    ]);
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4b5563), letterSpacing: 1.2));
  }

  InputDecoration _inputDec(String hint, Widget prefix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9ca3af), fontSize: 14),
      prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: prefix),
      prefixIconConstraints: const BoxConstraints(minWidth: 44),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFe5e7eb))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFe5e7eb))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.navy, width: 2)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
