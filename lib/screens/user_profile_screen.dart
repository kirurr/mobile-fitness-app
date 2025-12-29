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
          content: Text('Profile saved'),
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
        title: const Text('Profile'),
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
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Center(
                                  child: TextFormField(
                                    controller: _nameController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Your name',
                                      border: InputBorder.none,
                                    ),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Age',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white60,
                                                ),
                                              ),
                                              TextFormField(
                                                controller: _ageController,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Years',
                                                  suffixText: 'years',
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (v) => v == null ||
                                                        int.tryParse(v) == null
                                                    ? 'Enter a number'
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Weight',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white60,
                                                ),
                                              ),
                                              TextFormField(
                                                controller: _weightController,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'kg',
                                                  suffixText: 'kg',
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (v) => v == null ||
                                                        int.tryParse(v) == null
                                                    ? 'Enter a number'
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Height',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white60,
                                                ),
                                              ),
                                              TextFormField(
                                                controller: _heightController,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'cm',
                                                  suffixText: 'cm',
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (v) => v == null ||
                                                        int.tryParse(v) == null
                                                    ? 'Enter a number'
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Training goal',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white60,
                                                ),
                                              ),
                                              DropdownButtonHideUnderline(
                                                child:
                                                    DropdownButtonFormField<int>(
                                                  isExpanded: true,
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  initialValue:
                                                      _selectedGoalId,
                                                  items: goals
                                                      .map(
                                                        (g) =>
                                                            DropdownMenuItem<int>(
                                                          value: g.id,
                                                          child: Text(
                                                            g.name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (val) => setState(
                                                    () => _selectedGoalId = val,
                                                  ),
                                                  validator: (_) =>
                                                      _selectedGoalId == null
                                                          ? 'Select a goal'
                                                          : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Training level',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white60,
                                                ),
                                              ),
                                              DropdownButtonHideUnderline(
                                                child:
                                                    DropdownButtonFormField<int>(
                                                  isExpanded: true,
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  initialValue:
                                                      _selectedDifficultyId,
                                                  items: levels
                                                      .map(
                                                        (lvl) =>
                                                            DropdownMenuItem<int>(
                                                          value: lvl.id,
                                                          child: Text(
                                                            lvl.name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (val) => setState(
                                                    () => _selectedDifficultyId =
                                                        val,
                                                  ),
                                                  validator: (_) =>
                                                      _selectedDifficultyId ==
                                                              null
                                                          ? 'Select a level'
                                                          : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Card(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const UserSubscriptionsScreen(),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.workspace_premium),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'My subscriptions',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.white54,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                        : const Text('Save'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tip: tap any field to update it.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: TextButton(
                                    onPressed: _saving ? null : _signOut,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Sign out'),
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
