// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ConversationChat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationChat _$ConversationChatFromJson(Map<String, dynamic> json) =>
    ConversationChat(
      conversationId: json['conversationId'] as String,
      workerId: json['workerId'] as String,
      employerId: json['employerId'] as String,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastReadAtByWorker: json['lastReadAtByWorker'] == null
          ? null
          : DateTime.parse(json['lastReadAtByWorker'] as String),
      lastReadAtByEmployer: json['lastReadAtByEmployer'] == null
          ? null
          : DateTime.parse(json['lastReadAtByEmployer'] as String),
      opponent: ConversationOpponent.fromJson(
        json['opponent'] as Map<String, dynamic>,
      ),
      unreadCount: (json['unreadCount'] as num).toInt(),
      lastMessage: json['lastMessage'] as String?,
    );

Map<String, dynamic> _$ConversationChatToJson(ConversationChat instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'workerId': instance.workerId,
      'employerId': instance.employerId,
      'lastMessageAt': instance.lastMessageAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'lastReadAtByWorker': instance.lastReadAtByWorker?.toIso8601String(),
      'lastReadAtByEmployer': instance.lastReadAtByEmployer?.toIso8601String(),
      'opponent': instance.opponent.toJson(),
      'unreadCount': instance.unreadCount,
      'lastMessage': instance.lastMessage,
    };
