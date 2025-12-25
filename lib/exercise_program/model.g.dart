// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExerciseProgramCollection on Isar {
  IsarCollection<ExerciseProgram> get exercisePrograms => this.collection();
}

const ExerciseProgramSchema = CollectionSchema(
  name: r'ExerciseProgram',
  id: 932137881159612978,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 1, name: r'name', type: IsarType.string),
    r'userId': PropertySchema(id: 2, name: r'userId', type: IsarType.long),
  },

  estimateSize: _exerciseProgramEstimateSize,
  serialize: _exerciseProgramSerialize,
  deserialize: _exerciseProgramDeserialize,
  deserializeProp: _exerciseProgramDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'programExercises': LinkSchema(
      id: -4321866952079951006,
      name: r'programExercises',
      target: r'ProgramExercise',
      single: false,
    ),
    r'difficultyLevel': LinkSchema(
      id: -8175624487116130044,
      name: r'difficultyLevel',
      target: r'DifficultyLevel',
      single: true,
    ),
    r'subscription': LinkSchema(
      id: -399303845843864828,
      name: r'subscription',
      target: r'Subscription',
      single: true,
    ),
    r'fitnessGoals': LinkSchema(
      id: 7192935065577023259,
      name: r'fitnessGoals',
      target: r'FitnessGoal',
      single: false,
    ),
  },
  embeddedSchemas: {},

  getId: _exerciseProgramGetId,
  getLinks: _exerciseProgramGetLinks,
  attach: _exerciseProgramAttach,
  version: '3.3.0',
);

int _exerciseProgramEstimateSize(
  ExerciseProgram object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _exerciseProgramSerialize(
  ExerciseProgram object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeString(offsets[1], object.name);
  writer.writeLong(offsets[2], object.userId);
}

ExerciseProgram _exerciseProgramDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExerciseProgram(
    description: reader.readString(offsets[0]),
    id: id,
    name: reader.readString(offsets[1]),
    userId: reader.readLongOrNull(offsets[2]),
  );
  return object;
}

P _exerciseProgramDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exerciseProgramGetId(ExerciseProgram object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exerciseProgramGetLinks(ExerciseProgram object) {
  return [
    object.programExercises,
    object.difficultyLevel,
    object.subscription,
    object.fitnessGoals,
  ];
}

void _exerciseProgramAttach(
  IsarCollection<dynamic> col,
  Id id,
  ExerciseProgram object,
) {
  object.id = id;
  object.programExercises.attach(
    col,
    col.isar.collection<ProgramExercise>(),
    r'programExercises',
    id,
  );
  object.difficultyLevel.attach(
    col,
    col.isar.collection<DifficultyLevel>(),
    r'difficultyLevel',
    id,
  );
  object.subscription.attach(
    col,
    col.isar.collection<Subscription>(),
    r'subscription',
    id,
  );
  object.fitnessGoals.attach(
    col,
    col.isar.collection<FitnessGoal>(),
    r'fitnessGoals',
    id,
  );
}

extension ExerciseProgramQueryWhereSort
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QWhere> {
  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExerciseProgramQueryWhere
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QWhereClause> {
  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ExerciseProgramQueryFilter
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QFilterCondition> {
  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userId'),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userId'),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  userIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: value),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  userIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  userIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  userIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ExerciseProgramQueryObject
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QFilterCondition> {}

extension ExerciseProgramQueryLinks
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QFilterCondition> {
  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  programExercises(FilterQuery<ProgramExercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'programExercises');
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  programExercisesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'programExercises', length, true, length, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  programExercisesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'programExercises', 0, true, 0, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  programExercisesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'programExercises', 0, false, 999999, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  programExercisesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'programExercises', 0, true, length, include);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  programExercisesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'programExercises',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  programExercisesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'programExercises',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  difficultyLevel(FilterQuery<DifficultyLevel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'difficultyLevel');
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  difficultyLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'difficultyLevel', 0, true, 0, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  subscription(FilterQuery<Subscription> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'subscription');
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  subscriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subscription', 0, true, 0, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  fitnessGoals(FilterQuery<FitnessGoal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'fitnessGoals');
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  fitnessGoalsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fitnessGoals', length, true, length, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  fitnessGoalsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fitnessGoals', 0, true, 0, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  fitnessGoalsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fitnessGoals', 0, false, 999999, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  fitnessGoalsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fitnessGoals', 0, true, length, include);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  fitnessGoalsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'fitnessGoals', length, include, 999999, true);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterFilterCondition>
  fitnessGoalsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'fitnessGoals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ExerciseProgramQuerySortBy
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QSortBy> {
  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ExerciseProgramQuerySortThenBy
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QSortThenBy> {
  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QAfterSortBy>
  thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension ExerciseProgramQueryWhereDistinct
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QDistinct> {
  QueryBuilder<ExerciseProgram, ExerciseProgram, QDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseProgram, ExerciseProgram, QDistinct> distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }
}

extension ExerciseProgramQueryProperty
    on QueryBuilder<ExerciseProgram, ExerciseProgram, QQueryProperty> {
  QueryBuilder<ExerciseProgram, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExerciseProgram, String, QQueryOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<ExerciseProgram, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ExerciseProgram, int?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProgramExerciseCollection on Isar {
  IsarCollection<ProgramExercise> get programExercises => this.collection();
}

const ProgramExerciseSchema = CollectionSchema(
  name: r'ProgramExercise',
  id: 6402339891812254407,
  properties: {
    r'duration': PropertySchema(id: 0, name: r'duration', type: IsarType.long),
    r'exerciseId': PropertySchema(
      id: 1,
      name: r'exerciseId',
      type: IsarType.long,
    ),
    r'order': PropertySchema(id: 2, name: r'order', type: IsarType.long),
    r'reps': PropertySchema(id: 3, name: r'reps', type: IsarType.long),
    r'restDuration': PropertySchema(
      id: 4,
      name: r'restDuration',
      type: IsarType.long,
    ),
    r'sets': PropertySchema(id: 5, name: r'sets', type: IsarType.long),
  },

  estimateSize: _programExerciseEstimateSize,
  serialize: _programExerciseSerialize,
  deserialize: _programExerciseDeserialize,
  deserializeProp: _programExerciseDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'program': LinkSchema(
      id: -8170225759158986428,
      name: r'program',
      target: r'ExerciseProgram',
      single: true,
    ),
    r'exercise': LinkSchema(
      id: -9048103005103473612,
      name: r'exercise',
      target: r'Exercise',
      single: true,
    ),
  },
  embeddedSchemas: {},

  getId: _programExerciseGetId,
  getLinks: _programExerciseGetLinks,
  attach: _programExerciseAttach,
  version: '3.3.0',
);

int _programExerciseEstimateSize(
  ProgramExercise object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _programExerciseSerialize(
  ProgramExercise object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.duration);
  writer.writeLong(offsets[1], object.exerciseId);
  writer.writeLong(offsets[2], object.order);
  writer.writeLong(offsets[3], object.reps);
  writer.writeLong(offsets[4], object.restDuration);
  writer.writeLong(offsets[5], object.sets);
}

ProgramExercise _programExerciseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProgramExercise(
    duration: reader.readLongOrNull(offsets[0]),
    exerciseId: reader.readLong(offsets[1]),
    id: id,
    order: reader.readLongOrNull(offsets[2]),
    reps: reader.readLongOrNull(offsets[3]),
    restDuration: reader.readLong(offsets[4]),
    sets: reader.readLong(offsets[5]),
  );
  return object;
}

