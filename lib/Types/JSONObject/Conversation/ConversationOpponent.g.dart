// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ConversationOpponent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationOpponent _$ConversationOpponentFromJson(
  Map<String, dynamic> json,
) => ConversationOpponent(
  id: json['id'] as String,
  name: json['name'] as String,
  profilePhoto: json['profilePhoto'] == null
      ? null
      : ProfilePhoto.fromJson(json['profilePhoto'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConversationOpponentToJson(
  ConversationOpponent instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'profilePhoto': instance.profilePhoto?.toJson(),
};
