import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_program/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/mapper.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/exercise_program/repository.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:test/test.dart';

class _FakeExerciseProgramRemote extends ExerciseProgramRemoteDataSource {
  final List<ExerciseProgram> items;
  ExerciseProgram? nextCreate;
  final List<int> deleted = [];

  _FakeExerciseProgramRemote(this.items, Isar isar)
      : super(ApiClient.instance, ExerciseProgramMapper(isar: isar));

  @override
  Future<List<ExerciseProgram>> getAll({
    int? difficultyLevelId,
    int? subscriptionId,
    int? fitnessGoalId,
    int? userId,
  }) async {
    return items;
  }

  @override
  Future<ExerciseProgram> create(ExerciseProgramPayloadDTO payload) async {
    final created = nextCreate!;
    items.add(created);
    return created;
  }

  @override
  Future<void> delete(int id) async {
    deleted.add(id);
    items.removeWhere((p) => p.id == id);
  }
}

ExerciseProgram _buildProgram({
  required int id,
  required DifficultyLevel difficulty,
  Subscription? subscription,
  required List<FitnessGoal> goals,
  required Exercise exercise,
  required String name,
}) {
  final program = ExerciseProgram(
    id: id,
    userId: 1,
    name: name,
    description: '$name description',
  );

  program.difficultyLevel.value = difficulty;
  if (subscription != null) {
    program.subscription.value = subscription;
  }
  program.fitnessGoals.addAll(goals);

  final pe = ProgramExercise(
    id: id * 10,
    exerciseId: exercise.id,
    order: 1,
    sets: 3,
    reps: 10,
    duration: null,
    restDuration: 60,
  )
    ..exercise.value = exercise
    ..program.value = program;

  program.programExercises.add(pe);
  return program;
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_exercise_program');
  return Isar.open(
    [
      ExerciseProgramSchema,
      ProgramExerciseSchema,
      ExerciseSchema,
      ExerciseCategorySchema,
      MuscleGroupSchema,
      DifficultyLevelSchema,
      SubscriptionSchema,
      FitnessGoalSchema,
    ],
    directory: dir.path,
    inspector: false,
    name: 'exercise_program_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('ExerciseProgramRepository', () {
    late Isar isar;
    late ExerciseProgramRepository repo;
    late _FakeExerciseProgramRemote remote;
    late DifficultyLevel difficulty;
    late Subscription subscription;
    late FitnessGoal goal;
    late Exercise exercise;
    late ExerciseCategory category;
    late MuscleGroup muscleGroup;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();

      difficulty = DifficultyLevel(id: 1, name: 'Intermediate', description: 'Medium');
      subscription = Subscription(id: 2, name: 'Premium', monthlyCost: 20);
      goal = FitnessGoal(id: 3, name: 'Strength');
      category = ExerciseCategory(id: 4, name: 'Cardio', description: 'Heart work');
      muscleGroup = MuscleGroup(id: 5, name: 'Legs');
      exercise = Exercise(id: 6, name: 'Lunge', type: 'strength')
        ..category.value = category
        ..muscleGroup.value = muscleGroup
        ..difficultyLevel.value = difficulty;

      await isar.writeTxn(() async {
        await isar.difficultyLevels.put(difficulty);
        await isar.subscriptions.put(subscription);
        await isar.fitnessGoals.put(goal);
        await isar.exerciseCategorys.put(category);
        await isar.muscleGroups.put(muscleGroup);
        await isar.exercises.put(exercise);
      });

      final initialProgram = _buildProgram(
        id: 10,
        difficulty: difficulty,
        subscription: subscription,
        goals: [goal],
        exercise: exercise,
        name: 'Initial Plan',
      );

      final createdProgram = _buildProgram(
        id: 11,
        difficulty: difficulty,
        subscription: subscription,
        goals: [goal],
        exercise: exercise,
        name: 'Created Plan',
      );

      remote = _FakeExerciseProgramRemote([initialProgram], isar)
        ..nextCreate = createdProgram;

      repo = ExerciseProgramRepository(
        local: ExerciseProgramLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshPrograms replaces local data and stores program exercises', () async {
      final staleProgram = _buildProgram(
        id: 99,
        difficulty: difficulty,
        subscription: subscription,
        goals: [goal],
        exercise: exercise,
        name: 'Stale Plan',
      );
      await ExerciseProgramLocalDataSource(isar).create(staleProgram);

      await repo.refreshPrograms();

      final programs = await repo.getLocalPrograms();
      expect(programs.length, 1);
      final program = programs.first;
      expect(program.id, 10);
      expect(program.difficultyLevel.value?.id, difficulty.id);
      expect(program.subscription.value?.id, subscription.id);
      expect(program.fitnessGoals.length, 1);
      expect(program.programExercises.length, 1);
      expect(program.programExercises.first.exerciseId, exercise.id);
    });

    test('createProgram saves returned program locally', () async {
      const payload = ExerciseProgramPayloadDTO(
        name: 'Created Plan',
        description: 'Created Plan description',
        difficultyLevelId: 1,
        subscriptionId: 2,
        userId: 1,
        fitnessGoalIds: [3],
        exercises: [
          ProgramExerciseDTO(
            id: null,
            exerciseId: 6,
            order: 1,
            sets: 3,
            reps: 10,
            duration: null,
            restDuration: 60,
          ),
        ],
      );

      await repo.createProgram(payload);

      final programs = await repo.getLocalPrograms();
      expect(programs.any((p) => p.id == 11), isTrue);
      final stored = programs.firstWhere((p) => p.id == 11);
      expect(stored.programExercises.length, 1);
      expect(stored.programExercises.first.exerciseId, exercise.id);
    });

    test('deleteProgram removes local data when remote succeeds', () async {
      final stored = _buildProgram(
        id: 50,
        difficulty: difficulty,
        subscription: subscription,
        goals: [goal],
        exercise: exercise,
        name: 'To Delete',
      );
      await ExerciseProgramLocalDataSource(isar).create(stored);
      remote.items.add(stored);

      await repo.deleteProgram(stored.id);

      final remaining = await repo.getLocalPrograms();
      expect(remaining.where((p) => p.id == stored.id), isEmpty);
      expect(remote.deleted, contains(stored.id));
    });
  });
}
