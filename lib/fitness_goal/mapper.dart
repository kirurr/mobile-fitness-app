import 'package:mobile_fitness_app/fitness_goal/dto.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';

class FitnessGoalMapper {
  static FitnessGoal fromDto(FitnessGoalDTO dto) {
    return FitnessGoal(
      id: dto.id,
      name: dto.name,
    );
  }

  static FitnessGoalDTO toDto(FitnessGoal model) {
    return FitnessGoalDTO(
      id: model.id,
      name: model.name,
    );
  }
}
