// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requirements _$RequirementsFromJson(Map<String, dynamic> json) => Requirements(
  skills: (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
  experience: json['experience'] as String,
);

Map<String, dynamic> _$RequirementsToJson(Requirements instance) =>
    <String, dynamic>{
      'skills': instance.skills,
      'experience': instance.experience,
    };
