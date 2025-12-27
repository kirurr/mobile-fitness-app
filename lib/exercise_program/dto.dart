class ProgramExerciseDTO {
  final int? id;
  final int exerciseId;
  final int? order;
  final int sets;
  final int? reps;
  final int? duration;
  final int restDuration;

  const ProgramExerciseDTO({
    this.id,
    required this.exerciseId,
    required this.order,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.restDuration,
  });

  factory ProgramExerciseDTO.fromJson(Map<String, dynamic> json) {
    return ProgramExerciseDTO(
      id: json['id'] as int?,
      exerciseId: json['exerciseId'] as int,
      order: json['order'] as int?,
      sets: json['sets'] as int,
      reps: json['reps'] as int?,
      duration: json['duration'] as int?,
      restDuration: json['restDuration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'exerciseId': exerciseId,
      'order': order,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'restDuration': restDuration,
    };
  }
}

class ExerciseProgramDTO {
  final int id;
  final int? userId;
  final String name;
  final String description;
  final int difficultyLevelId;
  final int? subscriptionId;
  final List<int> fitnessGoalIds;
  final List<ProgramExerciseDTO> exercises;

  const ExerciseProgramDTO({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.difficultyLevelId,
    required this.subscriptionId,
    required this.fitnessGoalIds,
    required this.exercises,
  });

  factory ExerciseProgramDTO.fromJson(Map<String, dynamic> json) {
    return ExerciseProgramDTO(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      difficultyLevelId: json['difficultyLevelId'] as int,
      subscriptionId: json['subscriptionId'] as int?,
      fitnessGoalIds: (json['fitnessGoals'] as List? ?? [])
          .map((item) => (item as Map<String, dynamic>)['id'] as int)
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .map((item) {
            final map = item as Map<String, dynamic>;
            final nested = map['programExercise'];
            if (nested is Map<String, dynamic>) {
              return ProgramExerciseDTO.fromJson(nested);
            }
            return ProgramExerciseDTO.fromJson(map);
          }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'difficultyLevelId': difficultyLevelId,
      'subscriptionId': subscriptionId,
      'fitnessGoalIds': fitnessGoalIds,
      'exerciseIds': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class ExerciseProgramPayloadDTO {
  final int? id;
  final String name;
  final String description;
  final int difficultyLevelId;
  final int? subscriptionId;
  final int? userId;
  final List<int> fitnessGoalIds;
  final List<ProgramExerciseDTO> exercises;

  const ExerciseProgramPayloadDTO({
    this.id,
    required this.name,
    required this.description,
    required this.difficultyLevelId,
    required this.subscriptionId,
    required this.userId,
    required this.fitnessGoalIds,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'difficultyLevelId': difficultyLevelId,
      'subscriptionId': subscriptionId,
      'userId': userId,
      'fitnessGoalIds': fitnessGoalIds,
      'exerciseIds': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
