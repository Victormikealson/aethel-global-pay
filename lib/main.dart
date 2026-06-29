import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'state/app_state.dart';
import 'services/notification_service.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase — wrapped in try/catch so app doesn't crash if it fails
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    // App continues with local SharedPreferences storage only
  }

  // Initialise local notifications
  await NotificationService().init();

  // Check if user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('user_email') != null;

  runApp(HermusGlobalHauls(isLoggedIn: isLoggedIn));
}

class HermusGlobalHauls extends StatelessWidget {
  final bool isLoggedIn;
  const HermusGlobalHauls({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AppStateProvider(
      state: appState,
      child: _AppRoot(isLoggedIn: isLoggedIn),
    );
  }
}

class _AppRoot extends StatelessWidget {
  final bool isLoggedIn;
  const _AppRoot({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return MaterialApp(
      title: 'Hermus Global Hauls',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: isLoggedIn ? const DashboardScreen() : const AuthScreen(),
    );
  }
}
