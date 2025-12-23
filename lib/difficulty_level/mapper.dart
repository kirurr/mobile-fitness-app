import 'package:mobile_fitness_app/difficulty_level/dto.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';

class DifficultyLevelMapper {
  static DifficultyLevel fromDto(DifficultyLevelDTO dto) {
    return DifficultyLevel(
      id: dto.id,
      name: dto.name,
      description: dto.description,
    );
  }

  static DifficultyLevelDTO toDto(DifficultyLevel model) {
    return DifficultyLevelDTO(
      id: model.id,
      name: model.name,
      description: model.description,
    );
  }
}
