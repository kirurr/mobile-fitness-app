class UserCompletedExerciseDTO {
  final int id;
  final int completedProgramId;
  final int? programExerciseId;
  final int? exerciseId;
  final int sets;
  final int? reps;
  final int? duration;
  final int? weight;
  final int? restDuration;

  const UserCompletedExerciseDTO({
    required this.id,
    required this.completedProgramId,
    required this.programExerciseId,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.weight,
    required this.restDuration,
  });

  factory UserCompletedExerciseDTO.fromJson(Map<String, dynamic> json) {
    return UserCompletedExerciseDTO(
      id: (json['id'] as num).toInt(),
      completedProgramId: (json['completedProgramId'] as num).toInt(),
      programExerciseId: (json['programExerciseId'] as num?)?.toInt(),
      exerciseId: (json['exerciseId'] as num?)?.toInt(),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
      restDuration: (json['restDuration'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedProgramId': completedProgramId,
      'programExerciseId': programExerciseId,
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'weight': weight,
      'restDuration': restDuration,
    };
  }
}

class UserCompletedExercisePayloadDTO {
  final int? id;
  final int completedProgramId;
  final int? programExerciseId;
  final int? exerciseId;
  final int sets;
  final int? reps;
  final int? duration;
  final int? weight;
  final int? restDuration;

  const UserCompletedExercisePayloadDTO({
    this.id,
    required this.completedProgramId,
    this.programExerciseId,
    this.exerciseId,
    this.sets = 1,
    this.reps,
    this.duration,
    this.weight,
    this.restDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedProgramId': completedProgramId,
      'programExerciseId': programExerciseId,
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'weight': weight,
      'restDuration': restDuration,
    };
  }
}
