// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApplicationPagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationPagination _$ApplicationPaginationFromJson(
  Map<String, dynamic> json,
) => ApplicationPagination(
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
  returned: (json['returned'] as num).toInt(),
);

Map<String, dynamic> _$ApplicationPaginationToJson(
  ApplicationPagination instance,
) => <String, dynamic>{
  'limit': instance.limit,
  'offset': instance.offset,
  'hasMore': instance.hasMore,
  'returned': instance.returned,
};