P _programExerciseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _programExerciseGetId(ProgramExercise object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _programExerciseGetLinks(ProgramExercise object) {
  return [object.program, object.exercise];
}

void _programExerciseAttach(
  IsarCollection<dynamic> col,
  Id id,
  ProgramExercise object,
) {
  object.id = id;
  object.program.attach(
    col,
    col.isar.collection<ExerciseProgram>(),
    r'program',
    id,
  );
  object.exercise.attach(col, col.isar.collection<Exercise>(), r'exercise', id);
}

extension ProgramExerciseQueryWhereSort
    on QueryBuilder<ProgramExercise, ProgramExercise, QWhere> {
  QueryBuilder<ProgramExercise, ProgramExercise, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProgramExerciseQueryWhere
    on QueryBuilder<ProgramExercise, ProgramExercise, QWhereClause> {
  QueryBuilder<ProgramExercise, ProgramExercise, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ProgramExerciseQueryFilter
    on QueryBuilder<ProgramExercise, ProgramExercise, QFilterCondition> {
  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'duration'),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'duration'),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  durationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duration', value: value),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  durationGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  durationLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  exerciseIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exerciseId', value: value),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  exerciseIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'exerciseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  exerciseIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'exerciseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  exerciseIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'exerciseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  orderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'order'),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  orderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'order'),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  orderEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  orderGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  orderLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  orderBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  repsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reps'),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  repsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reps'),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  repsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reps', value: value),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  repsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  repsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  repsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  restDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'restDuration', value: value),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  restDurationGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'restDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  restDurationLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'restDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  restDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'restDuration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  setsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sets', value: value),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  setsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sets',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  setsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sets',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  setsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sets',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ProgramExerciseQueryObject
    on QueryBuilder<ProgramExercise, ProgramExercise, QFilterCondition> {}

extension ProgramExerciseQueryLinks
    on QueryBuilder<ProgramExercise, ProgramExercise, QFilterCondition> {
  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition> program(
    FilterQuery<ExerciseProgram> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'program');
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  programIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'program', 0, true, 0, true);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  exercise(FilterQuery<Exercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'exercise');
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterFilterCondition>
  exerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercise', 0, true, 0, true);
    });
  }
}

extension ProgramExerciseQuerySortBy
    on QueryBuilder<ProgramExercise, ProgramExercise, QSortBy> {
  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> sortByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortByRestDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> sortBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  sortBySetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.desc);
    });
  }
}

extension ProgramExerciseQuerySortThenBy
    on QueryBuilder<ProgramExercise, ProgramExercise, QSortThenBy> {
  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> thenByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenByRestDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.desc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy> thenBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.asc);
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QAfterSortBy>
  thenBySetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.desc);
    });
  }
}

extension ProgramExerciseQueryWhereDistinct
    on QueryBuilder<ProgramExercise, ProgramExercise, QDistinct> {
  QueryBuilder<ProgramExercise, ProgramExercise, QDistinct>
  distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QDistinct>
  distinctByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseId');
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QDistinct> distinctByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reps');
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QDistinct>
  distinctByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restDuration');
    });
  }

  QueryBuilder<ProgramExercise, ProgramExercise, QDistinct> distinctBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sets');
    });
  }
}

extension ProgramExerciseQueryProperty
    on QueryBuilder<ProgramExercise, ProgramExercise, QQueryProperty> {
  QueryBuilder<ProgramExercise, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProgramExercise, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<ProgramExercise, int, QQueryOperations> exerciseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseId');
    });
  }

  QueryBuilder<ProgramExercise, int?, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<ProgramExercise, int?, QQueryOperations> repsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reps');
    });
  }

  QueryBuilder<ProgramExercise, int, QQueryOperations> restDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restDuration');
    });
  }

  QueryBuilder<ProgramExercise, int, QQueryOperations> setsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sets');
    });
  }
}
