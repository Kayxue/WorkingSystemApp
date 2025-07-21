// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GigPagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gigpagination _$GigpaginationFromJson(Map<String, dynamic> json) =>
    Gigpagination(
      limit: (json['limit'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
      returned: (json['returned'] as num).toInt(),
    );

Map<String, dynamic> _$GigpaginationToJson(Gigpagination instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'page': instance.page,
      'hasMore': instance.hasMore,
      'returned': instance.returned,
    };
