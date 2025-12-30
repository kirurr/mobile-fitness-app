import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/plan_program_screen.dart';
import 'package:mobile_fitness_app/screens/training_start_screen.dart';
import 'package:mobile_fitness_app/widgets/schedule_cards.dart';

class PlannedProgramsScreen extends StatefulWidget {
  const PlannedProgramsScreen({super.key});

  @override
  State<PlannedProgramsScreen> createState() => _PlannedProgramsScreenState();
}

class _PlannedProgramsScreenState extends State<PlannedProgramsScreen> {
  List<ExerciseProgram> _initialPrograms = [];
  List<PlannedExerciseProgram> _initialPlans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final deps = DependencyScope.of(context);
    final programs = await deps.exerciseProgramRepository.getAllPrograms();
    final plans =
        await deps.plannedExerciseProgramRepository.getLocalPlannedPrograms();
    if (!mounted) return;
    setState(() {
      _initialPrograms = programs;
      _initialPlans = plans;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deps = DependencyScope.of(context);
    final plannedRepo = deps.plannedExerciseProgramRepository;
    final programRepo = deps.exerciseProgramRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planned Programs'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PlanProgramScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
            tooltip: 'Plan program',
          ),
        ],
      ),
      body: StreamBuilder<List<ExerciseProgram>>(
        stream: programRepo.watchAllPrograms(),
        initialData: _initialPrograms,
        builder: (context, programsSnapshot) {
          final programs = programsSnapshot.data ?? const <ExerciseProgram>[];
          final programById = {
            for (final program in programs) program.id: program,
          };

          return StreamBuilder<List<PlannedExerciseProgram>>(
            stream: plannedRepo.watchPlannedPrograms(),
            initialData: _initialPlans,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final items = snapshot.data ?? const <PlannedExerciseProgram>[];
              final entries = _expandPlannedDates(items, programById);

              if (entries.isEmpty) {
                return const Center(child: Text('No planned programs yet.'));
              }

              final grouped = _groupByMonth(entries);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: grouped.entries.expand((entry) {
                  final header = Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${entry.value.length} workouts',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  final cards = ScheduleCardsList(
                    entries: entry.value,
                    onTap: (scheduleEntry) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrainingStartScreen(
                          initialProgramId: scheduleEntry.planned.programId,
                        ),
                      ),
                    ),
                    footerBuilder: (context, scheduleEntry) {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlanProgramScreen(
                                plannedProgramId: scheduleEntry.planned.id,
                              ),
                            ),
                          ),
                          child: const Text('Edit plan'),
                        ),
                      );
                    },
                  );

                  return [
                    header,
                    cards,
                    const SizedBox(height: 12),
                  ];
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  List<ScheduleEntry> _expandPlannedDates(
    List<PlannedExerciseProgram> items,
    Map<int, ExerciseProgram> programById,
  ) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final entries = <ScheduleEntry>[];

    for (final item in items) {
      final dates = item.dates.toList();
      for (final planned in dates) {
        final parsed = _parseDate(planned.date);
        if (parsed == null) continue;
        if (parsed.isBefore(startOfToday)) continue;
        entries.add(
          ScheduleEntry(
            planned: item,
            date: parsed,
            program: programById[item.programId],
          ),
        );
      }
    }

    return entries;
  }

  Map<String, List<ScheduleEntry>> _groupByMonth(
    List<ScheduleEntry> entries,
  ) {
    final sorted = [...entries];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    final result = <String, List<ScheduleEntry>>{};
    for (final entry in sorted) {
      final key = _formatMonthYear(entry.date);
      result.putIfAbsent(key, () => []).add(entry);
    }
    return result;
  }

  DateTime? _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatMonthYear(DateTime date) {
    final month = _monthName(date.month);
    return '$month ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return 'Unknown';
    return months[month - 1];
  }
}
