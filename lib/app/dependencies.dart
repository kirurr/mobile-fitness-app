import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/fitness_goal/assembler.dart';
import 'package:mobile_fitness_app/fitness_goal/repository.dart';
import 'package:mobile_fitness_app/app/isar.dart';

class Dependencies {
  final Isar db;
  final FitnessGoalRepository fitnessGoalRepository;

  Dependencies._({required this.db, required this.fitnessGoalRepository});

  static Future<Dependencies> init() async {
    await dotenv.load(fileName: ".env");
    await ApiClient.instance.init();

    final isarService = await IsarService().openDB();

    final fitnessGoalRepository = FitnessGoalAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );

    return Dependencies._(
      db: isarService,
      fitnessGoalRepository: fitnessGoalRepository,
    );
  }
}
