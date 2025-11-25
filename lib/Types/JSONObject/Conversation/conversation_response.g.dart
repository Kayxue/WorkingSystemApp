// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationResponse _$ConversationResponseFromJson(
  Map<String, dynamic> json,
) => ConversationResponse(
  conversations: (json['conversations'] as List<dynamic>)
      .map((e) => ConversationChat.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConversationResponseToJson(
  ConversationResponse instance,
) => <String, dynamic>{
  'conversations': instance.conversations.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
};
