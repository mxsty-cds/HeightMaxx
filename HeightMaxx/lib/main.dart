import 'package:flutter/material.dart';
import 'screens/homepage_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeightMaxx',
      theme: ThemeData(useMaterial3: true),
      home: const HomePageScreen(),
    );
  }
}

