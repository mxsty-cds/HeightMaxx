import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import '../widgets/bubble_tap_effect.dart';
import '../widgets/exercise_animation_view.dart';

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

  /// Drives the circular progress ring (reverses from 1→0 over the exercise).
  late AnimationController _progressController;
  /// Drives the fade/slide transition between exercises.
  late AnimationController _fadeController;
  /// Drives the looping stick-figure animation for the current exercise.
  late AnimationController _animController;
  /// Drives the pulsing glow ring behind the timer while the timer is running.
  late AnimationController _pulseController;

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
      duration: const Duration(milliseconds: 400),
    )..forward();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _fadeController.dispose();
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _isPaused = false;
    _animController.repeat();
    _pulseController.repeat(reverse: true);
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
    _animController.stop();
    _pulseController.stop();
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
        _animController.reset();
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
        _animController.reset();
        _startTimer();
      });
    }
  }

  // --- Backend: finish workout & award XP ----------------------------------
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

  // =========================================================================
  // Build
  // =========================================================================

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
          // Background decorative blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPrimary.withValues(alpha: 0.04),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(alpha: 0.08),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          // Second background blob (bottom-left)
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSecondary.withValues(alpha: 0.04),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentSecondary.withValues(alpha: 0.07),
                    blurRadius: 100,
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
                const SizedBox(height: 8),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _fadeController,
                        curve: Curves.easeOut,
                      )),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            _ExerciseTitleSection(
                              name: current.name,
                              bodyArea: current.bodyArea,
                              quote: _quotes[_currentIndex % _quotes.length],
                            ),
                            const SizedBox(height: 36),
                            _buildTimerWithAnimation(current),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (next != null) _NextUpCard(exercise: next),
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Top bar
  // =========================================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          _glassIconButton(Icons.close_rounded, () => Navigator.pop(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.exercises.length,
                    minHeight: 7,
                    backgroundColor: AppColors.subtleBackground,
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentIndex + 1} / ${widget.exercises.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Timer + animated figure
  // =========================================================================

  Widget _buildTimerWithAnimation(Exercise current) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseScale = _isPaused
            ? 1.0
            : 1.0 + _pulseController.value * 0.055;
        final pulseAlpha = _isPaused
            ? 0.0
            : 0.12 + _pulseController.value * 0.18;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing glow ring
            Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 310,
                height: 310,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withValues(alpha: pulseAlpha),
                      blurRadius: 48,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
            ),

            // Progress ring
            SizedBox(
              width: 300,
              height: 300,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => CircularProgressIndicator(
                  value: _progressController.value,
                  strokeWidth: 14,
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

            // Inner content: animated figure + timer label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExerciseAnimationView(
                  exercise: current,
                  animation: _animController,
                ),
                const SizedBox(height: 2),
                Text(
                  _secondsRemaining.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const Text(
                  'SECONDS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // Controls
  // =========================================================================

  Widget _buildControls() {
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

          // Play / pause button with animated glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final glowAlpha = _isPaused
                  ? 0.2
                  : 0.3 + _pulseController.value * 0.25;
              final glowRadius = _isPaused ? 15.0 : 20.0 + _pulseController.value * 12;

              return BubbleTapEffect(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _isPaused ? _startTimer() : _pauseTimer();
                },
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPrimary.withValues(alpha: glowAlpha),
                        blurRadius: glowRadius,
                        offset: const Offset(0, 8),
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
              );
            },
          ),

          _glassIconButton(Icons.skip_next_rounded, nextAction),
        ],
      ),
    );
  }

  // =========================================================================
  // Shared helpers
  // =========================================================================

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
            color: AppColors.surface.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.subtleBackground.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 28),
        ),
      ),
    );
  }

  // =========================================================================
  // Victory screen
  // =========================================================================

  void _showVictoryScreen(int xp, bool leveledUp) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Victory",
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (dialogContext, anim1, anim2) {
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
      child: BubbleTapEffect(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Extracted sub-widgets
// =============================================================================

/// Displays the exercise name, body-area chip, and motivational quote.
class _ExerciseTitleSection extends StatelessWidget {
  final String name;
  final String bodyArea;
  final String quote;

  const _ExerciseTitleSection({
    required this.name,
    required this.bodyArea,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Body-area chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              bodyArea.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.accentPrimary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Exercise name
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          // Motivational quote
          Text(
            quote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Next up" card shown at the bottom of the screen.
class _NextUpCard extends StatelessWidget {
  final Exercise exercise;

  const _NextUpCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.subtleBackground),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.next_plan_outlined,
              color: AppColors.accentPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT UP',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.subtleBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${exercise.durationSeconds}s',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

