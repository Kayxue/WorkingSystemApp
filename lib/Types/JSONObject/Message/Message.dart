import 'package:json_annotation/json_annotation.dart';

part 'Message.g.dart';

@JsonSerializable()
class Message {
  final String messagesId;
  final String conversationId;
  final String? senderWorkerId;
  final String? senderEmployerId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.messagesId,
    required this.conversationId,
    this.senderWorkerId,
    this.senderEmployerId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
