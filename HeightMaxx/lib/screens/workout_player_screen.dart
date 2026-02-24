import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final int initialIndex;

  const WorkoutPlayerScreen({
    super.key,
    required this.exercises,
    required this.initialIndex,
  });

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPaused = false;

  late AnimationController _pulseController;

  Exercise get _currentExercise => widget.exercises[_currentIndex];
  bool get _isLastExercise => _currentIndex == widget.exercises.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _remainingSeconds = _currentExercise.durationSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds <= 5) HapticFeedback.selectionClick();
      } else if (_remainingSeconds == 0) {
        _timer?.cancel();
        HapticFeedback.heavyImpact();
        _handleNext();
      }
    });
  }

  void _handleNext() {
    if (_isLastExercise) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentIndex++;
        _remainingSeconds = widget.exercises[_currentIndex].durationSeconds;
      });
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Вычисляем прогресс всей тренировки
    double totalProgress = (_currentIndex + 1) / widget.exercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Чистый светлый фон
      body: Stack(
        children: [
          // Декоративный градиент на фоне для "дорогого" вида
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentPrimary.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Верхняя панель (Header)
                _buildCustomAppBar(totalProgress),

                // 2. Основной контент (Scrollable чтобы не было Overflow)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            _currentExercise.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "EXERCISE ${_currentIndex + 1} OF ${widget.exercises.length}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Центральная Иллюстрация
                          _buildExerciseIllustration(),

                          const SizedBox(height: 30),

                          // Таймер
                          _buildTimerDisplay(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Нижняя панель управления (Footer)
                _buildControlPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 30, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.subtleBackground,
                valueColor: const AlwaysStoppedAnimation(AppColors.accentPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseIllustration() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.97, end: 1.03).animate(_pulseController),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPrimary.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.accessibility_new_rounded, size: 100, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CircularProgressIndicator(
            value: _remainingSeconds / _currentExercise.durationSeconds,
            strokeWidth: 10,
            strokeCap: StrokeCap.round,
            backgroundColor: AppColors.subtleBackground,
            valueColor: const AlwaysStoppedAnimation(AppColors.accentPrimary),
          ),
        ),
        Text(
          "$minutes:$seconds",
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            fontFeatures: [FontFeature.tabularFigures()],
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSecondaryCircleButton(Icons.skip_previous_rounded, () {}),
          GestureDetector(
            onTap: () => setState(() => _isPaused = !_isPaused),
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          _buildSecondaryCircleButton(Icons.skip_next_rounded, _handleNext),
        ],
      ),
    );
  }

  Widget _buildSecondaryCircleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.subtleBackground, width: 2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30, color: AppColors.textPrimary),
      ),
    );
  }
}