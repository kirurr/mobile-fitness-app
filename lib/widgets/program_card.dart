import 'package:flutter/material.dart';

class ProgramCard extends StatelessWidget {
  final String title;
  final String description;
  final String durationText;
  final int exerciseCount;
  final String subscriptionName;
  final bool isFree;
  final String difficultyName;
  final VoidCallback onTap;
  final bool isSelected;

  const ProgramCard({
    super.key,
    required this.title,
    required this.description,
    required this.durationText,
    required this.exerciseCount,
    required this.subscriptionName,
    required this.isFree,
    required this.difficultyName,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFree ? Colors.white10 : const Color(0xFF2C1F5D),
                    borderRadius: BorderRadius.circular(8),
                    border: isFree
                        ? null
                        : Border.all(color: const Color(0xFF805FF4)),
                  ),
                  child: Text(
                    subscriptionName,
                    style: TextStyle(
                      color:
                          isFree ? Colors.white70 : const Color(0xFF805FF4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _ProgramStat(
                  icon: Icons.schedule,
                  value: durationText,
                  label: 'Duration',
                ),
                const SizedBox(width: 16),
                _ProgramStat(
                  icon: Icons.fitness_center,
                  value: '$exerciseCount',
                  label: 'Exercises',
                ),
                const Spacer(),
                if (difficultyName.isNotEmpty && difficultyName != '-')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt, size: 14, color: primary),
                        const SizedBox(width: 4),
                        Text(
                          difficultyName,
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}

class _ProgramStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProgramStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
