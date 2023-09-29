import 'package:json_annotation/json_annotation.dart';

part 'account_history_response.g.dart';

@JsonSerializable()
class AccountHistory {
  final String hash;
  final String address;
  final String type;
  final int height;
  final int timestamp;
  final String date;
  final String amountRaw; //BigInt
  final num amount;
  final String newRepresentative;

  AccountHistory(
      this.hash,
      this.address,
      this.type,
      this.height,
      this.timestamp,
      this.date,
      this.amountRaw,
      this.amount,
      this.newRepresentative);

  factory AccountHistory.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$AccountHistoryToJson(this);
}
