import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/dto.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';

class PlannedExerciseProgramMapper {
  final Isar isar;

  PlannedExerciseProgramMapper({required this.isar});

  Future<PlannedExerciseProgram> fromDto(PlannedExerciseProgramDTO dto) async {
    final model = PlannedExerciseProgram(
      id: dto.id,
      programId: dto.programId,
      synced: true,
      pendingDelete: false,
      isLocalOnly: false,
    );

    model.program.value = await isar.exercisePrograms.get(dto.programId);

    final dates = dto.dates
        .map(
          (d) => PlannedExerciseProgramDate(
            id: d.id,
            plannedExerciseProgramId: dto.id,
            date: d.date,
          )..plannedProgram.value = model,
        )
        .toList();

    model.dates.addAll(dates);
    return model;
  }

  Future<PlannedExerciseProgramDTO> toDto(PlannedExerciseProgram model) async {
    await model.program.load();
    await model.dates.load();

    final dateDtos = model.dates
        .map(
          (d) => PlannedExerciseProgramDateDTO(
            id: d.id,
            plannedExerciseProgramId: model.id,
            date: d.date,
          ),
        )
        .toList();

    return PlannedExerciseProgramDTO(
      id: model.id,
      programId: model.program.value?.id ?? model.programId,
      dates: dateDtos,
    );
  }
}
