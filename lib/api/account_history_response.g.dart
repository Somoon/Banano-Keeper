// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistory _$AccountHistoryFromJson(Map<String, dynamic> json) =>
    AccountHistory(
      json['hash'] as String,
      json['address'] as String,
      json['type'] as String,
      json['height'] as int,
      json['timestamp'] as int,
      json['date'] as String,
      json['amountRaw'] as String,
      json['amount'] as num,
      json['newRepresentative'] as String,
    );

Map<String, dynamic> _$AccountHistoryToJson(AccountHistory instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'address': instance.address,
      'type': instance.type,
      'height': instance.height,
      'timestamp': instance.timestamp,
      'date': instance.date,
      'amountRaw': instance.amountRaw,
      'amount': instance.amount,
      'newRepresentative': instance.newRepresentative,
    };
