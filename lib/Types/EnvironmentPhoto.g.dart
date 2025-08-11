// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EnvironmentPhoto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Environmentphoto _$EnvironmentphotoFromJson(Map<String, dynamic> json) =>
    Environmentphoto(
      url: json['url'] as String,
      originalName: json['originalName'] as String,
      type: json['type'] as String,
      filename: json['filename'] as String,
    );

Map<String, dynamic> _$EnvironmentphotoToJson(Environmentphoto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'originalName': instance.originalName,
      'type': instance.type,
      'filename': instance.filename,
    };
