import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/app/dependencies.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/training_start_screen.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'package:mobile_fitness_app/user_data/model.dart';

class TrainingScreen extends StatefulWidget {
  final int? completedProgramId;

  const TrainingScreen({super.key, this.completedProgramId});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  ExerciseProgram? _program;
  UserCompletedProgram? _completedProgram;
  UserData? _userData;
  List<Exercise> _exercises = [];
  final Map<int, _ExerciseEditors> _editControllers = {};
  List<UserCompletedExercise> _completedCache = [];

  bool _loading = true;
  bool _endingProgram = false;
  bool _savingProgram = false;
  String? _error;

  final TextEditingController _programNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  Timer? _programMetaDebounce;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  final Map<int, Timer> _inlineSaveTimers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _programNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    for (final entry in _editControllers.values) {
      entry.dispose();
    }
    _programMetaDebounce?.cancel();
    _elapsedTimer?.cancel();
    for (final timer in _inlineSaveTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final deps = DependencyScope.of(context);
      final userData = await deps.userDataRepository.getLocalUserData();
      if (userData == null) {
        setState(() {
          _error = 'User data not found. Complete your profile first.';
          _loading = false;
        });
        return;
      }
      final exercises = await deps.exerciseRepository.getLocalExercises();
      final difficultyId = userData.trainingLevel.value?.id;
      if (difficultyId == null) {
        setState(() {
          _error = 'Training level not set for user.';
          _loading = false;
        });
        return;
      }
      final programs = await deps.exerciseProgramRepository.getLocalPrograms();

      final completedProgramId = widget.completedProgramId;
      UserCompletedProgram? completedProgram;
      ExerciseProgram? selectedProgram;
      List<UserCompletedExercise> completedExercises = [];

      if (completedProgramId != null) {
        completedProgram = await deps.userCompletedProgramRepository
            .getLocalCompletedProgramById(completedProgramId);
        if (completedProgram == null) {
          if (!mounted) return;
          setState(() {
            _error = 'Completed program not found.';
            _loading = false;
          });
          return;
        }

        selectedProgram = completedProgram.program.value ??
            _findProgramById(programs, completedProgram.programId);
        completedExercises = await deps.userCompletedExerciseRepository
            .getLocalCompletedExercises(completedProgram.id);
      }
      if (!mounted) return;
      setState(() {
        _userData = userData;
        _exercises = exercises;
        _program = selectedProgram;
        _completedProgram = completedProgram;
        _completedCache = completedExercises;
        _editControllers.clear();
        _loading = false;
      });
      if (completedProgram != null) {
        _syncProgramMetaEditors(
          program: selectedProgram,
          completedProgram: completedProgram,
        );
        _syncElapsedTimer();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to start training: $e';
        _loading = false;
      });
    }
  }

  Exercise? _findExercise(int? id) {
    if (id == null) return null;
    return _exercises.firstWhere(
      (ex) => ex.id == id,
      orElse: () => Exercise(id: id, name: 'Exercise $id', type: ''),
    );
  }

  ExerciseProgram? _findProgramById(List<ExerciseProgram> programs, int id) {
    for (final program in programs) {
      if (program.id == id) {
        return program;
      }
    }
    return null;
  }

  bool _isTimed(int? exerciseId) {
    final exercise = _findExercise(exerciseId);
    final type = exercise?.type.toLowerCase() ?? '';
    return type.contains('time') ||
        type.contains('timed') ||
        type == 'duration';
  }

  void _syncProgramMetaEditors({
    ExerciseProgram? program,
    UserCompletedProgram? completedProgram,
  }) {
    _programNameController.text = program?.name ?? '';
    _startDateController.text = _formatDateTimeInput(completedProgram?.startDate);
    _endDateController.text = _formatDateTimeInput(completedProgram?.endDate);
  }

  String? _parseDateInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    var normalized = trimmed;
    if (normalized.contains(' ') && !normalized.contains('T')) {
      normalized = normalized.replaceFirst(' ', 'T');
    }
    if (RegExp(r'\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}$')
        .hasMatch(normalized)) {
      normalized = '$normalized:00';
    }
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;
    return parsed.toUtc().toIso8601String();
  }

  Future<void> _saveProgramMeta({bool showFeedback = true}) async {
    if (_savingProgram) return;
    final program = _program;
    final completedProgram = _completedProgram;
    if (program == null || completedProgram == null) {
      return;
    }

    final name = _programNameController.text.trim();
    if (name.isEmpty) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program name is required')),
        );
      }
      return;
    }

    final startIso = _parseDateInput(_startDateController.text);
    if (startIso == null) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid start date')),
        );
      }
      return;
    }
    final endText = _endDateController.text.trim();
    final endIso = endText.isEmpty ? null : _parseDateInput(endText);
    if (endText.isNotEmpty && endIso == null) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid end date')),
        );
      }
      return;
    }

    final difficultyId =
        (program.difficultyLevel.isNotEmpty
                ? program.difficultyLevel.first.id
                : null) ??
        _userData?.trainingLevel.value?.id;
    if (difficultyId == null) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Difficulty level is required')),
        );
      }
      return;
    }

    setState(() {
      _savingProgram = true;
    });

    final deps = DependencyScope.of(context);
    try {
      final programPayload = ExerciseProgramPayloadDTO(
        name: name,
        description: program.description,
        difficultyLevelId: difficultyId,
        subscriptionId: null,
        userId: program.userId,
        fitnessGoalIds: program.fitnessGoals.map((g) => g.id).toList(),
        exercises: program.programExercises.map((pe) {
          return ProgramExerciseDTO(
            exerciseId: pe.exerciseId,
            order: pe.order,
            sets: pe.sets,
            reps: pe.reps,
            duration: pe.duration,
            restDuration: pe.restDuration,
          );
        }).toList(),
      );
      final updatedProgram =
          await deps.exerciseProgramRepository.updateLocalProgram(
        program.id,
        programPayload,
      );

      final completedPayload = UserCompletedProgramPayloadDTO(
        userId: completedProgram.userId,
        programId: completedProgram.programId,
        startDate: startIso,
        endDate: endIso,
      );
      final updatedCompleted = await deps.userCompletedProgramRepository.update(
        completedProgram.id,
        completedPayload,
        triggerSync: false,
      );

      if (!mounted) return;
      setState(() {
        _program = updatedProgram;
        _completedProgram =
            updatedCompleted ??
            UserCompletedProgram(
              id: completedProgram.id,
              userId: completedProgram.userId,
              programId: completedProgram.programId,
              startDate: startIso,
              endDate: endIso,
            );
      });
      _syncProgramMetaEditors(
        program: updatedProgram,
        completedProgram: _completedProgram,
      );
      _syncElapsedTimer();
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program updated')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update program: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingProgram = false;
        });
      }
    }
  }

  Future<void> _incrementSet(UserCompletedExercise item) async {
    final updatedSets = item.sets + 1;
    final payload = UserCompletedExercisePayloadDTO(
      completedProgramId: item.completedProgramId,
      programExerciseId: item.programExerciseId,
      exerciseId: item.exerciseId,
      sets: updatedSets,
      reps: item.reps,
      duration: item.duration,
      weight: item.weight,
      restDuration: item.restDuration,
    );

    final deps = DependencyScope.of(context);
    final repo = deps.userCompletedExerciseRepository;
    final programRepo = deps.userCompletedProgramRepository;
    await repo.update(item.id, payload, triggerSync: false);
    await programRepo.refreshLocalLinksForProgram(item.completedProgramId);
    final editors = _editControllers[item.id];
    if (editors != null) {
      editors.sets.text = updatedSets.toString();
    }
  }

  Future<void> _finishProgram() async {
    final completedProgram = _completedProgram;
    if (completedProgram == null) {
      return;
    }
    final deps = DependencyScope.of(context);

    setState(() {
      _endingProgram = true;
    });

    try {
      final completedExercises = await deps.userCompletedExerciseRepository
          .getLocalCompletedExercises(completedProgram.id);
      final program = _program;
      if (program != null && program.programExercises.isNotEmpty) {
        await _linkCompletedExercisesToProgramExercises(
          deps,
          program,
          completedExercises,
        );
      } else {
        await _syncProgramExercisesFromCompleted(deps);
      }

      final endIso = DateTime.now().toUtc().toIso8601String();
      final payload = UserCompletedProgramPayloadDTO(
        userId: completedProgram.userId,
        programId: completedProgram.programId,
        startDate: completedProgram.startDate,
        endDate: endIso,
      );

      await deps.userCompletedProgramRepository.update(
        completedProgram.id,
        payload,
        triggerSync: false,
      );

      if (!mounted) return;
      setState(() {
        _completedProgram = UserCompletedProgram(
          id: completedProgram.id,
          userId: completedProgram.userId,
          programId: completedProgram.programId,
          startDate: completedProgram.startDate,
          endDate: endIso,
        );
      });
      _syncProgramMetaEditors(
        program: _program,
        completedProgram: _completedProgram,
      );
      _endDateController.text = _formatDateTimeInput(endIso);
      _syncElapsedTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Workout finished')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to finish workout: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _endingProgram = false;
        });
      }
    }
  }

  Future<void> _syncProgramExercisesFromCompleted(Dependencies deps) async {
    final completedProgram = _completedProgram;
    final userData = _userData;
    if (completedProgram == null || userData == null || _program == null) {
      return;
    }

    final completedExercises = await deps.userCompletedExerciseRepository
        .getLocalCompletedExercises(completedProgram.id);

    if (completedExercises.isEmpty) return;

    final difficultyId =
        (_program?.difficultyLevel.isNotEmpty == true
                ? _program!.difficultyLevel.first.id
                : null) ??
            userData.trainingLevel.value?.id;
    if (difficultyId == null) return;

    final goalId = userData.fitnessGoal.value?.id;

    final exercisesPayload = completedExercises
        .asMap()
        .entries
        .map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return ProgramExerciseDTO(
            exerciseId:
                item.exerciseId ?? item.programExercise.value?.exerciseId ?? 0,
            order: idx,
            sets: item.sets,
            reps: item.reps,
            duration: item.duration,
            restDuration: item.restDuration ?? 0,
          );
        })
        .where((p) => p.exerciseId != 0)
        .toList();
    if (exercisesPayload.isEmpty) return;

    final payload = ExerciseProgramPayloadDTO(
      name: _program?.name ?? 'untitled program',
      description: _program?.description ?? 'Generated training',
      difficultyLevelId: difficultyId,
      subscriptionId: null,
      userId: userData.userId,
      fitnessGoalIds: goalId != null ? [goalId] : [],
      exercises: exercisesPayload,
    );


    final updated = await deps.exerciseProgramRepository.updateLocalProgram(
      _program!.id,
      payload,
    );

    final localProgram = await _getLocalProgramById(deps, _program!.id);
    if (localProgram != null) {
      await _linkCompletedExercisesToProgramExercises(
        deps,
        updated,
        completedExercises,
      );
    }
    await deps.userCompletedProgramRepository.refreshLocalLinksForProgram(
      completedProgram.id,
    );

    if (!mounted) return;
    setState(() {
      _program = localProgram ?? updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedProgram = _completedProgram;
    return Scaffold(
      appBar: AppBar(title: const Text('Training')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : completedProgram == null
          ? Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const TrainingStartScreen(),
                    ),
                  ),
                  child: const Text('Choose a program'),
                ),
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _programMetaEditor(),
                      StreamBuilder<List<UserCompletedExercise>>(
                        stream: DependencyScope.of(context)
                            .userCompletedExerciseRepository
                            .watchCompletedExercises(completedProgram.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data ?? const [];
                            if (data.isNotEmpty || _completedCache.isEmpty) {
                              _completedCache = data;
                            }
                          }

                          final items = snapshot.data ?? _completedCache;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (completedProgram.endDate != null) ...[
                                const SizedBox(height: 16),
                                _completedSummaryCard(items),
                              ],
                              const SizedBox(height: 16),
                              const Text(
                                'Completed Exercises',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCompletedExercisesList(snapshot, items),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: const Border(
                          top: BorderSide(color: Colors.white12),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.6),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _endingProgram ? null : _finishProgram,
                            icon: const Icon(Icons.flag),
                            label: _endingProgram
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Finish Workout'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCompletedExercisesList(
    AsyncSnapshot<List<UserCompletedExercise>> snapshot,
    List<UserCompletedExercise> items,
  ) {
    final waiting = snapshot.connectionState == ConnectionState.waiting;
    if (waiting && _completedCache.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: LinearProgressIndicator(),
      );
    }
    if (items.isEmpty) {
      return const Text('No exercises yet.');
    }
    return Column(
      children: items.map((item) {
        final isTimed = _isTimed(item.exerciseId);
        final editors = _getEditors(item, isTimed);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _findExercise(
                              item.exerciseId,
                            )?.name ??
                            'Exercise ${item.exerciseId ?? '-'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _incrementSet(item),
                      tooltip: 'Add set done',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_exerciseSubtitle(item)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _compactNumberField(
                      controller: editors.sets,
                      label: 'Sets',
                      onChanged: () => _scheduleInlineSave(item, editors, isTimed),
                    ),
                    const SizedBox(width: 8),
                    _compactNumberField(
                      controller: isTimed ? editors.duration : editors.reps,
                      label: isTimed ? 'Duration (s)' : 'Reps',
                      onChanged: () => _scheduleInlineSave(item, editors, isTimed),
                    ),
                    const SizedBox(width: 8),
                    _compactNumberField(
                      controller: editors.rest,
                      label: 'Rest (s)',
                      onChanged: () => _scheduleInlineSave(item, editors, isTimed),
                    ),
                    const SizedBox(width: 8),
                    _compactNumberField(
                      controller: editors.weight,
                      label: 'Weight',
                      onChanged: () => _scheduleInlineSave(item, editors, isTimed),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildDateTimeField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'YYYY-MM-DD HH:MM',
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(
    TextEditingController controller, {
    bool allowEmpty = false,
  }) async {
    final now = DateTime.now();
    final initial = _parseDateInput(controller.text) != null
        ? DateTime.parse(_parseDateInput(controller.text)!).toLocal()
        : now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null) {
      if (allowEmpty && controller.text.isNotEmpty) {
        controller.text = '';
        _scheduleProgramMetaSave();
      }
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;
    final value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    controller.text = _formatDateTimeInput(value.toIso8601String());
    _scheduleProgramMetaSave();
  }

  void _scheduleProgramMetaSave() {
    _programMetaDebounce?.cancel();
    _syncElapsedTimer();
    _programMetaDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _saveProgramMeta(showFeedback: false),
    );
  }

  String _formatDateTimeInput(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _showAddExerciseDialog() async {
    final completedProgram = _completedProgram;
    if (completedProgram == null) return;
    final deps = DependencyScope.of(context);
    final selectedIds = <int>{};
    var search = '';
    final selectedCategories = <int>{};
    final selectedDifficulties = <int>{};
    int? selectedMuscleId;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add exercises'),
              content: SizedBox(
                width: double.maxFinite,
                child: StreamBuilder<List<Exercise>>(
                  stream: deps.exerciseRepository.watchExercises(),
                  builder: (context, snapshot) {
                    final exercises = snapshot.data ?? const <Exercise>[];
                    final categoryMap = <int, ExerciseCategory>{};
                    final muscleMap = <int, MuscleGroup>{};
                    final difficultyMap = <int, DifficultyLevel>{};
                    for (final ex in exercises) {
                      final category = ex.category.value;
                      if (category != null) {
                        categoryMap[category.id] = category;
                      }
                      final muscle = ex.muscleGroup.value;
                      if (muscle != null) {
                        muscleMap[muscle.id] = muscle;
                      }
                      final difficulty = ex.difficultyLevel.value;
                      if (difficulty != null) {
                        difficultyMap[difficulty.id] = difficulty;
                      }
                    }

                    final filtered = exercises.where((ex) {
                      final name = ex.name.toLowerCase();
                      if (search.isNotEmpty &&
                          !name.contains(search.toLowerCase())) {
                        return false;
                      }
                      final categoryId = ex.category.value?.id;
                      if (selectedCategories.isNotEmpty &&
                          (categoryId == null ||
                              !selectedCategories.contains(categoryId))) {
                        return false;
                      }
                      final difficultyId = ex.difficultyLevel.value?.id;
                      if (selectedDifficulties.isNotEmpty &&
                          (difficultyId == null ||
                              !selectedDifficulties.contains(difficultyId))) {
                        return false;
                      }
                      final muscleId = ex.muscleGroup.value?.id;
                      if (selectedMuscleId != null &&
                          muscleId != selectedMuscleId) {
                        return false;
                      }
                      return true;
                    }).toList();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search by name',
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              search = value.trim();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: categoryMap.values.map((category) {
                            final isSelected =
                                selectedCategories.contains(category.id);
                            return FilterChip(
                              selected: isSelected,
                              label: Text(category.name),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    selectedCategories.add(category.id);
                                  } else {
                                    selectedCategories.remove(category.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Difficulty',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: difficultyMap.values.map((difficulty) {
                            final isSelected =
                                selectedDifficulties.contains(difficulty.id);
                            return FilterChip(
                              selected: isSelected,
                              label: Text(difficulty.name),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    selectedDifficulties.add(difficulty.id);
                                  } else {
                                    selectedDifficulties.remove(difficulty.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int?>(
                          value: selectedMuscleId,
                          decoration:
                              const InputDecoration(labelText: 'Muscle group'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All'),
                            ),
                            ...muscleMap.values.map(
                              (muscle) => DropdownMenuItem<int?>(
                                value: muscle.id,
                                child: Text(muscle.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedMuscleId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final ex = filtered[index];
                              final isSelected = selectedIds.contains(ex.id);
                              return ListTile(
                                title: Text(ex.name),
                                subtitle: Text(ex.type),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle)
                                    : const Icon(Icons.circle_outlined),
                                onTap: () {
                                  setDialogState(() {
                                    if (isSelected) {
                                      selectedIds.remove(ex.id);
                                    } else {
                                      selectedIds.add(ex.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                if (selectedIds.isNotEmpty)
                  ElevatedButton(
                    onPressed: () async {
                      final exercises = await deps.exerciseRepository
                          .getLocalExercises();
                      final toAdd = exercises
                          .where((ex) => selectedIds.contains(ex.id))
                          .toList();
                      await _addSelectedExercises(completedProgram.id, toAdd);
                      if (mounted) Navigator.of(context).pop();
                    },
                    child: Text('Add exercises (${selectedIds.length})'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addSelectedExercises(
    int completedProgramId,
    List<Exercise> exercises,
  ) async {
    if (exercises.isEmpty) return;
    final repo = DependencyScope.of(context).userCompletedExerciseRepository;
    for (final exercise in exercises) {
      final isTimed = _isTimed(exercise.id);
      final payload = UserCompletedExercisePayloadDTO(
        completedProgramId: completedProgramId,
        programExerciseId: null,
        exerciseId: exercise.id,
        sets: 1,
        reps: isTimed ? null : 10,
        duration: isTimed ? 60 : null,
        weight: 0,
        restDuration: 60,
      );
      await repo.create(payload, triggerSync: false);
    }
  }

  Widget _buildElapsedSection() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);
    String two(int v) => v.toString().padLeft(2, '0');
    const muted = TextStyle(color: Colors.white54, fontSize: 12);
    const numberStyle = TextStyle(fontSize: 34, fontWeight: FontWeight.bold);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Elapsed time', style: muted),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(two(hours), style: numberStyle),
                      const SizedBox(height: 4),
                      const Text('hours', style: muted),
                    ],
                  ),
                ),
                const Text(':', style: muted),
                Expanded(
                  child: Column(
                    children: [
                      Text(two(minutes), style: numberStyle),
                      const SizedBox(height: 4),
                      const Text('min', style: muted),
                    ],
                  ),
                ),
                const Text(':', style: muted),
                Expanded(
                  child: Column(
                    children: [
                      Text(two(seconds), style: numberStyle),
                      const SizedBox(height: 4),
                      const Text('sec', style: muted),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _syncElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    final completed = _completedProgram;
    final startIso =
        _parseDateInput(_startDateController.text) ?? completed?.startDate;
    if (startIso == null || startIso.isEmpty) {
      setState(() => _elapsed = Duration.zero);
      return;
    }
    final start = DateTime.tryParse(startIso);
    if (start == null) {
      setState(() => _elapsed = Duration.zero);
      return;
    }

    final endIso =
        _endDateController.text.trim().isNotEmpty
            ? _parseDateInput(_endDateController.text)
            : completed?.endDate;
    final end = endIso == null || endIso.isEmpty
        ? null
        : DateTime.tryParse(endIso);

    if (end != null) {
      final diff = end.toUtc().difference(start.toUtc());
      setState(() => _elapsed = diff.isNegative ? Duration.zero : diff);
      return;
    }

    void tick() {
      if (!mounted) return;
      final now = DateTime.now().toUtc();
      final diff = now.difference(start.toUtc());
      setState(() => _elapsed = diff.isNegative ? Duration.zero : diff);
    }

    tick();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Widget _programMetaEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _programNameController,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: 'Workout name',
            border: InputBorder.none,
          ),
          onChanged: (_) => _scheduleProgramMetaSave(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeField(
                label: 'Start date',
                controller: _startDateController,
                onTap: () => _pickDateTime(_startDateController),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeField(
                label: 'End date',
                controller: _endDateController,
                onTap: () => _pickDateTime(_endDateController, allowEmpty: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildElapsedSection(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showAddExerciseDialog,
            child: const Text('Add exercise'),
          ),
        ),
      ],
    );
  }

  String _exerciseSubtitle(UserCompletedExercise item) {
    final parts = <String>[];
    parts.add('Sets: ${item.sets}');
    if (item.reps != null) {
      parts.add('Reps: ${item.reps}');
    }
    if (item.duration != null) {
      parts.add('Duration: ${item.duration}s');
    }
    if (item.restDuration != null) {
      parts.add('Rest: ${item.restDuration}s');
    }
    if (item.weight != null) {
      parts.add('Weight: ${item.weight}');
    }
    return parts.join(' | ');
  }

  Widget _completedSummaryCard(List<UserCompletedExercise> exercises) {
    final completedProgram = _completedProgram;
    final programName = _program?.name ?? 'untitled program';
    final start = _formatDateTime(completedProgram?.startDate);
    final end = _formatDateTime(completedProgram?.endDate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Workout complete',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(programName, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('$start - $end'),
            const SizedBox(height: 12),
            const Text(
              'Completed exercises:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (exercises.isEmpty)
              const Text('No exercises logged.')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exercises.map((item) {
                  final name =
                      _findExercise(item.exerciseId)?.name ??
                      'Exercise ${item.exerciseId ?? '-'}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('- $name - ${_exerciseSummary(item)}'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(iso).toLocal();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${dateTime.year}-${two(dateTime.month)}-${two(dateTime.day)} '
          '${two(dateTime.hour)}:${two(dateTime.minute)}';
    } catch (_) {
      return iso;
    }
  }

  String _exerciseSummary(UserCompletedExercise item) {
    final parts = <String>[];
    parts.add('${item.sets} sets');
    if (item.reps != null) {
      parts.add('${item.reps} reps');
    }
    if (item.duration != null) {
      parts.add('${item.duration}s');
    }
    if (item.restDuration != null) {
      parts.add('rest ${item.restDuration}s');
    }
    if (item.weight != null) {
      parts.add('${item.weight} weight');
    }
    return parts.join(', ');
  }


  Future<ExerciseProgram?> _getLocalProgramById(
    Dependencies deps,
    int id,
  ) async {
    final programs = await deps.exerciseProgramRepository.getLocalPrograms();
    for (final program in programs) {
      if (program.id == id) {
        return program;
      }
    }
    return null;
  }

  Future<void> _linkCompletedExercisesToProgramExercises(
    Dependencies deps,
    ExerciseProgram program,
    List<UserCompletedExercise> completedExercises,
  ) async {
    if (completedExercises.isEmpty) return;
    final programExercisesByOrder = <int, ProgramExercise>{};
    for (final pe in program.programExercises) {
      final order = pe.order;
      if (order != null) {
        programExercisesByOrder[order] = pe;
      }
    }
    final usedProgramExerciseIds = <int>{};
    final repo = deps.userCompletedExerciseRepository;

    for (final entry in completedExercises.asMap().entries) {
      final item = entry.value;
      ProgramExercise? programExercise = programExercisesByOrder[entry.key];
      if (programExercise == null && item.exerciseId != null) {
        for (final pe in program.programExercises) {
          if (pe.exerciseId == item.exerciseId &&
              !usedProgramExerciseIds.contains(pe.id)) {
            programExercise = pe;
            break;
          }
        }
      }
      if (programExercise == null) continue;
      if (item.programExerciseId == programExercise.id) continue;
      usedProgramExerciseIds.add(programExercise.id);

      final payload = UserCompletedExercisePayloadDTO(
        completedProgramId: item.completedProgramId,
        programExerciseId: programExercise.id,
        exerciseId: item.exerciseId,
        sets: item.sets,
        reps: item.reps,
        duration: item.duration,
        weight: item.weight,
        restDuration: item.restDuration,
      );
      await repo.update(item.id, payload, triggerSync: false);
    }
  }

  _ExerciseEditors _getEditors(UserCompletedExercise item, bool isTimed) {
    final existing = _editControllers[item.id];
    if (existing != null) {
      existing.sets.text = item.sets.toString();
      existing.rest.text = (item.restDuration ?? 0).toString();
      existing.weight.text = (item.weight ?? 0).toString();
      if (isTimed) {
        existing.duration.text = (item.duration ?? 0).toString();
      } else {
        existing.reps.text = (item.reps ?? 0).toString();
      }
      return existing;
    }
    final editors = _ExerciseEditors(
      sets: TextEditingController(text: item.sets.toString()),
      reps: TextEditingController(text: (item.reps ?? 0).toString()),
      duration: TextEditingController(text: (item.duration ?? 0).toString()),
      rest: TextEditingController(text: (item.restDuration ?? 0).toString()),
      weight: TextEditingController(text: (item.weight ?? 0).toString()),
    );
    _editControllers[item.id] = editors;
    return editors;
  }

  Future<void> _saveInlineEdit(
    UserCompletedExercise item,
    _ExerciseEditors editors,
    bool isTimed, {
    bool showFeedback = true,
  }) async {
    final sets = int.tryParse(editors.sets.text) ?? item.sets;
    final rest = int.tryParse(editors.rest.text) ?? item.restDuration;
    final weight = int.tryParse(editors.weight.text) ?? item.weight;
    final reps = isTimed ? null : int.tryParse(editors.reps.text);
    final duration = isTimed ? int.tryParse(editors.duration.text) : null;

    final payload = UserCompletedExercisePayloadDTO(
      completedProgramId: item.completedProgramId,
      programExerciseId: item.programExerciseId,
      exerciseId: item.exerciseId,
      sets: sets,
      reps: reps,
      duration: duration,
      weight: weight,
      restDuration: rest,
    );

    try {
      final deps = DependencyScope.of(context);
      final repo = deps.userCompletedExerciseRepository;
      final programRepo = deps.userCompletedProgramRepository;
      await repo.update(item.id, payload, triggerSync: false);
      await programRepo.refreshLocalLinksForProgram(item.completedProgramId);
      if (!mounted) return;
      if (showFeedback) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Exercise updated')));
      }
    } catch (e) {
      if (!mounted) return;
      if (showFeedback) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  void _scheduleInlineSave(
    UserCompletedExercise item,
    _ExerciseEditors editors,
    bool isTimed,
  ) {
    _inlineSaveTimers[item.id]?.cancel();
    _inlineSaveTimers[item.id] = Timer(
      const Duration(milliseconds: 400),
      () => _saveInlineEdit(item, editors, isTimed, showFeedback: false),
    );
  }

  Widget _compactNumberField({
    required TextEditingController controller,
    required String label,
    VoidCallback? onChanged,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => onChanged?.call(),
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _ExerciseEditors {
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController duration;
  final TextEditingController rest;
  final TextEditingController weight;

  _ExerciseEditors({
    required this.sets,
    required this.reps,
    required this.duration,
    required this.rest,
    required this.weight,
  });

  void dispose() {
    sets.dispose();
    reps.dispose();
    duration.dispose();
    rest.dispose();
    weight.dispose();
  }
}
