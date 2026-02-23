// lib/screens/workout_player_screen.dart
//
// The active playback interface for exercises.
// Features a massive timer, clear typography, and auto-managing state.

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

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  late int _currentIndex;
  late int _remainingSeconds;
  Timer? _timer;

  Exercise get _currentExercise => widget.exercises[_currentIndex];
  bool get _isLastExercise => _currentIndex == widget.exercises.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _remainingSeconds = _currentExercise.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        HapticFeedback.heavyImpact(); // Alert user that time is up
      }
    });
  }

  void _handleNext() {
    HapticFeedback.lightImpact();
    if (_isLastExercise) {
      // Finished the routine
      Navigator.of(context).pop();
    } else {
      // Advance to next exercise
      setState(() {
        _currentIndex++;
        _remainingSeconds = _currentExercise.durationSeconds;
      });
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Helper to format seconds into MM:SS
  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Exercise Name
              Text(
                _currentExercise.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),

              // Animation Placeholder
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.subtleBackground,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.surface, width: 4),
                  ),
                  child: const Center(
                    child: Text(
                      'Animation\nPlaceholder',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Timer Display
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    _formattedTime,
                    style: TextStyle(
                      // Monospaced features help stop text jitter as seconds tick
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2.0,
                      color: _remainingSeconds == 0 
                          ? AppColors.success 
                          : AppColors.accent,
                    ),
                  ),
                ),
              ),

              // Next / Finish Button
              ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.surface,
                  elevation: 8,
                  shadowColor: AppColors.textPrimary.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _isLastExercise ? 'Finish Routine' : 'Next Exercise',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}