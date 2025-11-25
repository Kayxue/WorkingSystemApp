import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Message/message.dart';

part 'messages_response.g.dart';

@JsonSerializable()
class MessagesResponse {
  final List<Message> messages;

  MessagesResponse({required this.messages});

  factory MessagesResponse.fromJson(Map<String, dynamic> json) => _$MessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesResponseToJson(this);
}
