import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/app/route_observer.dart';
import 'package:mobile_fitness_app/auth/service.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise_program/repository.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/repository.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'package:mobile_fitness_app/user_data/model.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';
import 'package:mobile_fitness_app/widgets/program_card.dart';
import 'package:mobile_fitness_app/screens/app_shell.dart';
import 'package:mobile_fitness_app/screens/user_data_form_screen.dart';
import 'package:mobile_fitness_app/screens/user_subscriptions_screen.dart';
import 'package:mobile_fitness_app/screens/training_screen.dart';
import 'package:mobile_fitness_app/screens/training_start_screen.dart';
import 'package:mobile_fitness_app/widgets/schedule_cards.dart';
import 'sign_in_screen.dart';

class MainScreen extends StatefulWidget {
  final bool skipBootstrap;
  final MainScreenSeedData? seedData;
  const MainScreen({super.key, this.skipBootstrap = false, this.seedData});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with RouteAware, TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _promptedUserData = false;
  bool _checkingUserData = true;
  bool _routeSubscribed = false;
  int? _selectedDifficultyId;
  int? _selectedSubscriptionId;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  int? _shakingProgramId;

  @override
  void initState() {
    super.initState();
    _checkingUserData = !widget.skipBootstrap;
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _shakingProgramId = null;
        });
      }
    });
    if (!widget.skipBootstrap) {
      _guardAuth();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncOnStart();
        _refreshUserData();
        _checkUserDataOnStart();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.skipBootstrap) return;
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
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (widget.skipBootstrap) return;
    _syncOnReturn();
  }

  Future<void> _syncOnStart() async {
    final deps = DependencyScope.of(context);
    await deps.syncService.syncPending();
    await deps.syncService.refreshAll();
  }

  Future<void> _syncOnReturn() async {
    final deps = DependencyScope.of(context);
    await deps.syncService.syncPending();
  }

  Future<void> _guardAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    }
  }


  Future<void> _refreshUserData({bool force = false}) async {
    try {
      final deps = DependencyScope.of(context);
      if (!force) {
        final local = await deps.userDataRepository.getLocalUserData();
        if (local != null) return;
      }
      await deps.userDataRepository.refreshUserData();
    } catch (_) {
      // Allow offline/local-first behavior even if refresh fails.
    }
  }

  Future<void> _checkUserDataOnStart() async {
    if (_promptedUserData) return;
    final deps = DependencyScope.of(context);
    final userRepo = deps.userDataRepository;
    try {
      final first = await userRepo.watchUserData().first;
      if (first == null && mounted) {
        _promptedUserData = true;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const UserDataFormScreen(),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingUserData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingUserData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final deps = DependencyScope.of(context);
    final userRepo = deps.userDataRepository;
    final seed = widget.seedData;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wellcome back',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  StreamBuilder<UserData?>(
                    stream: userRepo.watchUserData(),
                    initialData: seed?.userData,
                    builder: (context, snapshot) {
                      final name = snapshot.data?.name ?? '';
                      return Text(
                        name.isEmpty ? ' ' : name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => AppShell.of(context)?.setIndex(3),
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildActiveWorkoutBanner(context),
            _buildFastStartCard(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My weekly progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => AppShell.of(context)?.setIndex(2),
                    child: Text(
                      'History',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildProgressCard(context),
            const SizedBox(height: 12),
            _buildSchedulesSection(context),
            const SizedBox(height: 12),
            _buildProgramsSection(context),
            const SizedBox(height: 12),
            _buildSubscriptionsSection(context),
            const SizedBox(height: 12),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutBanner(BuildContext context) {
    final deps = DependencyScope.of(context);
    final completedRepo = deps.userCompletedProgramRepository;
    final programRepo = deps.exerciseProgramRepository;
    final seed = widget.seedData;

    return StreamBuilder<List<UserCompletedProgram>>(
      stream: completedRepo.watchCompletedPrograms(),
      initialData: seed?.completedPrograms ?? const <UserCompletedProgram>[],
      builder: (context, completedSnapshot) {
        final completed = completedSnapshot.data ?? const <UserCompletedProgram>[];
        final active = completed
            .where((item) => item.endDate == null || item.endDate!.isEmpty)
            .toList();
        if (active.isEmpty) {
          return const SizedBox.shrink();
        }

        active.sort((a, b) {
          final aDate = _parseDate(a.startDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = _parseDate(b.startDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        final current = active.first;
        final startText = _formatDateTimeShort(current.startDate);

        return StreamBuilder<List<ExerciseProgram>>(
          stream: programRepo.watchPrograms(),
          initialData: seed?.visiblePrograms ?? const <ExerciseProgram>[],
          builder: (context, programSnapshot) {
            final programs = programSnapshot.data ?? const <ExerciseProgram>[];
            final programById = {
              for (final program in programs) program.id: program,
            };
            final name =
                current.program.value?.name ??
                programById[current.programId]?.name ??
                'Workout';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C271E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout in progress — $name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Started: $startText',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrainingScreen(
                              completedProgramId: current.id,
                            ),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubscriptionsSection(BuildContext context) {
    final deps = DependencyScope.of(context);
    final userSubscriptionRepo = deps.userSubscriptionRepository;
    final primary = Theme.of(context).colorScheme.primary;
    final seed = widget.seedData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your subscriptions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<UserSubscription>>(
            stream: userSubscriptionRepo.watchUserSubscriptions(),
            initialData:
                seed?.userSubscriptions ?? const <UserSubscription>[],
            builder: (context, snapshot) {
              final subs = snapshot.data ?? const <UserSubscription>[];
              if (subs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.lock, color: primary, size: 28),
                      const SizedBox(height: 8),
                      const Text(
                        'You have no active subscriptions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Get access to premium programs and progress insights.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.55),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UserSubscriptionsScreen(),
                            ),
                          ),
                          child: const Text('View subscriptions'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  ...subs.map(
                    (sub) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.subscription.value?.name ?? 'Subscription',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Until ${_formatDateWithYear(sub.endDate)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserSubscriptionsScreen(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text('Manage subscriptions'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFastStartCard(BuildContext context) {
    final colorPrimary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/overlay.png',
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.35),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fast start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready? Start a training right now',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: colorPrimary.withOpacity(0.6),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TrainingStartScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final colorPrimary = Theme.of(context).colorScheme.primary;
    final deps = DependencyScope.of(context);
    final completedRepo = deps.userCompletedProgramRepository;
    final seed = widget.seedData;

    return StreamBuilder<List<UserCompletedProgram>>(
      stream: completedRepo.watchCompletedPrograms(),
      initialData: seed?.completedPrograms ?? const <UserCompletedProgram>[],
      builder: (context, snapshot) {
        final completed = snapshot.data ?? const <UserCompletedProgram>[];
        final progress = _calculateWeeklyProgress(completed);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: colorPrimary),
                    const SizedBox(width: 8),
                    Text(
                      progress.hoursText,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${progress.workouts} workouts',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchedulesSection(BuildContext context) {
    final deps = DependencyScope.of(context);
    final plannedRepo = deps.plannedExerciseProgramRepository;
    final programRepo = deps.exerciseProgramRepository;
    final seed = widget.seedData;
    final initialData =
        seed == null
            ? const _ScheduleData()
            : _ScheduleData(
              planned: seed.plannedPrograms,
              programs: seed.allPrograms,
              isRefreshing: false,
            );

    return StreamBuilder<_ScheduleData>(
      stream: _watchScheduleData(plannedRepo, programRepo),
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Ошибка: ${snapshot.error}'),
          );
        }

        final data = snapshot.data ?? const _ScheduleData();
        final programs = data.programs;
        final plannedItems = data.planned;
        final programById = {
          for (final program in programs) program.id: program,
        };
        final weekItems = _filterUpcoming(plannedItems, maxItems: 3);
        final entries = weekItems
            .map(
              (item) => ScheduleEntry(
                planned: item.item,
                date: item.date,
                program: programById[item.item.programId],
              ),
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Schedules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => AppShell.of(context)?.setIndex(1),
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (weekItems.isEmpty)
                Center(
                  child: TextButton(
                    onPressed: () => AppShell.of(context)?.setIndex(1),
                    child: const Text('Schedule a workout'),
                  ),
                )
              else
                ScheduleCardsList(
                  entries: entries,
                  onTap: (entry) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrainingStartScreen(
                        initialProgramId: entry.planned.programId,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgramsSection(BuildContext context) {
    final deps = DependencyScope.of(context);
    final programRepo = deps.exerciseProgramRepository;
    final difficultyRepo = deps.difficultyLevelRepository;
    final subscriptionRepo = deps.subscriptionRepository;
    final seed = widget.seedData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Programs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap a program to start a workout.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<DifficultyLevel>>(
                  stream: difficultyRepo.watchLevels(),
                  initialData:
                      seed?.difficultyLevels ?? const <DifficultyLevel>[],
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const <DifficultyLevel>[];
                    return DropdownButtonFormField<int?>(
                      value: _selectedDifficultyId,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...items.map(
                          (item) => DropdownMenuItem<int?>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficultyId = value;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<List<Subscription>>(
                  stream: subscriptionRepo.watchSubscriptions(),
                  initialData: seed?.subscriptions ?? const <Subscription>[],
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const <Subscription>[];
                    return DropdownButtonFormField<int?>(
                      value: _selectedSubscriptionId,
                      decoration: const InputDecoration(
                        labelText: 'Subscription',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...items.map(
                          (item) => DropdownMenuItem<int?>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSubscriptionId = value;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<ExerciseProgram>>(
            stream: programRepo.watchPrograms(),
            initialData: seed?.visiblePrograms ?? const <ExerciseProgram>[],
            builder: (context, snapshot) {
              final programs = snapshot.data ?? const <ExerciseProgram>[];
              final filtered = programs.where((program) {
                final difficulty =
                    program.difficultyLevel.isNotEmpty
                        ? program.difficultyLevel.first.id
                        : null;
                final subscription =
                    program.subscription.isNotEmpty
                        ? program.subscription.first.id
                        : null;

                final matchesDifficulty =
                    _selectedDifficultyId == null ||
                    difficulty == _selectedDifficultyId;
                final matchesSubscription =
                    _selectedSubscriptionId == null ||
                    subscription == _selectedSubscriptionId;

                return matchesDifficulty && matchesSubscription;
              }).toList();

              return StreamBuilder<List<UserSubscription>>(
                stream: deps.userSubscriptionRepository.watchUserSubscriptions(),
                initialData:
                    seed?.userSubscriptions ?? const <UserSubscription>[],
                builder: (context, subSnapshot) {
                  final userSubscriptions =
                      subSnapshot.data ?? const <UserSubscription>[];

                  if (filtered.isEmpty) {
                    return const Text('No programs found.');
                  }

                  return Column(
                    children: filtered.map((program) {
                      final subscription =
                          program.subscription.isNotEmpty
                              ? program.subscription.first
                              : null;
                      final difficulty =
                          program.difficultyLevel.isNotEmpty
                              ? program.difficultyLevel.first
                              : null;
                      return _buildProgramCard(
                        context,
                        program,
                        userSubscriptions,
                        subscriptionName: subscription?.name ?? 'Free',
                        isFree: subscription == null,
                        difficultyName: difficulty?.name ?? '-',
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(
    BuildContext context,
    ExerciseProgram program,
    List<UserSubscription> userSubscriptions,
    {required String subscriptionName,
    required bool isFree,
    required String difficultyName}) {
    final durationText = _formatProgramDuration(program);
    final exerciseCount = program.programExercises.length;
    final hasAccess = _hasProgramAccess(program, userSubscriptions);
    final shouldShake = _shakingProgramId == program.id;

    final card = ProgramCard(
      title: program.name,
      description: program.description,
      durationText: durationText,
      exerciseCount: exerciseCount,
      subscriptionName: subscriptionName,
      isFree: isFree,
      difficultyName: difficultyName,
      onTap: () {
        if (hasAccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TrainingStartScreen(initialProgramId: program.id),
            ),
          );
          return;
        }

        _triggerProgramShake(program.id);
        _showSubscriptionRequiredToast(context, subscriptionName);
      },
    );

    if (!shouldShake) {
      return card;
    }

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: card,
    );
  }


  bool _hasProgramAccess(
    ExerciseProgram program,
    List<UserSubscription> userSubscriptions,
  ) {
    if (program.subscription.isEmpty) return true;
    final required = program.subscription.first.id;
    final now = DateTime.now();
    for (final sub in userSubscriptions) {
      final subscriptionId = sub.subscription.value?.id;
      if (subscriptionId != required) continue;
      final start = _parseDate(sub.startDate);
      final end = _parseDate(sub.endDate);
      if (start == null || end == null) continue;
      if (!start.isAfter(now) && !end.isBefore(now)) {
        return true;
      }
    }
    return false;
  }

  void _triggerProgramShake(int programId) {
    setState(() {
      _shakingProgramId = programId;
    });
    _shakeController.forward(from: 0);
  }

  void _showSubscriptionRequiredToast(
    BuildContext context,
    String? subscriptionName,
  ) {
    final name = subscriptionName?.isNotEmpty == true
        ? subscriptionName
        : 'this plan';
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    final topInset = MediaQuery.of(context).padding.top;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Available only with a $name subscription.'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 16 + topInset, 16, 0),
        action: SnackBarAction(
          label: 'Subscribe',
          onPressed: () {
            messenger.hideCurrentSnackBar();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const UserSubscriptionsScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  List<_PlannedWeekItem> _filterUpcoming(
    List<PlannedExerciseProgram> items, {
    required int maxItems,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final result = <_PlannedWeekItem>[];
    for (final item in items) {
      final dates = item.dates.toList();
      DateTime? earliest;
      for (final planned in dates) {
        final parsed = _parseDate(planned.date);
        if (parsed == null) continue;
        if (parsed.isBefore(start)) continue;
        if (earliest == null || parsed.isBefore(earliest)) {
          earliest = parsed;
        }
      }
      if (earliest != null) {
        result.add(_PlannedWeekItem(item, earliest));
      }
    }

    result.sort((a, b) => a.date.compareTo(b.date));
    return result.take(maxItems).toList();
  }

  String _formatProgramDuration(ExerciseProgram? program) {
    if (program == null) return '0 m';
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

  Stream<_ScheduleData> _watchScheduleData(
    PlannedExerciseProgramRepository plannedRepo,
    ExerciseProgramRepository programRepo,
  ) {
    late StreamSubscription<List<PlannedExerciseProgram>> plannedSub;
    late StreamSubscription<List<ExerciseProgram>> programSub;

    return Stream<_ScheduleData>.multi((controller) async {
      var planned = <PlannedExerciseProgram>[];
      var programs = <ExerciseProgram>[];
      var hasPlannedUpdate = false;

      try {
        planned = await plannedRepo.getLocalPlannedPrograms();
        programs = await programRepo.watchAllPrograms().first;
        controller.add(
          _ScheduleData(
            planned: planned,
            programs: programs,
            isRefreshing: false,
          ),
        );
        hasPlannedUpdate = true;
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }

      plannedSub = plannedRepo.watchPlannedPrograms().listen(
        (items) {
          planned = items;
          hasPlannedUpdate = true;
          controller.add(
            _ScheduleData(
              planned: planned,
              programs: programs,
              isRefreshing: false,
            ),
          );
        },
        onError: controller.addError,
      );

      programSub = programRepo.watchAllPrograms().listen(
        (items) {
          programs = items;
          controller.add(
            _ScheduleData(
              planned: planned,
              programs: programs,
              isRefreshing: !hasPlannedUpdate,
            ),
          );
        },
        onError: controller.addError,
      );

      controller.onCancel = () async {
        await plannedSub.cancel();
        await programSub.cancel();
      };
    });
  }

  _WeeklyProgress _calculateWeeklyProgress(List<UserCompletedProgram> items) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));

    int workouts = 0;
    int totalMinutes = 0;
    for (final item in items) {
      final startDate = _parseDate(item.startDate);
      if (startDate == null) continue;
      if (startDate.isBefore(start) || !startDate.isBefore(end)) continue;

      final endDate = _parseDate(item.endDate) ?? startDate;
      final diff = endDate.difference(startDate);
      final minutes = diff.inMinutes;
      if (minutes > 0) {
        totalMinutes += minutes;
      }
      workouts += 1;
    }

    final hoursValue = totalMinutes / 60;
    final hoursText =
        hoursValue == hoursValue.roundToDouble()
            ? '${hoursValue.toStringAsFixed(0)} h'
            : '${hoursValue.toStringAsFixed(1)} h';

    return _WeeklyProgress(hoursText: hoursText, workouts: workouts);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatDateWithYear(String? value) {
    final date = _parseDate(value);
    if (date == null) return '-';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  String _formatDateTimeShort(String? value) {
    final date = _parseDate(value);
    if (date == null) return '-';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

}

class _PlannedWeekItem {
  final PlannedExerciseProgram item;
  final DateTime date;

  _PlannedWeekItem(this.item, this.date);
}

class _WeeklyProgress {
  final String hoursText;
  final int workouts;

  _WeeklyProgress({required this.hoursText, required this.workouts});
}

class _ScheduleData {
  final List<PlannedExerciseProgram> planned;
  final List<ExerciseProgram> programs;
  final bool isRefreshing;

  const _ScheduleData({
    this.planned = const [],
    this.programs = const [],
    this.isRefreshing = true,
  });
}

class MainScreenSeedData {
  final UserData? userData;
  final List<ExerciseProgram> visiblePrograms;
  final List<ExerciseProgram> allPrograms;
  final List<PlannedExerciseProgram> plannedPrograms;
  final List<UserCompletedProgram> completedPrograms;
  final List<UserSubscription> userSubscriptions;
  final List<Subscription> subscriptions;
  final List<DifficultyLevel> difficultyLevels;

  const MainScreenSeedData({
    required this.userData,
    required this.visiblePrograms,
    required this.allPrograms,
    required this.plannedPrograms,
    required this.completedPrograms,
    required this.userSubscriptions,
    required this.subscriptions,
    required this.difficultyLevels,
  });
}
