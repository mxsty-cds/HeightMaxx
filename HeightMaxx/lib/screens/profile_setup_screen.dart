import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_factors.dart';
import '../screens/homepage_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/circular_value_slider.dart';
import '../widgets/selectable_pill.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  int _currentIndex = 0;
  bool _isSubmitting = false;

  // Temporary state for the form
  double _age = 18;
  Sex? _sex;
  double _heightFt = 5.9;
  final int _weightKg = 65;
  ActivityLevel? _activityLevel;
  GrowthGoal? _growthGoal = GrowthGoal.both;
  String _workoutFocus = 'mixed';
  int _workoutDaysPerWeek = 4;
  int _workoutMinutesPerSession = 20;

  double get _heightCm => _heightFt * 30.48;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard if open

    if (_currentIndex == 0) {
      if (_nameController.text.trim().isEmpty || _sex == null) {
        _showValidation('Please enter your name and select your sex.');
        return;
      }
    }

    if (_currentIndex == 2) {
      if (_activityLevel == null || _growthGoal == null) {
        _showValidation('Please select activity level and growth goal.');
        return;
      }
    }

    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeSetup();
    }
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _completeSetup() async {
    if (_isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final rawName = _nameController.text.trim();
      final rawNickname = _nicknameController.text.trim();

      final finalName = rawName.isNotEmpty ? rawName : 'Mover';
      final finalNickname = rawNickname.isNotEmpty ? rawNickname : finalName;
      final finalId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final sanitizedUsername = finalNickname
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9_\s]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
      final finalUsername = sanitizedUsername.isNotEmpty
          ? sanitizedUsername
          : 'user_${DateTime.now().millisecondsSinceEpoch}';

      final newUser = UserProfile(
        id: finalId,
        fullName: finalName,
        username: finalUsername,
        nickname: finalNickname,
        age: _age.round(),
        sex: _sex,
        heightCm: double.parse(_heightCm.toStringAsFixed(1)),
        weightKg: _weightKg.toDouble(),
        activityLevel: _activityLevel,
        growthGoal: _growthGoal,
        workoutFocus: _workoutFocus,
        workoutDaysPerWeek: _workoutDaysPerWeek,
        workoutMinutesPerSession: _workoutMinutesPerSession,
        totalGrowthCm: 0,
        totalWorkoutsCompleted: 0,
        profileCreatedAt: DateTime.now(),
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePageScreen(user: newUser, initialIndex: 1),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showValidation('Could not complete profile. Please try again.');
      debugPrint('Profile setup failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  _buildStep1BasicInfo(),
                  _buildStep2Metrics(),
                  _buildStep3Habits(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: LinearProgressIndicator(
        value: (_currentIndex + 1) / 3,
        backgroundColor: AppColors.subtleBackground,
        valueColor: const AlwaysStoppedAnimation<Color>(
          AppColors.accentPrimary,
        ),
        borderRadius: BorderRadius.circular(8),
        minHeight: 6,
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return _buildStepContainer(
      title: 'Let\'s build your profile',
      subtitle: 'This helps us personalize your growth journey.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Full Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Alex Carter',
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          const Text('What should we call you?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            controller: _nicknameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Alex (Optional)',
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          const Text('Sex', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: Sex.values.map(
              (option) => SelectablePill(
                label: option.formattedName,
                icon: option == Sex.male ? Icons.male_rounded : Icons.female_rounded,
                isSelected: _sex == option,
                onTap: () => setState(() => _sex = option),
              ),
            ).toList(),
          ),
          const SizedBox(height: 40),
          const Text('Select Your Age', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          CircularValueSlider(
            value: _age,
            min: 10,
            max: 80,
            unit: 'Years',
            isDecimal: false,
            onChanged: (val) => setState(() => _age = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Metrics() {
    return _buildStepContainer(
      title: 'Current Metrics',
      subtitle: 'Used to calculate your personal posture baseline.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Height (Feet)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          CircularValueSlider(
            value: _heightFt,
            min: 4.0,
            max: 8.0,
            unit: 'ft',
            isDecimal: true,
            onChanged: (val) => setState(() => _heightFt = val),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${_heightFt.toStringAsFixed(1)} ft • ${_heightCm.toStringAsFixed(1)} cm',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Habits() {
    return _buildStepContainer(
      title: 'Habits & Goals',
      subtitle: 'Set your daily movement and workout routine specs.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ActivityLevel.values
                .map(
                  (activity) => SelectablePill(
                    label: activity.formattedName,
                    isSelected: _activityLevel == activity,
                    onTap: () => setState(() => _activityLevel = activity),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          const Text('Primary Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: GrowthGoal.values
                .map(
                  (goal) => SelectablePill(
                    label: goal.formattedName,
                    isSelected: _growthGoal == goal,
                    onTap: () => setState(() => _growthGoal = goal),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          const Text('Workout Focus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFocusChip('mobility', 'MOBILITY'),
              _buildFocusChip('posture', 'POSTURE'),
              _buildFocusChip('mixed', 'MIXED'),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Workout Days Per Week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          CircularValueSlider(
            value: _workoutDaysPerWeek.toDouble(),
            min: 1,
            max: 7,
            unit: 'Days',
            isDecimal: false,
            onChanged: (val) => setState(() => _workoutDaysPerWeek = val.round()),
          ),
          const SizedBox(height: 28),
          const Text('Minutes Per Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          CircularValueSlider(
            value: _workoutMinutesPerSession.toDouble(),
            min: 5,
            max: 90,
            unit: 'Min',
            isDecimal: false,
            onChanged: (val) => setState(() => _workoutMinutesPerSession = val.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusChip(String value, String label) {
    return SelectablePill(
      label: label,
      isSelected: _workoutFocus == value,
      onTap: () => setState(() => _workoutFocus = value),
    );
  }

  Widget _buildStepContainer({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 48),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.accentPrimary.withValues(alpha: 0.4),
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _isSubmitting ? null : _nextPage,
        child: Text(
          _currentIndex == 2 ? 'Complete Profile' : 'Continue',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
    );
  }
}