// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlannedExerciseProgramCollection on Isar {
  IsarCollection<PlannedExerciseProgram> get plannedExercisePrograms =>
      this.collection();
}

const PlannedExerciseProgramSchema = CollectionSchema(
  name: r'PlannedExerciseProgram',
  id: 4534556264694277461,
  properties: {
    r'isLocalOnly': PropertySchema(
      id: 0,
      name: r'isLocalOnly',
      type: IsarType.bool,
    ),
    r'pendingDelete': PropertySchema(
      id: 1,
      name: r'pendingDelete',
      type: IsarType.bool,
    ),
    r'programId': PropertySchema(
      id: 2,
      name: r'programId',
      type: IsarType.long,
    ),
    r'synced': PropertySchema(id: 3, name: r'synced', type: IsarType.bool),
  },

  estimateSize: _plannedExerciseProgramEstimateSize,
  serialize: _plannedExerciseProgramSerialize,
  deserialize: _plannedExerciseProgramDeserialize,
  deserializeProp: _plannedExerciseProgramDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'program': LinkSchema(
      id: 8398095627817387337,
      name: r'program',
      target: r'ExerciseProgram',
      single: true,
    ),
    r'dates': LinkSchema(
      id: -9035068505721758351,
      name: r'dates',
      target: r'PlannedExerciseProgramDate',
      single: false,
    ),
  },
  embeddedSchemas: {},

  getId: _plannedExerciseProgramGetId,
  getLinks: _plannedExerciseProgramGetLinks,
  attach: _plannedExerciseProgramAttach,
  version: '3.3.0',
);

int _plannedExerciseProgramEstimateSize(
  PlannedExerciseProgram object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _plannedExerciseProgramSerialize(
  PlannedExerciseProgram object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isLocalOnly);
  writer.writeBool(offsets[1], object.pendingDelete);
  writer.writeLong(offsets[2], object.programId);
  writer.writeBool(offsets[3], object.synced);
}

PlannedExerciseProgram _plannedExerciseProgramDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlannedExerciseProgram(
    id: id,
    isLocalOnly: reader.readBoolOrNull(offsets[0]) ?? false,
    pendingDelete: reader.readBoolOrNull(offsets[1]) ?? false,
    programId: reader.readLong(offsets[2]),
    synced: reader.readBoolOrNull(offsets[3]) ?? true,
  );
  return object;
}

P _plannedExerciseProgramDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _plannedExerciseProgramGetId(PlannedExerciseProgram object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _plannedExerciseProgramGetLinks(
  PlannedExerciseProgram object,
) {
  return [object.program, object.dates];
}

void _plannedExerciseProgramAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlannedExerciseProgram object,
) {
  object.id = id;
  object.program.attach(
    col,
    col.isar.collection<ExerciseProgram>(),
    r'program',
    id,
  );
  object.dates.attach(
    col,
    col.isar.collection<PlannedExerciseProgramDate>(),
    r'dates',
    id,
  );
}

extension PlannedExerciseProgramQueryWhereSort
    on QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QWhere> {
  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlannedExerciseProgramQueryWhere
    on
        QueryBuilder<
          PlannedExerciseProgram,
          PlannedExerciseProgram,
          QWhereClause
        > {
  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterWhereClause
  >
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

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterWhereClause
  >
  idBetween(
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

extension PlannedExerciseProgramQueryFilter
    on
        QueryBuilder<
          PlannedExerciseProgram,
          PlannedExerciseProgram,
          QFilterCondition
        > {
  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  isLocalOnlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isLocalOnly', value: value),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  pendingDeleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pendingDelete', value: value),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  programIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'programId', value: value),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  programIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'programId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  programIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'programId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  programIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'programId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }
}

extension PlannedExerciseProgramQueryObject
    on
        QueryBuilder<
          PlannedExerciseProgram,
          PlannedExerciseProgram,
          QFilterCondition
        > {}

extension PlannedExerciseProgramQueryLinks
    on
        QueryBuilder<
          PlannedExerciseProgram,
          PlannedExerciseProgram,
          QFilterCondition
        > {
  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  program(FilterQuery<ExerciseProgram> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'program');
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  programIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'program', 0, true, 0, true);
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  dates(FilterQuery<PlannedExerciseProgramDate> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'dates');
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  datesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'dates', length, true, length, true);
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  datesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'dates', 0, true, 0, true);
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  datesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'dates', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  datesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'dates', 0, true, length, include);
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  datesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'dates', length, include, 999999, true);
    });
  }

  QueryBuilder<
    PlannedExerciseProgram,
    PlannedExerciseProgram,
    QAfterFilterCondition
  >
  datesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'dates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PlannedExerciseProgramQuerySortBy
    on QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QSortBy> {
  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortByProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.desc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension PlannedExerciseProgramQuerySortThenBy
    on
        QueryBuilder<
          PlannedExerciseProgram,
          PlannedExerciseProgram,
          QSortThenBy
        > {
  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenByProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.desc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension PlannedExerciseProgramQueryWhereDistinct
    on QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QDistinct> {
  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QDistinct>
  distinctByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocalOnly');
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QDistinct>
  distinctByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingDelete');
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QDistinct>
  distinctByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'programId');
    });
  }

  QueryBuilder<PlannedExerciseProgram, PlannedExerciseProgram, QDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }
}

