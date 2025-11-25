import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Conversation/conversation_chat.dart';
import 'package:working_system_app/Types/JSONObject/pagination.dart';

part 'conversation_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversationResponse {
  List<ConversationChat> conversations;
  Pagination pagination;

  ConversationResponse({required this.conversations, required this.pagination});

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}
