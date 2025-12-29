import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/app_shell.dart';
import 'package:mobile_fitness_app/screens/training_screen.dart';

class CompletedTrainingScreen extends StatelessWidget {
  final int completedProgramId;
  final int programId;
  final String programName;
  final String startDate;
  final String endDate;
  final int exerciseCount;

  const CompletedTrainingScreen({
    super.key,
    required this.completedProgramId,
    required this.programId,
    required this.programName,
    required this.startDate,
    required this.endDate,
    required this.exerciseCount,
  });

  @override
  Widget build(BuildContext context) {
    final durationText = _formatDuration(startDate, endDate);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.45),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Workout completed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                programName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${_formatShortDate(startDate)} - ${_formatShortDate(endDate)}',
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: durationText,
                    iconColor: primary,
                    valueColor: primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.fitness_center,
                    label: 'Exercises',
                    value: '$exerciseCount',
                    iconColor: primary,
                    valueColor: primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrainingScreen(
                      completedProgramId: completedProgramId,
                      showCompletedScreen: false,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Edit workout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<ExerciseProgram>>(
              stream: DependencyScope.of(context)
                  .exerciseProgramRepository
                  .watchAllPrograms(),
              initialData: const <ExerciseProgram>[],
              builder: (context, snapshot) {
                final programs =
                    snapshot.data ?? const <ExerciseProgram>[];
                ExerciseProgram? found;
                for (final program in programs) {
                  if (program.id == programId) {
                    found = program;
                    break;
                  }
                }
                final isAdded = found?.isUserAdded == true;

                return OutlinedButton(
                  onPressed: found == null
                      ? null
                      : () async {
                        final repo = DependencyScope.of(context)
                            .exerciseProgramRepository;
                        final nextValue = !isAdded;
                        final saved = await repo.markProgramUserAdded(
                          programId,
                          isUserAdded: nextValue,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              saved
                                  ? (nextValue
                                      ? 'Program saved.'
                                      : 'Program removed.')
                                  : 'Program not found.',
                            ),
                          ),
                        );
                      },
                  child: Text(isAdded ? 'Remove program' : 'Save program'),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AppShell()),
                (_) => false,
              ),
              icon: const Icon(Icons.home),
              label: const Text('Back to home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatShortDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      final month = _monthName(date.month);
      String two(int v) => v.toString().padLeft(2, '0');
      return '$month ${date.day}, ${two(date.hour)}:${two(date.minute)}';
    } catch (_) {
      return '-';
    }
  }

  static String _formatDuration(String startIso, String endIso) {
    try {
      final start = DateTime.parse(startIso).toLocal();
      final end = DateTime.parse(endIso).toLocal();
      final diff = end.difference(start);
      final totalMinutes = diff.inMinutes;
      if (totalMinutes < 1) return '< 1 min';
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      if (hours <= 0) return '$minutes min';
      if (minutes == 0) return '$hours h';
      return '$hours h $minutes min';
    } catch (_) {
      return '-';
    }
  }

  static String _monthName(int month) {
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
    if (month < 1 || month > 12) return '-';
    return months[month - 1];
  }
}
