// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_snippet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplySnippet _$ReplySnippetFromJson(Map<String, dynamic> json) => ReplySnippet(
  messagesId: json['messagesId'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReplySnippetToJson(ReplySnippet instance) =>
    <String, dynamic>{
      'messagesId': instance.messagesId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };
