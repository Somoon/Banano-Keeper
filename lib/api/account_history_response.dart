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

  // AccountHistory.fromJson(Map<String, dynamic> json)
  //     : hash = json['hash'],
  //       address = json['address'],
  //       type = json['type'],
  //       height = json['height'],
  //       timestamp = json['timestamp'],
  //       date = json['date'],
  //       amountRaw = json['amountRaw'],
  //       amount = json['amount'];
  //
  // Map<String, dynamic> toJson() => {};
}
// {
//   hash: 0ACC8F864FD10BE0C257D1946AD7359E00716CEC53E4F608B970D155DB4B3893,
//   address: ban_1jung1eb3uomk1gsx7w6w7toqrikxm5pgn5wbsg5fpy96ckpdf6wmiuuzpca,
//   type: receive,
//   height: 6926,
//   timestamp: 1692327472,
//   date: 8/17/2023 10:57:52 PM,
//   amountRaw: 1006000000000000000000000000000,
//   amount: 10.06
// }
