import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/user_data/dto.dart';
import 'package:mobile_fitness_app/user_data/model.dart';

class UserDataMapper {
  final Isar isar;

  UserDataMapper({required this.isar});

  Future<UserData> fromDto(UserDataDTO dto) async {
    final user = UserData(
      userId: dto.userId,
      name: dto.name,
      age: dto.age,
      weight: dto.weight,
      height: dto.height,
    );

    user.fitnessGoal.value = await isar.fitnessGoals.get(dto.fitnessGoalId);
    user.trainingLevel.value = await isar.difficultyLevels.get(dto.trainingLevel);

    return user;
  }

  Future<UserDataDTO> toDto(UserData model) async {
    await model.fitnessGoal.load();
    await model.trainingLevel.load();

    return UserDataDTO(
      userId: model.userId,
      name: model.name,
      age: model.age,
      weight: model.weight,
      height: model.height,
      fitnessGoalId: model.fitnessGoal.value!.id,
      trainingLevel: model.trainingLevel.value!.id,
    );
  }
}
