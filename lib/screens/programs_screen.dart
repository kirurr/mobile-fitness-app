import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExerciseProgram? _editing;
  bool _isSubmitting = false;
  bool _loadingRefs = true;

  List<DifficultyLevel> _difficultyLevels = [];
  List<Subscription> _subscriptions = [];
  List<FitnessGoal> _fitnessGoals = [];
  List<Exercise> _exercises = [];

  int? _selectedDifficultyId;
  int? _selectedSubscriptionId;
  final Set<int> _selectedFitnessGoalIds = {};
  final Set<int> _selectedExerciseIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReferenceData());
  }

  Future<void> _loadReferenceData() async {
    final deps = DependencyScope.of(context);
    final diff = await deps.difficultyLevelRepository.getLocalLevels();
    final subs = await deps.subscriptionRepository.getLocalSubscriptions();
    final goals = await deps.fitnessGoalRepository.getLocalGoals();
    final exercises = await deps.exerciseRepository.getLocalExercises();

    if (!mounted) return;
    setState(() {
      _difficultyLevels = diff;
      _subscriptions = subs;
      _fitnessGoals = goals;
      _exercises = exercises;
      _loadingRefs = false;
    });
  }

  void _startEdit(ExerciseProgram program) {
    setState(() {
      _editing = program;
      _nameController.text = program.name;
      _descriptionController.text = program.description;
      _selectedDifficultyId =
          program.difficultyLevel.isNotEmpty
              ? program.difficultyLevel.first.id
              : null;
      _selectedSubscriptionId =
          program.subscription.isNotEmpty
              ? program.subscription.first.id
              : null;
      _selectedFitnessGoalIds
        ..clear()
        ..addAll(program.fitnessGoals.map((g) => g.id));
      _selectedExerciseIds
        ..clear()
        ..addAll(program.programExercises.map((pe) => pe.exerciseId));
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final difficultyId = _selectedDifficultyId;
    final subscriptionId = _selectedSubscriptionId;

    if (name.isEmpty || description.isEmpty || difficultyId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, description, difficulty are required')),
      );
      return;
    }

    final payload = ExerciseProgramPayloadDTO(
      name: name,
      description: description,
      difficultyLevelId: difficultyId,
      subscriptionId: subscriptionId,
      userId: null,
      fitnessGoalIds: _selectedFitnessGoalIds.toList(),
      exercises: _selectedExerciseIds.toList().asMap().entries.map(
        (entry) {
          final order = entry.key;
          final exerciseId = entry.value;
          return ProgramExerciseDTO(
            exerciseId: exerciseId,
            order: order,
            sets: 1,
            reps: null,
            duration: null,
            restDuration: 0,
          );
        },
      ).toList(),
    );

    final repo = DependencyScope.of(context).exerciseProgramRepository;
    setState(() => _isSubmitting = true);
    try {
      if (_editing != null) {
        await repo.updateProgram(_editing!.id, payload);
      } else {
        await repo.createProgram(payload);
      }
      _resetForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _editing = null;
      _nameController.clear();
      _descriptionController.clear();
      _selectedDifficultyId = null;
      _selectedSubscriptionId = null;
      _selectedFitnessGoalIds.clear();
      _selectedExerciseIds.clear();
    });
  }

  Future<void> _delete(int id) async {
    final repo = DependencyScope.of(context).exerciseProgramRepository;
    await repo.deleteProgram(id);
    if (_editing?.id == id) {
      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = DependencyScope.of(context).exerciseProgramRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Programs'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editing == null ? 'Create Program' : 'Edit Program',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            _loadingRefs
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: _selectedDifficultyId,
                        decoration: const InputDecoration(labelText: 'Difficulty Level'),
                        items: _difficultyLevels
                            .map(
                              (d) => DropdownMenuItem<int>(
                                value: d.id,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _selectedDifficultyId = val),
                      ),
                      DropdownButtonFormField<int?>(
                        initialValue: _selectedSubscriptionId,
                        decoration:
                            const InputDecoration(labelText: 'Subscription (optional)'),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('None'),
                          ),
                          ..._subscriptions.map(
                            (s) => DropdownMenuItem<int?>(
                              value: s.id,
                              child: Text('${s.name} (${s.monthlyCost})'),
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => _selectedSubscriptionId = val),
                      ),
                      const SizedBox(height: 12),
                      const Text('Fitness Goals',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ..._fitnessGoals.map(
                        (goal) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(goal.name),
                          value: _selectedFitnessGoalIds.contains(goal.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedFitnessGoalIds.add(goal.id);
                              } else {
                                _selectedFitnessGoalIds.remove(goal.id);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Exercises',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ..._exercises.map(
                        (ex) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(ex.name),
                          subtitle: Text(
                            'Type: ${ex.type} | Difficulty: ${ex.difficultyLevel.value?.name ?? '-'}',
                          ),
                          value: _selectedExerciseIds.contains(ex.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedExerciseIds.add(ex.id);
                              } else {
                                _selectedExerciseIds.remove(ex.id);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(_editing == null ? 'Create' : 'Update'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isSubmitting ? null : _resetForm,
                  child: const Text('Clear'),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Existing Programs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<List<ExerciseProgram>>(
              stream: repo.watchPrograms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Text('No programs yet');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _startEdit(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
