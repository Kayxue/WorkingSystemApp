import 'package:json_annotation/json_annotation.dart';

part 'ConversationOpponent.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversationOpponent {
  String? id;
  String name;
  Map<String, dynamic>? profile;

  ConversationOpponent({this.id, required this.name, this.profile});

  factory ConversationOpponent.fromJson(Map<String, dynamic> json) =>
      _$ConversationOpponentFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationOpponentToJson(this);
}
