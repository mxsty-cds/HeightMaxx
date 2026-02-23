import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Application',
      theme: ThemeData(useMaterial3: true),
      home: const WelcomeScreen(),
    );
  }
}

// --- THEME CONSTANTS ---
const Color appBackground = Color(0xFFFAFAFA);
const Color appSurface = Colors.white;
const Color appAccent = Color(0xFF00E676); // Vibrant Green
const Color appTextMain = Color(0xFF111111);
const Color appTextMuted = Color(0xFF888888);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconOpacity;
  late Animation<Offset> _iconSlide;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _buttonOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // 1.5 second total animation duration for a smooth, unhurried feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Staggered Intervals: Icon (0-40%), Text (30-70%), Button (60-100%)
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _iconSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
          ),
        );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Start the animation immediately on load
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStartPressed() {
    HapticFeedback.heavyImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Setting system UI overlay to match the light, minimal aesthetic
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Animated Icon / Logo Area
              SlideTransition(
                position: _iconSlide,
                child: FadeTransition(
                  opacity: _iconOpacity,
                  child: Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: appSurface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: appAccent.withAlpha((0.15 * 255).round()),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.height_rounded, // Represents vertical growth
                        size: 48,
                        color: appAccent,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Animated Typography Area
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: const [
                      Text(
                        'Unlock Your\nPresence.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1.5,
                          color: appTextMain,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Build the habit of perfect posture.\nLevel up your physical confidence daily.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: appTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Animated CTA Button
              SlideTransition(
                position: _buttonSlide,
                child: FadeTransition(
                  opacity: _buttonOpacity,
                  child: ElevatedButton(
                    onPressed: _onStartPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Begin Journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
