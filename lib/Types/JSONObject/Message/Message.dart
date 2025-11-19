import 'package:json_annotation/json_annotation.dart';
import 'package:working_system_app/Types/JSONObject/Message/ReplySnippet.dart';
import 'package:working_system_app/Types/JSONObject/Message/GigReturnForMessage.dart';

part 'Message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  final String messagesId;
  final String conversationId;
  final String? senderWorkerId;
  final String? senderEmployerId;
  final String content;
  final DateTime createdAt;
  final String? replyToId;
  final ReplySnippet? replySnippet;
  final GigReturnForMessage? gig;

  Message({
    required this.messagesId,
    required this.conversationId,
    this.senderWorkerId,
    this.senderEmployerId,
    required this.content,
    required this.createdAt,
    this.replyToId,
    this.replySnippet,
    this.gig,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
