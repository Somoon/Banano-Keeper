// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StateBlock _$StateBlockFromJson(Map<String, dynamic> json) => StateBlock(
      json['account'] as String,
      json['previous'] as String,
      json['representative'] as String,
      json['balance'] as String,
      json['link'] as String,
      json['signature'] as String,
    )..type = json['type'] as String;

Map<String, dynamic> _$StateBlockToJson(StateBlock instance) =>
    <String, dynamic>{
      'type': instance.type,
      'account': instance.account,
      'previous': instance.previous,
      'representative': instance.representative,
      'balance': instance.balance,
      'link': instance.link,
      'signature': instance.signature,
    };
