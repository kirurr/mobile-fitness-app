import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/training_screen.dart';
import 'package:mobile_fitness_app/screens/training_start_screen.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';

class UserCompletedProgramsScreen extends StatelessWidget {
  const UserCompletedProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = DependencyScope.of(context);
    final completedRepo = deps.userCompletedProgramRepository;
    final programRepo = deps.exerciseProgramRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Programs'),
      ),
      body: FutureBuilder<List<ExerciseProgram>>(
        future: programRepo.getLocalPrograms(),
        builder: (context, programsSnapshot) {
          final programs = programsSnapshot.data ?? const <ExerciseProgram>[];
          final programById = {
            for (final program in programs) program.id: program,
          };

          return StreamBuilder<List<UserCompletedProgram>>(
            stream: completedRepo.watchCompletedPrograms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('No completed programs yet.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final programName = item.program.value?.name ??
                      programById[item.programId]?.name ??
                      'Program';
                  final exerciseCount = item.completedExercises.length;
                  final start = _formatDateTime(item.startDate);
                  final end = _formatDateTime(item.endDate);
                  final isCompleted = item.endDate != null;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(programName),
                            subtitle: Text(
                              'Start: $start\n'
                              'End: $end\n'
                              'Exercises: $exerciseCount',
                            ),
                            trailing: Icon(
                              isCompleted ? Icons.check_circle : Icons.timelapse,
                              color: isCompleted ? Colors.green : Colors.orange,
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TrainingScreen(
                                  completedProgramId: item.id,
                                ),
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TrainingStartScreen(
                                          initialProgramId: item.programId,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Repeat Program'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TrainingScreen(
                                          completedProgramId: item.id,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Edit Program'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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
}
