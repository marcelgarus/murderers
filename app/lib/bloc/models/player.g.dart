// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      state: _$enumDecodeNullable(_$PlayerStateEnumMap, json['state']),
      death: json['death'] == null
          ? null
          : Death.fromJson(json['death'] as Map<String, dynamic>),
      kills: json['kills'] as int,
      rank: json['rank'] as int);
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'state': _$PlayerStateEnumMap[instance.state],
      'kills': instance.kills,
      'rank': instance.rank,
      'death': instance.death
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$PlayerStateEnumMap = <PlayerState, dynamic>{
  PlayerState.joining: 'joining',
  PlayerState.alive: 'alive',
  PlayerState.dying: 'dying',
  PlayerState.dead: 'dead'
};
