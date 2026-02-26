import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'profile_setup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Данные на английском, согласно твоему плану (5 слайдов)
  final List<Map<String, dynamic>> splashData = [
    {
      "title": "Unlock Your Maximum Height",
      "text": "Scientifically designed routines to maximize your growth potential.",
      // Пока используем иконку, потом заменим на картинку "image": "assets/images/slide1.png"
      "icon": Icons.accessibility_new_rounded,
    },
    {
      "title": "AI Personalized Plan",
      "text": "Custom workouts built specifically for your body type and goals.",
      "icon": Icons.psychology_rounded,
    },
    {
      "title": "Track Your Progress",
      "text": "See your improvements and celebrate every millimeter grown.",
      "icon": Icons.show_chart_rounded,
    },
    {
      "title": "Join Global Leaderboard",
      "text": "Compete with others and stay motivated on your journey.",
      "icon": Icons.emoji_events_rounded,
    },
    {
      // Последний слайд - призыв к действию
      "title": "Ready to Grow?",
      "text": "Let's build your perfect posture and start increasing your height today!",
      "icon": Icons.rocket_launch_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Use theme background color for consistent branding
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4, // Увеличили место для контента
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: splashData.length,
                itemBuilder: (context, index) => SplashContent(
                  title: splashData[index]["title"]!,
                  text: splashData[index]["text"]!,
                  iconData: splashData[index]["icon"],
                  // Передаем индекс, чтобы анимировать только активную страницу
                  isActive: _currentPage == index,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    // Индикаторы (точки)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                            (index) => buildDot(index: index),
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Анимированная Кнопка
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentPage == splashData.length - 1
                          ? _buildGetStartedButton()
                          : _buildNextButton(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      key: const ValueKey("GetStartedBtn"),
      width: double.infinity,
      child: GradientButton(
        label: 'Get Started',
        borderRadius: AppTheme.radiusLG,
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProfileSetupScreen(),
            ),
          );
        },
      ),
    );
  }

  // Simple "Next" button for intermediate slides
  Widget _buildNextButton() {
    return SizedBox(
      key: const ValueKey("NextBtn"),
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutQuart,
          );
        },
        child: const Text(
          "Next",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Page indicator dots with animated width
  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 28 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.accentPrimary
            : AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// --- Виджет Контента Слайда с Анимациями ---
class SplashContent extends StatefulWidget {
  final String title;
  final String text;
  final IconData iconData;
  final bool isActive;

  const SplashContent({
    super.key,
    required this.title,
    required this.text,
    required this.iconData,
    required this.isActive,
  });

  @override
  State<SplashContent> createState() => _SplashContentState();
}

// Используем TickerProvider для анимации
class _SplashContentState extends State<SplashContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Контроллер для плавающей анимации (вверх-вниз)
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )
      ..repeat(reverse: true); // Повторять туда-сюда бесконечно
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(flex: 2),
          // --- Плавающая Анимация Иконки ---
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Двигаем иконку вверх-вниз на 15 пикселей
              return Transform.translate(
                offset: Offset(0, 15 * _controller.value - 7.5),
                child: child,
              );
            },
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // accentGlow is ~30% alpha; use 15% for a subtler shadow
                    color: AppColors.accentPrimary.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Icon(
                widget.iconData,
                size: 100,
                color: AppColors.accentPrimary,
              ),
            ),
          ),
          const Spacer(flex: 2),
          // --- Title & description ---
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: AppTheme.headline2.copyWith(
              fontSize: 26,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.text,
            textAlign: TextAlign.center,
            style: AppTheme.bodyText2.copyWith(fontSize: 16),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}