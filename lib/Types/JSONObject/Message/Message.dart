import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Message/ReplySnippet.dart';

part 'Message.g.dart';

@JsonSerializable()
class Message {
  final String messagesId;
  final String conversationId;
  final String? senderWorkerId;
  final String? senderEmployerId;
  final String content;
  final DateTime createdAt;
  final String? replyToId;
  final ReplySnippet? replySnippet;

  Message({
    required this.messagesId,
    required this.conversationId,
    this.senderWorkerId,
    this.senderEmployerId,
    required this.content,
    required this.createdAt,
    this.replyToId,
    this.replySnippet,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
