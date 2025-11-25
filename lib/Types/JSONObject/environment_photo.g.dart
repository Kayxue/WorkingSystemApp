// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvironmentPhoto _$EnvironmentPhotoFromJson(Map<String, dynamic> json) =>
    EnvironmentPhoto(
      url: json['url'] as String,
      originalName: json['originalName'] as String,
      type: json['type'] as String,
      filename: json['filename'] as String,
    );

Map<String, dynamic> _$EnvironmentPhotoToJson(EnvironmentPhoto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'originalName': instance.originalName,
      'type': instance.type,
      'filename': instance.filename,
    };
