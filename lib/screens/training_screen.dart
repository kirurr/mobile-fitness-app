import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/app/dependencies.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/user_subscriptions_screen.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'package:mobile_fitness_app/user_data/model.dart';

class TrainingScreen extends StatefulWidget {
  final int? completedProgramId;
  final int? initialProgramId;

  const TrainingScreen({super.key, this.completedProgramId, this.initialProgramId});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  ExerciseProgram? _program;
  UserCompletedProgram? _completedProgram;
  UserData? _userData;
  List<Exercise> _exercises = [];
  List<ExerciseProgram> _availablePrograms = [];
  ExerciseProgram? _selectedProgram;
  List<UserSubscription> _userSubscriptions = [];
  List<UserCompletedExercise> _currentCompletedExercises = [];
  final Map<int, _ExerciseEditors> _editControllers = {};
  List<UserCompletedExercise> _completedCache = [];

  bool _loading = true;
  bool _savingExercise = false;
  bool _endingProgram = false;
  bool _startingProgram = false;
  bool _startingCustomProgram = false;
  bool _savingProgram = false;
  String? _error;

  int? _selectedExerciseId;
  final TextEditingController _setsController = TextEditingController(
    text: '1',
  );
  final TextEditingController _repsController = TextEditingController(
    text: '10',
  );
  final TextEditingController _durationController = TextEditingController(
    text: '30',
  );
  final TextEditingController _restController = TextEditingController(
    text: '60',
  );
  final TextEditingController _weightController = TextEditingController(
    text: '0',
  );
  final TextEditingController _programNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _restController.dispose();
    _weightController.dispose();
    _programNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    for (final entry in _editControllers.values) {
      entry.dispose();
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
      final userSubscriptions =
          await deps.userSubscriptionRepository.getLocalUserSubscriptions();

      final completedProgramId = widget.completedProgramId;
      final initialProgramId = widget.initialProgramId;
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
      } else if (initialProgramId != null) {
        selectedProgram = _findProgramById(programs, initialProgramId);
      }

      if (!mounted) return;
      setState(() {
        _userData = userData;
        _exercises = exercises;
        _availablePrograms = programs;
        _selectedProgram =
            selectedProgram ?? (programs.isNotEmpty ? programs.first : null);
        _program = selectedProgram;
        _completedProgram = completedProgram;
        _currentCompletedExercises = completedExercises;
        _completedCache = completedExercises;
        _userSubscriptions = userSubscriptions;
        _selectedExerciseId = null;
        _editControllers.clear();
        _loading = false;
      });
      _syncProgramMetaEditors(
        program: selectedProgram,
        completedProgram: completedProgram,
      );
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

  void _syncProgramMetaEditors({
    ExerciseProgram? program,
    UserCompletedProgram? completedProgram,
  }) {
    _programNameController.text = program?.name ?? '';
    _startDateController.text = completedProgram?.startDate ?? '';
    _endDateController.text = completedProgram?.endDate ?? '';
  }

