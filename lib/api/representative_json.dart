import 'package:json_annotation/json_annotation.dart';

part 'representative_json.g.dart';

@JsonSerializable()
class Representative {
  final String address;
  final String? alias;
  final num daysAge;
  final Map<String, dynamic>? monitorStats;
  final bool online;
  final bool principal;
  final num score;
  final Map<String, num>? uptimePercentages;
  final num weight;
  final num weightPercentage;

  Representative(
    this.address,
    this.alias,
    this.daysAge,
    this.monitorStats,
    this.online,
    this.principal,
    this.score,
    this.uptimePercentages,
    this.weight,
    this.weightPercentage,
  );

  factory Representative.fromJson(Map<String, dynamic> json) =>
      _$RepresentativeFromJson(json);

  Map<String, dynamic> toJson() => _$RepresentativeToJson(this);
}
