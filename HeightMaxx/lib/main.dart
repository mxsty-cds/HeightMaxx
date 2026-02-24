import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    debugPrint(
      'Firebase is disabled for this run. Add platform config files (google-services.json / GoogleService-Info.plist) to enable it.',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeightMaxx',
      theme: ThemeData(useMaterial3: true),
      home: const WelcomeScreen(),
    );
  }
}

