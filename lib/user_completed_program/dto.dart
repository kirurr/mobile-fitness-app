import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';

class UserCompletedProgramDTO {
  final int id;
  final int userId;
  final int programId;
  final String startDate;
  final String? endDate;
  final List<UserCompletedExerciseDTO> completedExercises;

  const UserCompletedProgramDTO({
    required this.id,
    required this.userId,
    required this.programId,
    required this.startDate,
    required this.endDate,
    required this.completedExercises,
  });

  factory UserCompletedProgramDTO.fromJson(Map<String, dynamic> json) {
    final exercisesSource =
        (json['completedExercises'] as List?) ??
        (json['completed_exercises'] as List?) ??
        (json['completedExercise'] as List?) ??
        (json['completed_exercise'] as List?) ??
        const [];
    final exercises = exercisesSource
        .map(
          (item) =>
              UserCompletedExerciseDTO.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return UserCompletedProgramDTO(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      programId: (json['programId'] as num).toInt(),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
      completedExercises: exercises,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'programId': programId,
      'startDate': startDate,
      'endDate': endDate,
      'completedExercises': completedExercises
          .map((exercise) => exercise.toJson())
          .toList(),
    };
  }
}

class UserCompletedProgramPayloadDTO {
  final int? id;
  final int userId;
  final int programId;
  final String? startDate;
  final String? endDate;

  const UserCompletedProgramPayloadDTO({
    this.id,
    required this.userId,
    required this.programId,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'programId': programId,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
