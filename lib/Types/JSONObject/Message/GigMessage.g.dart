// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GigMessage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GigMessage _$GigMessageFromJson(Map<String, dynamic> json) => GigMessage(
  message: Message.fromJson(json['message'] as Map<String, dynamic>),
  gig: GigReturnForMessage.fromJson(json['gig'] as Map<String, dynamic>),
  employerName: json['employerName'] as String,
);

Map<String, dynamic> _$GigMessageToJson(GigMessage instance) =>
    <String, dynamic>{
      'message': instance.message.toJson(),
      'gig': instance.gig.toJson(),
      'employerName': instance.employerName,
    };
