import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/dto.dart';

class PlanProgramScreen extends StatefulWidget {
  const PlanProgramScreen({super.key});

  @override
  State<PlanProgramScreen> createState() => _PlanProgramScreenState();
}

class _PlanProgramScreenState extends State<PlanProgramScreen> {
  bool _loadingPrograms = true;
  bool _saving = false;
  List<ExerciseProgram> _programs = [];
  ExerciseProgram? _selectedProgram;
  final Set<DateTime> _selectedDates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPrograms());
  }

  Future<void> _loadPrograms() async {
    final deps = DependencyScope.of(context);
    final programs = await deps.exerciseProgramRepository.getLocalPrograms();
    if (!mounted) return;
    setState(() {
      _programs = programs;
      _selectedProgram = programs.isNotEmpty ? programs.first : null;
      _loadingPrograms = false;
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
      await DependencyScope.of(context)
          .plannedExerciseProgramRepository
          .create(payload);
      if (!mounted) return;
      setState(() {
        _selectedDates.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Plan saved')));
    } catch (e, stackTrace) {
      print('PlanProgramScreen._savePlan failed: $e\n$stackTrace');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Program'),
      ),
      body: _loadingPrograms
          ? const Center(child: CircularProgressIndicator())
          : _programs.isEmpty
          ? const Center(child: Text('No programs available'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Program',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ExerciseProgram>(
                    value: _selectedProgram,
                    items: _programs
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
                    decoration: const InputDecoration(labelText: 'Program'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Planned dates',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save plan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}
