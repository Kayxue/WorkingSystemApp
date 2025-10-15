// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  limit: (json['limit'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
  returned: (json['returned'] as num).toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'page': instance.page,
      'hasMore': instance.hasMore,
      'returned': instance.returned,
    };
