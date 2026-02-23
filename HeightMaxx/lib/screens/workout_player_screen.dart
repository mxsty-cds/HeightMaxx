// lib/screens/workout_player_screen.dart
//
// Stripped-down playback interface. The timer subtly pulses every second
// it ticks down, maintaining focus without being distracting.

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
  
  // Controls the subtle pulsing animation of the timer text
  bool _pulseState = false;

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
          _pulseState = !_pulseState; // Toggle pulse state every tick
        });
      } else {
        _timer?.cancel();
        HapticFeedback.heavyImpact(); 
      }
    });
  }

  void _handleNext() {
    HapticFeedback.lightImpact();
    if (_isLastExercise) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentIndex++;
        _remainingSeconds = _currentExercise.durationSeconds;
        _pulseState = false;
      });
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
              Text(
                _currentExercise.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 40),

              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(color: AppColors.accentSecondary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.fitness_center_rounded, size: 64, color: AppColors.accentPrimary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Expanded(
                flex: 2,
                child: Center(
                  // Micro-interaction: Timer pulses slightly on each tick
                  child: AnimatedScale(
                    scale: _pulseState ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Text(
                      _formattedTime,
                      style: TextStyle(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 88,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2.0,
                        color: _remainingSeconds == 0 ? AppColors.accentPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 8,
                  shadowColor: AppColors.textPrimary.withValues(alpha: 0.3),
                ),
                child: Text(
                  _isLastExercise ? 'Finish Routine' : 'Next Exercise',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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