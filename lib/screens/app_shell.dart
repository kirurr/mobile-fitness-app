import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependencies.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/app/route_observer.dart';
import 'package:mobile_fitness_app/screens/main_screen.dart';
import 'package:mobile_fitness_app/screens/planned_programs_screen.dart';
import 'package:mobile_fitness_app/screens/training_start_screen.dart';
import 'package:mobile_fitness_app/screens/user_completed_programs_screen.dart';
import 'package:mobile_fitness_app/screens/user_data_form_screen.dart';
import 'package:mobile_fitness_app/screens/user_profile_screen.dart';
import 'package:mobile_fitness_app/widgets/app_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static AppShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppShellState>();
  }

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> with RouteAware {
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  bool _promptedUserData = false;
  MainScreenSeedData? _mainSeed;
  bool _routeSubscribed = false;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_routeSubscribed && route is PageRoute) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_routeSubscribed) {
      appRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    _syncOnTabEntry();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final deps = DependencyScope.of(context);
    try {
      await _preloadLocalData(deps);
      await _primeStreams(deps);
      if (!mounted) return;
      setState(() => _loading = false);
      _ensureUserData(deps);
      unawaited(_refreshInBackground(deps));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load data: $e';
        _loading = false;
      });
    }
  }

  Future<void> _preloadLocalData(Dependencies deps) async {
    final userData = await deps.userDataRepository.getLocalUserData();
    final visiblePrograms = await deps.exerciseProgramRepository.getLocalPrograms();
    final allPrograms = await deps.exerciseProgramRepository.getAllPrograms();
    final plannedPrograms =
        await deps.plannedExerciseProgramRepository.getLocalPlannedPrograms();
    final completedPrograms =
        await deps.userCompletedProgramRepository.getLocalCompletedPrograms();
    final userSubscriptions =
        await deps.userSubscriptionRepository.getLocalUserSubscriptions();
    final subscriptions = await deps.subscriptionRepository.getLocalSubscriptions();
    final difficultyLevels = await deps.difficultyLevelRepository.getLocalLevels();

    _mainSeed = MainScreenSeedData(
      userData: userData,
      visiblePrograms: visiblePrograms,
      allPrograms: allPrograms,
      plannedPrograms: plannedPrograms,
      completedPrograms: completedPrograms,
      userSubscriptions: userSubscriptions,
      subscriptions: subscriptions,
      difficultyLevels: difficultyLevels,
    );

    await Future.wait([
      deps.fitnessGoalRepository.getLocalGoals(),
      deps.exerciseRepository.getLocalExercises(),
    ]);
  }

  Future<void> _refreshInBackground(Dependencies deps) async {
    try {
      await deps.syncService.syncPending();
      await deps.syncService.refreshAll();
    } catch (_) {
      // Background refresh can fail silently in offline mode.
    }
  }

  Future<void> _syncOnTabEntry() async {
    if (_syncing) return;
    _syncing = true;
    final deps = DependencyScope.of(context);
    try {
      await deps.syncService.syncPending();
      await deps.syncService.refreshAll();
    } catch (_) {
      // Allow offline use without blocking UI.
    } finally {
      _syncing = false;
    }
  }

  Future<void> _primeStreams(Dependencies deps) async {
    final futures = <Future<void>>[
      deps.userDataRepository.watchUserData().first.then((_) {}),
      deps.exerciseProgramRepository.watchAllPrograms().first.then((_) {}),
      deps.plannedExerciseProgramRepository.watchPlannedPrograms().first
          .then((_) {}),
      deps.userCompletedProgramRepository.watchCompletedPrograms().first
          .then((_) {}),
      deps.userSubscriptionRepository.watchUserSubscriptions().first
          .then((_) {}),
      deps.subscriptionRepository.watchSubscriptions().first.then((_) {}),
      deps.fitnessGoalRepository.watchGoals().first.then((_) {}),
      deps.difficultyLevelRepository.watchLevels().first.then((_) {}),
      deps.exerciseRepository.watchExercises().first.then((_) {}),
    ];
    await Future.wait(
      futures.map(
        (future) => future.timeout(const Duration(seconds: 2), onTimeout: () {}),
      ),
    );
  }

  Future<void> _ensureUserData(Dependencies deps) async {
    if (_promptedUserData) return;
    try {
      final first = await deps.userDataRepository.watchUserData().first;
      if (!mounted) return;
      if (first == null) {
        _promptedUserData = true;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const UserDataFormScreen(),
          ),
        );
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    final pages = <Widget>[
      MainScreen(skipBootstrap: true, seedData: _mainSeed),
      const PlannedProgramsScreen(),
      const UserCompletedProgramsScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 6),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.55),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TrainingStartScreen(),
              ),
            ),
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.black,
            elevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: setIndex,
      ),
    );
  }

  void setIndex(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    unawaited(_syncOnTabEntry());
  }
}
