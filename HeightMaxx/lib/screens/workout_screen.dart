import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user.dart';
import '../models/exercise.dart';
import '../theme/app_colors.dart';
import 'workout_player_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final UserProfile? user;

  const WorkoutScreen({super.key, this.user});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  List<Exercise> _routine = [];
  bool _isLoading = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _fetchRoutine();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoutine() async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _routine = const [
        Exercise(
          id: 'e1',
          name: 'Hanging exercise',
          durationSeconds: 30,
          bodyArea: 'Spine',
          description:
              'Decompress the vertebrae by hanging from a bar. Lengthens the spine and relieves disc pressure.',
          visualType: ExerciseVisualType.hanging,
        ),
        Exercise(
          id: 'e2',
          name: 'Cobra stretch',
          durationSeconds: 45,
          bodyArea: 'Lower Back',
          description:
              'Extend the lower back gently while lying face-down. Improves lumbar flexibility and posture.',
          visualType: ExerciseVisualType.cobraStretch,
        ),
        Exercise(
          id: 'e3',
          name: 'Forward bend',
          durationSeconds: 30,
          bodyArea: 'Hamstrings & Back',
          description:
              'Reach toward your toes from a standing position. Stretches the posterior chain and improves flexibility.',
          visualType: ExerciseVisualType.forwardBend,
        ),
        Exercise(
          id: 'e4',
          name: 'Spine stretch',
          durationSeconds: 60,
          bodyArea: 'Full Spine',
          description:
              'Seated forward reach targeting the full length of the spine. Increases spinal mobility and decompression.',
          visualType: ExerciseVisualType.spineStretch,
        ),
        Exercise(
          id: 'e5',
          name: 'Jump training',
          durationSeconds: 40,
          bodyArea: 'Legs & Core',
          description:
              'Explosive jump sets that stimulate growth plates and strengthen the lower body for better posture.',
          visualType: ExerciseVisualType.jumpTraining,
        ),
      ];
      _isLoading = false;
    });
  }

  String get _focus => widget.user?.workoutFocus?.toUpperCase() ?? 'MIXED';

  String get _estimatedTime {
    if (_routine.isEmpty) return '0 min';
    final totalSeconds = _routine.fold<int>(
      0,
      (sum, item) => sum + item.durationSeconds,
    );
    return '${(totalSeconds / 60).ceil()} min';
  }

  void _openPlayer(BuildContext context, int initialIndex) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutPlayerScreen(
          exercises: _routine,
          initialIndex: initialIndex,
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(),
              _isLoading
                  ? _buildShimmerList()
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 180),
                      sliver: _buildList(),
                    ),
            ],
          ),
          if (!_isLoading) _buildStickyStartButton(context),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      collapsedHeight: 100,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Фоновый градиентный шейп
            Positioned(
              top: -50,
              right: -50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentPrimary.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_focus ROUTINE',
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Daily\nDecompression',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildHeaderChip(Icons.timer_rounded, _estimatedTime),
                      const SizedBox(width: 12),
                      _buildHeaderChip(Icons.bolt_rounded, '120 XP'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accentPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final exercise = _routine[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openPlayer(context, index),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Exercise icon with order number
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _bodyAreaIcon(exercise.bodyArea),
                            size: 20,
                            color: AppColors.accentPrimary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Body area and duration in a single row
                          Row(
                            children: [
                              Icon(
                                Icons.place_rounded,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  exercise.bodyArea,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.av_timer_rounded,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${exercise.durationSeconds}s',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (exercise.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              exercise.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }, childCount: _routine.length),
    );
  }

  /// Returns a representative icon for the body area targeted.
  /// Uses exact keyword matching to avoid partial-match false positives.
  IconData _bodyAreaIcon(String bodyArea) {
    final area = bodyArea.toLowerCase();
    // Exact keyword checks — ordered from most specific to least specific
    if (area.contains('lower back')) return Icons.airline_seat_flat_rounded;
    if (area.contains('full spine') || area.contains('spine')) {
      return Icons.airline_seat_flat_rounded;
    }
    if (area.contains('back')) return Icons.airline_seat_flat_rounded;
    if (area.contains('core')) return Icons.sports_gymnastics_rounded;
    if (area.contains('hamstring') ||
        area.contains('legs') ||
        area.contains('leg')) {
      return Icons.directions_run_rounded;
    }
    if (area.contains('shoulder') || area.contains('chest')) {
      return Icons.sports_handball_rounded;
    }
    if (area.contains('hips') || area.contains('hip')) {
      return Icons.rotate_90_degrees_ccw_rounded;
    }
    return Icons.self_improvement_rounded; // default: full body / stretching
  }

  Widget _buildShimmerList() {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(
                    alpha: 0.5 + 0.5 * _shimmerController.value,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              );
            },
          ),
          childCount: 5,
        ),
      ),
    );
  }

  Widget _buildStickyStartButton(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient.withOpacity(0.9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openPlayer(context, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'BEGIN SESSION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
