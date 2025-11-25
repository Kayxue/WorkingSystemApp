// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPagination _$NotificationPaginationFromJson(
  Map<String, dynamic> json,
) => NotificationPagination(
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  hasMore: json['hasMore'] as bool,
  returned: (json['returned'] as num).toInt(),
);

Map<String, dynamic> _$NotificationPaginationToJson(
  NotificationPagination instance,
) => <String, dynamic>{
  'limit': instance.limit,
  'offset': instance.offset,
  'hasMore': instance.hasMore,
  'returned': instance.returned,
};
