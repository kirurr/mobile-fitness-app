import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/training_screen.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';

class UserCompletedProgramsScreen extends StatefulWidget {
  const UserCompletedProgramsScreen({super.key});

  @override
  State<UserCompletedProgramsScreen> createState() =>
      _UserCompletedProgramsScreenState();
}

class _UserCompletedProgramsScreenState
    extends State<UserCompletedProgramsScreen> {
  List<ExerciseProgram> _initialPrograms = [];
  List<UserCompletedProgram> _initialCompleted = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final deps = DependencyScope.of(context);
    final programs = await deps.exerciseProgramRepository.getAllPrograms();
    final completed =
        await deps.userCompletedProgramRepository.getLocalCompletedPrograms();
    if (!mounted) return;
    setState(() {
      _initialPrograms = programs;
      _initialCompleted = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deps = DependencyScope.of(context);
    final completedRepo = deps.userCompletedProgramRepository;
    final programRepo = deps.exerciseProgramRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Programs'),
      ),
      body: StreamBuilder<List<ExerciseProgram>>(
        stream: programRepo.watchAllPrograms(),
        initialData: _initialPrograms,
        builder: (context, programsSnapshot) {
          final programs = programsSnapshot.data ?? const <ExerciseProgram>[];
          final programById = {
            for (final program in programs) program.id: program,
          };

          return StreamBuilder<List<UserCompletedProgram>>(
            stream: completedRepo.watchCompletedPrograms(),
            initialData: _initialCompleted,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('No completed programs yet.'));
              }

              final grouped = _groupByMonth(items);

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

                  final cards = entry.value.map((item) {
                    final programName = item.program.value?.name ??
                        programById[item.programId]?.name ??
                        'Program';
                    final exerciseCount = item.completedExercises.length;
                    final startText = _formatStartDate(item.startDate);
                    final durationText =
                        _formatDuration(item.startDate, item.endDate);
                    final isCompleted = item.endDate != null;
                    final statusIcon =
                        isCompleted ? Icons.check_circle : Icons.timelapse;
                    final statusColor =
                        isCompleted ? Colors.green : Colors.orange;

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrainingScreen(
                              completedProgramId: item.id,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            programName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          statusIcon,
                                          color: statusColor,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    startText,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    durationText,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    Icons.fitness_center,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$exerciseCount exercises',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });

                  return [
                    header,
                    ...cards,
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

  Map<String, List<UserCompletedProgram>> _groupByMonth(
    List<UserCompletedProgram> items,
  ) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final aDate = _parseDate(a.startDate) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = _parseDate(b.startDate) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    final result = <String, List<UserCompletedProgram>>{};
    for (final item in sorted) {
      final date = _parseDate(item.startDate);
      final key = date == null ? 'Unknown' : _formatMonthYear(date);
      result.putIfAbsent(key, () => []).add(item);
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

  String _formatStartDate(String? iso) {
    final dateTime = _parseDate(iso);
    if (dateTime == null) return '-';
    String two(int v) => v.toString().padLeft(2, '0');
    final month = _monthName(dateTime.month);
    return '$month ${dateTime.day}, ${two(dateTime.hour)}:${two(dateTime.minute)}';
  }

  String _formatDuration(String? startIso, String? endIso) {
    final start = _parseDate(startIso);
    if (start == null) return '-';
    final end = endIso == null || endIso.isEmpty
        ? DateTime.now()
        : _parseDate(endIso);
    if (end == null) return '-';
    final diff = end.difference(start);
    final totalMinutes = diff.inMinutes;
    if (totalMinutes < 1) return '< 1 min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '$minutes min';
    if (minutes == 0) return '$hours h';
    return '$hours h $minutes min';
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
