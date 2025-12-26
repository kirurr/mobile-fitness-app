import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/plan_program_screen.dart';

class PlannedProgramsScreen extends StatelessWidget {
  const PlannedProgramsScreen({super.key});

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
      body: FutureBuilder<List<ExerciseProgram>>(
        future: programRepo.getLocalPrograms(),
        builder: (context, programsSnapshot) {
          final programs = programsSnapshot.data ?? const <ExerciseProgram>[];
          final programById = {
            for (final program in programs) program.id: program,
          };

          return StreamBuilder<List<PlannedExerciseProgram>>(
            stream: plannedRepo.watchPlannedPrograms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('No planned programs yet.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final programName = item.program.value?.name ??
                      programById[item.programId]?.name ??
                      'Program';
                  final dates = item.dates.toList()
                    ..sort((a, b) => a.date.compareTo(b.date));
                  final datesText = dates.isEmpty
                      ? '-'
                      : dates
                          .map((d) => _formatDateTime(d.date))
                          .join(', ');

                  return Card(
                    child: ListTile(
                      title: Text(programName),
                      subtitle: Text('Planned dates: $datesText'),
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
