import 'package:mobile_fitness_app/muscle_group/dto.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';

class MuscleGroupMapper {
  static MuscleGroup fromDto(MuscleGroupDTO dto) {
    return MuscleGroup(
      id: dto.id,
      name: dto.name,
    );
  }

  static MuscleGroupDTO toDto(MuscleGroup model) {
    return MuscleGroupDTO(
      id: model.id,
      name: model.name,
    );
  }
}
