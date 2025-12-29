import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/screens/training_screen.dart';
import 'package:mobile_fitness_app/screens/user_subscriptions_screen.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_data/model.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/widgets/program_card.dart';

class TrainingStartScreen extends StatefulWidget {
  final int? initialProgramId;

  const TrainingStartScreen({super.key, this.initialProgramId});

  @override
  State<TrainingStartScreen> createState() => _TrainingStartScreenState();
}

class _TrainingStartScreenState extends State<TrainingStartScreen>
    with TickerProviderStateMixin {
  ExerciseProgram? _selectedProgram;
  List<ExerciseProgram> _availablePrograms = [];
  UserData? _userData;
  List<UserSubscription> _userSubscriptions = [];

  bool _loading = true;
  bool _startingProgram = false;
  bool _startingCustomProgram = false;
  String? _error;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  int? _shakingProgramId;

  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final deps = DependencyScope.of(context);
      final userData = await deps.userDataRepository.getLocalUserData();
      if (userData == null) {
        setState(() {
          _error = 'User data not found. Complete your profile first.';
          _loading = false;
        });
        return;
      }

      final programs = await deps.exerciseProgramRepository.getLocalPrograms();
      final userSubscriptions =
          await deps.userSubscriptionRepository.getLocalUserSubscriptions();

      ExerciseProgram? selected;
      if (widget.initialProgramId != null) {
        for (final program in programs) {
          if (program.id == widget.initialProgramId) {
            selected = program;
            break;
          }
        }
      }
      selected ??= programs.isNotEmpty ? programs.first : null;

      setState(() {
        _userData = userData;
        _availablePrograms = programs;
        _userSubscriptions = userSubscriptions;
        _selectedProgram = selected;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load programs: $e';
        _loading = false;
      });
    }
  }

  Future<void> _startSelectedProgram() async {
    final userData = _userData;
    final program = _selectedProgram;
    if (userData == null || program == null) return;
    if (!_hasSubscriptionAccess(program)) {
      _showSubscriptionRequiredToast(
        context,
        program.subscription.isNotEmpty ? program.subscription.first.name : null,
      );
      return;
    }

    setState(() {
      _startingProgram = true;
    });

    try {
      final deps = DependencyScope.of(context);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final completedProgramPayload = UserCompletedProgramPayloadDTO(
        userId: userData.userId,
        programId: program.id,
        startDate: nowIso,
        endDate: null,
      );

      final createdCompletedProgram = await deps.userCompletedProgramRepository
          .create(completedProgramPayload, triggerSync: false);

      final completedExerciseRepo = deps.userCompletedExerciseRepository;
      for (final programExercise in program.programExercises) {
        final payload = UserCompletedExercisePayloadDTO(
          completedProgramId: createdCompletedProgram.id,
          programExerciseId: programExercise.id,
          exerciseId: programExercise.exerciseId,
          sets: programExercise.sets,
          reps: programExercise.reps,
          duration: programExercise.duration,
          weight: null,
          restDuration: programExercise.restDuration,
        );
        await completedExerciseRepo.create(payload, triggerSync: false);
      }

      await deps.userCompletedProgramRepository.refreshLocalLinksForProgram(
        createdCompletedProgram.id,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TrainingScreen(
            completedProgramId: createdCompletedProgram.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to start workout: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _startingProgram = false;
        });
      }
    }
  }

  Future<void> _startCustomProgram() async {
    final userData = _userData;
    if (userData == null) return;

    final difficultyId = userData.trainingLevel.value?.id;
    if (difficultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Training level not set for user.')),
      );
      return;
    }

    setState(() {
      _startingCustomProgram = true;
    });

    try {
      final deps = DependencyScope.of(context);
      final fitnessGoalId = userData.fitnessGoal.value?.id;
      final programPayload = ExerciseProgramPayloadDTO(
        name: 'untitled program',
        description: 'Generated training',
        difficultyLevelId: difficultyId,
        subscriptionId: null,
        userId: userData.userId,
        fitnessGoalIds: fitnessGoalId != null ? [fitnessGoalId] : [],
        exercises: const [],
      );

      final createdProgram =
          await deps.exerciseProgramRepository.createLocalProgram(programPayload);

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final completedProgramPayload = UserCompletedProgramPayloadDTO(
        userId: userData.userId,
        programId: createdProgram.id,
        startDate: nowIso,
        endDate: null,
      );

      final createdCompletedProgram = await deps.userCompletedProgramRepository
          .create(completedProgramPayload, triggerSync: false);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TrainingScreen(
            completedProgramId: createdCompletedProgram.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to start workout: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _startingCustomProgram = false;
        });
      }
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
        appBar: AppBar(title: const Text('Training')),
        body: Center(child: Text(_error!)),
      );
    }

    final selected = _selectedProgram;
    final hasSelectedExercises = selected?.programExercises.isNotEmpty ?? false;
    final hasSubscriptionAccess =
        selected != null ? _hasSubscriptionAccess(selected) : false;
    final selectedName = selected?.name ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Training')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFreeWorkoutCard(context),
                const SizedBox(height: 16),
                if (_availablePrograms.isEmpty) ...[
                  const Text('No programs available. Please sync or create one.'),
                ] else ...[
                  const Text(
                    'Choose a program',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: _availablePrograms.map((program) {
                      final subscription =
                          program.subscription.isNotEmpty
                              ? program.subscription.first
                              : null;
                      final difficulty =
                          program.difficultyLevel.isNotEmpty
                              ? program.difficultyLevel.first
                              : null;
                      final durationText = _formatProgramDuration(program);
                      final exerciseCount = program.programExercises.length;
                      final hasAccess = _hasSubscriptionAccess(program);
                      final shouldShake = _shakingProgramId == program.id;
                      final card = ProgramCard(
                        title: program.name,
                        description: program.description,
                        durationText: durationText,
                        exerciseCount: exerciseCount,
                        subscriptionName: subscription?.name ?? 'Free',
                        isFree: subscription == null,
                        difficultyName: difficulty?.name ?? '-',
                        isSelected: selected?.id == program.id,
                        onTap: () {
                          if (!hasAccess) {
                            _triggerProgramShake(program.id);
                            _showSubscriptionRequiredToast(
                              context,
                              subscription?.name,
                            );
                            return;
                          }
                          setState(() => _selectedProgram = program);
                        },
                      );

                      if (!shouldShake) return card;
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
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  if (selected != null && !hasSelectedExercises)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Selected program has no exercises.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildProgramSelectionBar(
              context,
              selectedName: selectedName,
              canStart:
                  selected != null &&
                  hasSelectedExercises &&
                  hasSubscriptionAccess &&
                  !_startingProgram,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeWorkoutCard(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: _startingCustomProgram ? null : _startCustomProgram,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C271E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Free workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Start without a program and build your own.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_startingCustomProgram)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramSelectionBar(
    BuildContext context, {
    required String selectedName,
    required bool canStart,
  }) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            top: BorderSide(color: Colors.white12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(
                    text: 'Selected: ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextSpan(
                    text: selectedName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canStart ? _startSelectedProgram : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: _startingProgram
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Start'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatProgramDuration(ExerciseProgram program) {
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
    messenger.hideCurrentSnackBar();
    final topInset = MediaQuery.of(context).padding.top;
    messenger.showSnackBar(
      SnackBar(
        content: Text('Available only with a $name subscription.'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 16 + topInset, 16, 0),
        action: SnackBarAction(
          label: 'Subscribe',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const UserSubscriptionsScreen(),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasSubscriptionAccess(ExerciseProgram program) {
    final requiredSubscription =
        program.subscription.isNotEmpty ? program.subscription.first : null;
    if (requiredSubscription == null) return true;
    final userData = _userData;
    if (userData == null) return false;

    final nowUtc = DateTime.now().toUtc();
    for (final sub in _userSubscriptions) {
      if (sub.userId != userData.userId || sub.pendingDelete) continue;
      final linked = sub.subscription.value;
      if (linked == null || linked.id != requiredSubscription.id) continue;
      if (_isSubscriptionActive(sub, nowUtc)) return true;
    }
    return false;
  }

  bool _isSubscriptionActive(UserSubscription sub, DateTime nowUtc) {
    final start = DateTime.tryParse(sub.startDate);
    final end = DateTime.tryParse(sub.endDate);
    if (start == null || end == null) return false;
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    if (nowUtc.isBefore(startUtc)) return false;
    if (nowUtc.isAfter(endUtc)) return false;
    return true;
  }
}
