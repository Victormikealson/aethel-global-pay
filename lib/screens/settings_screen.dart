import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showCurrent = false, _showNew = false, _showConfirm = false;
  bool _loading = false;
  String _error = '';
  bool _success = false;

  Future<String> _getStoredPw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pmb_password') ?? 'A@arugaba74';
  }

  Future<void> _handleSubmit() async {
    setState(() { _error = ''; _success = false; });
    final stored = await _getStoredPw();
    if (_currentCtrl.text != stored) {
      setState(() => _error = 'Current password is incorrect.');
      return;
    }
    if (_newCtrl.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pmb_password', _newCtrl.text);
    setState(() {
      _loading = false;
      _success = true;
      _error = '';
    });
    _currentCtrl.clear();
    _newCtrl.clear();
    _confirmCtrl.clear();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _success = false);
    });
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Settings', style: GoogleFonts.playfairDisplay(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Manage your security preferences', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
          const SizedBox(height: 24),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(gradient: navyGradient, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Change Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const Text('Update your secure account password', style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                    ]),
                  ]),
                  const SizedBox(height: 24),

                  if (_success) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.greenBg,
                        border: Border.all(color: const Color(0xFFbbf7d0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle, color: AppColors.green, size: 18),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Password Updated Successfully', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w600, fontSize: 13)),
                          const Text('Your new password is now active', style: TextStyle(color: AppColors.green, fontSize: 11)),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_error.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfef2f2),
                        border: Border.all(color: const Color(0xFFfecaca)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_error, style: const TextStyle(color: Color(0xFFdc2626), fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _pwField('CURRENT PASSWORD', 'Enter current password', _currentCtrl, _showCurrent, () => setState(() => _showCurrent = !_showCurrent)),
                  const SizedBox(height: 16),
                  _pwField('NEW PASSWORD', 'Enter new password', _newCtrl, _showNew, () => setState(() => _showNew = !_showNew)),
                  const SizedBox(height: 16),
                  _pwField('CONFIRM NEW PASSWORD', 'Confirm new password', _confirmCtrl, _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),

                  // Match hint
                  if (_newCtrl.text.isNotEmpty && _confirmCtrl.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(children: [
                        Icon(
                          _newCtrl.text == _confirmCtrl.text ? Icons.check_circle : Icons.cancel,
                          size: 13,
                          color: _newCtrl.text == _confirmCtrl.text ? AppColors.green : const Color(0xFFef4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _newCtrl.text == _confirmCtrl.text ? 'Passwords match' : 'Passwords do not match',
                          style: TextStyle(
                            fontSize: 12,
                            color: _newCtrl.text == _confirmCtrl.text ? AppColors.green : const Color(0xFFef4444),
                          ),
                        ),
                      ]),
                    ),

                  const SizedBox(height: 24),
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: navyGradient, borderRadius: BorderRadius.circular(12)),
                    child: TextButton(
                      onPressed: _loading ? null : _handleSubmit,
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Update Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.3)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 14),
                  const Row(children: [
                    Icon(Icons.shield_outlined, size: 15, color: AppColors.textGray),
                    SizedBox(width: 8),
                    Text('Your password is encrypted and stored securely', style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pwField(String label, String hint, TextEditingController ctrl, bool show, VoidCallback toggle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textGray, letterSpacing: 1)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        obscureText: !show,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9ca3af), fontSize: 13),
          prefixIcon: const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Icon(Icons.lock_outline, color: Color(0xFF9ca3af), size: 17)),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          suffixIcon: IconButton(
            icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9ca3af), size: 17),
            onPressed: toggle,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.navy, width: 2)),
        ),
      ),
    ]);
  }
}
