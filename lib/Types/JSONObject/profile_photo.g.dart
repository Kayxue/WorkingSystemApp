// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfilePhoto _$ProfilePhotoFromJson(Map<String, dynamic> json) => ProfilePhoto(
  url: json['url'] as String,
  originalName: json['originalName'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$ProfilePhotoToJson(ProfilePhoto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'originalName': instance.originalName,
      'type': instance.type,
    };
