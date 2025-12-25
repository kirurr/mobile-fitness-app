import 'package:mobile_fitness_app/exercise_category/dto.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';

class ExerciseCategoryMapper {
  static ExerciseCategory fromDto(ExerciseCategoryDTO dto) {
    return ExerciseCategory(
      id: dto.id,
      name: dto.name,
      description: dto.description,
    );
  }

  static ExerciseCategoryDTO toDto(ExerciseCategory model) {
    return ExerciseCategoryDTO(
      id: model.id,
      name: model.name,
      description: model.description,
    );
  }
}