  String? _parseDateInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) return null;
    return parsed.toUtc().toIso8601String();
  }

  Future<void> _saveProgramMeta() async {
    final program = _program;
    final completedProgram = _completedProgram;
    if (program == null || completedProgram == null) {
      return;
    }

    final name = _programNameController.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program name is required')),
      );
      return;
    }

    final startIso = _parseDateInput(_startDateController.text);
    if (startIso == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid start date')),
      );
      return;
    }
    final endText = _endDateController.text.trim();
    final endIso = endText.isEmpty ? null : _parseDateInput(endText);
    if (endText.isNotEmpty && endIso == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid end date')),
      );
      return;
    }

    final difficultyId =
        (program.difficultyLevel.isNotEmpty
                ? program.difficultyLevel.first.id
                : null) ??
        _userData?.trainingLevel.value?.id;
    if (difficultyId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Difficulty level is required')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program updated')),
      );
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

  void _prefillFromExisting(int? exerciseId) {
    if (exerciseId == null) return;
    final existing = _currentCompletedExercises.firstWhere(
      (c) => c.exerciseId == exerciseId,
      orElse: () => UserCompletedExercise(
        id: -1,
        completedProgramId: _completedProgram?.id ?? -1,
        programExerciseId: null,
        exerciseId: exerciseId,
        sets: 1,
        reps: null,
        duration: null,
        weight: null,
        restDuration: null,
      ),
    );

    _setsController.text = existing.sets.toString();
    _restController.text = (existing.restDuration ?? 60).toString();
    _weightController.text = (existing.weight ?? 0).toString();
    final isTimed = _isTimed(exerciseId);
    if (isTimed) {
      _durationController.text = (existing.duration ?? 30).toString();
    } else {
      _repsController.text = (existing.reps ?? 10).toString();
    }
  }

  bool _isTimed(int? exerciseId) {
    final exercise = _findExercise(exerciseId);
    final type = exercise?.type.toLowerCase() ?? '';
    return type.contains('time') ||
        type.contains('timed') ||
        type == 'duration';
  }

  bool _isTimedSelected() {
    return _isTimed(_selectedExerciseId);
  }

  Future<void> _saveExercise() async {
    final completedProgram = _completedProgram;
    if (completedProgram == null || _selectedExerciseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select an exercise first')));
      return;
    }

    final sets = int.tryParse(_setsController.text) ?? 1;
    final rest = int.tryParse(_restController.text);
    final isTimed = _isTimedSelected();
    final reps = isTimed ? null : int.tryParse(_repsController.text);
    final duration = isTimed ? int.tryParse(_durationController.text) : null;
    final weight = int.tryParse(_weightController.text);

    final existing = _currentCompletedExercises.firstWhere(
      (c) => c.exerciseId == _selectedExerciseId,
      orElse: () => UserCompletedExercise(
        id: -1,
        completedProgramId: completedProgram.id,
        programExerciseId: null,
        exerciseId: _selectedExerciseId,
        sets: 0,
        reps: null,
        duration: null,
        weight: null,
        restDuration: null,
      ),
    );

    final payload = UserCompletedExercisePayloadDTO(
      completedProgramId: completedProgram.id,
      programExerciseId: existing.programExerciseId,
      exerciseId: _selectedExerciseId,
      sets: sets,
      reps: reps,
      duration: duration,
      weight: weight ?? existing.weight,
      restDuration: rest,
    );

    setState(() {
      _savingExercise = true;
    });

    try {
      final repo = DependencyScope.of(context).userCompletedExerciseRepository;
      final programRepo =
          DependencyScope.of(context).userCompletedProgramRepository;
      if (existing.id == -1) {
        await repo.create(payload, triggerSync: false);
      } else {
        await repo.update(existing.id, payload, triggerSync: false);
      }
      await programRepo.refreshLocalLinksForProgram(completedProgram.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing.id == -1 ? 'Exercise added' : 'Exercise updated',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save exercise: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _savingExercise = false;
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

      final payload = UserCompletedProgramPayloadDTO(
        userId: completedProgram.userId,
        programId: completedProgram.programId,
        startDate: completedProgram.startDate,
        endDate: DateTime.now().toUtc().toIso8601String(),
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
          endDate: payload.endDate,
        );
      });
      _syncProgramMetaEditors(
        program: _program,
        completedProgram: _completedProgram,
      );
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
          ? _programSelection()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _programInfo(),
                  const SizedBox(height: 16),
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
                          _currentCompletedExercises = data;
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
                          _addExerciseCard(),
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _endingProgram ? null : _finishProgram,
                              child: _endingProgram
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
                        ],
                      );
                    },
                  ),
                ],
              ),
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
                    ),
                    const SizedBox(width: 8),
                    _compactNumberField(
                      controller: isTimed ? editors.duration : editors.reps,
                      label: isTimed ? 'Duration (s)' : 'Reps',
                    ),
                    const SizedBox(width: 8),
                    _compactNumberField(
                      controller: editors.rest,
                      label: 'Rest (s)',
                    ),
                    const SizedBox(width: 8),
                    _compactNumberField(
                      controller: editors.weight,
                      label: 'Weight',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _saveInlineEdit(
                      item,
                      editors,
                      isTimed,
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _programInfo() {
    final programGoals = _program?.fitnessGoals
            .map((goal) => goal.name)
            .toList(growable: false) ??
        const <String>[];
    final goalText = programGoals.isNotEmpty
        ? programGoals.join(', ')
        : (_userData?.fitnessGoal.value?.name ?? '-');
    final difficulty =
        (_program?.difficultyLevel.isNotEmpty == true
                ? _program!.difficultyLevel.first.name
                : null) ??
        _userData?.trainingLevel.value?.name ??
        '-';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Workout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Program: ${_program?.name ?? 'untitled program'}'),
            Text('Started: ${_formatDateTime(_completedProgram?.startDate)}'),
            Text('Goal: $goalText'),
            Text('Difficulty: $difficulty'),
          ],
        ),
      ),
    );
  }

  Future<void> _startSelectedProgram() async {
    final userData = _userData;
    final program = _selectedProgram;
    if (userData == null || program == null) return;
    if (!_hasSubscriptionAccess(program)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription required to start workout')),
      );
      return;
    }

    setState(() {
      _startingProgram = true;
    });

    try {
      final deps = DependencyScope.of(context);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final completedProgramPayload = UserCompletedProgramPayloadDTO(
        userId: userData.userId,
        programId: program.id,
        startDate: nowIso,
        endDate: null,
      );

      final createdCompletedProgram = await deps.userCompletedProgramRepository
          .create(completedProgramPayload, triggerSync: false);

      final completedExerciseRepo = deps.userCompletedExerciseRepository;
      for (final programExercise in program.programExercises) {
        final payload = UserCompletedExercisePayloadDTO(
          completedProgramId: createdCompletedProgram.id,
          programExerciseId: programExercise.id,
          exerciseId: programExercise.exerciseId,
          sets: programExercise.sets,
          reps: programExercise.reps,
          duration: programExercise.duration,
          weight: null,
          restDuration: programExercise.restDuration,
        );
        await completedExerciseRepo.create(payload, triggerSync: false);
      }

      await deps.userCompletedProgramRepository.refreshLocalLinksForProgram(
        createdCompletedProgram.id,
      );
      final completedExercises = await completedExerciseRepo
          .getLocalCompletedExercises(createdCompletedProgram.id);

      if (!mounted) return;
      setState(() {
        _program = program;
        _completedProgram = createdCompletedProgram;
        _currentCompletedExercises = completedExercises;
        _completedCache = completedExercises;
        _selectedExerciseId = null;
        _editControllers.clear();
      });
      _syncProgramMetaEditors(
        program: program,
        completedProgram: createdCompletedProgram,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to start workout: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _startingProgram = false;
        });
      }
    }
  }

  Future<void> _startCustomProgram() async {
    final userData = _userData;
    if (userData == null) return;

    final difficultyId = userData.trainingLevel.value?.id;
    if (difficultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Training level not set for user.')),
      );
      return;
    }

    setState(() {
      _startingCustomProgram = true;
    });

    try {
      final deps = DependencyScope.of(context);
      final fitnessGoalId = userData.fitnessGoal.value?.id;
      final programPayload = ExerciseProgramPayloadDTO(
        name: 'untitled program',
        description: 'Generated training',
        difficultyLevelId: difficultyId,
        subscriptionId: null,
        userId: userData.userId,
        fitnessGoalIds: fitnessGoalId != null ? [fitnessGoalId] : [],
        exercises: const [],
      );

      final createdProgram =
          await deps.exerciseProgramRepository.createLocalProgram(programPayload);

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final completedProgramPayload = UserCompletedProgramPayloadDTO(
        userId: userData.userId,
        programId: createdProgram.id,
        startDate: nowIso,
        endDate: null,
      );

      final createdCompletedProgram = await deps.userCompletedProgramRepository
          .create(completedProgramPayload, triggerSync: false);

      if (!mounted) return;
      setState(() {
        _program = createdProgram;
        _completedProgram = createdCompletedProgram;
        _currentCompletedExercises = [];
        _completedCache = [];
        _selectedExerciseId = null;
        _editControllers.clear();
      });
      _syncProgramMetaEditors(
        program: createdProgram,
        completedProgram: createdCompletedProgram,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to start workout: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _startingCustomProgram = false;
        });
      }
    }
  }

  Widget _addExerciseCard() {
    final isTimed = _isTimedSelected();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add / Update Exercise',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              decoration: const InputDecoration(labelText: 'Exercise'),
              initialValue: _selectedExerciseId,
              items: _exercises
                  .map(
                    (ex) => DropdownMenuItem<int?>(
                      value: ex.id,
                      child: Text('${ex.name} (${ex.type})'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedExerciseId = val);
                _prefillFromExisting(val);
              },
            ),
            TextField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sets completed'),
            ),
            TextField(
              controller: isTimed ? _durationController : _repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isTimed ? 'Duration (seconds)' : 'Reps',
              ),
            ),
            TextField(
              controller: _restController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rest (seconds)'),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weight (optional)'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savingExercise ? null : _saveExercise,
                child: _savingExercise
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _programSelection() {
    if (_availablePrograms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No programs available. Please sync or create one.'),
            const SizedBox(height: 16),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: _startingCustomProgram ? null : _startCustomProgram,
                child: _startingCustomProgram
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Start Custom Workout'),
              ),
            ),
          ],
        ),
      );
    }

    final selected = _selectedProgram;
    final hasExercises = selected?.programExercises.isNotEmpty ?? false;
    final requiredSubscription =
        selected?.subscription.isNotEmpty == true
            ? selected!.subscription.first
            : null;
    final hasSubscriptionAccess =
        selected != null ? _hasSubscriptionAccess(selected) : false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose a program',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ExerciseProgram>(
            decoration: const InputDecoration(labelText: 'Program'),
            initialValue: _selectedProgram,
            items: _availablePrograms
                .map(
                  (program) => DropdownMenuItem<ExerciseProgram>(
                    value: program,
                    child: Text(program.name),
                  ),
                )
                .toList(),
            onChanged: (program) {
              setState(() => _selectedProgram = program);
            },
          ),
          if (requiredSubscription != null && !hasSubscriptionAccess) ...[
            const SizedBox(height: 12),
            Text(
              'Requires subscription: ${requiredSubscription.name}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserSubscriptionsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Оформить подписку ${requiredSubscription.name}',
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _selectedProgram == null
              ? const Text('Select a program to start.')
              : _programPreview(_selectedProgram!),
          const SizedBox(height: 16),
          if (selected != null && !hasExercises)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Selected program has no exercises.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _startingProgram || !hasExercises || !hasSubscriptionAccess
                      ? null
                      : _startSelectedProgram,
              child: _startingProgram
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Workout'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startingCustomProgram ? null : _startCustomProgram,
              child: _startingCustomProgram
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Custom Workout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _programPreview(ExerciseProgram program) {
    final goals = program.fitnessGoals
        .map((goal) => goal.name)
        .toList(growable: false);
    final goalText = goals.isNotEmpty ? goals.join(', ') : '-';
    final difficulty =
        program.difficultyLevel.isNotEmpty
            ? program.difficultyLevel.first.name
            : '-';
    final exerciseCount = program.programExercises.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(program.description),
            const SizedBox(height: 8),
            Text('Difficulty: $difficulty'),
            Text('Goal: $goalText'),
            Text('Exercises: $exerciseCount'),
          ],
        ),
      ),
    );
  }

  Widget _programMetaEditor() {
    final endDateLabel = _completedProgram?.endDate == null
        ? 'End date (optional)'
        : 'End date';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Program',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _programNameController,
              decoration: const InputDecoration(labelText: 'Program name'),
            ),
            TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Start date',
                hintText: 'YYYY-MM-DDTHH:MM:SSZ',
              ),
            ),
            TextField(
              controller: _endDateController,
              decoration: InputDecoration(
                labelText: endDateLabel,
                hintText: 'YYYY-MM-DDTHH:MM:SSZ',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savingProgram ? null : _saveProgramMeta,
                child: _savingProgram
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
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

  bool _hasSubscriptionAccess(ExerciseProgram program) {
    final requiredSubscription =
        program.subscription.isNotEmpty ? program.subscription.first : null;
    if (requiredSubscription == null) return true;
    final userData = _userData;
    if (userData == null) return false;

    final nowUtc = DateTime.now().toUtc();
    for (final sub in _userSubscriptions) {
      if (sub.userId != userData.userId || sub.pendingDelete) continue;
      final linked = sub.subscription.value;
      if (linked == null || linked.id != requiredSubscription.id) continue;
      if (_isSubscriptionActive(sub, nowUtc)) return true;
    }
    return false;
  }

  bool _isSubscriptionActive(UserSubscription sub, DateTime nowUtc) {
    final start = DateTime.tryParse(sub.startDate);
    final end = DateTime.tryParse(sub.endDate);
    if (start == null || end == null) return false;
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    if (nowUtc.isBefore(startUtc)) return false;
    if (nowUtc.isAfter(endUtc)) return false;
    return true;
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
    bool isTimed,
  ) async {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exercise updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  Widget _compactNumberField({
    required TextEditingController controller,
    required String label,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
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
