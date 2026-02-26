import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Добавили этот импорт
import 'package:heightmaxx/screens/homepage_screen.dart';
import 'firebase_options.dart'; // Не забудь про этот файл!

// Твои экраны
import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase должна быть идемпотентной:
  // в некоторых средах [DEFAULT] уже создан до этого вызова.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (error) {
    if (error.code != 'duplicate-app') {
      rethrow;
    }
    Firebase.app();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeightMaxx',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      // Здесь происходит магия проверки
      home: const AuthWrapper(),
    );
  }
}

// Специальный виджет-прослойка
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const WelcomeScreen();
    }

    // StreamBuilder слушает изменения в Auth: залогинился юзер или вышел
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Если Firebase еще проверяет состояние (загрузка)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accentPrimary),
            ),
          );
        }

        // Если данные есть — значит юзер авторизован
        if (snapshot.hasData) {
          return const HomePageScreen();
        }

        // Если данных нет — отправляем на приветственный экран
        return const WelcomeScreen();
      },
    );
  }
}
