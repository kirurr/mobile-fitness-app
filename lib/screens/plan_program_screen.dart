import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/dto.dart';
import 'package:mobile_fitness_app/widgets/program_card.dart';

class PlanProgramScreen extends StatefulWidget {
  final int? plannedProgramId;

  const PlanProgramScreen({super.key, this.plannedProgramId});

  @override
  State<PlanProgramScreen> createState() => _PlanProgramScreenState();
}

class _PlanProgramScreenState extends State<PlanProgramScreen> {
  bool _saving = false;
  ExerciseProgram? _selectedProgram;
  PlannedExerciseProgram? _editingPlan;
  final Set<DateTime> _selectedDates = {};
  List<ExerciseProgram> _initialPrograms = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlan();
      _loadInitialPrograms();
    });
  }

  Future<void> _loadPlan() async {
    final deps = DependencyScope.of(context);
    PlannedExerciseProgram? existingPlan;
    if (widget.plannedProgramId != null) {
      existingPlan = await deps.plannedExerciseProgramRepository
          .getLocalPlannedProgramById(widget.plannedProgramId!);
    }
    if (!mounted) return;
    setState(() {
      _editingPlan = existingPlan;
    });
    if (existingPlan != null) {
      _syncSelectedDates(existingPlan);
    }
  }

  Future<void> _loadInitialPrograms() async {
    final deps = DependencyScope.of(context);
    final programs = await deps.exerciseProgramRepository.getLocalPrograms();
    if (!mounted) return;
    setState(() {
      _initialPrograms = programs;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _selectedDates.add(
        DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        ),
      );
    });
  }

  void _removeDate(DateTime date) {
    setState(() {
      _selectedDates.remove(date);
    });
  }

  Future<void> _savePlan() async {
    if (_saving) return;
    final program = _selectedProgram;
    if (program == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a program')));
      return;
    }
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select at least one date')));
      return;
    }

    final dates = _selectedDates
        .map((d) => d.toUtc().toIso8601String())
        .toList()
      ..sort();

    setState(() {
      _saving = true;
    });

    try {
      final payload = PlannedExerciseProgramPayloadDTO(
        programId: program.id,
        dates: dates,
      );
      final repo = DependencyScope.of(context).plannedExerciseProgramRepository;
      final editingPlan = _editingPlan;
      if (editingPlan == null) {
        await repo.create(payload);
      } else {
        await repo.update(editingPlan.id, payload);
      }
      if (!mounted) return;
      setState(() {
        if (_editingPlan == null) {
          _selectedDates.clear();
        } else {
          _editingPlan = PlannedExerciseProgram(
            id: _editingPlan!.id,
            programId: program.id,
            synced: _editingPlan!.synced,
            pendingDelete: _editingPlan!.pendingDelete,
            isLocalOnly: _editingPlan!.isLocalOnly,
          );
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Plan saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save plan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _selectedDates.toList()
      ..sort((a, b) => a.compareTo(b));
    final isEditing = _editingPlan != null;
    final deps = DependencyScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Plan' : 'Plan Program'),
      ),
      body: StreamBuilder<List<ExerciseProgram>>(
              stream: deps.exerciseProgramRepository.watchPrograms(),
              initialData: _initialPrograms,
              builder: (context, snapshot) {
                final programs = snapshot.data ?? const <ExerciseProgram>[];
                if (programs.isEmpty) {
                  return const Center(child: Text('No programs available'));
                }
                ExerciseProgram? resolved = _selectedProgram;
                if (resolved == null ||
                    !programs.any((p) => p.id == resolved!.id)) {
                  resolved = _resolveSelectedProgram(programs, _editingPlan);
                }
                if (_selectedProgram?.id != resolved?.id) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _selectedProgram = resolved;
                    });
                  });
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose a program',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: programs.map((program) {
                          final subscription =
                              program.subscription.isNotEmpty
                                  ? program.subscription.first
                                  : null;
                          final difficulty =
                              program.difficultyLevel.isNotEmpty
                                  ? program.difficultyLevel.first
                                  : null;
                          return ProgramCard(
                            title: program.name,
                            description: program.description,
                            durationText: _formatProgramDuration(program),
                            exerciseCount: program.programExercises.length,
                            subscriptionName: subscription?.name ?? 'Free',
                            isFree: subscription == null,
                            difficultyName: difficulty?.name ?? '-',
                            isSelected: resolved?.id == program.id,
                            onTap: () => setState(
                              () => _selectedProgram = program,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Planned dates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (dates.isEmpty)
                        const Text('No dates selected')
                      else
                        Column(
                          children: dates
                              .map(
                                (date) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(_formatDate(date)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeDate(date),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _pickDate,
                          child: const Text('Add date & time'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _savePlan,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(isEditing ? 'Save changes' : 'Save plan'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  ExerciseProgram? _resolveSelectedProgram(
    List<ExerciseProgram> programs,
    PlannedExerciseProgram? plan,
  ) {
    if (programs.isEmpty) return null;
    if (plan == null) return programs.first;
    for (final program in programs) {
      if (program.id == plan.programId) {
        return program;
      }
    }
    return programs.first;
  }

  void _syncSelectedDates(PlannedExerciseProgram plan) {
    _selectedDates
      ..clear()
      ..addAll(
        plan.dates.map((d) => DateTime.tryParse(d.date)).whereType<DateTime>(),
      );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String two(int v) => v.toString().padLeft(2, '0');
    final month = (date.month >= 1 && date.month <= 12)
        ? months[date.month - 1]
        : '??';
    return '$month ${date.day}, ${two(date.hour)}:${two(date.minute)}';
  }

  String _formatProgramDuration(ExerciseProgram program) {
    final exercises = program.programExercises.toList();
    int totalSeconds = 0;
    for (final item in exercises) {
      final sets = item.sets;
      final duration = item.duration ?? 0;
      final rest = item.restDuration;
      totalSeconds += duration * sets;
      if (rest > 0 && sets > 1) {
        totalSeconds += rest * (sets - 1);
      }
    }

    final totalMinutes = (totalSeconds / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '${minutes} m';
    if (minutes == 0) return '${hours} h';
    return '${hours} h ${minutes} m';
  }
}
