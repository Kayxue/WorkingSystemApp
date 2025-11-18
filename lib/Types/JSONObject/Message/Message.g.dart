// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  messagesId: json['messagesId'] as String,
  conversationId: json['conversationId'] as String,
  senderWorkerId: json['senderWorkerId'] as String?,
  senderEmployerId: json['senderEmployerId'] as String?,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'messagesId': instance.messagesId,
  'conversationId': instance.conversationId,
  'senderWorkerId': instance.senderWorkerId,
  'senderEmployerId': instance.senderEmployerId,
  'content': instance.content,
  'createdAt': instance.createdAt.toIso8601String(),
};
