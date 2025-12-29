import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/screens/main_screen.dart';
import 'package:mobile_fitness_app/screens/planned_programs_screen.dart';
import 'package:mobile_fitness_app/screens/user_completed_programs_screen.dart';
import 'package:mobile_fitness_app/screens/user_profile_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  activeColor: primary,
                  onTap: () => _goTo(context, 0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.calendar_today,
                  label: 'Schedules',
                  isActive: currentIndex == 1,
                  activeColor: primary,
                  onTap: () => _goTo(context, 1),
                ),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: _NavItem(
                  icon: Icons.history,
                  label: 'History',
                  isActive: currentIndex == 2,
                  activeColor: primary,
                  onTap: () => _goTo(context, 2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isActive: currentIndex == 3,
                  activeColor: primary,
                  onTap: () => _goTo(context, 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTo(BuildContext context, int index) {
    if (index == currentIndex) return;
    final Widget screen = switch (index) {
      0 => const MainScreen(),
      1 => const PlannedProgramsScreen(),
      2 => const UserCompletedProgramsScreen(),
      _ => const UserProfileScreen(),
    };
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
