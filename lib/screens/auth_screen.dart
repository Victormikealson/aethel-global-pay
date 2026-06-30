import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import 'dashboard_screen.dart';

/// Authentication screen using Firebase Auth.
///
/// State variables:
///   [_isLogin]          → toggles Login / Register
///   [_isLoading]        → spinner while authenticating
///   [_errorMessage]     → shows auth errors
///   [_obscurePassword]  → toggles password visibility
///
/// setState() called in:
///   _toggleMode()    → flips [_isLogin]
///   _togglePassword] → flips [_obscurePassword]
///   _submit()        → sets [_isLoading], [_errorMessage]
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = '';
    });
  }

  void _togglePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final email    = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name     = _nameController.text.trim();
      final phone    = _phoneController.text.trim();

      Map<String, dynamic> result;

      if (_isLogin) {
        result = await FirebaseService.login(
            email: email, password: password);
      } else {
        result = await FirebaseService.register(
            name: name, email: email,
            password: password, phone: phone);
      }

      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'Authentication failed');
      }

      // Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', result['name'] ?? name);
      if (phone.isNotEmpty) {
        await prefs.setString('user_phone', phone);
      }

      // Request notification permission
      await NotificationService().requestPermission();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping, size: 72, color: Colors.green[800]),
                const SizedBox(height: 8),
                Text('Hermus Global Hauls',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800])),
                const SizedBox(height: 4),
                Text(
                  _isLogin ? 'Sign in to continue' : 'Create your account',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Registration-only fields
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter your name' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_android),
                                border: OutlineInputBorder(),
                                hintText: 'e.g. 0771234567',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter your phone number';
                                }
                                if (v.trim().length < 10) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter your email';
                              }
                              if (!v.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: _togglePassword,
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),

                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(_errorMessage,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13),
                                textAlign: TextAlign.center),
                          ],

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20, width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text(_isLogin ? 'Login' : 'Register',
                                      style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Register"
                        : 'Already have an account? Login',
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
