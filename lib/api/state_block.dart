import 'package:json_annotation/json_annotation.dart';

part 'state_block.g.dart';

@JsonSerializable()
class StateBlock {
  String type = 'state';
  final String account;
  final String previous;
  final String representative;
  final String balance;
  final String link;
  String signature;

  StateBlock(
    this.account,
    this.previous,
    this.representative,
    this.balance,
    this.link,
    this.signature,
  );

  factory StateBlock.fromJson(Map<String, dynamic> json) =>
      _$StateBlockFromJson(json);

  Map<String, dynamic> toJson() => _$StateBlockToJson(this);
}
