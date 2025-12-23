import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/user_data/dto.dart';

class UserDataFormScreen extends StatefulWidget {
  const UserDataFormScreen({super.key});

  @override
  State<UserDataFormScreen> createState() => _UserDataFormScreenState();
}

class _UserDataFormScreenState extends State<UserDataFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final List<FitnessGoal> _fitnessGoals = [];
  final List<DifficultyLevel> _difficultyLevels = [];
  int? _selectedGoalId;
  int? _selectedDifficultyId;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedGoalId == null ||
        _selectedDifficultyId == null) {
      return;
    }

    final selectedGoal = _fitnessGoals.firstWhere(
      (g) => g.id == _selectedGoalId,
      orElse: () => throw Exception('Selected fitness goal not found'),
    );
    final selectedDifficulty = _difficultyLevels.firstWhere(
      (d) => d.id == _selectedDifficultyId,
      orElse: () => throw Exception('Selected training level not found'),
    );

    final deps = DependencyScope.of(context);
    final repo = deps.userDataRepository;

    setState(() => _submitting = true);
    try {
      final dto = CreateUserDataDTO(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        weight: int.parse(_weightController.text),
        height: int.parse(_heightController.text),
        fitnessGoalId: selectedGoal.id,
        trainingLevel: selectedDifficulty.id,
      );

      await repo.createUserData(dto);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deps = DependencyScope.of(context);
    final goalRepo = deps.fitnessGoalRepository;
    final difficultyRepo = deps.difficultyLevelRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
      ),
      body: StreamBuilder<List<FitnessGoal>>(
        stream: goalRepo.watchGoals(),
        builder: (context, goalSnap) {
          final goals = goalSnap.data ?? [];
          _fitnessGoals
            ..clear()
            ..addAll(goals);
          return StreamBuilder<List<DifficultyLevel>>(
            stream: difficultyRepo.watchLevels(),
            builder: (context, diffSnap) {
              final levels = diffSnap.data ?? [];
              _difficultyLevels
                ..clear()
                ..addAll(levels);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || int.tryParse(v) == null ? 'Enter a number' : null,
                      ),
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(labelText: 'Weight'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || int.tryParse(v) == null ? 'Enter a number' : null,
                      ),
                      TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(labelText: 'Height'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || int.tryParse(v) == null ? 'Enter a number' : null,
                      ),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Fitness Goal'),
                        initialValue: _selectedGoalId,
                        items: goals
                            .map(
                              (g) => DropdownMenuItem<int>(
                                value: g.id,
                                child: Text(g.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGoalId = val),
                        validator: (_) =>
                            _selectedGoalId == null ? 'Select a goal' : null,
                      ),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Training Level'),
                        initialValue: _selectedDifficultyId,
                        items: levels
                            .map(
                              (lvl) => DropdownMenuItem<int>(
                                value: lvl.id,
                                child: Text(lvl.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedDifficultyId = val),
                        validator: (_) =>
                            _selectedDifficultyId == null
                                ? 'Select a training level'
                                : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
