import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/auth/service.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/screens/user_subscriptions_screen.dart';
import 'package:mobile_fitness_app/screens/sign_in_screen.dart';
import 'package:mobile_fitness_app/user_data/model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  UserData? _userData;
  int? _selectedGoalId;
  int? _selectedDifficultyId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocalUserData());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalUserData() async {
    final deps = DependencyScope.of(context);
    final data = await deps.userDataRepository.getLocalUserData();
    if (!mounted) return;
    setState(() {
      _userData = data;
      _nameController.text = data?.name ?? '';
      _ageController.text = data?.age.toString() ?? '';
      _weightController.text = data?.weight.toString() ?? '';
      _heightController.text = data?.height.toString() ?? '';
      _selectedGoalId = data?.fitnessGoal.value?.id;
      _selectedDifficultyId = data?.trainingLevel.value?.id;
      _loading = false;
    });
  }

  Future<void> _saveProfile(
    List<FitnessGoal> goals,
    List<DifficultyLevel> levels,
  ) async {
    if (_userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not found.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate() ||
        _selectedGoalId == null ||
        _selectedDifficultyId == null) {
      return;
    }

    final goal = goals.firstWhere(
      (g) => g.id == _selectedGoalId,
      orElse: () => throw Exception('Selected fitness goal not found'),
    );
    final level = levels.firstWhere(
      (l) => l.id == _selectedDifficultyId,
      orElse: () => throw Exception('Selected training level not found'),
    );

    final updated = UserData(
      userId: _userData!.userId,
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      weight: int.parse(_weightController.text),
      height: int.parse(_heightController.text),
    );
    updated.fitnessGoal.value = goal;
    updated.trainingLevel.value = level;

    setState(() => _saving = true);
    try {
      final deps = DependencyScope.of(context);
      await deps.userDataRepository.saveLocalUserData(updated);
      if (!mounted) return;
      setState(() {
        _userData = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved locally. Sync to upload changes.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _saving = true);
    await _authService.signout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deps = DependencyScope.of(context);
    final goalRepo = deps.fitnessGoalRepository;
    final difficultyRepo = deps.difficultyLevelRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<FitnessGoal>>(
              stream: goalRepo.watchGoals(),
              builder: (context, goalSnap) {
                final goals = goalSnap.data ?? const [];
                return StreamBuilder<List<DifficultyLevel>>(
                  stream: difficultyRepo.watchLevels(),
                  builder: (context, levelSnap) {
                    final levels = levelSnap.data ?? const [];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_userData == null)
                            const Text(
                              'User data not found. Please complete your profile first.',
                            )
                          else
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current info',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Name: ${_userData!.name}'),
                                    Text('Age: ${_userData!.age}'),
                                    Text('Weight: ${_userData!.weight}'),
                                    Text('Height: ${_userData!.height}'),
                                    Text(
                                      'Goal: ${_userData!.fitnessGoal.value?.name ?? '-'}',
                                    ),
                                    Text(
                                      'Level: ${_userData!.trainingLevel.value?.name ?? '-'}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const UserSubscriptionsScreen(),
                                    ),
                                  ),
                                  child: const Text('User Subscriptions'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _saving ? null : _signOut,
                                  child: const Text('Sign Out'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Edit profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration:
                                      const InputDecoration(labelText: 'Name'),
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                                TextFormField(
                                  controller: _ageController,
                                  decoration:
                                      const InputDecoration(labelText: 'Age'),
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null ||
                                          int.tryParse(v) == null
                                      ? 'Enter a number'
                                      : null,
                                ),
                                TextFormField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Weight',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null ||
                                          int.tryParse(v) == null
                                      ? 'Enter a number'
                                      : null,
                                ),
                                TextFormField(
                                  controller: _heightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Height',
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null ||
                                          int.tryParse(v) == null
                                      ? 'Enter a number'
                                      : null,
                                ),
                                DropdownButtonFormField<int>(
                                  decoration: const InputDecoration(
                                    labelText: 'Fitness Goal',
                                  ),
                                  initialValue: _selectedGoalId,
                                  items: goals
                                      .map(
                                        (g) => DropdownMenuItem<int>(
                                          value: g.id,
                                          child: Text(g.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedGoalId = val),
                                  validator: (_) => _selectedGoalId == null
                                      ? 'Select a goal'
                                      : null,
                                ),
                                DropdownButtonFormField<int>(
                                  decoration: const InputDecoration(
                                    labelText: 'Training Level',
                                  ),
                                  initialValue: _selectedDifficultyId,
                                  items: levels
                                      .map(
                                        (lvl) => DropdownMenuItem<int>(
                                          value: lvl.id,
                                          child: Text(lvl.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) => setState(
                                    () => _selectedDifficultyId = val,
                                  ),
                                  validator: (_) =>
                                      _selectedDifficultyId == null
                                          ? 'Select a training level'
                                          : null,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _saving || _userData == null
                                        ? null
                                        : () => _saveProfile(goals, levels),
                                    child: _saving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Save Locally'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
