import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final int initialIndex;
  final UserProfile? user;

  const WorkoutPlayerScreen({
    super.key,
    required this.exercises,
    this.initialIndex = 0,
    this.user,
  });

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late int _secondsRemaining;
  Timer? _timer;
  bool _isPaused = false;

  late AnimationController _progressController;
  late AnimationController _fadeController;

  final List<String> _quotes = [
    "Visualize your spine lengthening...",
    "Deep breaths. Feel the decompression.",
    "Consistency is the key to height.",
    "Almost there! Your future self is watching.",
    "Gravity is your only opponent.",
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _secondsRemaining = widget.exercises[_currentIndex].durationSeconds;

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _secondsRemaining),
    )..reverse(from: 1.0);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _isPaused = false;
    _progressController.reverse(
      from: _secondsRemaining / widget.exercises[_currentIndex].durationSeconds,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        if (_secondsRemaining <= 3) HapticFeedback.vibrate();
      } else {
        _nextExercise();
      }
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _progressController.stop();
    setState(() => _isPaused = true);
  }

  void _nextExercise() {
    if (_currentIndex < widget.exercises.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentIndex++;
          _secondsRemaining = widget.exercises[_currentIndex].durationSeconds;
          _progressController.duration = Duration(seconds: _secondsRemaining);
        });
        _fadeController.forward();
        _startTimer();
      });
    } else {
      _finishWorkout();
    }
  }

  void _prevExercise() {
    if (_currentIndex > 0) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentIndex--;
          _secondsRemaining = widget.exercises[_currentIndex].durationSeconds;
          _progressController.duration = Duration(seconds: _secondsRemaining);
        });
        _fadeController.forward();
        _startTimer();
      });
    }
  }

  // --- ЛОГИКА ЗАВЕРШЕНИЯ (BACKEND) ---
  Future<void> _finishWorkout() async {
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    int baseXP = 120;
    int multiplier = widget.user?.level ?? 1;
    int totalXP = baseXP + (multiplier * 7);

    int currentXp = (widget.user?.currentXp ?? 0) + totalXP;
    int xpToNext = widget.user?.xpToNextLevel ?? 100;
    int newLevel = widget.user?.level ?? 1;
    bool leveledUp = false;

    if (currentXp >= xpToNext) {
      leveledUp = true;
      newLevel++;
      currentXp -= xpToNext;
      xpToNext = (newLevel * 120);
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'currentXp': currentXp,
        'level': newLevel,
        'xpToNextLevel': xpToNext,
        'totalWorkoutsCompleted': FieldValue.increment(1),
        'lastActiveDate': DateTime.now().toIso8601String(),
      });
    }

    if (!mounted) return;
    _showVictoryScreen(totalXP, leveledUp);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.exercises[_currentIndex];
    final next = (_currentIndex < widget.exercises.length - 1)
        ? widget.exercises[_currentIndex + 1]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPrimary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(alpha: 0.1),
                    blurRadius:
                        100, // Вот теперь Flutter понимает, что это размытие тени!
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 10),

                // Обернули в скролл, чтобы на маленьких экранах не было ошибки переполнения!
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            current.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _quotes[_currentIndex % _quotes.length],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildTimerCircle(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                if (next != null) _buildNextUpCard(next),

                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _glassIconButton(Icons.close_rounded, () => Navigator.pop(context)),
          const SizedBox(width: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / widget.exercises.length,
                minHeight: 8,
                backgroundColor: AppColors.subtleBackground,
                color: AppColors.accentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) => CircularProgressIndicator(
              value: _progressController.value,
              strokeWidth: 15,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.subtleBackground,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progressController.value < 0.2
                    ? Colors.redAccent
                    : AppColors.accentPrimary,
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _secondsRemaining.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const Text(
              'SECONDS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextUpCard(Exercise next) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.subtleBackground),
      ),
      child: Row(
        children: [
          const Icon(Icons.next_plan_outlined, color: AppColors.accentPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT UP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentPrimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  next.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${next.durationSeconds}s',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    // 1. ЖЕЛЕЗОБЕТОННОЕ ИСПРАВЛЕНИЕ ТИПОВ ДЛЯ КНОПОК
    VoidCallback? prevAction;
    if (_currentIndex > 0) {
      prevAction = () {
        HapticFeedback.lightImpact();
        _prevExercise();
      };
    }

    void nextAction() {
      HapticFeedback.lightImpact();
      _nextExercise();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30, top: 10, left: 40, right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _glassIconButton(Icons.skip_previous_rounded, prevAction),

          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _isPaused ? _startTimer() : _pauseTimer();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(
                      alpha: _isPaused ? 0.2 : 0.4,
                    ),
                    blurRadius: _isPaused ? 15 : 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: child.key == const ValueKey('pause')
                        ? Tween<double>(begin: 0.75, end: 1.0).animate(anim)
                        : Tween<double>(begin: 0.5, end: 1.0).animate(anim),
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    key: ValueKey(_isPaused ? 'play' : 'pause'),
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
            ),
          ),

          _glassIconButton(Icons.skip_next_rounded, nextAction),
        ],
      ),
    );
  }

  Widget _glassIconButton(IconData icon, VoidCallback? onTap) {
    final bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isDisabled ? 0.3 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.subtleBackground.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 28),
        ),
      ),
    );
  }

  void _showVictoryScreen(int xp, bool leveledUp) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Victory",
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (dialogContext, anim1, anim2) {
        // 2. ИСПРАВЛЕНИЕ КОНТЕКСТА ЗДЕСЬ
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppColors.accentPrimary.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("🏆", style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text(
                    "MISSION COMPLETE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "+$xp XP",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (leveledUp)
                    const Text(
                      "LEVEL UP!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber,
                      ),
                    ),
                  const SizedBox(height: 40),
                  _buildPrimaryButton("CLAIM REWARDS", () {
                    // Закрываем всё ПРАВИЛЬНО, чтобы не было крашей
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
