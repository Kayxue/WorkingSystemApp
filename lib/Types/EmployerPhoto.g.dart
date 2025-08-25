// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EmployerPhoto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployerPhoto _$EmployerPhotoFromJson(Map<String, dynamic> json) =>
    EmployerPhoto(
      url: json['url'] as String,
      originalName: json['originalName'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$EmployerPhotoToJson(EmployerPhoto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'originalName': instance.originalName,
      'type': instance.type,
    };
