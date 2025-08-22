// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_cm.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSettingsCMCollection on Isar {
  IsarCollection<UserSettingsCM> get userSettingsCMs => this.collection();
}

const UserSettingsCMSchema = CollectionSchema(
  name: r'UserSettingsCM',
  id: 8635764340789353766,
  properties: {
    r'darkModePreference': PropertySchema(
      id: 0,
      name: r'darkModePreference',
      type: IsarType.byte,
      enumMap: _UserSettingsCMdarkModePreferenceEnumValueMap,
    ),
    r'language': PropertySchema(
      id: 1,
      name: r'language',
      type: IsarType.string,
    ),
    r'passedOnBoarding': PropertySchema(
      id: 2,
      name: r'passedOnBoarding',
      type: IsarType.bool,
    )
  },
  estimateSize: _userSettingsCMEstimateSize,
  serialize: _userSettingsCMSerialize,
  deserialize: _userSettingsCMDeserialize,
  deserializeProp: _userSettingsCMDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userSettingsCMGetId,
  getLinks: _userSettingsCMGetLinks,
  attach: _userSettingsCMAttach,
  version: '3.1.8',
);

int _userSettingsCMEstimateSize(
  UserSettingsCM object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.language;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userSettingsCMSerialize(
  UserSettingsCM object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.darkModePreference.index);
  writer.writeString(offsets[1], object.language);
  writer.writeBool(offsets[2], object.passedOnBoarding);
}

UserSettingsCM _userSettingsCMDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSettingsCM(
    darkModePreference: _UserSettingsCMdarkModePreferenceValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        DarkModePreferenceCM.accordingToSystemPreferences,
    language: reader.readStringOrNull(offsets[1]),
    passedOnBoarding: reader.readBoolOrNull(offsets[2]),
  );
  object.id = id;
  return object;
}

P _userSettingsCMDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_UserSettingsCMdarkModePreferenceValueEnumMap[
              reader.readByteOrNull(offset)] ??
          DarkModePreferenceCM.accordingToSystemPreferences) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _UserSettingsCMdarkModePreferenceEnumValueMap = {
  'alwaysDark': 0,
  'alwaysLight': 1,
  'accordingToSystemPreferences': 2,
};
const _UserSettingsCMdarkModePreferenceValueEnumMap = {
  0: DarkModePreferenceCM.alwaysDark,
  1: DarkModePreferenceCM.alwaysLight,
  2: DarkModePreferenceCM.accordingToSystemPreferences,
};

Id _userSettingsCMGetId(UserSettingsCM object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSettingsCMGetLinks(UserSettingsCM object) {
  return [];
}

void _userSettingsCMAttach(
    IsarCollection<dynamic> col, Id id, UserSettingsCM object) {
  object.id = id;
}

extension UserSettingsCMQueryWhereSort
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QWhere> {
  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSettingsCMQueryWhere
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QWhereClause> {
  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserSettingsCMQueryFilter
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QFilterCondition> {
  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      darkModePreferenceEqualTo(DarkModePreferenceCM value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'darkModePreference',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      darkModePreferenceGreaterThan(
    DarkModePreferenceCM value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'darkModePreference',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      darkModePreferenceLessThan(
    DarkModePreferenceCM value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'darkModePreference',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      darkModePreferenceBetween(
    DarkModePreferenceCM lower,
    DarkModePreferenceCM upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'darkModePreference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      passedOnBoardingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'passedOnBoarding',
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      passedOnBoardingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'passedOnBoarding',
      ));
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterFilterCondition>
      passedOnBoardingEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'passedOnBoarding',
        value: value,
      ));
    });
  }
}

extension UserSettingsCMQueryObject
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QFilterCondition> {}

extension UserSettingsCMQueryLinks
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QFilterCondition> {}

extension UserSettingsCMQuerySortBy
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QSortBy> {
  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      sortByDarkModePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkModePreference', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      sortByDarkModePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkModePreference', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      sortByPassedOnBoarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passedOnBoarding', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      sortByPassedOnBoardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passedOnBoarding', Sort.desc);
    });
  }
}

extension UserSettingsCMQuerySortThenBy
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QSortThenBy> {
  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      thenByDarkModePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkModePreference', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      thenByDarkModePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'darkModePreference', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      thenByPassedOnBoarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passedOnBoarding', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QAfterSortBy>
      thenByPassedOnBoardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passedOnBoarding', Sort.desc);
    });
  }
}

extension UserSettingsCMQueryWhereDistinct
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QDistinct> {
  QueryBuilder<UserSettingsCM, UserSettingsCM, QDistinct>
      distinctByDarkModePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'darkModePreference');
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettingsCM, UserSettingsCM, QDistinct>
      distinctByPassedOnBoarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'passedOnBoarding');
    });
  }
}

extension UserSettingsCMQueryProperty
    on QueryBuilder<UserSettingsCM, UserSettingsCM, QQueryProperty> {
  QueryBuilder<UserSettingsCM, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSettingsCM, DarkModePreferenceCM, QQueryOperations>
      darkModePreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'darkModePreference');
    });
  }

  QueryBuilder<UserSettingsCM, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<UserSettingsCM, bool?, QQueryOperations>
      passedOnBoardingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'passedOnBoarding');
    });
  }
}
