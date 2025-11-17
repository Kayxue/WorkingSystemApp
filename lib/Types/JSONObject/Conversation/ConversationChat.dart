import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Conversation/ConversationOpponent.dart';

part 'ConversationChat.g.dart';

@JsonSerializable(explicitToJson: true)
class ConversationChat {
  String conversationId;
  String workerId;
  String employerId;
  DateTime lastMessageAt;
  DateTime createdAt;
  DateTime? lastReadAtByWorker;
  DateTime? lastReadAtByEmployer;
  ConversationOpponent opponent;
  int unreadCount;
  String? lastMessage;

  ConversationChat({
    required this.conversationId,
    required this.workerId,
    required this.employerId,
    required this.lastMessageAt,
    required this.createdAt,
    this.lastReadAtByWorker,
    this.lastReadAtByEmployer,
    required this.opponent,
    required this.unreadCount,
    this.lastMessage,
  });

  factory ConversationChat.fromJson(Map<String, dynamic> json) =>
      _$ConversationChatFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationChatToJson(this);
}