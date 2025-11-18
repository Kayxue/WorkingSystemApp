import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/ProfilePhoto.dart';

part 'ConversationOpponent.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversationOpponent {
  String id;
  String name;
  ProfilePhoto? profilePhoto;

  ConversationOpponent({
    required this.id,
    required this.name,
    this.profilePhoto,
  });

  factory ConversationOpponent.fromJson(Map<String, dynamic> json) =>
      _$ConversationOpponentFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationOpponentToJson(this);
}
