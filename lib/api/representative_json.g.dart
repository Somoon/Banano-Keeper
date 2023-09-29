// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'representative_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Representative _$RepresentativeFromJson(Map<String, dynamic> json) =>
    Representative(
      json['address'] as String,
      json['alias'] as String?,
      json['daysAge'] as num,
      (json['monitorStats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e),
      ),
      json['online'] as bool,
      json['principal'] as bool,
      json['score'] as num,
      (json['uptimePercentages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as num),
      ),
      json['weight'] as num,
      json['weightPercentage'] as num,
    );

Map<String, dynamic> _$RepresentativeToJson(Representative instance) =>
    <String, dynamic>{
      'address': instance.address,
      'alias': instance.alias,
      'daysAge': instance.daysAge,
      'monitorStats': instance.monitorStats,
      'online': instance.online,
      'principal': instance.principal,
      'score': instance.score,
      'uptimePercentages': instance.uptimePercentages,
      'weight': instance.weight,
      'weightPercentage': instance.weightPercentage,
    };