extension PlannedExerciseProgramQueryProperty
    on
        QueryBuilder<
          PlannedExerciseProgram,
          PlannedExerciseProgram,
          QQueryProperty
        > {
  QueryBuilder<PlannedExerciseProgram, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlannedExerciseProgram, bool, QQueryOperations>
  isLocalOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocalOnly');
    });
  }

  QueryBuilder<PlannedExerciseProgram, bool, QQueryOperations>
  pendingDeleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingDelete');
    });
  }

  QueryBuilder<PlannedExerciseProgram, int, QQueryOperations>
  programIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'programId');
    });
  }

  QueryBuilder<PlannedExerciseProgram, bool, QQueryOperations>
  syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlannedExerciseProgramDateCollection on Isar {
  IsarCollection<PlannedExerciseProgramDate> get plannedExerciseProgramDates =>
      this.collection();
}

const PlannedExerciseProgramDateSchema = CollectionSchema(
  name: r'PlannedExerciseProgramDate',
  id: 350456488632151762,
  properties: {
    r'date': PropertySchema(id: 0, name: r'date', type: IsarType.string),
    r'plannedExerciseProgramId': PropertySchema(
      id: 1,
      name: r'plannedExerciseProgramId',
      type: IsarType.long,
    ),
  },

  estimateSize: _plannedExerciseProgramDateEstimateSize,
  serialize: _plannedExerciseProgramDateSerialize,
  deserialize: _plannedExerciseProgramDateDeserialize,
  deserializeProp: _plannedExerciseProgramDateDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'plannedProgram': LinkSchema(
      id: 2034052464277522511,
      name: r'plannedProgram',
      target: r'PlannedExerciseProgram',
      single: true,
    ),
  },
  embeddedSchemas: {},

  getId: _plannedExerciseProgramDateGetId,
  getLinks: _plannedExerciseProgramDateGetLinks,
  attach: _plannedExerciseProgramDateAttach,
  version: '3.3.0',
);

int _plannedExerciseProgramDateEstimateSize(
  PlannedExerciseProgramDate object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.date.length * 3;
  return bytesCount;
}

void _plannedExerciseProgramDateSerialize(
  PlannedExerciseProgramDate object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.date);
  writer.writeLong(offsets[1], object.plannedExerciseProgramId);
}

PlannedExerciseProgramDate _plannedExerciseProgramDateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlannedExerciseProgramDate(
    date: reader.readString(offsets[0]),
    id: id,
    plannedExerciseProgramId: reader.readLong(offsets[1]),
  );
  return object;
}

P _plannedExerciseProgramDateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _plannedExerciseProgramDateGetId(PlannedExerciseProgramDate object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _plannedExerciseProgramDateGetLinks(
  PlannedExerciseProgramDate object,
) {
  return [object.plannedProgram];
}

void _plannedExerciseProgramDateAttach(
  IsarCollection<dynamic> col,
  Id id,
  PlannedExerciseProgramDate object,
) {
  object.id = id;
  object.plannedProgram.attach(
    col,
    col.isar.collection<PlannedExerciseProgram>(),
    r'plannedProgram',
    id,
  );
}

extension PlannedExerciseProgramDateQueryWhereSort
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QWhere
        > {
  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlannedExerciseProgramDateQueryWhere
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QWhereClause
        > {
  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterWhereClause
  >
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

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterWhereClause
  >
  idBetween(
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

extension PlannedExerciseProgramDateQueryFilter
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QFilterCondition
        > {
  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'date',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'date',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'date',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'date',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'date',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: ''),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'date', value: ''),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  plannedExerciseProgramIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'plannedExerciseProgramId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  plannedExerciseProgramIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plannedExerciseProgramId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  plannedExerciseProgramIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plannedExerciseProgramId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  plannedExerciseProgramIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plannedExerciseProgramId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PlannedExerciseProgramDateQueryObject
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QFilterCondition
        > {}

extension PlannedExerciseProgramDateQueryLinks
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QFilterCondition
        > {
  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  plannedProgram(FilterQuery<PlannedExerciseProgram> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'plannedProgram');
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterFilterCondition
  >
  plannedProgramIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'plannedProgram', 0, true, 0, true);
    });
  }
}

extension PlannedExerciseProgramDateQuerySortBy
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QSortBy
        > {
  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  sortByPlannedExerciseProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedExerciseProgramId', Sort.asc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  sortByPlannedExerciseProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedExerciseProgramId', Sort.desc);
    });
  }
}

extension PlannedExerciseProgramDateQuerySortThenBy
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QSortThenBy
        > {
  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  thenByPlannedExerciseProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedExerciseProgramId', Sort.asc);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QAfterSortBy
  >
  thenByPlannedExerciseProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedExerciseProgramId', Sort.desc);
    });
  }
}

extension PlannedExerciseProgramDateQueryWhereDistinct
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QDistinct
        > {
  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QDistinct
  >
  distinctByDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    PlannedExerciseProgramDate,
    PlannedExerciseProgramDate,
    QDistinct
  >
  distinctByPlannedExerciseProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedExerciseProgramId');
    });
  }
}

extension PlannedExerciseProgramDateQueryProperty
    on
        QueryBuilder<
          PlannedExerciseProgramDate,
          PlannedExerciseProgramDate,
          QQueryProperty
        > {
  QueryBuilder<PlannedExerciseProgramDate, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlannedExerciseProgramDate, String, QQueryOperations>
  dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PlannedExerciseProgramDate, int, QQueryOperations>
  plannedExerciseProgramIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedExerciseProgramId');
    });
  }
}
