import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for Hermus Global Hauls
/// Package: com.example.hermus_global_hauls
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  // Android — matches com.example.hermus_global_hauls
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCu3MzguzKTndCLdWGNn7WozQEfbI0GLeo',
    appId: '1:152880296226:android:1a45854e2d626ca30db57b',
    messagingSenderId: '152880296226',
    projectId: 'hermusglobal',
    storageBucket: 'hermusglobal.firebasestorage.app',
  );

  // Web — uses same project, web app needs to be added in Firebase console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCu3MzguzKTndCLdWGNn7WozQEfbI0GLeo',
    appId: '1:152880296226:android:1a45854e2d626ca30db57b',
    messagingSenderId: '152880296226',
    projectId: 'hermusglobal',
    storageBucket: 'hermusglobal.firebasestorage.app',
  );

  // iOS — placeholder, not used
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCu3MzguzKTndCLdWGNn7WozQEfbI0GLeo',
    appId: '1:152880296226:android:1a45854e2d626ca30db57b',
    messagingSenderId: '152880296226',
    projectId: 'hermusglobal',
    storageBucket: 'hermusglobal.firebasestorage.app',
  );
}
