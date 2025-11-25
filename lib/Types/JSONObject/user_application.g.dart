// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserApplication _$UserApplicationFromJson(Map<String, dynamic> json) =>
    UserApplication(
      applications: (json['applications'] as List<dynamic>)
          .map((e) => Application.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UserApplicationToJson(UserApplication instance) =>
    <String, dynamic>{
      'applications': instance.applications.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };
