import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Твои импорты
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

  // Данные для сбора (Questions Data)
  double _age = 18;
  Sex? _sex;
  double _heightFt = 5.9;
  double _weightKg = 65; // Добавил возможность выбора веса
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

  // --- ЛОГИКА FIREBASE ---

  Future<void> _completeSetup() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      // 1. Анонимная авторизация
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final String uid = userCredential.user!.uid;

      // 2. Подготовка данных
      final rawName = _nameController.text.trim();
      final finalName = rawName.isNotEmpty ? rawName : 'Mover';

      // Создаем объект профиля
      final newUser = UserProfile(
        id: uid, // Используем Firebase UID
        fullName: finalName,
        username: 'user_${uid.substring(0, 5)}',
        nickname: _nicknameController.text.trim().isNotEmpty ? _nicknameController.text.trim() : finalName,
        age: _age.round(),
        sex: _sex,
        heightCm: double.parse(_heightCm.toStringAsFixed(1)),
        weightKg: _weightKg,
        activityLevel: _activityLevel,
        growthGoal: _growthGoal,
        workoutFocus: _workoutFocus,
        workoutDaysPerWeek: _workoutDaysPerWeek,
        workoutMinutesPerSession: _workoutMinutesPerSession,
        totalGrowthCm: 0,
        totalWorkoutsCompleted: 0,
        profileCreatedAt: DateTime.now(),
      );

      // 3. Сохранение в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser.toJson()); // Убедись, что в модели UserProfile есть метод toMap()

      if (!mounted) return;

      // 4. Переход в приложение
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePageScreen(user: newUser, initialIndex: 1),
        ),
      );
    } catch (error) {
      debugPrint('Setup Error: $error');
      _showValidation('Connection failed. Please check your internet.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- UI БЛОКИ ---

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
                  _buildStep1TheIdentity(),
                  _buildStep2ThePhysics(),
                  _buildStep3TheStrategy(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // ШАГ 1: Личность
  Widget _buildStep1TheIdentity() {
    return _buildStepContainer(
      title: 'The Identity',
      subtitle: 'How should the world of movement recognize you?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('YOUR FULL NAME'),
          _buildTextField(_nameController, 'e.g. Alex Carter'),
          const SizedBox(height: 24),
          _buildLabel('BIOLOGICAL SEX'),
          Wrap(
            spacing: 12,
            children: Sex.values.map((s) => SelectablePill(
              label: s.formattedName,
              icon: s == Sex.male ? Icons.male : Icons.female,
              isSelected: _sex == s,
              onTap: () => setState(() => _sex = s),
            )).toList(),
          ),
          const SizedBox(height: 32),
          _buildLabel('YOUR CURRENT AGE'),
          CircularValueSlider(
            value: _age, min: 10, max: 60, unit: 'yrs',
            onChanged: (v) => setState(() => _age = v),
          ),
        ],
      ),
    );
  }

  // ШАГ 2: Физика
  Widget _buildStep2ThePhysics() {
    return _buildStepContainer(
      title: 'The Physics',
      subtitle: 'Precise metrics allow us to calibrate your growth potential.',
      child: Column(
        children: [
          _buildLabel('CURRENT HEIGHT'),
          CircularValueSlider(
            value: _heightFt, min: 4.0, max: 7.5, unit: 'ft', isDecimal: true,
            onChanged: (v) => setState(() => _heightFt = v),
          ),
          const SizedBox(height: 12),
          Text('${_heightCm.toStringAsFixed(1)} CM',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.accentPrimary)),
          const SizedBox(height: 40),
          _buildLabel('CURRENT WEIGHT'),
          CircularValueSlider(
            value: _weightKg, min: 30, max: 150, unit: 'kg',
            onChanged: (v) => setState(() => _weightKg = v),
          ),
        ],
      ),
    );
  }

  // ШАГ 3: Стратегия
  Widget _buildStep3TheStrategy() {
    return _buildStepContainer(
      title: 'The Strategy',
      subtitle: 'Define your effort levels and primary objectives.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('ACTIVITY LEVEL'),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ActivityLevel.values.map((a) => SelectablePill(
              label: a.formattedName, isSelected: _activityLevel == a,
              onTap: () => setState(() => _activityLevel = a),
            )).toList(),
          ),
          const SizedBox(height: 24),
          _buildLabel('GROWTH FOCUS'),
          Wrap(
            spacing: 8,
            children: GrowthGoal.values.map((g) => SelectablePill(
              label: g.formattedName, isSelected: _growthGoal == g,
              onTap: () => setState(() => _growthGoal = g),
            )).toList(),
          ),
          const SizedBox(height: 32),
          _buildLabel('WORKOUT COMMITMENT'),
          Row(
            children: [
              Expanded(child: _buildSmallMetric('Days/Week', _workoutDaysPerWeek.toDouble(), 1, 7)),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallMetric('Min/Session', _workoutMinutesPerSession.toDouble(), 5, 60)),
            ],
          ),
        ],
      ),
    );
  }

  // --- ХЕЛПЕРЫ ---

  Widget _buildSmallMetric(String label, double val, double min, double max) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        CircularValueSlider(
          value: val, min: min, max: max, unit: '',
          onChanged: (v) => setState(() {
            if (label.contains('Days')) _workoutDaysPerWeek = v.round();
            else _workoutMinutesPerSession = v.round();
          }),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.textSecondary)),
  );

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildStepContainer({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : (_currentIndex == 2 ? _completeSetup : _nextPage),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(_currentIndex == 2 ? 'FINALIZE PROFILE' : 'CONTINUE',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }

  void _nextPage() {
    if (_currentIndex == 0 && (_nameController.text.isEmpty || _sex == null)) {
      _showValidation('Please fill in your name and sex.');
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _showValidation(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: (_currentIndex + 1) / 3,
      backgroundColor: AppColors.subtleBackground,
      color: AppColors.accentPrimary,
      minHeight: 8,
    );
  }
}